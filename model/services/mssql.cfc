component accessors="true" output="false" {

	property SQLService;

	public component function init() {
		return this;
	}

	public string function createSQL( required struct beanmap ) {
		var sql = "";
		var pkproperty = arguments.beanmap.properties[ arguments.beanmap.primarykey ];
		var primarykeyfield = getPrimaryKeyField( beanmap=arguments.beanmap );
		var tablename = getTableName( beanmap=arguments.beanmap );

		if ( pkproperty.isidentity ) {
			sql &= "DECLARE @ident TABLE (newid int) ";
		} else {
			sql &= "DECLARE @identid int = (SELECT MAX(" & tablename & "." & primarykeyfield & ") FROM " & tablename & ") ";
			sql &= "SET @identid = @identid + 1; ";
		}

		sql &= "INSERT INTO " & getTableName( beanmap=arguments.beanmap ) & " (";

		if ( !pkproperty.isidentity ) {
			sql &= tablename & "." & primarykeyfield & ", ";
		}

		sql &= getFields( type="insert", beanmap=arguments.beanmap );

		if ( pkproperty.isidentity ) {
			sql &= ") OUTPUT inserted." & primarykeyfield & " into @ident VALUES (:";
		} else {
			sql &= ") VALUES (@identid, :";
		}

		sql &= getFields( type="values", beanmap=arguments.beanmap );

		if ( pkproperty.isidentity ) {
			sql &= ") SELECT newid FROM @ident";
		} else {
			sql &= ") SELECT @identid AS newid";
		}

		return sql;
	}

	public string function deleteSQL( required struct beanmap ) {
		var sql = "DELETE FROM " & getTableName( beanmap=arguments.beanmap );
		sql &= " WHERE " & getPrimaryKeyField( beanmap=arguments.beanmap );
		sql &= " = :" & arguments.beanmap.primarykey;
		return sql;
	}

	public string function deleteByNotInSQL( required struct beanmap, required struct pkproperty ) {
		var sql = "DELETE FROM " & getTableName( beanmap=arguments.beanmap );
		sql &= " WHERE " & getPropertyField( prop=arguments.pkproperty ) & " NOT IN (:" & arguments.pkproperty.name & ")";
		return sql;
	}

	public string function readSQL(
		required struct beanmap,
		required struct sqlparams={},
		required string orderby="",
		boolean pkOnly=false
	) {
		var tablename = getTableName( beanmap=arguments.beanmap );

		var sql = "SELECT ";
		sql &= getFields( type="select", beanmap=arguments.beanmap, pkOnly=arguments.pkOnly );
		sql &= " FROM " & tablename;

		if ( structCount(arguments.sqlparams) ) {
			sql &= getWhereStatement( beanmap=arguments.beanmap, sqlparams=arguments.sqlparams, tablename=tablename );
		}

		sql &= " ORDER BY " & getFullOrderBy( beanmap=arguments.beanmap, orderby=arguments.orderby );

		return sql;
	}

	public string function readByJoinSQL( required struct beanmap, required struct relationship ) {
		var tablename = getTableName( beanmap=arguments.beanmap );
		var primarykey = getPrimaryKeyField( beanmap=arguments.beanmap );

		var joinpath = ( len(arguments.relationship.joinSchema) ? "[" & arguments.relationship.joinSchema & "]." : "" );
		joinpath &= "[" & arguments.relationship.joinTable & "]";

		var sql = "SELECT ";
		sql &= getFields( type="select", beanmap=arguments.beanmap );
		sql &= " FROM " & tablename;

		sql &= " JOIN " & joinpath;
		sql &= " ON " & joinpath & ".[" & arguments.relationship.joinColumn & "] = " & tablename & "." & primarykey;

		sql &= " WHERE " & joinpath & ".[" & arguments.relationship.fkColumn & "] = :" & arguments.relationship.fkColumn;

		sql &= " ORDER BY " & getFullOrderBy( beanmap=arguments.beanmap );

		return sql;
	}

	public string function updateSQL( required struct beanmap ) {
		var tablename = getTableName( beanmap=arguments.beanmap );

		var sql = "UPDATE " & tablename & " SET ";
		sql &= getFields( type="update", beanmap=arguments.beanmap );
		sql &= " WHERE " & tablename & "." & getPrimaryKeyField( beanmap=arguments.beanmap ) & " = :" & arguments.beanmap.primarykey;

		return sql;
	}

	private string function getFieldByType(
		required string type,
		required struct prop,
		required string propname,
		required string columnname,
		required string tablename
	) {
		var field = "";

		switch ( arguments.type ) {

			case "insert":
				field &= arguments.columnname;
				break;

			case "values":
				field &= ":" & arguments.propname;
				break;

			case "update":
				field &= arguments.columnname & " = :" & arguments.propname;
				break;

			default:
				if ( len(arguments.prop.columnName) || ( arguments.prop.sqltype == "cf_sql_integer" && arguments.prop.null ) ) {
					field &= getSelectAsField(
						columnname=columnname,
						sqltype=arguments.prop.sqltype,
						isNull=arguments.prop.null,
						tablename=arguments.tablename
					);
					field &= "[" & arguments.propname & "]";
				}
				else {
					field &= columnname;
				}
		}

		return field;
	}

	/*
	* @type possible values: insert, update, select, values
	*/
	private string function getFields( required string type, required struct beanmap, boolean pkOnly=false ) {
		var includepk = ( arguments.type == "select" ? true : false );
		var tablename = getTableName( beanmap=arguments.beanmap );
		arguments.pkOnly = ( arguments.type == "select" ? arguments.pkOnly : false );

		var fields = "";
		for ( var propname in arguments.beanmap.properties ) {
			var prop = arguments.beanmap.properties[ propname ];

			var isIncluded = variables.SQLService.isPropertyIncluded(
				prop=prop,
				primarykey=arguments.beanmap.primarykey,
				includepk=includepk,
				type=arguments.type,
				pkOnly=arguments.pkOnly
			);

			if ( isIncluded ) {
				var columnname = tablename & "." & getPropertyField( prop=prop );

				if ( len(fields) ) {
					fields &= ", ";
				}
				fields &= getFieldByType( type=arguments.type, prop=prop, propname=propname, columnname=columnname, tablename=tablename );
			}
		}

		return fields;
	}

	private string function getFullOrderBy( required struct beanmap, string orderby="" ) {
		arguments.orderby = ( len(arguments.orderby) ? arguments.orderby : arguments.beanmap.orderby );

		var fullorderby = "";
		var orderprops = listToArray(arguments.orderby);

		for ( var orderprop in orderprops ) {
			orderprop = trim(orderprop);
			var orderinfo = getOrderInfo( orderby=orderprop );

			var prop = structKeyExists(arguments.beanmap.properties,orderinfo.propname) ? arguments.beanmap.properties[orderinfo.propname] : {};
			if ( structIsEmpty(prop) ) {
				prop = getPropertyByColumnName( beanmap=arguments.beanmap, columnname=orderinfo.propname );
			}

			if ( structCount(prop) ) {
				fullorderby &= ( len(fullorderby) ? ", " : "" ) & getPropertyField( prop=prop ) & " " & orderinfo.direction;
			}
		}

		if ( !len(fullorderby) ) {
			fullorderby = getPrimaryKeyField( beanmap=arguments.beanmap ) & " ASC";
		}

		return fullorderby;
	}

	private struct function getOrderInfo( required string orderby ) {
		var result = {
			propname = arguments.orderby,
			direction = "ASC"
		};

		var order = listToArray(arguments.orderby, " ");
		if ( arrayLen(order) > 1 ) {
			result.propname = trim(order[1]);
			if ( order[2] == "desc" ) {
				result.direction = "DESC";
			}
		}

		return result;
	}

	private string function getPrimaryKeyField( required struct beanmap ) {
		var pkproperty = arguments.beanmap.properties[ arguments.beanmap.primarykey ];
		return getPropertyField( prop=pkproperty );
	}

	private struct function getPropertyByColumnName( required struct beanmap, required string columnname ){
		var prop = {};

		for ( var propname in arguments.beanmap.properties ) {
			if ( arguments.beanmap.properties[propname].columnname == arguments.columnname ) {
				prop = arguments.beanmap.properties[propname];
				break;
			}
		}

		return prop;
	}

	private string function getPropertyField( required struct prop ){
		return "[" & ( len(arguments.prop.columnname) ? arguments.prop.columnname : arguments.prop.name ) & "]";
	}

	private string function getSelectAsField( required string columnname, required string sqltype, required boolean isNull ) {
		var fieldresult = "";

		if ( arguments.sqltype == "cf_sql_integer" && arguments.isNull ) {
			fieldresult &= "ISNULL(";
		}

		fieldresult &= arguments.columnname;

		if ( arguments.sqltype == "cf_sql_integer" && arguments.isNull ) {
			fieldresult &= ",0)";
		}

		fieldresult &= " AS ";

		return fieldresult;
	}

	private string function getTableName( required struct beanmap ) {
		return "[" & ( len(arguments.beanmap.schema) ? arguments.beanmap.schema : "dbo" ) & "].[" & arguments.beanmap.table & "]";
	}

	private string function getWhereStatement( required struct beanmap, required struct sqlparams, required string tablename ) {
		var where = "";
		for ( var field in arguments.sqlparams ) {
			if ( structKeyExists(arguments.beanmap.properties,field) ) {
				var prop = arguments.beanmap.properties[field];
				where &= ( len(where) ? " AND " : " WHERE " ) & arguments.tablename;
				where &= "." & getPropertyField( prop=prop ) & " = :" & field;
			} else {
				throw(message="The property '#lCase(field)#' was not found in the '#arguments.beanmap.bean#' bean definition");
			}
		}
		return where;
	}

}

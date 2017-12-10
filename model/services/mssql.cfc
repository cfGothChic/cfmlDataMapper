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
			sql &= "DECLARE @ident Table (newid int) ";
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

	public string function deleteByNotInSQL( required string beanmap, required struct pkproperty, required string key ) {
		var sql = "DELETE FROM " & getTableName( beanmap=arguments.beanmap );
		sql &= " WHERE " & ( len(arguments.pkproperty.columnName) ? arguments.pkproperty.columnName : arguments.key );
		sql &= " NOT IN (:" & arguments.key & ")";
		return sql;
	}

	public string function readSQL(
		required struct beanmap,
		required struct params={},
		required string orderby="",
		boolean pkOnly=false
	) {
		var tablename = getTableName( beanmap=arguments.beanmap );

		var sql = "SELECT ";
		sql &= getFields( type="select", beanmap=arguments.beanmap, pkOnly=arguments.pkOnly );
		sql &= " FROM " & tablename;

		if ( !structIsEmpty(arguments.params) ) {
			var where = "";
			for ( var field in arguments.params ) {
				if ( structKeyExists(arguments.beanmap.properties,field) ) {
					where &= ( len(where) ? " AND " : " WHERE " ) & tablename;

					where &= ".[" & (
						(
							structKeyExists(arguments.beanmap.properties[ field ],"columnName")
							&& len(arguments.beanmap.properties[ field ].columnName)
						)
						? arguments.beanmap.properties[ field ].columnName
						: field
					);

					where &= "] = :" & field;
				} else {
					throw(message="The property '#field#' was not found in the '#arguments.bean#' bean definition");
				}
			}
			sql &= where;
		}

		if ( len(arguments.orderby) || len(arguments.beanmap.orderby) ) {
			sql &= " ORDER BY " & getFullOrderBy( beanmap=arguments.beanmap, orderby=arguments.orderby );
		}

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

		if ( len(arguments.beanmap.orderby) ) {
			sql &= " ORDER BY " & arguments.beanmap.orderby;
		}

		return sql;
	}

	public string function updateSQL( required struct beanmap ) {
		var tablename = getTableName( beanmap=arguments.beanmap );

		var sql = "UPDATE " & tablename & " SET ";
		sql &= getFields( type="update", beanmap=arguments.beanmap );
		sql &= " WHERE " & tablename & "." & getPrimaryKeyField( beanmap=arguments.beanmap ) & " = :" & arguments.beanmap.primarykey;

		return sql;
	}

	/*
	* @type possible values: insert, update, select, values
	*/
	private string function getFields( required string type, required struct beanmap, boolean pkOnly=false ) {
		var delimiter = ( arguments.type == "values" ? ", :" : ", " );
		var includepk = ( arguments.type == "select" ? true : false );
		var tablename = getTableName( beanmap=arguments.beanmap );
		arguments.pkOnly = ( arguments.type == "select" ? arguments.pkOnly : false );

		var fields = "";
		for ( var prop IN arguments.beanmap.properties ) {
			var isIncluded = variables.SQLService.isPropertyIncluded( prop=prop, beanmap=arguments.beanmap, includepk=includepk, type=arguments.type, pkOnly=arguments.pkOnly);

			if ( isIncluded ) {
				var columnname = tablename & ".[" & ( len( arguments.beanmap.properties[ prop ].columnName ) ? arguments.beanmap.properties[ prop ].columnName : prop ) & "]";
				if ( len(fields) ) {
					fields &= delimiter;
				}

				if ( arguments.type == "insert" ) {
					fields &= columnname;
				} else if ( arguments.type == "values" ) {
					fields &= prop;
				} else if ( arguments.type == "update" ) {
					fields &= columnname & " = :" & prop;
				} else {
					if ( len( arguments.beanmap.properties[ prop ].columnName ) ) {
						fields &= getSelectField(
							columnname=columnname,
							sqltype=arguments.beanmap.properties[ prop ].sqltype,
							isNull=arguments.beanmap.properties[ prop ].null,
							tablename=tablename
						);
						fields &= "[" & prop & "]";
					} else {
						fields &= columnname;
					}
				}
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

			var propname = orderprop;
			var direction = "ASC";
			if ( listLen(orderprop," ") > 1 ) {
				propname = ListFirst(orderprop," ");
				direction = ListLast(orderprop," ");
				direction =  arrayFindNoCase(["asc","desc"],direction) ? direction : "ASC";
			}

			var prop = structKeyExists(arguments.beanmap.properties,propname) ? arguments.beanmap.properties[propname] : {};

			if ( structIsEmpty(prop) ) {
				for ( var propname in arguments.beanmap.properties ) {
					if ( arguments.beanmap.properties[propname].columnname == propname ) {
						prop = arguments.beanmap.properties[propname];
						break;
					}
				}
			}

			if ( !structIsEmpty(prop) ) {
				fullorderby &= ( len(fullorderby) ? ", " : "" ) & ( len(prop.columnname) ? prop.columnname : prop.name ) & " " & direction;
			}
		}

		return fullorderby;
	}

	private string function getPrimaryKeyField( required struct beanmap ) {
		var pkproperty = arguments.beanmap.properties[ arguments.beanmap.primarykey ];
		return "[" & ( len(pkproperty.columnName) ? pkproperty.columnName : arguments.beanmap.primarykey ) & "]";
	}

	private string function getSelectField( required string columnname, required string sqltype, required boolean isNull ) {
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
		return ( len(arguments.beanmap.schema) ? "[" & arguments.beanmap.schema & "]." : "" ) & "[" & arguments.beanmap.table & "]";
	}

}

component accessors="true" output="false" {

	property dataGateway;
	property dataFactory;

	public component function init() {
		return this;
	}

	public numeric function create( required string beanname, required component bean ) {
		var beanmap = variables.dataFactory.getBeanMap( bean=arguments.beanname );
		var sql = createString( beanmap=beanmap );
		var params = getParams( bean=arguments.bean, beanmap=beanmap, includepk=0 );
		var newid = variables.dataGateway.create( sql=sql, params=params );
		return newid;
	}

	public void function delete( required string bean, required numeric id ) {
		var beanmap = variables.dataFactory.getBeanMap( bean=arguments.bean );
		var sql = deleteString( beanmap=beanmap );
		variables.dataGateway.delete( sql=sql, primarykey=beanmap.primarykey, id=arguments.id );
	}

	public void function deleteByNotIn( required string bean, required string key, required string list ) {
		var beanmap = variables.dataFactory.getBeanMap( bean=arguments.bean );
		var pkproperty = beanmap.properties[ arguments.key ];
		var sql = deleteByNotInString( beanmap=beanmap, pkproperty=pkproperty, key=arguments.key );
		variables.dataGateway.deleteByNotIn( sql=sql, key=arguments.key, list=arguments.list, sqltype=pkproperty.sqltype );
	}

	public query function read(
		required string bean,
		struct params={},
		string orderby="",
		boolean pkOnly=false
	) {
		var beanmap = variables.dataFactory.getBeanMap( bean=arguments.bean );

		var sql = readString(
			beanmap=beanmap,
			params=arguments.params,
			orderby=arguments.orderby,
			pkOnly=arguments.pkOnly
		);

		var qRecords = variables.dataGateway.read( sql=sql, params=params, beanmap=beanmap );
		return qRecords;
	}

	public query function readByJoin( required numeric beanid, required struct relationship ) {
		var beanmap = variables.dataFactory.getBeanMap( bean=arguments.relationship.bean );

		if (
			!len(arguments.relationship.fkColumn)
			|| !len(arguments.relationship.fksqltype)
			|| !len(arguments.relationship.joinColumn)
			|| !len(arguments.relationship.joinTable)
		) {
			throw(beanmap.bean & " bean is missing required bean map variables for the " & arguments.relationship.name & " relationship join table: fkColumn, fksqltype, joinColumn, joinTable");
		}

		var sql = readByJoinString( beanmap=beanmap, relationship=arguments.relationship );

		var qRecords = variables.dataGateway.readByJoin(
			sql=sql,
			beanid=arguments.beanid,
			fkColumn=arguments.relationship.fkColumn,
			fksqltype=arguments.relationship.fksqltype
		);

		return qRecords;
	}

	public void function update( required string beanname, required component bean ) {
		var beanmap = variables.dataFactory.getBeanMap( arguments.beanname );
		var sql = updateString( beanmap=beanmap );
		var params = getParams( bean=arguments.bean, beanmap=beanmap );
		variables.dataGateway.update( sql=sql, params=params );
	}

	private string function createString( required struct beanmap ) {
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

	private string function deleteString( required struct beanmap ) {
		var sql = "DELETE FROM " & getTableName( beanmap=arguments.beanmap );
		sql &= " WHERE " & getPrimaryKeyField( beanmap=arguments.beanmap );
		sql &= " = :" & arguments.beanmap.primarykey;
		return sql;
	}

	private string function deleteByNotInString( required string beanmap, required struct pkproperty, required string key ) {
		var sql = "DELETE FROM " & getTableName( beanmap=arguments.beanmap );
		sql &= " WHERE " & ( len(arguments.pkproperty.columnName) ? arguments.pkproperty.columnName : arguments.key );
		sql &= " NOT IN (:" & arguments.key & ")";
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
			var isIncluded = isPropertyIncluded( prop=prop, beanmap=arguments.beanmap, includepk=includepk, type=arguments.type, pkOnly=arguments.pkOnly);

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

	private struct function getParams( required component bean, required struct beanmap, boolean includepk=true ) {
		var params = {};

		for ( var prop in arguments.beanmap.properties ) {
			var isIncluded = isPropertyIncluded( prop=prop, beanmap=arguments.beanmap, includepk=includepk );

			if ( isIncluded ) {
				var valuestring = arguments.bean.getPropertyValue( propertyname=prop );
				params[ prop ] = { value=valuestring, cfsqltype=arguments.beanmap.properties[ prop ].sqltype };
				if (
					arguments.beanmap.properties[ prop ].null
					&& (
						!len(valuestring)
						|| findNoCase("integer",arguments.beanmap.properties[ prop ].sqltype)
						&& isNumeric(valuestring) && !valuestring
					)
				) {
					params[ prop ].value = "";
					params[ prop ].null = true;
				} else {
					params[ prop ].null = false;
				}
			}
		}
		return params;
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

	private string function readByJoinString( required struct beanmap, required struct relationship ) {
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

	private string function readString(
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

	private boolean function isPropertyIncluded(
		required string prop,
		required struct beanmap,
		required boolean includepk,
		string type="update",
		boolean pkOnly=false
	) {
		if ( arguments.type == "select" ) {
			return (
				!arguments.pkOnly
				|| arguments.prop == arguments.beanmap.primarykey
			);
		} else {
			return (
				arguments.beanmap.properties[ arguments.prop ].insert
				&& (
					arguments.includepk
					|| arguments.prop != arguments.beanmap.primarykey
				)
			);
		}
	}

	private string function updateString( required struct beanmap ) {
		var tablename = getTableName( beanmap=arguments.beanmap );

		var sql = "UPDATE " & tablename & " SET ";
		sql &= getFields( type="update", beanmap=arguments.beanmap );
		sql &= " WHERE " & tablename & "." & getPrimaryKeyField( beanmap=arguments.beanmap ) & " = :" & arguments.beanmap.primarykey;

		return sql;
	}

}

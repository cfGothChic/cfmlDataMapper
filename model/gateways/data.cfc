component accessors=true {

	property dataFactory;
	property storedprocTag;

	public function init( dsn ) {
		variables.dsn = arguments.dsn;
		return this;
	}

	public numeric function create( string beanname, bean ) {
		var querycfc = new query( datasource=variables.dsn );
		var beanmap = variables.dataFactory.getBeanMap(arguments.beanname);
		var pkproperty = beanmap.properties[ beanmap.primarykey ];
		var sql = "";
		var primarykeyfield = getPrimaryKeyField(beanmap);
		var tablename = getTableName(beanmap);

		if ( pkproperty.isidentity ) {
			sql &= "DECLARE @ident Table (newid int) ";
		} else {
			sql &= "DECLARE @identid int = (SELECT MAX(" & tablename & "." & primarykeyfield & ") FROM " & tablename & ") ";
			sql &= "SET @identid = @identid + 1; ";
		}

		sql &= "INSERT INTO " & getTableName(beanmap) & " (";

		if ( !pkproperty.isidentity ) {
			sql &= tablename & "." & primarykeyfield & ", ";
		}

		sql &= getFields("insert", beanmap);

		if ( pkproperty.isidentity ) {
			sql &= ") OUTPUT inserted." & primarykeyfield & " into @ident VALUES (:";
		} else {
			sql &= ") VALUES (@identid, :";
		}

		sql &= getFields("values", beanmap);

		if ( pkproperty.isidentity ) {
			sql &= ") SELECT newid FROM @ident";
		} else {
			sql &= ") SELECT @identid AS newid";
		}

		var params = getParams( arguments.bean, beanmap, 0);
		for ( var field IN params ) {
			querycfc.addParam(name=field, value=params[ field ].value, null=params[ field ].null, cfsqltype=params[ field ].cfsqltype);
		}

		querycfc.setSql(sql);
		var qRecord = querycfc.execute().getResult();
		return qRecord.newid;
	}

	public void function delete( string bean, numeric id ) {
		var beanmap = variables.dataFactory.getBeanMap(arguments.bean);
		var sql = "DELETE FROM " & getTableName(beanmap) & " WHERE " & getPrimaryKeyField(beanmap) & " = :" & beanmap.primarykey;
		var querycfc = new query( datasource=variables.dsn, sql=sql );
		querycfc.addParam(name=beanmap.primarykey, value=arguments.id, cfsqltype="cf_sql_integer");
		querycfc.execute();
	}

	public void function deleteByValueList( string bean, string key, string list ) {
		var beanmap = variables.dataFactory.getBeanMap(arguments.bean);
		var pkproperty = beanmap.properties[ arguments.key ];
		var sql = "DELETE FROM " & getTableName(beanmap) & " WHERE " & ( len(pkproperty.columnName) ? pkproperty.columnName : arguments.key ) & " NOT IN (:" & arguments.key & ")";

		var querycfc = new query( sql=sql, datasource=variables.dsn );
		querycfc.addParam(name=arguments.key, value=arguments.list, cfsqltype=pkproperty.sqltype, list=true);
		querycfc.execute().getResult();
	}

	public query function read( string bean, struct params={}, string orderby="", boolean pkOnly=false ) {
		var querycfc = new query( datasource=variables.dsn );
		var beanmap = variables.dataFactory.getBeanMap(arguments.bean);
		var tablename = getTableName(beanmap);

		var sql = "SELECT ";
		sql &= getFields("select", beanmap, arguments.pkOnly);
		sql &= " FROM " & tablename;

		if ( !structIsEmpty(arguments.params) ) {
			var where = "";
			for ( var field IN arguments.params ) {
				if ( structKeyExists(beanmap.properties,field) ) {
					where &= ( len(where) ? " AND " : " WHERE " ) & tablename;
					where &= ".[" & ( structKeyExists(beanmap.properties[ field ],"columnName") && len(beanmap.properties[ field ].columnName) ? beanmap.properties[ field ].columnName : field ) & "] = :" & field;
					querycfc.addParam(name=field, value=arguments.params[ field ], cfsqltype=beanmap.properties[ field ].sqltype);
				} else {
					throw(message="The property '#field#' was not found in the '#arguments.bean#' bean definition");
				}
			}
			sql &= where;
		}

		if ( len(arguments.orderby) || len(beanmap.orderby) ) {
			sql &= " ORDER BY " & ( len(arguments.orderby) ? arguments.orderby : beanmap.orderby );
		}

		querycfc.setSql(sql);
		return querycfc.execute().getResult();
	}

	public query function readByJoinTable( numeric beanid, struct relationship ) {
		var querycfc = new query( datasource=variables.dsn );
		var beanmap = variables.dataFactory.getBeanMap(arguments.relationship.bean);
		var tablename = getTableName(beanmap);

		if ( !len(arguments.relationship.fkColumn) || !len(arguments.relationship.fksqltype) || !len(arguments.relationship.joinColumn) || !len(arguments.relationship.joinTable) ) {
			throw(beanmap.bean & " bean is missing required bean map variables for the " & arguments.relationship.name & " relationship join table: fkColumn, fksqltype, joinColumn, joinTable");
		}

		var joinpath = ( len(arguments.relationship.joinSchema) ? "[" & arguments.relationship.joinSchema & "]." : "" ) & "[" & arguments.relationship.joinTable & "]";
		var primarykey = getPrimaryKeyField(beanmap);

		var sql = "SELECT ";
		sql &= getFields("select", beanmap);
		sql &= " FROM " & tablename;
		sql &= " JOIN " & joinpath & " ON " & joinpath & ".[" & arguments.relationship.joinColumn & "] = " & tablename & "." & primarykey;
		sql &= " WHERE " & joinpath & ".[" & arguments.relationship.fkColumn & "] = :" & arguments.relationship.fkColumn;
		if ( len(beanmap.orderby) ) {
			sql &= " ORDER BY " & beanmap.orderby;
		}
		querycfc.setSql(sql);

		querycfc.addParam(name=arguments.relationship.fkColumn, value=arguments.beanid, cfsqltype=arguments.relationship.fksqltype);

		return querycfc.execute().getResult();
	}

	public struct function readSproc( string sprocname, array params=[], array resultkeys=[] ) {
		var result = {};

		if ( structKeyExists(server, "railo") || structKeyExists(server, "lucee") ) {
			// because "new storedproc()" doesn't exist in railo and the railo script version causes a syntax error in cf9
			result = variables.storedprocTag.storedproc(argumentCollection=arguments);

		} else {
			var sproc = new storedproc();
			sproc.setDatasource(variables.dsn);
			sproc.setProcedure(arguments.sprocname);

			for ( var param in arguments.params ) {
				if ( isStruct(param) && structKeyExists(param,"cfsqltype") && structKeyExists(param,"value") ) {
					sproc.addParam(cfsqltype=param.cfsqltype, type="in", value=param.value);
				}
			}
			var k = 0;
			for ( var key in arguments.resultkeys ) {
				k++;
				sproc.addProcResult(name=key,resultset=k);
			}

			result = sproc.execute().getProcResultSets();
		}

		return result;
	}

	public void function update( string beanname, bean ) {
		var beanmap = variables.dataFactory.getBeanMap(arguments.beanname);
		var tablename = getTableName(beanmap);

		var sql = "UPDATE " & tablename & " SET ";
		sql &= getFields("update", beanmap);
		sql &= " WHERE " & tablename & "." & getPrimaryKeyField(beanmap) & " = :" & beanmap.primarykey;

		var querycfc = new query( datasource=variables.dsn, sql=sql );

		var params = getParams( arguments.bean, beanmap );
		for ( var field IN params ) {
			querycfc.addParam(name=field, value=params[ field ].value, null=params[ field ].null, cfsqltype=params[ field ].cfsqltype);
		}

		querycfc.execute();
	}

	/*
	* @type possible values: insert, update, select, values
	*/
	private string function getFields( string type, struct beanmap, boolean pkOnly=false ) {
		var delimiter = ( arguments.type == "values" ? ", :" : ", " );
		var includepk = ( arguments.type == "select" ? true : false );
		var tablename = getTableName(arguments.beanmap);
		arguments.pkOnly = ( arguments.type == "select" ? arguments.pkOnly : false );

		var fields = "";
		for ( var prop IN arguments.beanmap.properties ) {
			if ( isPropertyIncluded(prop, arguments.beanmap, includepk, arguments.type, arguments.pkOnly) ) {
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
						fields &= getSelectField(columnname,arguments.beanmap.properties[ prop ].sqltype,arguments.beanmap.properties[ prop ].null,tablename);
						fields &= "[" & prop & "]";
					} else {
						fields &= columnname;
					}
				}
			}
		}

		return fields;
	}

	private struct function getParams( bean, struct beanmap, boolean includepk=true ) {
		var params = {};

		for ( var prop IN arguments.beanmap.properties ) {
			if ( isPropertyIncluded(prop, arguments.beanmap, arguments.includepk) ) {
				var valuestring = arguments.bean.getPropertyValue(prop);
				params[ prop ] = { value=valuestring, cfsqltype=arguments.beanmap.properties[ prop ].sqltype };
				if ( arguments.beanmap.properties[ prop ].null && ( !len(valuestring) || findNoCase("integer",arguments.beanmap.properties[ prop ].sqltype) && isNumeric(valuestring) && !valuestring ) ) {
					params[ prop ].value = "";
					params[ prop ].null = true;
				} else {
					params[ prop ].null = false;
				}
			}
		}
		return params;
	}

	private string function getPrimaryKeyField( struct beanmap ) {
		var pkproperty = beanmap.properties[ beanmap.primarykey ];
		return "[" & ( len(pkproperty.columnName) ? pkproperty.columnName : beanmap.primarykey ) & "]";
	}

	private string function getSelectField( string columnname, string sqltype, boolean isNull ) {
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

	private string function getTableName( struct beanmap ) {
		return ( len(arguments.beanmap.schema) ? "[" & arguments.beanmap.schema & "]." : "" ) & "[" & arguments.beanmap.table & "]";
	}

	private boolean function isPropertyIncluded( string prop, struct beanmap, boolean includepk, string type="update", boolean pkOnly=false ) {
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

}

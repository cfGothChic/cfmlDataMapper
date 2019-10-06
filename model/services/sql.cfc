component accessors="true" output="false" {

	property DataGateway;
	property DataFactory;
	property MSSQLService;
	property MySQLService;
	property ValidationService;

	property dataFactoryConfig;

	public component function init() {
		return this;
	}

	public numeric function create( required string beanname, required component bean ) {
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.beanname );
		var sql = createSQL( beanmap=beanmap );
		var sqlparams = getPropertyParams( bean=arguments.bean, beanmap=beanmap, includepk=0 );
		var newid = variables.DataGateway.create( sql=sql, sqlparams=sqlparams );
		return newid;
	}

	public void function delete( required string beanname, required numeric id ) {
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.beanname );
		var sql = deleteSQL( beanmap=beanmap );
		variables.DataGateway.delete( sql=sql, primarykey=beanmap.primarykey, id=arguments.id );
	}

	public void function deleteByNotIn( required string beanname, required string key, required string list ) {
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.beanname );
		var pkproperty = beanmap.properties[ arguments.key ];
		var sql = deleteByNotInSQL( beanmap=beanmap, pkproperty=pkproperty );
		variables.DataGateway.deleteByNotIn(
			sql=sql,
			key=arguments.key,
			list=arguments.list,
			sqltype=pkproperty.sqltype
		);
	}

	public string function getServerType() {
		param variables.dataFactoryConfig.serverType = "mssql";

		if (
			len(variables.dataFactoryConfig.serverType)
			&& !arrayFindNoCase(["mssql","mysql"], variables.dataFactoryConfig.serverType)
		) {
			throw("The DataFactory serverType config variable must be 'mssql' or 'mysql' (defaults to 'mssql'): " & variables.dataFactoryConfig.serverType);
		}

		return variables.dataFactoryConfig.serverType;
	}

	public boolean function isPropertyIncluded(
		required struct prop,
		required string primarykey,
		boolean includepk=true,
		string type="update",
		boolean pkOnly=false
	) {
		if ( arguments.type == "select" ) {
			return (
				!arguments.pkOnly
				|| arguments.prop.name == arguments.primarykey
			);
		} else {
			return (
				arguments.prop.insert
				&& (
					arguments.includepk
					|| arguments.prop.name != arguments.primarykey
				)
			);
		}
	}

	public query function read(
		required string beanname,
		required string methodname,
		struct params={},
		string orderby="",
		boolean pkOnly=false
	) {
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.beanname );

		var sqlparams = getQueryParams(
			params=arguments.params,
			properties=beanmap.properties,
			beanname=arguments.beanname,
			methodname=arguments.methodname
		);

		var sql = readSQL(
			beanmap=beanmap,
			sqlparams=sqlparams,
			orderby=arguments.orderby,
			pkOnly=arguments.pkOnly
		);

		var qRecords = variables.DataGateway.read( sql=sql, sqlparams=sqlparams, beanmap=beanmap );
		return qRecords;
	}

	public query function readByJoin( required numeric beanid, required struct relationship ) {
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.relationship.bean );

		var sql = readByJoinSQL( beanmap=beanmap, relationship=arguments.relationship );

		var qRecords = variables.DataGateway.readByJoin(
			sql=sql,
			beanid=arguments.beanid,
			fkColumn=arguments.relationship.fkColumn,
			fksqltype=arguments.relationship.fksqltype
		);

		return qRecords;
	}

	public void function update( required string beanname, required component bean ) {
		var beanmap = variables.DataFactory.getBeanMap( arguments.beanname );
		var sql = updateSQL( beanmap=beanmap );
		var sqlparams = getPropertyParams( bean=arguments.bean, beanmap=beanmap );
		variables.DataGateway.update( sql=sql, sqlparams=sqlparams );
	}

	/* raw sql building functions */

	public string function createSQL( required struct beanmap ) {
		var sql = "";
		var pkproperty = arguments.beanmap.properties[ arguments.beanmap.primarykey ];
		var primarykeyfield = getPrimaryKeyField( beanmap=arguments.beanmap );
		var tablename = getServerTypeService().getTableName( beanmap=arguments.beanmap );

		sql &= getServerTypeService().getCreateSetNewId( isidentity=pkproperty.isidentity, tablename=tablename, primarykeyfield=primarykeyfield );

		sql &= "INSERT INTO " & tablename & " (";

		if ( !pkproperty.isidentity ) {
			sql &= ( len(pkproperty.columnname) ? pkproperty.columnname : pkproperty.name ) & ", ";
		}

		sql &= getFields( type="insert", beanmap=arguments.beanmap );

		sql &= getServerTypeService().getCreateValues( isidentity=pkproperty.isidentity, primarykeyfield=primarykeyfield );

		sql &= getFields( type="values", beanmap=arguments.beanmap );

		sql &= getServerTypeService().getCreateNewId( isidentity=pkproperty.isidentity );

		return sql;
	}

	public string function deleteByNotInSQL( required struct beanmap, required struct pkproperty ) {
		var sql = "DELETE FROM " & getServerTypeService().getTableName( beanmap=arguments.beanmap );
		sql &= " WHERE " & getServerTypeService().getPropertyField( prop=arguments.pkproperty );
		sql &= " NOT IN (:" & arguments.pkproperty.name & ")";
		return sql;
	}

	public string function deleteSQL( required struct beanmap ) {
		var sql = "DELETE FROM " & getServerTypeService().getTableName( beanmap=arguments.beanmap );
		sql &= " WHERE " & getPrimaryKeyField( beanmap=arguments.beanmap );
		sql &= " = :" & arguments.beanmap.primarykey;
		return sql;
	}

	public string function readByJoinSQL( required struct beanmap, required struct relationship ) {
		var tablename = getServerTypeService().getTableName( beanmap=arguments.beanmap );
		var primarykey = getPrimaryKeyField( beanmap=arguments.beanmap );

		var rBeanMap = {
			database = arguments.beanmap.database,
			schema = arguments.relationship.joinSchema,
			table = arguments.relationship.joinTable
		};
		var rTablename = getServerTypeService().getTableName( beanmap=rBeanMap );

		var sql = "SELECT ";
		sql &= getFields( type="select", beanmap=arguments.beanmap );
		sql &= " FROM " & tablename;

		var prop = { name=arguments.relationship.joinColumn, columnname="" };
		sql &= " JOIN " & rTablename;
		sql &= " ON " & rTablename & "." & getServerTypeService().getPropertyField( prop=prop );
		sql &= " = " & tablename & "." & primarykey;

		prop = { name=arguments.relationship.fkColumn, columnname="" };
		sql &= " WHERE " & rTablename & "." & getServerTypeService().getPropertyField( prop=prop );
		sql &= " = :" & arguments.relationship.fkColumn;

		sql &= " ORDER BY " & getFullOrderBy( beanmap=arguments.beanmap );

		return sql;
	}

	public string function readSQL(
		required struct beanmap,
		required struct sqlparams={},
		required string orderby="",
		boolean pkOnly=false
	) {
		var tablename = getServerTypeService().getTableName( beanmap=arguments.beanmap );

		var sql = "SELECT ";
		sql &= getFields( type="select", beanmap=arguments.beanmap, pkOnly=arguments.pkOnly );
		sql &= " FROM " & tablename;

		if ( structCount(arguments.sqlparams) ) {
			sql &= getWhereStatement( beanmap=arguments.beanmap, sqlparams=arguments.sqlparams, tablename=tablename );
		}

		sql &= " ORDER BY " & getFullOrderBy( beanmap=arguments.beanmap, orderby=arguments.orderby );

		return sql;
	}

	public string function updateSQL( required struct beanmap ) {
		var tablename = getServerTypeService().getTableName( beanmap=arguments.beanmap );

		var sql = "UPDATE " & tablename & " SET ";
		sql &= getFields( type="update", beanmap=arguments.beanmap );
		sql &= " WHERE " & tablename & "." & getPrimaryKeyField( beanmap=arguments.beanmap ) & " = :" & arguments.beanmap.primarykey;

		return sql;
	}

	/* private functions */

	private boolean function isNullInteger( required string sqltype, required string value ) {
		return (
			findNoCase("integer",arguments.sqltype)
			&& isNumeric(arguments.value)
			&& !arguments.value
		);
	}

	private string function getFieldByType(
		required string type,
		required struct prop,
		required string propname,
		required string columnname
	) {
		var field = "";

		switch ( arguments.type ) {

			case "insert":
				field &= getServerTypeService().getPropertyField( prop=prop );
				break;

			case "values":
				field &= ":" & arguments.propname;
				break;

			case "update":
				field &= arguments.columnname & " = :" & arguments.propname;
				break;

			default:
				if ( len(arguments.prop.columnName) || ( arguments.prop.sqltype == "cf_sql_integer" && !arguments.prop.isrequired ) ) {
					field &= getServerTypeService().getSelectAsField(
						propname=arguments.propname,
						columnname=columnname,
						sqltype=arguments.prop.sqltype,
						isRequired=arguments.prop.isrequired
					);
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
		var tablename = getServerTypeService().getTableName( beanmap=arguments.beanmap );
		arguments.pkOnly = ( arguments.type == "select" ? arguments.pkOnly : false );

		var fields = "";
		for ( var propname in arguments.beanmap.properties ) {
			var prop = arguments.beanmap.properties[ propname ];

			var isIncluded = isPropertyIncluded(
				prop=prop,
				primarykey=arguments.beanmap.primarykey,
				includepk=includepk,
				type=arguments.type,
				pkOnly=arguments.pkOnly
			);

			if ( isIncluded ) {
				var columnname = tablename & "." & getServerTypeService().getPropertyField( prop=prop );

				if ( len(fields) ) {
					fields &= ", ";
				}
				fields &= getFieldByType( type=arguments.type, prop=prop, propname=propname, columnname=columnname );
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
				fullorderby &= ( len(fullorderby) ? ", " : "" );
				fullorderby &= getServerTypeService().getTableName( beanmap=arguments.beanmap );
				fullorderby &= "." & getServerTypeService().getPropertyField( prop=prop );
				fullorderby &= " " & orderinfo.direction;
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
		return getServerTypeService().getPropertyField( prop=pkproperty );
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

	private struct function getPropertyParams( required component bean, required struct beanmap, boolean includepk=true ) {
		var sqlparams = {};

		for ( var propname in arguments.beanmap.properties ) {
			var prop = arguments.beanmap.properties[ propname ];

			var isIncluded = isPropertyIncluded( prop=prop, primarykey=arguments.beanmap.primarykey, includepk=includepk );

			if ( isIncluded ) {
				var value = arguments.bean.getPropertyValue( propertyname=propname );
				sqlparams[ propname ] = getSQLParam( prop=prop, value=value );
			}
		}

		return sqlparams;
	}

	private struct function getQueryParams(
		required struct params,
		required struct properties,
		required string methodname,
		required string beanname
	) {
		var sqlparams = {};

		if ( structCount(arguments.params) ) {
			for ( var fieldkey in arguments.params ) {
				var value = arguments.params[ fieldkey ];

				var isvalid = validateQueryParam(
					fieldkey=fieldkey,
					value=value,
					properties=arguments.properties,
					beanname=arguments.beanname,
					methodname=arguments.methodname
				);

				if ( isvalid ) {
					var prop = arguments.properties[ fieldkey ];
					sqlparams[ fieldkey ] = getSQLParam( prop=prop, value=value, allowNull=false );
				}

			}
		}

		return sqlparams;
	}

	private component function getServerTypeService() {
		if ( getServerType() == "mysql" ) {
			return variables.MySQLService;
		} else {
			return variables.MSSQLService;
		}
	}

	private struct function getSQLParam( required struct prop, required any value, boolean allowNull=true ) {
		var sqlparam = {
			value = arguments.value,
			cfsqltype = arguments.prop.sqltype,
			usenull = false
		};

		if (
			arguments.allowNull
			&& !arguments.prop.isrequired
			&& (
				!len(arguments.value)
				|| isNullInteger( sqltype=arguments.prop.sqltype, value=arguments.value )
			)
		) {
			sqlparam.value = "";
			sqlparam.usenull = true;
		}

		return sqlparam;
	}

	private string function getWhereStatement( required struct beanmap, required struct sqlparams, required string tablename ) {
		var where = "";
		for ( var field in arguments.sqlparams ) {
			if ( structKeyExists(arguments.beanmap.properties,field) ) {
				var prop = arguments.beanmap.properties[field];
				where &= ( len(where) ? " AND " : " WHERE " ) & arguments.tablename;
				where &= "." & getServerTypeService().getPropertyField( prop=prop ) & " = :" & field;
			} else {
				throw(message="The property '#lCase(field)#' was not found in the '#arguments.beanmap.bean#' bean definition");
			}
		}
		return where;
	}

	private boolean function validateQueryParam(
		required string fieldkey,
		required any value,
		required struct properties,
		required string beanname,
		required string methodname
	) {
		var isvalid = false;

		if ( !structKeyExists(arguments.properties, arguments.fieldkey) ) {
			throw("The '#arguments.fieldkey#' parameter passed into the #arguments.methodname#() function doesn't exist in the '#arguments.beanname#' bean properties.");
		}

		if ( !isSimpleValue(arguments.value) ) {
			throw("The '#arguments.fieldkey#' parameter passed into the #arguments.methodname#() function must be a simple value (string or number).");
		}

		if ( len(arguments.value) ) {
			isvalid =  true;
		}

		var prop = arguments.properties[ arguments.fieldkey ];
		if ( isvalid && prop.datatype != "any" && prop.datatype != "string" ) {

			var message = variables.ValidationService.validateByDataType(
				datatype=prop.datatype,
				value=arguments.value,
				displayname=prop.displayname
			);

			if ( len(message) ) {
				throw("A parameter passed into the #arguments.methodname#() function does not match the datatype of the '#arguments.beanname#' bean property: #message#.");
			}
		}

		return isvalid;
	}

}

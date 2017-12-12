component accessors="true" output="false" {

	property DataGateway;
	property DataFactory;
	property MSSQLService;
	property ValidationService;

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

	public void function delete( required string bean, required numeric id ) {
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.bean );
		var sql = deleteSQL( beanmap=beanmap );
		variables.DataGateway.delete( sql=sql, primarykey=beanmap.primarykey, id=arguments.id );
	}

	public void function deleteByNotIn( required string bean, required string key, required string list ) {
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.bean );
		var pkproperty = beanmap.properties[ arguments.key ];
		var sql = deleteByNotInSQL( beanmap=beanmap, pkproperty=pkproperty );
		variables.DataGateway.deleteByNotIn( sql=sql, key=arguments.key, list=arguments.list, sqltype=pkproperty.sqltype );
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

	/* passthrough functions to server specific sql script builders */

	public string function createSQL() {
		return variables.MSSQLService.createSQL( argumentCollection=arguments );
	}

	public string function deleteSQL() {
		return variables.MSSQLService.deleteSQL( argumentCollection=arguments );
	}

	public string function deleteByNotInSQL() {
		return variables.MSSQLService.deleteByNotInSQL( argumentCollection=arguments );
	}

	public string function readByJoinSQL() {
		return variables.MSSQLService.readByJoinSQL( argumentCollection=arguments );
	}

	public string function readSQL() {
		return variables.MSSQLService.readSQL( argumentCollection=arguments );
	}

	public string function updateSQL() {
		return variables.MSSQLService.updateSQL( argumentCollection=arguments );
	}

	/* private functions */

	private boolean function isNullInteger( required string sqltype, required string value ) {
		return (
			findNoCase("integer",arguments.sqltype)
			&& isNumeric(arguments.value)
			&& !arguments.value
		);
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

	private struct function getSQLParam( required struct prop, required any value, boolean allowNull=true ) {
		var sqlparam = {
			value = arguments.value,
			cfsqltype = arguments.prop.sqltype,
			"null" = false
		};

		if (
			arguments.allowNull
			&& arguments.prop.null
			&& (
				!len(arguments.value)
				|| isNullInteger( sqltype=arguments.prop.sqltype, value=arguments.value )
			)
		) {
			sqlparam.value = "";
			sqlparam.null = true;
		}

		return sqlparam;
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

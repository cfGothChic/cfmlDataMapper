component accessors=true {

	property dataFactory;
	property sqlService;
	property storedprocTag;

	public function init( dsn ) {
		variables.dsn = arguments.dsn;
		return this;
	}

	public numeric function create( required string beanname, required component bean ) {
		var querycfc = new query( datasource=variables.dsn );
		var beanmap = variables.dataFactory.getBeanMap( bean=arguments.beanname );
		var sql = variables.sqlService.create( beanmap=beanmap );

		var params = variables.sqlService.getParams( bean=arguments.bean, beanmap=beanmap, includepk=0 );
		for ( var field in params ) {
			querycfc.addParam( name=field, value=params[ field ].value, null=params[ field ].null, cfsqltype=params[ field ].cfsqltype );
		}

		querycfc.setSql(sql);
		var qRecord = querycfc.execute().getResult();
		return qRecord.newid;
	}

	public void function delete( required string bean, required numeric id ) {
		var beanmap = variables.dataFactory.getBeanMap( bean=arguments.bean );
		var sql = variables.sqlService.delete( beanmap=beanmap );
		var querycfc = new query( datasource=variables.dsn, sql=sql );
		querycfc.addParam( name=beanmap.primarykey, value=arguments.id, cfsqltype="cf_sql_integer" );
		querycfc.execute();
	}

	public void function deleteByValueList( required string bean, required string key, required string list ) {
		var beanmap = variables.dataFactory.getBeanMap( bean=arguments.bean );
		var pkproperty = beanmap.properties[ arguments.key ];
		var sql = variables.sqlService.deleteByValueList( beanmap=beanmap, pkproperty=pkproperty, key=arguments.key );

		var querycfc = new query( sql=sql, datasource=variables.dsn );
		querycfc.addParam( name=arguments.key, value=arguments.list, cfsqltype=pkproperty.sqltype, list=true );
		querycfc.execute().getResult();
	}

	public query function read(
		required string bean,
		struct params={},
		string orderby="",
		boolean pkOnly=false
	) {
		var querycfc = new query( datasource=variables.dsn );
		var beanmap = variables.dataFactory.getBeanMap( bean=arguments.bean );

		var sql = variables.sqlService.read(
			beanmap=beanmap,
			params=arguments.params,
			orderby=arguments.orderby,
			pkOnly=arguments.pkOnly
		);

		if ( !structIsEmpty(arguments.params) ) {
			for ( var field in arguments.params ) {
				if ( structKeyExists(beanmap.properties,field) ) {
					querycfc.addParam( name=field, value=arguments.params[ field ], cfsqltype=beanmap.properties[ field ].sqltype );
				}
			}
		}

		querycfc.setSql(sql);
		return querycfc.execute().getResult();
	}

	public query function readByJoinTable( required numeric beanid, required struct relationship ) {
		var querycfc = new query( datasource=variables.dsn );
		var beanmap = variables.dataFactory.getBeanMap( bean=arguments.relationship.bean );

		if (
			!len(arguments.relationship.fkColumn)
			|| !len(arguments.relationship.fksqltype)
			|| !len(arguments.relationship.joinColumn)
			|| !len(arguments.relationship.joinTable)
		) {
			throw(beanmap.bean & " bean is missing required bean map variables for the " & arguments.relationship.name & " relationship join table: fkColumn, fksqltype, joinColumn, joinTable");
		}

		var sql = variables.sqlService.readByJoinTable( beanmap=beanmap, relationship=arguments.relationship );
		querycfc.setSql(sql);

		querycfc.addParam( name=arguments.relationship.fkColumn, value=arguments.beanid, cfsqltype=arguments.relationship.fksqltype );

		return querycfc.execute().getResult();
	}

	public struct function readSproc( required string sprocname, array params=[], array resultkeys=[] ) {
		var result = {};

			// because "new storedproc()" doesn't exist in railo and the railo script version causes a syntax error in cf9
		if ( structKeyExists(server, "lucee") ) {
			result = variables.storedprocTag.storedproc( argumentCollection=arguments );

		} else {
			var sproc = new storedproc();
			sproc.setDatasource(variables.dsn);
			sproc.setProcedure(arguments.sprocname);

			for ( var param in arguments.params ) {
				if ( isStruct(param) && structKeyExists(param,"cfsqltype") && structKeyExists(param,"value") ) {
					sproc.addParam( cfsqltype=param.cfsqltype, type="in", value=param.value );
				}
			}
			var k = 0;
			for ( var key in arguments.resultkeys ) {
				k++;
				sproc.addProcResult( name=key, resultset=k );
			}

			result = sproc.execute().getProcResultSets();
		}

		return result;
	}

	public void function update( required string beanname, required component bean ) {
		var beanmap = variables.dataFactory.getBeanMap( arguments.beanname );

		var sql = variables.sqlService.update( beanmap=beanmap );

		var querycfc = new query( datasource=variables.dsn, sql=sql );

		var params = variables.sqlService.getParams( bean=arguments.bean, beanmap=beanmap );
		for ( var field IN params ) {
			querycfc.addParam( name=field, value=params[ field ].value, null=params[ field ].null, cfsqltype=params[ field ].cfsqltype );
		}

		querycfc.execute();
	}

}

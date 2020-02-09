component accessors=true {

	property dsn;

	public function init() {
		return this;
	}

	public numeric function create( required string sql, required struct sqlparams ) {
		var querycfc = new query( datasource=variables.dsn, sql=arguments.sql );
		addParams( querycfc=querycfc, sqlparams=arguments.sqlparams );

		var qRecord = querycfc.execute().getResult();
		return qRecord.newid;
	}

	public void function delete( required string sql, required string primarykey, required numeric id ) {
		var querycfc = new query( datasource=variables.dsn, sql=arguments.sql );
		querycfc.addParam( name=arguments.primarykey, value=arguments.id, cfsqltype="cf_sql_integer" );
		querycfc.execute();
	}

	public void function deleteByNotIn( required string sql, required string key, required string list, required string sqltype ) {
		var querycfc = new query( datasource=variables.dsn, sql=arguments.sql );
		querycfc.addParam( name=arguments.key, value=arguments.list, cfsqltype=arguments.sqltype, list=true );
		querycfc.execute().getResult();
	}

	public query function read( required string sql, required struct sqlparams ) {
		var querycfc = new query( datasource=variables.dsn, sql=arguments.sql );
		addParams( querycfc=querycfc, sqlparams=arguments.sqlparams );
		return querycfc.execute().getResult();
	}

	public query function readByJoin(
		required string sql,
		required numeric beanid,
		required string fkColumn,
		required string fksqltype
	) {
		var querycfc = new query( datasource=variables.dsn, sql=arguments.sql );
		querycfc.addParam( name=arguments.fkColumn, value=arguments.beanid, cfsqltype=arguments.fksqltype );
		return querycfc.execute().getResult();
	}

	public struct function readSproc( required string sprocname, array params=[], array resultkeys=[] ) {
		var result = {};

		cfstoredproc( procedure=arguments.sprocname, datasource=variables.dsn ) {
			for ( var param in arguments.params ) {
				if ( isStruct(param) && structKeyExists(param,"cfsqltype") && structKeyExists(param,"value") ) {
					cfprocparam( cfsqltype=param.cfsqltype, value=param.value );
				}
			}
			var k = 0;
			for ( var key in arguments.resultkeys ) {
				k++;
				cfprocresult( name="result.#key#", resultset=k );
			}
		}

		return result;
	}

	public void function update( required string sql, required struct sqlparams ) {
		var querycfc = new query( datasource=variables.dsn, sql=arguments.sql );
		addParams( querycfc=querycfc, sqlparams=arguments.sqlparams );
		querycfc.execute();
	}

	private void function addParams( required component querycfc, required struct sqlparams ) {
		for ( var fieldkey in arguments.sqlparams ) {
			var field = arguments.sqlparams[ fieldkey ];
			arguments.querycfc.addParam( name=fieldkey, value=field.value, null=field.usenull, cfsqltype=field.cfsqltype );
		}
	}

}

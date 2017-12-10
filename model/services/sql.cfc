﻿component accessors="true" output="false" {

	property DataGateway;
	property DataFactory;
	property MSSQLService;

	public component function init() {
		return this;
	}

	public numeric function create( required string beanname, required component bean ) {
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.beanname );
		var sql = createSQL( beanmap=beanmap );
		var params = getParams( bean=arguments.bean, beanmap=beanmap, includepk=0 );
		var newid = variables.DataGateway.create( sql=sql, params=params );
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
		var sql = deleteByNotInSQL( beanmap=beanmap, pkproperty=pkproperty, key=arguments.key );
		variables.DataGateway.deleteByNotIn( sql=sql, key=arguments.key, list=arguments.list, sqltype=pkproperty.sqltype );
	}

	public boolean function isPropertyIncluded(
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

	public query function read(
		required string bean,
		struct params={},
		string orderby="",
		boolean pkOnly=false
	) {
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.bean );

		var sql = readSQL(
			beanmap=beanmap,
			params=arguments.params,
			orderby=arguments.orderby,
			pkOnly=arguments.pkOnly
		);

		var qRecords = variables.DataGateway.read( sql=sql, params=params, beanmap=beanmap );
		return qRecords;
	}

	public query function readByJoin( required numeric beanid, required struct relationship ) {
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.relationship.bean );

		if (
			!len(arguments.relationship.fkColumn)
			|| !len(arguments.relationship.fksqltype)
			|| !len(arguments.relationship.joinColumn)
			|| !len(arguments.relationship.joinTable)
		) {
			throw(beanmap.bean & " bean is missing required bean map variables for the " & arguments.relationship.name & " relationship join table: fkColumn, fksqltype, joinColumn, joinTable");
		}

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
		var params = getParams( bean=arguments.bean, beanmap=beanmap );
		variables.DataGateway.update( sql=sql, params=params );
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

}

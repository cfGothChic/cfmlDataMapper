component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = new cfmlDataMapper.model.services.sql();
		prepareMock( testClass );
	}

	function run() {

		describe("The SQL Service", function(){

			beforeEach(function( currentSpec ){
				beanmap = {
					bean = "user",
					primarykey = "id",
					properties = {
						id = {
							name = "id",
							displayname = "ID",
							insert = true,
							datatype = "integer",
							sqltype = "cf_sql_integer",
							null = true
						},
						email = {
							name = "email",
							displayname = "Email",
							insert = true,
							datatype = "string",
							sqltype = "cf_sql_varchar",
							null = true
						}
					}
				};

				userBean = createMock("model.beans.user");

				makePublic( testClass, "isNullInteger" );
			});


			// isNullInteger()
			it( "returns true if the sqltype is an integer and it is 0", function(){
				var result = testClass.isNullInteger( sqltype="integer", value=0 );

				expect( result ).toBeTypeOf( "boolean" );
				expect( result ).toBeTrue();
			});


			it( "returns false if the sqltype is an integer and it is not 0", function(){
				var result = testClass.isNullInteger( sqltype="integer", value=1 );

				expect( result ).toBeTypeOf( "boolean" );
				expect( result ).toBeFalse();
			});


			it( "returns false if the sqltype is not an integer", function(){
				var result = testClass.isNullInteger( sqltype="varchar", value="" );

				expect( result ).toBeTypeOf( "boolean" );
				expect( result ).toBeFalse();
			});


			describe("checks if a property should be included and", function(){

				// isPropertyIncluded()
				it( "returns true if the type is select and not primarykey only", function(){
					var result = testClass.isPropertyIncluded(
						prop=beanmap.properties.email,
						primarykey=beanmap.primarykey,
						includepk=true,
						type="select",
						pkOnly=false
					);

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns true if the type is select, the field is the primarykey and it is primarykey only", function(){
					var result = testClass.isPropertyIncluded(
						prop=beanmap.properties.id,
						primarykey=beanmap.primarykey,
						includepk=true,
						type="select",
						pkOnly=true
					);

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns false if the type is select, the field is not the primarykey and it is primarykey only", function(){
					var result = testClass.isPropertyIncluded(
						prop=beanmap.properties.email,
						primarykey=beanmap.primarykey,
						includepk=true,
						type="select",
						pkOnly=true
					);

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeFalse();
				});


				it( "returns true if the type is not select, the property is inserted and its including the primarykey", function(){
					var result = testClass.isPropertyIncluded(
						prop=beanmap.properties.email,
						primarykey=beanmap.primarykey,
						includepk=true,
						type="update",
						pkOnly=false
					);

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns true if the type is not select, the property is inserted and its not the primrarykey when not included", function(){
					var result = testClass.isPropertyIncluded(
						prop=beanmap.properties.email,
						primarykey=beanmap.primarykey,
						includepk=false,
						type="update",
						pkOnly=false
					);

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns false if the type is not select, the property is inserted and its the primarykey when not included", function(){
					var result = testClass.isPropertyIncluded(
						prop=beanmap.properties.id,
						primarykey=beanmap.primarykey,
						includepk=false,
						type="update",
						pkOnly=false
					);

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeFalse();
				});


				it( "returns false if the type is not select and the property is not inserted", function(){
					beanmap.properties.email.insert = false;
					var result = testClass.isPropertyIncluded(
						prop=beanmap.properties.email,
						primarykey=beanmap.primarykey,
						includepk=true,
						type="update",
						pkOnly=false
					);

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeFalse();
				});

			});


			// validateQueryParam()
			describe("calls validateQueryParam() and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "validateQueryParam" );

					ValidationService = createEmptyMock("cfmlDataMapper.model.services.validation");
					ValidationService.$( "validateByDataType", "" );
					testClass.$property( propertyName="ValidationService", mock=ValidationService );

					args = {
						fieldkey = "email",
						value = "test",
						properties = beanmap.properties,
						beanname = "test",
						methodname = "test"
					};
				});


				it( "returns true if the parameter value has a length and has a string or any bean property datatype", function(){
					var result = testClass.validateQueryParam( argumentCollection=args );

					expect( ValidationService.$never("validateByDataType") ).toBeTrue();

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns true if the parameter value has a length and matches the bean property's datatype", function(){
					args.fieldkey = "id";
					args.value = 0;

					var result = testClass.validateQueryParam( argumentCollection=args );

					expect( ValidationService.$once("validateByDataType") ).toBeTrue();

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns false if the parameter value doesn't have a length", function(){
					args.value = "";

					var result = testClass.validateQueryParam( argumentCollection=args );

					expect( ValidationService.$never("validateByDataType") ).toBeTrue();

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeFalse();
				});


				it( "throws an error if the parameter doesn't match a bean property name", function(){
					args.fieldkey = "test";

					expect( function(){ testClass.validateQueryParam( argumentCollection=args ); } )
						.toThrow(type="application", regex="(exist)");
				});


				it( "throws an error if the parameter value isn't a simple value", function(){
					args.value = {};

					expect( function(){ testClass.validateQueryParam( argumentCollection=args ); } )
						.toThrow(type="application", regex="(simple)");
				});


				it( "throws an error if the parameter value doesn't match the bean property datatype", function(){
					ValidationService.$( "validateByDataType", "message" );

					args.fieldkey = "id";
					args.value = "test";

					expect( function(){ testClass.validateQueryParam( argumentCollection=args ); } )
						.toThrow(type="application", regex="(datatype)");
				});

			});


			// getSQLParam()
			describe("calls getSQLParam() and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getSQLParam" );

					testClass.$( "isNullInteger", false );
				});


				it( "returns a structure of the sql queryparam attributes", function(){
					var result = testClass.getSQLParam( prop=beanmap.properties.email, value="test", allowNull=true );

					expect( testClass.$once("isNullInteger") ).toBeTrue();

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).toHaveKey( "value" );
					expect( result ).toHaveKey( "cfsqltype" );
					expect( result ).toHaveKey( "null" );
					expect( result.null ).toBeFalse();
				});


				it( "returns a structure of the sql queryparam attributes set to null if the value doesn't have a length", function(){
					var result = testClass.getSQLParam( prop=beanmap.properties.email, value="", allowNull=true );

					expect( testClass.$never("isNullInteger") ).toBeTrue();

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).toHaveKey( "value" );
					expect( result ).toHaveKey( "cfsqltype" );
					expect( result ).toHaveKey( "null" );
					expect( result.null ).toBeTrue();
				});


				it( "returns a structure of the sql queryparam attributes set to null if the value is a null integer", function(){
					testClass.$( "isNullInteger", true );

					var result = testClass.getSQLParam( prop=beanmap.properties.id, value=0, allowNull=true );

					expect( testClass.$once("isNullInteger") ).toBeTrue();

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).toHaveKey( "value" );
					expect( result ).toHaveKey( "cfsqltype" );
					expect( result ).toHaveKey( "null" );
					expect( result.null ).toBeTrue();
				});


				it( "returns a structure of the sql queryparam attributes not set to null", function(){
					var result = testClass.getSQLParam( prop=beanmap.properties.email, value="", allowNull=false );

					expect( testClass.$never("isNullInteger") ).toBeTrue();

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).toHaveKey( "value" );
					expect( result ).toHaveKey( "cfsqltype" );
					expect( result ).toHaveKey( "null" );
					expect( result.null ).toBeFalse();
				});

			});


			// getQueryParams()
			describe("calls getQueryParams() and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getQueryParams" );

					testClass.$( "validateQueryParam", true )
						.$( "getSQLParam", {} );
				});


				it( "returns a structure of sql parameters from the query properties", function(){
					var result = testClass.getQueryParams( params={ id=0 }, properties=beanmap.properties, methodname="test", beanname="test" );

					expect( testClass.$once("validateQueryParam") ).toBeTrue();
					expect( testClass.$once("getSQLParam") ).toBeTrue();

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).toHaveLength( 1 );
				});


				it( "returns an empty structure of sql parameters if no query parameters are passed in", function(){
					var result = testClass.getQueryParams( params={}, properties=beanmap.properties, methodname="test", beanname="test" );

					expect( testClass.$never("validateQueryParam") ).toBeTrue();
					expect( testClass.$never("getSQLParam") ).toBeTrue();

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).toBeEmpty();
				});


				it( "returns an empty structure of sql parameters if none of the query parameters are valid", function(){
					testClass.$( "validateQueryParam", false );

					var result = testClass.getQueryParams( params={ test="test" }, properties=beanmap.properties, methodname="test", beanname="test" );

					expect( testClass.$once("validateQueryParam") ).toBeTrue();
					expect( testClass.$never("getSQLParam") ).toBeTrue();

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).toBeEmpty();
				});

			});


			// getPropertyParams()
			describe("calls getPropertyParams() and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getPropertyParams" );

					userBean.$( "getPropertyValue", 1 );

					testClass.$( "isPropertyIncluded", true )
						.$( "getSQLParam", {} );
				});


				it( "returns a structure of sql parameters from the beanmap properties", function(){
					var result = testClass.getPropertyParams( bean=userBean, beanmap=beanmap, includepk=true );

					expect( testClass.$count("isPropertyIncluded") ).toBe( 2 );
					expect( userBean.$count("getPropertyValue") ).toBe( 2 );
					expect( testClass.$count("getSQLParam") ).toBe( 2 );

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).toHaveLength( 2 );
				});


				it( "returns an empty structure of sql parameters if none of the beanmap properties should be included", function(){
					testClass.$( "isPropertyIncluded", false );

					var result = testClass.getPropertyParams( bean=userBean, beanmap=beanmap, includepk=true );

					expect( testClass.$count("isPropertyIncluded") ).toBe( 2 );
					expect( userBean.$never("getPropertyValue") ).toBeTrue();
					expect( testClass.$never("getSQLParam") ).toBeTrue();

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).toBeEmpty();
				});

			});

			describe("determines the sql server type and", function(){

				beforeEach(function( currentSpec ){
					MSSQLService = createEmptyMock("cfmlDataMapper.model.services.mssql");
					MSSQLService.$( "createSQL", "" )
						.$( "deleteSQL", "" )
						.$( "deleteByNotInSQL", "" )
						.$( "readSQL", "" )
						.$( "readByJoinSQL", "" )
						.$( "updateSQL", "" );
					testClass.$property( propertyName="MSSQLService", mock=MSSQLService );

					MySQLService = createEmptyMock("cfmlDataMapper.model.services.mssql");
					MySQLService.$( "createSQL", "" )
						.$( "deleteSQL", "" )
						.$( "deleteByNotInSQL", "" )
						.$( "readSQL", "" )
						.$( "readByJoinSQL", "" )
						.$( "updateSQL", "" );
					testClass.$property( propertyName="MySQLService", mock=MySQLService );
				});


				// createSQL()
				it( "returns a create sql statement for mssql", function(){
					var result = testClass.createSQL();

					expect( MSSQLService.$once("createSQL") ).toBeTrue();
					expect( MySQLService.$never("createSQL") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
				});


				// deleteSQL()
				it( "returns a delete sql statement for mssql", function(){
					var result = testClass.deleteSQL();

					expect( MSSQLService.$once("deleteSQL") ).toBeTrue();
					expect( MySQLService.$never("deleteSQL") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
				});

				// deleteByNotInSQL()
				it( "returns a delete by not in list sql statement for mssql", function(){
					var result = testClass.deleteByNotInSQL();

					expect( MSSQLService.$once("deleteByNotInSQL") ).toBeTrue();
					expect( MySQLService.$never("deleteByNotInSQL") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
				});

				// readSQL()
				it( "returns an select sql statement for mssql", function(){
					var result = testClass.readSQL();

					expect( MSSQLService.$once("readSQL") ).toBeTrue();
					expect( MySQLService.$never("readSQL") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
				});


				// readByJoinSQL()
				it( "returns a select sql statement with a join table for mssql", function(){
					var result = testClass.readByJoinSQL();

					expect( MSSQLService.$once("readByJoinSQL") ).toBeTrue();
					expect( MySQLService.$never("readByJoinSQL") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
				});


				// updateSQL()
				it( "returns an update sql statement for mssql", function(){
					var result = testClass.updateSQL();

					expect( MSSQLService.$once("updateSQL") ).toBeTrue();
					expect( MySQLService.$never("updateSQL") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
				});

			});


			describe("gathers sql to run on the server and", function(){

				beforeEach(function( currentSpec ){
					DataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");
					DataFactory.$( "getBeanMap", beanmap );
					testClass.$property( propertyName="DataFactory", mock=DataFactory );

					DataGateway = createEmptyMock("cfmlDataMapper.model.gateways.data");
					DataGateway.$( "create", 1 )
						.$( "delete" )
						.$( "deleteByNotIn" )
						.$( "read", querySim("") )
						.$( "readByJoin", querySim("") )
						.$( "update" );
					testClass.$property( propertyName="DataGateway", mock=DataGateway );

					testClass.$( "createSQL", "" )
						.$( "deleteSQL", "" )
						.$( "deleteByNotInSQL", "" )
						.$( "readSQL", "" )
						.$( "readByJoinSQL", "" )
						.$( "updateSQL", "" )
						.$( "getQueryParams", {} )
						.$( "getPropertyParams", {} );
				});


				// create()
				it( "creates a new record and returns it's id", function(){
					var result = testClass.create( beanname="user", bean=userBean );

					expect( DataFactory.$once("getBeanMap") ).toBeTrue();
					expect( testClass.$once("createSQL") ).toBeTrue();
					expect( testClass.$once("getPropertyParams") ).toBeTrue();
					expect( DataGateway.$once("create") ).toBeTrue();

					expect( result ).toBeTypeOf( "numeric" );
				});


				// delete()
				it( "deletes a record", function(){
					var result = testClass.delete( bean="user", id=1 );

					expect( DataFactory.$once("getBeanMap") ).toBeTrue();
					expect( testClass.$once("deleteSQL") ).toBeTrue();
					expect( DataGateway.$once("delete") ).toBeTrue();
				});


				// deleteByNotIn()
				it( "deletes a list of records", function(){
					var result = testClass.deleteByNotIn( bean="user", key="id", list="1,2,3" );

					expect( DataFactory.$once("getBeanMap") ).toBeTrue();
					expect( testClass.$once("deleteByNotInSQL") ).toBeTrue();
					expect( DataGateway.$once("deleteByNotIn") ).toBeTrue();
				});


				// read()
				it( "returns a query of records", function(){
					var result = testClass.read( beanname="user", methodname="", params={}, orderby="", pkOnly=false );

					expect( DataFactory.$once("getBeanMap") ).toBeTrue();
					expect( testClass.$once("getQueryParams") ).toBeTrue();
					expect( testClass.$once("readSQL") ).toBeTrue();
					expect( DataGateway.$once("read") ).toBeTrue();

					expect( result ).toBeTypeOf( "query" );
				});


				// readByJoin()
				it( "returns a query of records from a join", function(){
					var relationship = {
						bean = "test",
						fkColumn = "test",
						fksqltype = "test"
					};

					var result = testClass.readByJoin( beanid=1, relationship=relationship );

					expect( DataFactory.$once("getBeanMap") ).toBeTrue();
					expect( testClass.$once("readByJoinSQL") ).toBeTrue();
					expect( DataGateway.$once("readByJoin") ).toBeTrue();

					expect( result ).toBeTypeOf( "query" );
				});


				// update()
				it( "updates a record", function(){
					var result = testClass.update( beanname="user", bean=userBean );

					expect( DataFactory.$once("getBeanMap") ).toBeTrue();
					expect( testClass.$once("updateSQL") ).toBeTrue();
					expect( testClass.$once("getPropertyParams") ).toBeTrue();
					expect( DataGateway.$once("update") ).toBeTrue();
				});

			});

		});

	}

}

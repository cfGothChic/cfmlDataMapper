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
					schema = "",
					table = "users",
					primarykey = "id",
					orderby = "name",
					properties = {
						id = {
							name = "id",
							columnname = "",
							displayname = "ID",
							insert = true,
							datatype = "integer",
							sqltype = "cf_sql_integer",
							"null" = true,
							isidentity = true
						},
						email = {
							name = "email",
							columnname = "",
							displayname = "Email",
							insert = true,
							datatype = "string",
							sqltype = "cf_sql_varchar",
							"null" = true
						}
					}
				};

				userBean = createMock("model.beans.user");

				makePublic( testClass, "getServerType" );
				makePublic( testClass, "isNullInteger" );
			});


			// getServerType()
			it( "returns the default server type", function(){
				var result = testClass.getServerType();

				expect( result ).toBeTypeOf( "string" );
				expect( result ).toBe( "mssql" );
			});


			it( "returns server type from the config variable", function(){
				testClass.$property( propertyName="dataFactoryConfig", mock={ serverType = "mysql" } );

				var result = testClass.getServerType();

				expect( result ).toBeTypeOf( "string" );
				expect( result ).toBe( "mysql" );
			});


			it( "throws an error if the server type config variable is invalid", function(){
				testClass.$property( propertyName="dataFactoryConfig", mock={ serverType = "test" } );

				expect( function(){ testClass.getServerType(); } )
					.toThrow(type="application", regex="(serverType)");
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

			describe("determines the sql server type", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getServerTypeService" );

					MSSQLService = createEmptyMock("cfmlDataMapper.model.services.mssql");
					testClass.$property( propertyName="MSSQLService", mock=MSSQLService );

					MySQLService = createEmptyMock("cfmlDataMapper.model.services.mysql");
					testClass.$property( propertyName="MySQLService", mock=MySQLService );
				});


				// getServerTypeService()
				it( "to be mssql and returns the MSSQLService component", function(){
					testClass.$( "getServerType", "mssql" );

					var result = testClass.getServerTypeService();

					expect( testClass.$once("getServerType") ).toBeTrue();

					expect( result ).toBeTypeOf( "component" );
					expect( result ).toBeInstanceOf( "cfmlDataMapper.model.services.mssql" );
				});


				it( "to be mysql and returns the MySQLService component", function(){
					testClass.$( "getServerType", "mysql" );

					var result = testClass.getServerTypeService();

					expect( testClass.$once("getServerType") ).toBeTrue();

					expect( result ).toBeTypeOf( "component" );
					expect( result ).toBeInstanceOf( "cfmlDataMapper.model.services.mysql" );
				});

			});


			describe("compiles sql from beanmap information and", function(){

				beforeEach(function( currentSpec ){
					MSSQLService.$( "getCreateNewId", "" )
						.$( "getCreateSetNewId", "" )
						.$( "getCreateValues", "" )
						.$( "getPropertyField", "" )
						.$( "getSelectAsField", "" )
						.$( "getTableName", "" );

					testClass.$( "getServerTypeService", MSSQLService )
						.$( "getFields", "[users].[email]" )
						.$( "getFullOrderBy", "[id] ASC" )
						.$( "getPrimaryKeyField", "[id]" )
						.$( "getWhereStatement", "WHERE" );
				});


				// createSQL()
				it( "returns a create sql statement with identity", function(){
					var result = testClass.createSQL( beanmap=beanmap );

					expect( testClass.$once("getPrimaryKeyField") ).toBeTrue();
					expect( testClass.$count("getServerTypeService") ).toBe( 4 );
					expect( MSSQLService.$once("getTableName") ).toBeTrue();
					expect( MSSQLService.$once("getCreateSetNewId") ).toBeTrue();
					expect( testClass.$count("getFields") ).toBe( 2 );
					expect( MSSQLService.$once("getCreateValues") ).toBeTrue();
					expect( MSSQLService.$once("getCreateNewId") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(INSERT)" );
					expect( result ).notToMatch( "(id,)" );
				});


				it( "returns a create sql statement without identity", function(){
					beanmap.properties.id.isidentity = false;

					var result = testClass.createSQL( beanmap=beanmap );

					expect( testClass.$once("getPrimaryKeyField") ).toBeTrue();
					expect( testClass.$count("getServerTypeService") ).toBe( 4 );
					expect( MSSQLService.$once("getTableName") ).toBeTrue();
					expect( MSSQLService.$once("getCreateSetNewId") ).toBeTrue();
					expect( testClass.$count("getFields") ).toBe( 2 );
					expect( MSSQLService.$once("getCreateValues") ).toBeTrue();
					expect( MSSQLService.$once("getCreateNewId") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(INSERT)" );
					expect( result ).toMatch( "(id,)" );
				});


				it( "returns a create sql statement without identity and has a columnname", function(){
					beanmap.properties.id.isidentity = false;
					beanmap.properties.id.columnname = "userid";

					var result = testClass.createSQL( beanmap=beanmap );

					expect( testClass.$once("getPrimaryKeyField") ).toBeTrue();
					expect( testClass.$count("getServerTypeService") ).toBe( 4 );
					expect( MSSQLService.$once("getTableName") ).toBeTrue();
					expect( MSSQLService.$once("getCreateSetNewId") ).toBeTrue();
					expect( testClass.$count("getFields") ).toBe( 2 );
					expect( MSSQLService.$once("getCreateValues") ).toBeTrue();
					expect( MSSQLService.$once("getCreateNewId") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(INSERT)" );
					expect( result ).toMatch( "(userid,)" );
				});


				// deleteByNotInSQL()
				it( "returns a delete by not in list sql statement", function(){
					var result = testClass.deleteByNotInSQL( beanmap=beanmap, pkproperty=beanmap.properties.id );

					expect( MSSQLService.$once("getTableName") ).toBeTrue();
					expect( MSSQLService.$once("getPropertyField") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(DELETE)" );
					expect( result ).toMatch( "(WHERE)" );
					expect( result ).toMatch( "(NOT)" );
				});


				// deleteSQL()
				it( "returns a delete sql statement", function(){
					var result = testClass.deleteSQL( beanmap=beanmap );

					expect( MSSQLService.$once("getTableName") ).toBeTrue();
					expect( testClass.$once("getPrimaryKeyField") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(DELETE)" );
					expect( result ).toMatch( "(WHERE)" );
				});


				// readByJoinSQL()
				it( "returns a select sql statement with a join table", function(){
					var relationship = {
						joinSchema = "",
						joinTable = "user_roles",
						joinColumn = "roleId",
						fkColumn = "userId"
					};

					var result = testClass.readByJoinSQL( beanmap=beanmap, relationship=relationship );

					expect( MSSQLService.$once("getTableName") ).toBeTrue();
					expect( testClass.$once("getPrimaryKeyField") ).toBeTrue();
					expect( testClass.$once("getFields") ).toBeTrue();
					expect( testClass.$once("getFullOrderBy") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(SELECT)" );
					expect( result ).toMatch( "(FROM)" );
					expect( result ).toMatch( "(JOIN)" );
					expect( result ).toMatch( "(ON)" );
					expect( result ).toMatch( "(WHERE)" );
					expect( result ).toMatch( "(ORDER)" );
				});


				// readSQL()
				it( "returns a select sql statement", function(){
					var result = testClass.readSQL( beanmap=beanmap, sqlparams={}, orderby="", pkOnly=false );

					expect( MSSQLService.$once("getTableName") ).toBeTrue();
					expect( testClass.$once("getFields") ).toBeTrue();
					expect( testClass.$never("getWhereStatement") ).toBeTrue();
					expect( testClass.$once("getFullOrderBy") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(SELECT)" );
					expect( result ).toMatch( "(FROM)" );
					expect( result ).notToMatch( "(WHERE)" );
					expect( result ).toMatch( "(ORDER)" );
				});


				it( "returns a select sql statement with param filters", function(){
					var result = testClass.readSQL( beanmap=beanmap, sqlparams={ email="test" }, orderby="", pkOnly=false );

					expect( MSSQLService.$once("getTableName") ).toBeTrue();
					expect( testClass.$once("getFields") ).toBeTrue();
					expect( testClass.$once("getWhereStatement") ).toBeTrue();
					expect( testClass.$once("getFullOrderBy") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(SELECT)" );
					expect( result ).toMatch( "(FROM)" );
					expect( result ).toMatch( "(WHERE)" );
					expect( result ).toMatch( "(ORDER)" );
				});


				// updateSQL()
				it( "returns an update sql statement", function(){
					var result = testClass.updateSQL( beanmap=beanmap );

					expect( MSSQLService.$once("getTableName") ).toBeTrue();
					expect( testClass.$once("getFields") ).toBeTrue();
					expect( testClass.$once("getPrimaryKeyField") ).toBeTrue();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(UPDATE)" );
					expect( result ).toMatch( "(SET)" );
					expect( result ).toMatch( "(WHERE)" );
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
					var result = testClass.delete( beanname="user", id=1 );

					expect( DataFactory.$once("getBeanMap") ).toBeTrue();
					expect( testClass.$once("deleteSQL") ).toBeTrue();
					expect( DataGateway.$once("delete") ).toBeTrue();
				});


				// deleteByNotIn()
				it( "deletes a list of records", function(){
					var result = testClass.deleteByNotIn( beanname="user", key="id", list="1,2,3" );

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

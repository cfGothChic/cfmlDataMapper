component accessors="true" extends="testbox.system.BaseSpec"{


	function beforeAll() {
		testClass = createMock("cfmlDataMapper.model.factory.data");

		departmentBean = createMock("model.beans.department");
		userBean = createMock("model.beans.user");
		userTypeBean = createMock("model.beans.userType");

		beanFactory = createEmptyMock("framework.ioc");
		beanFactory.$( "getBean" ).$args( "departmentBean" ).$results( departmentBean )
			.$( "getBean" ).$args( "userBean" ).$results( userBean )
			.$( "getBean" ).$args( "userTypeBean" ).$results( userTypeBean );
		testClass.$property( propertyName="beanFactory", mock=beanFactory );

		cacheService = createEmptyMock("cfmlDataMapper.model.services.cache");
		testClass.$property( propertyName="cacheService", mock=cacheService );

		dataGateway = createEmptyMock("cfmlDataMapper.model.gateways.data");
		testClass.$property( propertyName="dataGateway", mock=dataGateway );

		utilityService = createEmptyMock("cfmlDataMapper.model.services.utility");
		utilityService.$( "upperFirst", "Test" );
		testClass.$property( propertyName="utilityService", mock=utilityService );
	}

	function run() {

		describe("The Data Factory", function(){

			beforeEach(function( currentSpec ){
				frameworkone = createEmptyMock("framework.one");
			});


			describe("initializes and", function(){

				beforeEach(function( currentSpec ){
					testClass.init(frameworkone,utilityService);
				});


				describe("uses the beanmap and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "addInheritanceMapping" );
						makePublic( testClass, "checkBeanExists" );
					});


					// getBeanMap()
					it( "returns a structure of metadata related to a bean", function(){
						var result = testClass.getBeanMap( bean="user" );

						expect( result ).toBeTypeOf( "struct" );
						expect( result ).toHaveKey( "bean" );
						expect( result.bean ).toBe( "user" );
					});


					// checkBeanExists()
					it( "returns true if the bean is in the bean map", function(){
							var result = testClass.checkBeanExists( beanname="user" );

							expect( result ).toBeTypeOf( "boolean" );
							expect( result ).toBeTrue();
					});


					it( "errors if the bean is not in the bean map", function(){
						expect( function(){ testClass.checkBeanExists( beanname="test" ); } ).toThrow(type="application", regex="(test)");
					});

				});


				// getModuleBean()
				describe("uses fw1 and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getModuleBean" );

						frameworkone.$( "getDefaultBeanFactory", beanFactory )
							.$( "getSubsystemBeanFactory", beanFactory );

						testClass.$property( propertyName="fw", mock=frameworkone );

						testClass.$( "checkBeanExists", true );
					});


					it( "returns a bean from the model", function(){
						var result = testClass.getModuleBean( bean="user" );

						expect( testClass.$once("checkBeanExists") ).toBeTrue();
						expect( frameworkone.$once("getDefaultBeanFactory") ).toBeTrue();
						expect( frameworkone.$once("getSubsystemBeanFactory") ).toBeFalse();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns a bean from a subsystem", function(){
						var result = testClass.getModuleBean( bean="security.userType" );

						expect( testClass.$once("checkBeanExists") ).toBeTrue();
						expect( frameworkone.$once("getDefaultBeanFactory") ).toBeFalse();
						expect( frameworkone.$once("getSubsystemBeanFactory") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.userType" );
					});

				});


				describe("takes", function(){

					beforeEach(function( currentSpec ){
						beanFactory.$( "injectProperties" );

						userBean.$( "getId", 1 );
						testClass.$( "getModuleBean", userBean );
					});


					describe("a custom query and", function(){

						beforeEach(function( currentSpec ){
							qRecords = querySim("id
								1");
						});


						// getBeans()
						it( "returns an array of beans", function(){
							var result = testClass.getBeans( bean="user", qRecords=qRecords );

							expect( testClass.$once("getModuleBean") ).toBeTrue();
							expect( beanFactory.$atLeast(1, "injectProperties") ).toBeTrue();

							expect( result ).toBeTypeOf( "array" );
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});


						// getBeanStruct() {
						it( "returns a structure by id of beans", function(){
							var result = testClass.getBeanStruct( bean="user", qRecords=qRecords );

							expect( testClass.$once("getModuleBean") ).toBeTrue();
							expect( beanFactory.$atLeast(1, "injectProperties") ).toBeTrue();

							expect( result ).toBeTypeOf( "struct" );
							expect( structCount(result) ).toBe( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});

					});


					describe("an array of structures and", function(){

						beforeEach(function( currentSpec ){
							beansArray = [{ id = 1 }];
						});


						// getBeansFromArray()
						it( "returns an array of beans", function(){
							var result = testClass.getBeansFromArray( bean="user", beansArray=beansArray );

							expect( testClass.$once("getModuleBean") ).toBeTrue();
							expect( beanFactory.$atLeast(1, "injectProperties") ).toBeTrue();

							expect( result ).toBeTypeOf( "array" );
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});

					});

				});


				// getByParams()
				describe("calls getByParams() and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getByParams" );

						cacheService.$( "get", { success = false });

						testClass.$( "checkBeanExists", true );
					});


					it( "returns an empty bean when nothing matches the param criteria", function(){
						dataGateway.$( "read", querySim("") );

						var result = testClass.getByParams( beanname="user", params={} );

						expect( testClass.$once("checkBeanExists") ).toBeTrue();
						expect( dataGateway.$once("read") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns a populated bean that meets the param criteria", function(){
						dataGateway.$( "read", querySim("id
							1") );

						userTypeBean.$( "populateBean" );
						cacheService.$( "get", {
							success = true,
							bean = userTypeBean
						});

						var result = testClass.getByParams( beanname="userType", params={} );

						expect( testClass.$once("checkBeanExists") ).toBeTrue();
						expect( dataGateway.$once("read") ).toBeTrue();
						expect( userTypeBean.$once("populateBean") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.userType" );
					});

				});


				// get()
				describe("calls get() and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "getByParams", departmentBean );
						testClass.$( "getModuleBean", userBean );
					});


					it( "returns a bean from the cacheService", function(){
						cacheService.$( "get", {
							success = true,
							bean = userTypeBean
						});

						var result = testClass.get( bean="userType" );

						expect( cacheService.$once("get") ).toBeTrue();
						expect( testClass.$once("getByParams") ).toBeFalse();
						expect( testClass.$once("getModuleBean") ).toBeFalse();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.userType" );
					});


					it( "returns a bean filtered by params", function(){
						cacheService.$( "get", { success = false });

						var result = testClass.get( bean="userType", params={ foo="bar" } );

						expect( cacheService.$once("get") ).toBeTrue();
						expect( testClass.$once("getByParams") ).toBeTrue();
						expect( testClass.$once("getModuleBean") ).toBeFalse();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.department" );
					});


					it( "returns a bean from the model", function(){
						cacheService.$( "get", { success = false });

						var result = testClass.get( bean="userType" );

						expect( cacheService.$once("get") ).toBeTrue();
						expect( testClass.$once("getByParams") ).toBeFalse();
						expect( testClass.$once("getModuleBean") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});

				});


				// list()
				describe("calls list() and", function(){

					beforeEach(function( currentSpec ){
						dataGateway.$( "read", querySim("") );

						testClass.$( "getBeans", [userBean] );
					});


					it( "errors if the singular argument is passed in", function(){
						expect( function(){ testClass.list( bean="userType", singular=true ); } ).toThrow(type="application", regex="(singular)");
					});


					it( "returns an array of beans from the cacheService", function(){
						cacheService.$( "list", {
							success = true,
							beans = [userTypeBean]
						});

						var result = testClass.list( bean="userType" );

						expect( cacheService.$once("list") ).toBeTrue();
						expect( testClass.$once("getBeans") ).toBeFalse();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.userType" );
					});


					it( "returns an array of beans from the model", function(){
						cacheService.$( "list", { success = false });

						var result = testClass.list( bean="userType" );

						expect( cacheService.$once("list") ).toBeTrue();
						expect( testClass.$once("getBeans") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.user" );
					});

				});


				// hasBean()
				describe("calls hasBean() and", function(){

					it( "returns true when a bean exists in the model", function(){
						var result = testClass.hasBean( beanname="userType" );

						expect( result ).toBeTrue();
					});


					it( "returns false when a bean doesn't exist in the model", function(){
						var result = testClass.hasBean( beanname="test" );

						expect( result ).toBeFalse();
					});

				});

			});


			describe("uses bean metadata and", function(){

				beforeEach(function( currentSpec ){
					testClass.init(frameworkone,utilityService);

					metadata = {
						table = "users",
						primarykey = "id",
						name = "model.beans.adminuser",
						fullname = "model.beans.adminuser",
						extends = {
							fullname = "cfmlDataMapper.model.base.bean"
						},
						properties = [{
							name = "id",
							cfsqltype = "integer"
						},{
							name = "userType",
							bean = "userType"
						}]
					};

					makePublic( testClass, "createBeanMap" );
					makePublic( testClass, "getBeanMapMetadata" );
					makePublic( testClass, "getCfSqlType" );
					makePublic( testClass, "getDatatype" );
					makePublic( testClass, "getInheritanceMetadata" );
					makePublic( testClass, "getPropertyMetadata" );
					makePublic( testClass, "getRelationshipMetadata" );
				});


				afterEach(function( currentSpec ){
					metadata.fullname = "model.beans.adminuser";
				});


				// addInheritanceMapping()
				it( "adds inheritance mapping to a bean", function(){
					testClass.$( "getBeanMap", {
						bean = "user",
						properties = {
							name = "id"
						},
						relationships = {
							name = "userType"
						}
					});

					testClass.addInheritanceMapping( bean="adminuser" );

					expect( testClass.$once("getBeanMap") ).toBeTrue();
				});


				// getInheritanceMetadata()
				it( "returns an empty string if nothing is being inherited", function(){
					var result = testClass.getInheritanceMetadata( metadata=metadata );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns the bean name being inherited", function(){
					metadata.extends.fullname = "model.beans.user";

					var result = testClass.getInheritanceMetadata( metadata=metadata );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "user" );
				});


				it( "returns the subsystem bean name being inherited", function(){
					metadata.fullname = "security.model.beans.adminuser";
					metadata.extends.fullname = "security.model.beans.user";

					var result = testClass.getInheritanceMetadata( metadata=metadata );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "security.user" );
				});


				// getPropertyMetadata()
				it( "returns an empty structure if the property is not a data factory column definition", function(){
					var result = testClass.getPropertyMetadata( prop={} );

					expect( result ).toBeTypeOf( "struct" );
					expect( structCount(result) ).toBe( 0 );
				});


				it( "returns a structure of a bean column property's metadata", function(){
					var result = testClass.getPropertyMetadata( prop=metadata.properties[1] );

					expect( result ).toBeTypeOf( "struct" );
					expect( structCount(result) ).toBe( 15 );
					expect( result ).toHaveKey( "name" );
					expect( result ).toHaveKey( "defaultvalue" );
					expect( result ).toHaveKey( "displayname" );
					expect( result ).toHaveKey( "columnName" );
					expect( result ).toHaveKey( "insert" );
					expect( result ).toHaveKey( "isidentity" );
					expect( result ).toHaveKey( "null" );
					expect( result ).toHaveKey( "sqltype" );
					expect( result ).toHaveKey( "valtype" );
					expect( result ).toHaveKey( "regex" );
					expect( result ).toHaveKey( "minvalue" );
					expect( result ).toHaveKey( "maxvalue" );
					expect( result ).toHaveKey( "minlength" );
					expect( result ).toHaveKey( "maxlength" );
					expect( result ).toHaveKey( "datatype" );
				});


				// getCfSqlType()
				it( "returns the full queryparam cfsqltype declaration", function(){
					var result = testClass.getCfSqlType( sqltype="int" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "cf_sql_integer" );
				});


				// getDatatype()
				it( "returns the datatype when there is a valtype property declaration", function(){
					var result = testClass.getDatatype( valtype="email", sqltype="cf_sql_varchar" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "email" );
				});


				it( "returns the boolean datatype for the cf_sql_bit sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_bit" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "boolean" );
				});


				it( "returns the string datatype for the cf_sql_varchar sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_varchar" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "string" );
				});


				it( "returns the string datatype for the cf_sql_nvarchar sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_nvarchar" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "string" );
				});


				it( "returns the string datatype for the cf_sql_text sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_text" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "string" );
				});


				it( "returns the string datatype for the cf_sql_ntext sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_ntext" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "string" );
				});


				it( "returns the numeric datatype for the cf_sql_integer sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_integer" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "numeric" );
				});


				it( "returns the numeric datatype for the cf_sql_float sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_float" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "numeric" );
				});


				it( "returns the any datatype when no types are passed in", function(){
					var result = testClass.getDatatype( valtype="", sqltype="" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "any" );
				});


				// getRelationshipMetadata()
				it( "returns an empty structure if the property is not a data factory relationship definition", function(){
					var result = testClass.getRelationshipMetadata( prop={} );

					expect( result ).toBeTypeOf( "struct" );
					expect( structCount(result) ).toBe( 0 );
				});


				it( "returns a structure of a bean relationship's metadata", function(){
					var result = testClass.getRelationshipMetadata( prop=metadata.properties[2] );

					expect( result ).toBeTypeOf( "struct" );
					expect( structCount(result) ).toBe( 10 );
					expect( result ).toHaveKey( "name" );
					expect( result ).toHaveKey( "bean" );
					expect( result ).toHaveKey( "joinType" );
					expect( result ).toHaveKey( "contexts" );
					expect( result ).toHaveKey( "fkColumn" );
					expect( result ).toHaveKey( "fkName" );
					expect( result ).toHaveKey( "fksqltype" );
					expect( result ).toHaveKey( "joinSchema" );
					expect( result ).toHaveKey( "joinTable" );
					expect( result ).toHaveKey( "joinColumn" );
				});


				// getBeanMapMetadata()
				it( "creates a basic structure of object metadata for a bean without a table definition", function(){
					var result = testClass.getBeanMapMetadata( metadata={} );

					expect( result ).toBeTypeOf( "struct" );
					expect( structCount(result) ).toBe( 1 );
					expect( result ).toHaveKey( "cached" );
				});


				it( "creates a structure of object metadata for a bean with a table definition", function(){
					var result = testClass.getBeanMapMetadata( metadata=metadata );

					expect( result ).toBeTypeOf( "struct" );
					expect( structCount(result) ).toBe( 8 );
					expect( result ).toHaveKey( "table" );
					expect( result ).toHaveKey( "primarykey" );
					expect( result ).toHaveKey( "orderby" );
					expect( result ).toHaveKey( "schema" );
					expect( result ).toHaveKey( "cached" );
					expect( result ).toHaveKey( "cacheparams" );
					expect( result ).toHaveKey( "cacheparamdefault" );
					expect( result ).toHaveKey( "cacheparamwild" );
				});


				it( "errors if the cacheparams are not a json array of structures", function(){
					metadata.cached = true;
					metadata.cacheparams = "[]";

					expect( function(){ testClass.getBeanMapMetadata( metadata=metadata ); } ).toThrow(type="application", regex="(cacheparams)");
				});


				// createBeanMap()
				it( "creates a basic structure of metadata for a bean", function(){
					testClass.$( "getBeanMapMetadata", {} )
						.$( "getInheritanceMetadata", "" );

					testClass.createBeanMap( name="user", metadata={} );

					expect( testClass.$once("getBeanMapMetadata") ).toBeTrue();
					expect( testClass.$once("getInheritanceMetadata") ).toBeTrue();
				});


				it( "creates a complex structure of metadata for a bean", function(){
					testClass.$( "getBeanMapMetadata", {} )
						.$( "getInheritanceMetadata", "" )
						.$( "getPropertyMetadata", {} )
						.$( "getRelationshipMetadata", {} );

					testClass.createBeanMap( name="user", metadata=metadata );

					expect( testClass.$once("getBeanMapMetadata") ).toBeTrue();
					expect( testClass.$once("getInheritanceMetadata") ).toBeTrue();
					expect( testClass.$atLeast(1, "getPropertyMetadata") ).toBeTrue();
					expect( testClass.$atLeast(1, "getRelationshipMetadata") ).toBeTrue();
				});

			});


			describe("interacts with the file system and", function(){

				beforeEach(function( currentSpec ){
					testClass.init(frameworkone,utilityService);

					makePublic( testClass, "cacheBeanMetadata" );
					makePublic( testClass, "readBeanDirectory" );
				});


				// readBeanDirectory()
				it( "reads a model bean directory to find beans setup for the data factory", function(){
					testClass.$( "createBeanMap" );

					testClass.readBeanDirectory( beanpath="/model/beans/" );

					expect( testClass.$atLeast(1, "createBeanMap") ).toBeTrue();
				});


				// cacheBeanMetadata()
				it( "calls a function to read the bean directory", function(){
					testClass.$( "readBeanDirectory" );

					testClass.cacheBeanMetadata();

					expect( testClass.$once("readBeanDirectory") ).toBeTrue();
				});

			});


			// init()
			describe("on initialization", function(){

				it( "should cache the model's bean metadata", function(){
					testClass.$( "cacheBeanMetadata" );

					var result = testClass.init(frameworkone,utilityService);

					expect( testClass.$once("cacheBeanMetadata") ).toBeTrue();
					expect( result ).toBeInstanceOf( "cfmlDataMapper.model.factory.data" );
				});

			});

		});

	}

}

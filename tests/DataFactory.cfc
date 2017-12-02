component accessors="true" extends="testbox.system.BaseSpec"{


	function beforeAll() {
		testClass = createMock("cfmlDataMapper.model.factory.data");

		departmentBean = createMock("model.beans.department");
		userBean = createMock("model.beans.user");
		userTypeBean = createMock("model.beans.userType");
	}

	function run() {

		describe("The Data Factory", function(){

			beforeEach(function( currentSpec ){
				frameworkone = createEmptyMock("cfmlDataMapper.samples.framework.one");
			});


			describe("initializes and", function(){

				beforeEach(function( currentSpec ){
					testClass.init(frameworkone);
				});


				// getBeanMap()
				it( "returns a structure of metadata related to a transient bean", function(){
					var result = testClass.getBeanMap( bean="user" );

					expect( result ).toBeTypeOf( "struct" );
					expect( structKeyExists(result, "bean") ).toBeTrue();
					expect( result.bean ).toBe( "user" );
				});


				// cacheBeanMetadata()
				it( "caches a structure of metadata for all the beans it finds with dataFactory notation", function(){

				});


				// checkBeanExists()
				it( "returns true if the bean is in the bean map", function(){

				});


				it( "errors if the bean is not in the bean map", function(){

				});


				// createBeanMap()
				it( "creates a structure of metadata for a bean", function(){

				});


				// getBeanMapMetadata()
				it( "creates a structure of object metadata for a bean", function(){

				});


				// getByParams()
				it( "returns a transient bean that meets the param criteria", function(){

				});


				// getCfSqlType()
				it( "returns a string of the full queryparam cfsqltype declaration", function(){

				});


				// getDatatype()
				it( "returns a string with the datatype of a property related to what its cfsqltype is", function(){

				});


				// getInheritanceMetadata()
				it( "returns a string with the name of the bean being inherited", function(){

				});


				// getModuleBean()
				it( "returns a transient bean from the correct subsystem", function(){

				});


				// getPropertyMetadata()
				it( "returns a structure of a bean property's metadata", function(){

				});


				// getRelationshipMetadata()
				it( "returns a structure of a bean relationship's metadata", function(){

				});


				// readBeanDirectory()
				it( "reads a model bean directory to find beans setup for the data factory", function(){

				});


				// upperFirst()
				it( "returns a string with the first letter capitalized", function(){

				});


				describe("takes", function(){

					beforeEach(function( currentSpec ){
						beanFactory = createEmptyMock("cfmlDataMapper.samples.framework.ioc");
						beanFactory.$( "injectProperties" );
						testClass.$property( propertyName="beanFactory", mock=beanFactory );

						userBean.$( "getId", 1 );
						testClass.$( "getModuleBean", userBean );
					});


					describe("a custom query and", function(){

						beforeEach(function( currentSpec ){
							qRecords = querySim("id
								1");
						});


						// getBeans()
						it( "returns an array of transient beans", function(){
							var result = testClass.getBeans( bean="user", qRecords=qRecords );

							expect( testClass.$once("getModuleBean") ).toBeTrue();
							expect( beanFactory.$atLeast(1, "injectProperties") ).toBeTrue();

							expect( result ).toBeTypeOf( "array" );
							expect( arrayLen(result) ).toBe( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});


						// getBeanStruct() {
						it( "returns a structure by id of transient beans", function(){
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
						it( "returns an array of transient beans", function(){
							var result = testClass.getBeansFromArray( bean="user", beansArray=beansArray );

							expect( testClass.$once("getModuleBean") ).toBeTrue();
							expect( beanFactory.$atLeast(1, "injectProperties") ).toBeTrue();

							expect( result ).toBeTypeOf( "array" );
							expect( arrayLen(result) ).toBe( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});

					});

				});

				// get()
				describe("calls get() and", function(){

					beforeEach(function( currentSpec ){
						cacheService = createEmptyMock("cfmlDataMapper.model.services.cache");

						testClass.$( "getByParams", departmentBean );
						testClass.$( "getModuleBean", userBean );
					});


					it( "returns a transient bean from the cacheService", function(){
						cacheService.$( "get", {
							success = true,
							bean = userTypeBean
						});
						testClass.$property( propertyName="cacheService", mock=cacheService );

						var result = testClass.get( bean="userType" );

						expect( cacheService.$once("get") ).toBeTrue();
						expect( testClass.$once("getByParams") ).toBeFalse();
						expect( testClass.$once("getModuleBean") ).toBeFalse();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.userType" );
					});


					it( "returns a transient bean filtered by params", function(){
						cacheService.$( "get", { success = false });
						testClass.$property( propertyName="cacheService", mock=cacheService );

						var result = testClass.get( bean="userType", params={ foo="bar" } );

						expect( cacheService.$once("get") ).toBeTrue();
						expect( testClass.$once("getByParams") ).toBeTrue();
						expect( testClass.$once("getModuleBean") ).toBeFalse();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.department" );
					});


					it( "returns a transient bean from the model", function(){
						cacheService.$( "get", { success = false });
						testClass.$property( propertyName="cacheService", mock=cacheService );

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
						cacheService = createEmptyMock("cfmlDataMapper.model.services.cache");

						dataGateway = createEmptyMock("cfmlDataMapper.model.gateways.data");
						dataGateway.$( "read", querySim("") );
						testClass.$property( propertyName="dataGateway", mock=dataGateway );

						testClass.$( "getBeans", [userBean] );
					});


					it( "errors if the singular argument is passed in", function(){
						expect( function(){ testClass.list( bean="userType", singular=true ); } ).toThrow(type="application", regex="(singular)");
					});


					it( "returns an array of transient beans from the cacheService", function(){
						cacheService.$( "list", {
							success = true,
							beans = [userTypeBean]
						});
						testClass.$property( propertyName="cacheService", mock=cacheService );

						var result = testClass.list( bean="userType" );

						expect( cacheService.$once("list") ).toBeTrue();
						expect( testClass.$once("getBeans") ).toBeFalse();

						expect( result ).toBeTypeOf( "array" );
						expect( arrayLen(result) ).toBe( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.userType" );
					});


					it( "returns an array of transient beans from the model", function(){
						cacheService.$( "list", { success = false });
						testClass.$property( propertyName="cacheService", mock=cacheService );

						var result = testClass.list( bean="userType" );

						expect( cacheService.$once("list") ).toBeTrue();
						expect( testClass.$once("getBeans") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( arrayLen(result) ).toBe( 1 );
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

			describe("exposes private methods and", function(){

				beforeEach(function( currentSpec ){
					testClass.init(frameworkone);
				});


				// addInheritanceMapping()
				it( "adds inheritance mapping to a transient bean", function(){
					testClass.$( "getBeanMap", {
						bean = "user",
						properties = {
							name = "id"
						},
						relationships = {
							name = "userType"
						}
					});

					makePublic( testClass, "addInheritanceMapping" );
					testClass.addInheritanceMapping( bean="adminuser" );

					expect( testClass.$once("getBeanMap") ).toBeTrue();
				});

			});


			// init()
			xit( "should cache the model's bean metadata on initialization", function(){
				testClass.init(frameworkone);
			});

		});

	}

}

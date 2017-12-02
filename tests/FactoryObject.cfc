component accessors="true" extends="testbox.system.BaseSpec"{


	function beforeAll(){
		testClass = createMock("cfmlDataMapper.factory");
	}


	function run() {


		describe("The Factory Object", function(){


			// validateConfig()
			describe("validates the data factory config and", function(){


				it( "succeeds if all required variables are present", function(){
					var config = {
						dsn = "test",
						locations = "/test"
					};
					testClass.init(config);
				});


				it( "errors if the dsn variable is not present", function(){
					var config = {
						locations = "/test"
					};

					expect( function(){ testClass.init(config); } ).toThrow(type="application", regex="(dsn)");
				});


				it( "errors if the locations variable is not present", function(){
					var config = {
						dsn = "test"
					};

					expect( function(){ testClass.init(config); } ).toThrow(type="application", regex="(locations)");
				});


			});


			describe("initializes and", function(){


				beforeEach(function( currentSpec ){
					beanModalLocation = "/model";

					var config = {
						dsn = "test",
						locations = beanModalLocation
					};
					testClass.init(config);
				});


				// _get_framework_one()
				it( "initializes fw1 and returns it as an object", function(){
					makePublic( testClass, "_get_framework_one" );

					var result = testClass._get_framework_one();

					expect( result ).toBeInstanceOf( "cfmlDataMapper.samples.framework.one" );
				});


				// getConstants()
				it( "returns a structure of constants for the framework config", function(){
					makePublic( testClass, "getConstants" );

					var result = testClass.getConstants();

					expect( result ).toBeTypeOf( "struct" );
					expect( structKeyExists(result, "dsn") ).toBeTrue();
				});


				// getFrameworkConfig()
				it( "returns a structure of the framework config", function(){
					makePublic( testClass, "getFrameworkConfig" );

					var result = testClass.getFrameworkConfig();

					expect( result ).toBeTypeOf( "struct" );
					expect( structKeyExists(result, "diConfig") ).toBeTrue();
					expect( structKeyExists(result.diConfig, "constants") ).toBeTrue();
					expect( structKeyExists(result.diConfig.constants, "dsn") ).toBeTrue();
					expect( structKeyExists(result, "diLocations") ).toBeTrue();
					expect( structKeyExists(result, "reloadApplicationOnEveryRequest") ).toBeTrue();
				});


				it( "returns the framework config with reloadApplicationOnEveryRequest updated with the framework config variable", function(){
					var config = {
						dsn = "test",
						locations = beanModalLocation,
						reloadApplicationOnEveryRequest = true
					};
					testClass.init(config);

					makePublic( testClass, "getFrameworkConfig" );

					var result = testClass.getFrameworkConfig();

					expect( structKeyExists(result, "reloadApplicationOnEveryRequest") ).toBeTrue();
					expect( result.reloadApplicationOnEveryRequest ).toBeTrue();
				});


				// getLocations()
				it( "returns a string of model locations for the framework config", function(){
					makePublic( testClass, "getLocations" );

					var result = testClass.getLocations();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(/model)" );
					expect( result ).toMatch( "(/cfmlDataMapper)" );
				});


				describe("calls fw1 and", function(){


					beforeEach(function( currentSpec ){
						frameworkone = createEmptyMock("cfmlDataMapper.samples.framework.one");
						frameworkone.$( "onRequestStart", true );
					});


					// getFactory()
					it( "returns the model factory object", function(){
						var frameworkioc = createEmptyMock("cfmlDataMapper.samples.framework.ioc");
						var dataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");

						frameworkone.$( "getDefaultBeanFactory", frameworkioc )
							.getDefaultBeanFactory().$( "getBean", dataFactory );
						testClass.$( "_get_framework_one", frameworkone );

						var result = testClass.getFactory();

						expect( testClass.$times(2,"_get_framework_one") ).toBeTrue();
						expect( frameworkone.$once("onRequestStart") ).toBeTrue();
						expect( frameworkone.$atLeast(1, "getDefaultBeanFactory") ).toBeTrue();
						expect( frameworkone.getDefaultBeanFactory().$once("getBean") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "cfmlDataMapper.model.factory.data" );
					});


					// populate()
					it( "calls the fw1 populate function", function(){
						frameworkone.$( "populate" );
						testClass.$( "_get_framework_one", frameworkone );

						testClass.populate();

						expect( testClass.$times(2,"_get_framework_one") ).toBeTrue();
						expect( frameworkone.$once("onRequestStart") ).toBeTrue();
						expect( frameworkone.$once("populate") ).toBeTrue();
					});


				});


				describe("calls the data factory and", function(){


					beforeEach(function( currentSpec ){
						userTypeBean = createEmptyMock("model.beans.userType");
						dataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");

						testClass.$( "getFactory", dataFactory );
					});


					// get()
					it( "returns a transient bean", function(){
						dataFactory.$( "get", userTypeBean );

						var result = testClass.get( bean="userType" );

						expect( result ).toBeTypeOf( "component" );
						expect( dataFactory.$once("get") ).toBeTrue();
						expect( result ).toBeInstanceOf( "model.beans.userType" );
					});


					// list()
					it( "returns an array of transient beans", function(){
						dataFactory.$( "list", [userTypeBean] );

						var result = testClass.list( bean="userType" );

						expect( dataFactory.$once("list") ).toBeTrue();
						expect( result ).toBeTypeOf( "array" );
						expect( arrayLen(result) ).toBe( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.userType" );
					});


					// hasBean()
					it( "returns true when a bean exists in the model", function(){
						dataFactory.$( "hasBean", true );

						var result = testClass.hasBean( bean="userType" );

						expect( dataFactory.$once("hasBean") ).toBeTrue();
						expect( result ).toBeTrue();
					});


					it( "returns false when a bean doesn't exist in the model", function(){
						dataFactory.$( "hasBean", false );

						var result = testClass.hasBean( bean="test" );

						expect( dataFactory.$once("hasBean") ).toBeTrue();
						expect( result ).toBeFalse();
					});


					// getBeanMap()
					it( "returns a structure of metadata related to a transient bean", function(){
						dataFactory.$( "getBeanMap", { table="usertypes" } );

						var result = testClass.getBeanMap( bean="userType" );

						expect( dataFactory.$once("getBeanMap") ).toBeTrue();
						expect( result ).toBeTypeOf( "struct" );
						expect( structKeyExists(result, "table") ).toBeTrue();
					});


					// getBeans()
					it( "returns an array of transient beans from a custom query", function(){
						dataFactory.$( "getBeans", [userTypeBean] );

						var result = testClass.getBeans( bean="userType", qRecords = querySim("") );

						expect( dataFactory.$once("getBeans") ).toBeTrue();
						expect( result ).toBeTypeOf( "array" );
						expect( arrayLen(result) ).toBe( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.userType" );
					});


					// getBeansFromArray()
					it( "returns an array of transient beans from an array of structures", function(){
						dataFactory.$( "getBeansFromArray", [userTypeBean] );

						var result = testClass.getBeansFromArray( bean="userType", beansArray = [{ id = 1 }] );

						expect( dataFactory.$once("getBeansFromArray") ).toBeTrue();
						expect( result ).toBeTypeOf( "array" );
						expect( arrayLen(result) ).toBe( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.userType" );
					});


					// getBeanStruct() {
					it( "returns a structure by id of transient beans from a custom query", function(){
						dataFactory.$( "getBeanStruct", { 1 = userTypeBean } );

						var result = testClass.getBeanStruct( bean="userType", qRecords = querySim("") );

						expect( dataFactory.$once("getBeanStruct") ).toBeTrue();
						expect( result ).toBeTypeOf( "struct" );
						expect( structCount(result) ).toBe( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.userType" );
					});


				});


			});


		});


	}


}

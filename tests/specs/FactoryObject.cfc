component accessors="true" extends="testbox.system.BaseSpec"{

	function run() {

		describe("The Factory Object", function(){

			beforeEach(function( currentSpec ){
				testClass = createMock("cfmlDataMapper.factory");
			});

			describe("initializes and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getConstants" );

					beanModalLocation = "/model";

					config = {
						dsn = "test",
						locations = beanModalLocation
					};
					testClass.init(config);
				});


				// _get_framework_one()
				it( "initializes fw1 and returns it as an object", function(){
					makePublic( testClass, "_get_framework_one" );

					var result = testClass._get_framework_one();

					expect( result ).toBeInstanceOf( "framework.one" );
				});


				// getConstants()
				it( "returns a structure of constants for the framework config", function(){

					var result = testClass.getConstants();

					expect( result ).toBeStruct();
					expect( result ).toHaveLength(2);
					expect( result ).toHaveKey("dsn");
					expect( result ).toHaveKey("dataFactoryConfig");
					expect( result.dataFactoryConfig ).toBeStruct();
					expect( result.dataFactoryConfig ).toHaveKey("serverType");
				});

				it( "returns a structure of constants with supplied config for the framework config", function(){
					config.constants = { "foo"="bar" };
					testClass.init(config);

					var result = testClass.getConstants();

					expect( result ).toBeStruct();
					expect( result ).toHaveLength(3);
					expect( result ).toHaveKey("dsn");
					expect( result ).toHaveKey("dataFactoryConfig");
					expect( result ).toHaveKey("foo");
					expect( result.foo ).toBe("bar");
				});


				// getFrameworkConfig()
				it( "returns a structure of the framework config", function(){
					makePublic( testClass, "getFrameworkConfig" );

					var result = testClass.getFrameworkConfig();

					expect( result ).toBeStruct();
					expect( result ).toHaveLength(5);
					expect( result ).toHaveKey( "applicationKey" );
					expect( result ).toHaveKey( "usingSubsystems" );
					expect( result ).toHaveKey( "diConfig" );
					expect( result.diConfig ).toBeStruct();
					expect( result.diConfig ).toHaveKey( "constants" );
					expect( result.diConfig.constants ).toBeStruct();
					expect( result.diConfig.constants ).toHaveKey( "dsn" );
					expect( result ).toHaveKey( "diLocations" );
					expect( result ).toHaveKey( "reloadApplicationOnEveryRequest" );
				});


				// getLocations()
				it( "returns a string of model locations for the framework config", function(){
					makePublic( testClass, "getLocations" );

					var result = testClass.getLocations();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(#beanModalLocation#)" );
					expect( result ).toMatch( "(/cfmlDataMapper/model)" );
				});


				describe("calls fw1 and", function(){

					beforeEach(function( currentSpec ){
						frameworkone = createEmptyMock("framework.one");
						frameworkone.$( "onRequestStart", true );

						BeanFactory = createEmptyMock("framework.ioc");
					});


					// getBeanFactory()
					it( "returns the bean factory object", function(){
						frameworkone.$( "getDefaultBeanFactory", BeanFactory );
						testClass.$( "_get_framework_one", frameworkone );

						var result = testClass.getBeanFactory();

						expect( testClass.$times(2,"_get_framework_one") ).toBeTrue();
						expect( frameworkone.$once("onRequestStart") ).toBeTrue();
						expect( frameworkone.$atLeast(1, "getDefaultBeanFactory") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
					});

					// getFactory()
					it( "returns the data factory object", function(){
						var DataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");
						BeanFactory.$( "getBean", DataFactory );
						testClass.$( "getBeanFactory", BeanFactory );

						var result = testClass.getFactory();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "cfmlDataMapper.model.factory.data" );

						expect( testClass.$once("getBeanFactory") ).toBeTrue();
						expect( BeanFactory.$once("getBean") ).toBeTrue();
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
						DataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");

						testClass.$( "getFactory", DataFactory );
					});

					// get()
					it( "returns a transient bean", function(){
						DataFactory.$( "get", userTypeBean );

						var result = testClass.get( bean="userType" );

						expect( result ).toBeTypeOf( "component" );
						expect( DataFactory.$once("get") ).toBeTrue();
					});

					// list()
					it( "returns an array of transient beans", function(){
						DataFactory.$( "list", [] );

						var result = testClass.list( bean="userType" );

						expect( result ).toBeArray();
						expect( DataFactory.$once("list") ).toBeTrue();
					});

					// hasBean()
					it( "returns a boolean when checking if a bean exists in the model", function(){
						DataFactory.$( "hasBean", true );

						var result = testClass.hasBean( bean="userType" );

						expect( result ).toBeBoolean();
						expect( DataFactory.$once("hasBean") ).toBeTrue();
					});

					// getBeanMap()
					it( "returns a structure of metadata related to a transient bean", function(){
						DataFactory.$( "getBeanMap", {} );

						var result = testClass.getBeanMap( bean="userType" );

						expect( result ).toBeStruct();
						expect( DataFactory.$once("getBeanMap") ).toBeTrue();
					});

					// getBeansFromQuery()
					it( "returns an array of transient beans from a custom query", function(){
						DataFactory.$( "getBeansFromQuery", [] );

						var result = testClass.getBeansFromQuery( bean="userType", qRecords = querySim("") );

						expect( result ).toBeArray();
						expect( DataFactory.$once("getBeansFromQuery") ).toBeTrue();
					});

					// getBeansFromArray()
					it( "returns an array of transient beans from an array of structures", function(){
						DataFactory.$( "getBeansFromArray", [] );

						var result = testClass.getBeansFromArray( bean="userType", beansArray = [{ id = 1 }] );

						expect( result ).toBeArray();
						expect( DataFactory.$once("getBeansFromArray") ).toBeTrue();
					});

					// getBeansFromQueryAsStruct() {
					it( "returns a structure by id of transient beans from a custom query", function(){
						DataFactory.$( "getBeansFromQueryAsStruct", {} );

						var result = testClass.getBeansFromQueryAsStruct( bean="userType", qRecords = querySim("") );

						expect( result ).toBeStruct();
						expect( DataFactory.$once("getBeansFromQueryAsStruct") ).toBeTrue();
					});

					// getBeanListProperties()
					it( "returns an array of bean property structures from an array of beans", function(){
						DataFactory.$( "getBeanListProperties", [] );

						var result = testClass.getBeanListProperties( beans=[userTypeBean] );

						expect( result ).toBeArray();
						expect( DataFactory.$once("getBeanListProperties") ).toBeTrue();
					});

					// listWithProperties()
					it( "returns an array of bean property structures", function(){
						DataFactory.$( "listWithProperties", [] );

						var result = testClass.listWithProperties( bean="userType" );

						expect( result ).toBeArray();
						expect( DataFactory.$once("listWithProperties") ).toBeTrue();
					});

				});

			});


			// validateConfig()
			describe("validates the data factory config and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "validateConfig" );

					testClass.$( "setFactoryConfig" );
				});


				it( "succeeds if all required variables are present", function(){
					testClass.$( "getFactoryConfig", {
						dsn = "test",
						locations = "/test"
					});

					testClass.validateConfig();

					expect( testClass.$once("setFactoryConfig") ).toBeTrue();
				});


				it( "errors if the dsn variable is not present", function(){
					testClass.$( "getFactoryConfig", {
						locations = "/test"
					});

					expect( function(){ testClass.validateConfig(); } ).toThrow(type="application", regex="(dsn)");
				});


				it( "errors if the locations variable is not present", function(){
					testClass.$( "getFactoryConfig", {
						dsn = "test"
					});

					expect( function(){ testClass.validateConfig(); } ).toThrow(type="application", regex="(locations)");
				});

			});

			// init()
			describe("on initialization", function(){

				it( "should cache and validate the framework config", function(){
					testClass.$( "setFactoryConfig" )
						.$( "validateConfig" );

					var result = testClass.init({});

					expect( testClass.$once("setFactoryConfig") ).toBeTrue();
					expect( testClass.$once("validateConfig") ).toBeTrue();
					expect( result ).toBeInstanceOf( "cfmlDataMapper.factory" );
				});

			});

		});

	}

}

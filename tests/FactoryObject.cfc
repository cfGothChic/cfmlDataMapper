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
					var config = {
						dsn = "test",
						locations = "/test"
					};
					testClass.init(config);
				});

				// _get_framework_one()
				it( "initializes fw1 and returns it as an object", function(){

				});

				// getFactory()
				it( "returns the model factory object", function(){
					var frameworkone = createEmptyMock("cfmlDataMapper.samples.framework.one");
					var frameworkioc = createEmptyMock("cfmlDataMapper.samples.framework.ioc");
					var dataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");
					frameworkone.$( "onRequestStart", true )
						.$( "getDefaultBeanFactory", frameworkioc )
						.getDefaultBeanFactory().$( "getBean", dataFactory );
					testClass.$( "_get_framework_one", frameworkone );

					var factory = testClass.getFactory();
					expect( testClass.$times(2,"_get_framework_one") ).toBeTrue();
					expect( frameworkone.$once("onRequestStart") ).toBeTrue();
					expect( frameworkone.$atLeast(1, "getDefaultBeanFactory") ).toBeTrue();
					expect( frameworkone.getDefaultBeanFactory().$once("getBean") ).toBeTrue();
				});

				// populate()
				it( "calls the fw1 populate function", function(){

				});

				// getConstants()
				it( "returns a structure of constants for the framework config", function(){

				});

				// getFrameworkConfig()
				it( "returns a structure of the framework config", function(){

				});

				// getLocations()
				it( "returns a string of model locations for the framework config", function(){

				});

				describe("calls the data factory and", function(){

					// get()
					it( "returns a transient bean", function(){

					});

					// list()
					it( "returns an array of transient beans", function(){

					});

					// hasBean()
					it( "returns true when a bean exists in the model", function(){

					});

					it( "returns false when a bean doesn't exist in the model", function(){

					});

					// getBeanMap()
					it( "returns a structure of metadata related to a transient bean", function(){

					});

					// getBeans()
					it( "returns an array of transient beans from a custom query", function(){

					});

					// getBeansFromArray()
					it( "returns an array of transient beans from an array of structures", function(){

					});

					// getBeanStruct() {
					it( "returns a structure by id of transient beans from a custom query", function(){

					});

				});

			});

		});

	}

}

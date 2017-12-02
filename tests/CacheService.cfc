component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = createMock("cfmlDataMapper.model.services.cache");
	}

	function run() {

		describe("The Cache Service", function(){

			it( "removes a bean from the cache", function(){

			});

		});

	}

}

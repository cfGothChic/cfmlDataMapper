component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = new cfmlDataMapper.model.services.validation();
		prepareMock( testClass );
	}

	function run() {

		describe("The Validation Service", function(){

			beforeEach(function( currentSpec ){
			});


			// validateByDataType()
			it( "returns an error message if the value doesn't match the data type", function(){

			});


			// validateRange()
			it( "returns an error message if the value is not within the minimum and maximum range", function(){

			});


			// validateZipCode()
			it( "returns an error message if the value is not a properly formatted zip code", function(){

			});


			// validateBean()
			it( "returns an array of error messages after validating a bean's data from the beanmap definition", function(){

			});


		});

	}

}

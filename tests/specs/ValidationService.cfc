component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = new cfmlDataMapper.model.services.validation();
		prepareMock( testClass );
	}

	function run() {

		describe("The Validation Service", function(){

			describe("reads a beanmap property and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "validateByDataType" );
					makePublic( testClass, "validateLength" );
					makePublic( testClass, "validateRange" );
					makePublic( testClass, "validateRegex" );
					makePublic( testClass, "validateZipCode" );
				});


				// validateByDataType()
				it( "returns an empty string if the value is a boolean", function(){
					var result = testClass.validateByDataType( datatype="boolean", value="yes", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value isn't a boolean", function(){
					var result = testClass.validateByDataType( datatype="boolean", value="", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(Age)" );
					expect( result ).toMatch( "(numeric)" );
				});


				it( "returns an empty string if the value is a date", function(){
					var result = testClass.validateByDataType( datatype="timestamp", value=now(), displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value isn't a date", function(){
					var result = testClass.validateByDataType( datatype="timestamp", value="", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(Age)" );
					expect( result ).toMatch( "(date)" );
				});


				it( "returns an empty string if the value is an email address", function(){
					var result = testClass.validateByDataType( datatype="email", value="test@test.com", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value isn't an email address", function(){
					var result = testClass.validateByDataType( datatype="email", value="", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(Age)" );
					expect( result ).toMatch( "(email)" );
				});


				it( "returns an empty string if the value is numeric", function(){
					var result = testClass.validateByDataType( datatype="numeric", value=123, displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value isn't numeric", function(){
					var result = testClass.validateByDataType( datatype="numeric", value="", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(Age)" );
					expect( result ).toMatch( "(numeric)" );
				});


				it( "returns an empty string if the value is a telephone number", function(){
					var result = testClass.validateByDataType( datatype="telephone", value="215-555-5555", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value isn't a telephone number", function(){
					var result = testClass.validateByDataType( datatype="telephone", value="", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(Age)" );
					expect( result ).toMatch( "(telephone)" );
				});


				it( "returns an empty string if the value is a zipcode", function(){
					var result = testClass.validateByDataType( datatype="zipcode", value="12345", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value isn't a zipcode", function(){
					var result = testClass.validateByDataType( datatype="zipcode", value="", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(Age)" );
					expect( result ).toMatch( "(zipcode)" );
				});


				it( "returns an empty string if the datatype is any", function(){
					var result = testClass.validateByDataType( datatype="any", value="test", displayname="Age" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				// validateLength()
				it( "returns an empty string if the value length is within the minimum and maximum length", function(){
					var result = testClass.validateLength( minlength=10, maxlength=50, value="Daria Norris", displayname="Name" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value length is not within the minimum and maximum length", function(){
					var result = testClass.validateLength( minlength=10, maxlength=50, value="Daria", displayname="Name" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(Name)" );
					expect( result ).toMatch( "(between)" );
				});


				it( "returns an empty string if the value length is above the minimum length", function(){
					var result = testClass.validateLength( minlength=10, maxlength="", value="Daria Norris", displayname="Name" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value length is below the minimum length", function(){
					var result = testClass.validateLength( minlength=10, maxlength="", value="Daria", displayname="Name" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(Name)" );
					expect( result ).toMatch( "(longer)" );
				});


				it( "returns an empty string if the value length is below the maximum length", function(){
					var result = testClass.validateLength( minlength="", maxlength=10, value="Daria", displayname="Name" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value length is above the maximum length", function(){
					var result = testClass.validateLength( minlength="", maxlength=10, value="Daria Norris", displayname="Name" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(Name)" );
					expect( result ).toMatch( "(less)" );
				});


				// validateRegex()
				it( "returns an empty string if the value matches the regex string", function(){
					var result = testClass.validateRegex( regex="(sentence)", regexlabel="sentence", value="This is a sentence.", displayname="Word" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value does not match the regex string", function(){
					var result = testClass.validateRegex( regex="(cat)", regexlabel="sentence", value="This is a sentence.", displayname="Word" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toMatch( "(Word)" );
					expect( result ).toMatch( "(sentence)" );
				});


				// validateZipCode()
				it( "returns true if the value is a 5 digit zip code", function(){
					var result = testClass.validateZipCode( value="12345" );

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns true if the value is a 5 digit zip code with 4 digit extension", function(){
					var result = testClass.validateZipCode( value="12345-6789" );

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns false if the value is not a proper zip code", function(){
					var result = testClass.validateZipCode( value="123456789" );

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeFalse();
				});

				describe("checks validateByDataType() and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "validateByDataType", "" );
					});

					// validateRange()
					it( "returns an empty string if the value is within the minimum and maximum range", function(){
						var result = testClass.validateRange( minvalue=21, maxvalue=50, value=30, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeTypeOf( "string" );
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value is not within the minimum and maximum range", function(){
						var result = testClass.validateRange( minvalue=21, maxvalue=50, value=15, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeTypeOf( "string" );
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(between)" );
					});


					it( "returns an empty string if the value is above the minimum value", function(){
						var result = testClass.validateRange( minvalue=21, maxvalue="", value=30, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeTypeOf( "string" );
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value is below the minimum value", function(){
						var result = testClass.validateRange( minvalue=21, maxvalue="", value=15, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeTypeOf( "string" );
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(greater)" );
					});


					it( "returns an empty string if the value is below the maximum value", function(){
						var result = testClass.validateRange( minvalue="", maxvalue=50, value=30, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeTypeOf( "string" );
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value is above the maximum value", function(){
						var result = testClass.validateRange( minvalue="", maxvalue=50, value=75, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeTypeOf( "string" );
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(less)" );
					});

				});

			});


			describe("calls public functions and", function(){

				beforeEach(function( currentSpec ){

				});


				// validateBean()
				it( "returns an empty array if the bean's data matches the beanmap definition", function(){
					//var result = testClass.validateBean( beanmap, bean );
				});


				it( "returns an array of error messages if the bean's data doesn't match the beanmap definition", function(){
					//var result = testClass.validateBean( beanmap, bean );
				});

			});

		});

	}

}

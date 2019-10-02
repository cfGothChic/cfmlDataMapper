component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = createMock("cfmlDataMapper.model.services.validation");
	}

	function run() {

		describe("The Validation Service", function(){

			describe("reads a beanmap property and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "validateBeanProperty" );
					makePublic( testClass, "validateLength" );
					makePublic( testClass, "validateRange" );
					makePublic( testClass, "validateRegex" );
					makePublic( testClass, "validateRequired" );
					makePublic( testClass, "validateZipCode" );
				});


				// validateLength()
				it( "returns an empty string if the value length is within the minimum and maximum length", function(){
					var result = testClass.validateLength( minlength=10, maxlength=50, value="Daria Norris", displayname="Name" );

					expect( result ).toBeString();
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value length is not within the minimum and maximum length", function(){
					var result = testClass.validateLength( minlength=10, maxlength=50, value="Daria", displayname="Name" );

					expect( result ).toBeString();
					expect( result ).toMatch( "(Name)" );
					expect( result ).toMatch( "(between)" );
				});


				it( "returns an empty string if the value length is above the minimum length", function(){
					var result = testClass.validateLength( minlength=10, maxlength="", value="Daria Norris", displayname="Name" );

					expect( result ).toBeString();
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value length is below the minimum length", function(){
					var result = testClass.validateLength( minlength=10, maxlength="", value="Daria", displayname="Name" );

					expect( result ).toBeString();
					expect( result ).toMatch( "(Name)" );
					expect( result ).toMatch( "(longer)" );
				});


				it( "returns an empty string if the value length is below the maximum length", function(){
					var result = testClass.validateLength( minlength="", maxlength=10, value="Daria", displayname="Name" );

					expect( result ).toBeString();
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value length is above the maximum length", function(){
					var result = testClass.validateLength( minlength="", maxlength=10, value="Daria Norris", displayname="Name" );

					expect( result ).toBeString();
					expect( result ).toMatch( "(Name)" );
					expect( result ).toMatch( "(less)" );
				});


				// validateRegex()
				it( "returns an empty string if the value matches the regex string", function(){
					var result = testClass.validateRegex( regex="(sentence)", regexlabel="sentence", value="This is a sentence.", displayname="Word" );

					expect( result ).toBeString();
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value does not match the regex string", function(){
					var result = testClass.validateRegex( regex="(cat)", regexlabel="sentence", value="This is a sentence.", displayname="Word" );

					expect( result ).toBeString();
					expect( result ).toMatch( "(Word)" );
					expect( result ).toMatch( "(sentence)" );
				});


				// validateRequired()
				it( "returns an empty string if the value is required and has a length", function(){
					var result = testClass.validateRequired( value="This is a sentence.", displayname="Word" );

					expect( result ).toBeString();
					expect( result ).toBeEmpty();
				});


				it( "returns an error message if the value is required and does not have a length", function(){
					var result = testClass.validateRequired( value="", displayname="Word" );

					expect( result ).toBeString();
					expect( result ).toMatch( "(Word)" );
					expect( result ).toMatch( "(required)" );
				});


				// validateZipCode()
				it( "returns true if the value is a 5 digit zip code", function(){
					var result = testClass.validateZipCode( value="12345" );

					expect( result ).toBeBoolean();
					expect( result ).toBeTrue();
				});


				it( "returns true if the value is a 5 digit zip code with 4 digit extension", function(){
					var result = testClass.validateZipCode( value="12345-6789" );

					expect( result ).toBeBoolean();
					expect( result ).toBeTrue();
				});


				it( "returns false if the value is not a proper zip code", function(){
					var result = testClass.validateZipCode( value="123456789" );

					expect( result ).toBeBoolean();
					expect( result ).toBeFalse();
				});


				describe("calls validateByDataType() and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "validateZipCode", false );
					});


					// validateByDataType()
					it( "returns an empty string if the value is a boolean", function(){
						var result = testClass.validateByDataType( datatype="boolean", value="yes", displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value isn't a boolean", function(){
						var result = testClass.validateByDataType( datatype="boolean", value="", displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(numeric)" );
					});


					it( "returns an empty string if the value is a date", function(){
						var result = testClass.validateByDataType( datatype="timestamp", value=now(), displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value isn't a date", function(){
						var result = testClass.validateByDataType( datatype="timestamp", value="", displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(date)" );
					});


					it( "returns an empty string if the value is an email address", function(){
						var result = testClass.validateByDataType( datatype="email", value="test@test.com", displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value isn't an email address", function(){
						var result = testClass.validateByDataType( datatype="email", value="", displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(email)" );
					});


					it( "returns an empty string if the value is numeric", function(){
						var result = testClass.validateByDataType( datatype="numeric", value=123, displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value isn't numeric", function(){
						var result = testClass.validateByDataType( datatype="numeric", value="", displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(numeric)" );
					});


					it( "returns an empty string if the value is a telephone number", function(){
						var result = testClass.validateByDataType( datatype="telephone", value="215-555-5555", displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value isn't a telephone number", function(){
						var result = testClass.validateByDataType( datatype="telephone", value="", displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(telephone)" );
					});


					it( "returns an error message if the value isn't a zipcode", function(){
						var result = testClass.validateByDataType( datatype="zipcode", value="", displayname="Age" );

						expect( testClass.$once("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(zipcode)" );
					});


					it( "returns an empty string if the datatype is any", function(){
						var result = testClass.validateByDataType( datatype="any", value="test", displayname="Age" );

						expect( testClass.$never("validateZipCode") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toBeEmpty();
					});

				});


				describe("checks validateByDataType() and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "validateByDataType", "" );
					});


					// validateRange()
					it( "returns an empty string if the value is within the minimum and maximum range", function(){
						var result = testClass.validateRange( minvalue=21, maxvalue=50, value=30, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value is not within the minimum and maximum range", function(){
						var result = testClass.validateRange( minvalue=21, maxvalue=50, value=15, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(between)" );
					});


					it( "returns an empty string if the value is above the minimum value", function(){
						var result = testClass.validateRange( minvalue=21, maxvalue="", value=30, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value is below the minimum value", function(){
						var result = testClass.validateRange( minvalue=21, maxvalue="", value=15, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(greater)" );
					});


					it( "returns an empty string if the value is below the maximum value", function(){
						var result = testClass.validateRange( minvalue="", maxvalue=50, value=30, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toBeEmpty();
					});


					it( "returns an error message if the value is above the maximum value", function(){
						var result = testClass.validateRange( minvalue="", maxvalue=50, value=75, displayname="Age" );

						expect( testClass.$once("validateByDataType") ).toBeTrue();

						expect( result ).toBeString();
						expect( result ).toMatch( "(Age)" );
						expect( result ).toMatch( "(less)" );
					});

				});

				// validateBeanProperty()
				describe("calls validateBeanProperty() and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "validateByDataType", "error" )
							.$( "validateLength", "error" )
							.$( "validateRange", "error" )
							.$( "validateRegex", "error" )
							.$( "validateRequired", "error" );

						beanProperty = {
							displayname = "Test",
							"null" = true,
							datatype = "any",
							regex = "",
							regexlabel = "",
							minvalue = "",
							maxvalue = "",
							minlength = "",
							maxlength = ""
						};
					});


					it( "returns an empty array if the value is not required and doesn't exist", function(){
						var result = testClass.validateBeanProperty( value="", beanProperty=beanProperty );

						expect( testClass.$never("validateRequired") ).toBeTrue();
						expect( testClass.$never("validateByDataType") ).toBeTrue();
						expect( testClass.$never("validateRegex") ).toBeTrue();
						expect( testClass.$never("validateRange") ).toBeTrue();
						expect( testClass.$never("validateLength") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toBeEmpty();
					});


					it( "returns an array with a message if the value does not exist and is required", function(){
						beanProperty["null"] = false;

						var result = testClass.validateBeanProperty( value="", beanProperty=beanProperty );

						expect( testClass.$once("validateRequired") ).toBeTrue();
						expect( testClass.$never("validateByDataType") ).toBeTrue();
						expect( testClass.$never("validateRegex") ).toBeTrue();
						expect( testClass.$never("validateRange") ).toBeTrue();
						expect( testClass.$never("validateLength") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
					});


					it( "returns an array with a message if the value does not match the datatype", function(){
						var result = testClass.validateBeanProperty( value="test string", beanProperty=beanProperty );

						expect( testClass.$never("validateRequired") ).toBeTrue();
						expect( testClass.$once("validateByDataType") ).toBeTrue();
						expect( testClass.$never("validateRegex") ).toBeTrue();
						expect( testClass.$never("validateRange") ).toBeTrue();
						expect( testClass.$never("validateLength") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
					});


					it( "returns an array with a message if the value does not match the regex string", function(){
						beanProperty.regex = "test";

						var result = testClass.validateBeanProperty( value="test string", beanProperty=beanProperty );

						expect( testClass.$never("validateRequired") ).toBeTrue();
						expect( testClass.$once("validateByDataType") ).toBeTrue();
						expect( testClass.$once("validateRegex") ).toBeTrue();
						expect( testClass.$never("validateRange") ).toBeTrue();
						expect( testClass.$never("validateLength") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 2 );
					});


					it( "returns an array with a message if the value does not match the minvalue", function(){
						beanProperty.minvalue = "test";

						var result = testClass.validateBeanProperty( value="test string", beanProperty=beanProperty );

						expect( testClass.$never("validateRequired") ).toBeTrue();
						expect( testClass.$once("validateByDataType") ).toBeTrue();
						expect( testClass.$never("validateRegex") ).toBeTrue();
						expect( testClass.$once("validateRange") ).toBeTrue();
						expect( testClass.$never("validateLength") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 2 );
					});


					it( "returns an array with a message if the value does not match the maxvalue", function(){
						beanProperty.maxvalue = "test";

						var result = testClass.validateBeanProperty( value="test string", beanProperty=beanProperty );

						expect( testClass.$never("validateRequired") ).toBeTrue();
						expect( testClass.$once("validateByDataType") ).toBeTrue();
						expect( testClass.$never("validateRegex") ).toBeTrue();
						expect( testClass.$once("validateRange") ).toBeTrue();
						expect( testClass.$never("validateLength") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 2 );
					});


					it( "returns an array with a message if the value's length does not match the minlength", function(){
						beanProperty.minlength = "test";

						var result = testClass.validateBeanProperty( value="test string", beanProperty=beanProperty );

						expect( testClass.$never("validateRequired") ).toBeTrue();
						expect( testClass.$once("validateByDataType") ).toBeTrue();
						expect( testClass.$never("validateRegex") ).toBeTrue();
						expect( testClass.$never("validateRange") ).toBeTrue();
						expect( testClass.$once("validateLength") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 2 );
					});


					it( "returns an array with a message if the value's length does not match the maxlength", function(){
						beanProperty.maxlength = "test";

						var result = testClass.validateBeanProperty( value="test string", beanProperty=beanProperty );

						expect( testClass.$never("validateRequired") ).toBeTrue();
						expect( testClass.$once("validateByDataType") ).toBeTrue();
						expect( testClass.$never("validateRegex") ).toBeTrue();
						expect( testClass.$never("validateRange") ).toBeTrue();
						expect( testClass.$once("validateLength") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 2 );
					});

				});

			});


			describe("calls public functions and", function(){

				beforeEach(function( currentSpec ){
					userBean = createMock("model.beans.user");
					userBean.$( "getPropertyValue" ).$args( item="test" ).$results( "test" );

					beanmap = {
						properties = {
							test = {
								insert = true,
								isidentity = false
							}
						}
					};

					testClass.$( "validateBeanProperty", ["error"] );
				});


				// validateBean()
				it( "returns an empty array if the bean's property value matches the beanmap's property definition", function(){
					testClass.$( "validateBeanProperty", [] );

					var result = testClass.validateBean( beanmap=beanmap, bean=userBean );

					expect( testClass.$once("validateBeanProperty") ).toBeTrue();

					expect( result ).toBeArray();
					expect( result ).toBeEmpty();
				});


				it( "returns an empty array if the bean's property won't be inserted", function(){
					beanmap.properties.test.insert = false;

					var result = testClass.validateBean( beanmap=beanmap, bean=userBean );

					expect( testClass.$never("validateBeanProperty") ).toBeTrue();

					expect( result ).toBeArray();
					expect( result ).toBeEmpty();
				});


				it( "returns an empty array if the bean's property is an identity", function(){
					beanmap.properties.test.isidentity = true;

					var result = testClass.validateBean( beanmap=beanmap, bean=userBean );

					expect( testClass.$never("validateBeanProperty") ).toBeTrue();

					expect( result ).toBeArray();
					expect( result ).toBeEmpty();
				});


				it( "returns an array of error messages if the bean's data doesn't match the beanmap definition", function(){
					var result = testClass.validateBean( beanmap=beanmap, bean=userBean );

					expect( testClass.$once("validateBeanProperty") ).toBeTrue();

					expect( result ).toBeArray();
					expect( result ).toHaveLength( 1 );
				});

			});

		});

	}

}

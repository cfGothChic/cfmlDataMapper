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
					primarykey = "id",
					properties = {
						id = {
							name = "id",
							insert = true
						},
						email = {
							name = "email",
							insert = true
						}
					}
				};
			});

			// create()
			// delete()
			// deleteByNotIn()
			// read()
			// readByJoin()
			// update()
			// createSQL()
			// deleteSQL()
			// deleteByNotInSQL()
			// readByJoinSQL()
			// readSQL()
			// updateSQL()

			// isNullInteger()
			// getParams()
			// getSQLParam()

			describe("checks if a property should be included and", function(){

				beforeEach(function( currentSpec ){

				});


				// isPropertyIncluded()
				it( "returns true if the type is select and not primarykey only", function(){
					var result = testClass.isPropertyIncluded( prop="email", beanmap=beanmap, includepk=true, type="select", pkOnly=false );

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns true if the type is select, the field is the primarykey and it is primarykey only", function(){
					var result = testClass.isPropertyIncluded( prop="id", beanmap=beanmap, includepk=true, type="select", pkOnly=true );

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns false if the type is select, the field is not the primarykey and it is primarykey only", function(){
					var result = testClass.isPropertyIncluded( prop="email", beanmap=beanmap, includepk=true, type="select", pkOnly=true );

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeFalse();
				});


				it( "returns true if the type is not select, the property is inserted and its including the primarykey", function(){
					var result = testClass.isPropertyIncluded( prop="email", beanmap=beanmap, includepk=true, type="update", pkOnly=false );

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns true if the type is not select, the property is inserted and its not the primrarykey when not included", function(){
					var result = testClass.isPropertyIncluded( prop="email", beanmap=beanmap, includepk=false, type="update", pkOnly=false );

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeTrue();
				});


				it( "returns false if the type is not select, the property is inserted and its the primarykey when not included", function(){
					var result = testClass.isPropertyIncluded( prop="id", beanmap=beanmap, includepk=false, type="update", pkOnly=false );

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeFalse();
				});


				it( "returns false if the type is not select and the property is not inserted", function(){
					beanmap.properties.email.insert = false;
					var result = testClass.isPropertyIncluded( prop="email", beanmap=beanmap, includepk=true, type="update", pkOnly=false );

					expect( result ).toBeTypeOf( "boolean" );
					expect( result ).toBeFalse();
				});

			});

			describe("is given beanmap information and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getParams" );
				});


			});

		});

	}

}

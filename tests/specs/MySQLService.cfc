component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = createMock("cfmlDataMapper.model.services.mysql");
	}

	function run() {

		describe("The MySQL Service", function(){

			beforeEach(function( currentSpec ){
				beanmap = {
					database = "",
					table = "users",
					properties = {
						email = {
							name = "email",
							columnname = ""
						}
					}
				};
			});


			// getCreateNewId()
			it( "returns a string of sql for the create statement to return the new id if it is an identity", function(){
				var result = testClass.getCreateNewId( isidentity=true );

				expect( result ).toBeString();
				expect( result ).toMatch( "(LAST_INSERT_ID)" );
				expect( result ).notToMatch( "@newid" );
			});


			it( "returns a string of sql for the create statement to return the new id if it isn't an identity", function(){
				var result = testClass.getCreateNewId( isidentity=false );

				expect( result ).toBeString();
				expect( result ).notToMatch( "(LAST_INSERT_ID)" );
				expect( result ).toMatch( "@newid" );
			});


			// getCreateSetNewId()
			it( "returns an empty string to set the new id for the create statement if it is an identity", function(){
				var result = testClass.getCreateSetNewId( isidentity=true, tablename="`users`", primarykeyfield="`userid`" );

				expect( result ).toBeString();
				expect( result ).toBeEmpty();
			});


			it( "returns a string of sql to set the new id for the create statement if it isn't an identity", function(){
				var result = testClass.getCreateSetNewId( isidentity=false, tablename="`users`", primarykeyfield="`userid`" );

				expect( result ).toBeString();
				expect( result ).toMatch( "@newid" );
			});


			// getCreateValues()
			it( "returns a string of sql to set the new id for the create statement if it is an identity", function(){
				var result = testClass.getCreateValues( isidentity=true );

				expect( result ).toBeString();
				expect( result ).notToMatch( "@newid" );
			});


			it( "returns a string of sql to set the new id for the create statement if it isn't an identity", function(){
				var result = testClass.getCreateValues( isidentity=false );

				expect( result ).toBeString();
				expect( result ).toMatch( "@newid" );
			});


			describe("uses beanmap information to", function(){

				// getPropertyField()
				it( "return the property name if a columnname isn't defined", function(){
					var result = testClass.getPropertyField( prop=beanmap.properties.email );

					expect( result ).toBeString();
					expect( result ).toBe( "`email`" );
				});


				it( "return the property's column name", function(){
					beanmap.properties.email.columnname = "emailaddress";

					var result = testClass.getPropertyField( prop=beanmap.properties.email );

					expect( result ).toBeString();
					expect( result ).toBe( "`emailaddress`" );
				});


				// getSelectAsField()
				it( "return the just the column name if the property is not required", function(){
					var result = testClass.getSelectAsField( propname="name", columnname="`fullname`", sqltype="cf_sql_varchar", isRequired=false );

					expect( result ).toBeString();
					expect( result ).toBe( "`fullname` AS `name`" );
				});


				it( "return the just the column name if the property is an integer but is required", function(){
					var result = testClass.getSelectAsField( propname="name", columnname="`fullname`", sqltype="cf_sql_integer", isRequired=true );

					expect( result ).toBeString();
					expect( result ).toBe( "`fullname` AS `name`" );
				});


				it( "return the column name defaulted to 0 if the property is an integer and it is not required", function(){
					var result = testClass.getSelectAsField( propname="name", columnname="`fullname`", sqltype="cf_sql_integer", isRequired=false );

					expect( result ).toBeString();
					expect( result ).toBe( "IFNULL(`fullname`,0) AS `name`" );
				});


				// getTableName()
				it( "return the table name sql string with the default schema", function(){
					var result = testClass.getTableName( beanmap=beanmap );

					expect( result ).toBeString();
					expect( result ).toBe( "`users`" );
				});

				it( "return the table name sql string with a database name", function(){
					beanmap.database = "database";

					var result = testClass.getTableName( beanmap=beanmap );

					expect( result ).toBeString();
					expect( result ).toBe( "`database`.`users`" );
				});

			});

		});

	}

}

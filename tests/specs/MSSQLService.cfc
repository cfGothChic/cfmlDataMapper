component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = new cfmlDataMapper.model.services.mssql();
		prepareMock( testClass );
	}

	function run() {

		describe("The MSSQL Service", function(){

			beforeEach(function( currentSpec ){
				beanmap = {
					bean = "user",
					schema = "",
					table = "users",
					primarykey = "id",
					orderby = "name",
					properties = {
						id = {
							name = "id",
							columnname = "",
							sqltype = "cf_sql_integer",
							"null" = false,
							isidentity = true
						},
						email = {
							name = "email",
							columnname = "",
							sqltype = "cf_sql_varchar",
							"null" = false
						}
					}
				};

				makePublic( testClass, "getOrderInfo" );
			});


			// getCreateNewId()
			it( "returns a string of sql for the create statement to return the new id if it is an identity", function(){
				var result = testClass.getCreateNewId( isidentity=true );

				expect( result ).toBeTypeOf( "string" );
				expect( result ).toMatch( "(@ident)" );
				expect( result ).notToMatch( "@newid" );
			});


			it( "returns a string of sql for the create statement to return the new id if it isn't an identity", function(){
				var result = testClass.getCreateNewId( isidentity=false );

				expect( result ).toBeTypeOf( "string" );
				expect( result ).notToMatch( "(@ident)" );
				expect( result ).toMatch( "@newid" );
			});


			// getCreateSetNewId()
			it( "returns a string of sql to set the new id for the create statement if it is an identity", function(){
				var result = testClass.getCreateSetNewId( isidentity=true, tablename="[users]", primarykeyfield="[userid]" );

				expect( result ).toBeTypeOf( "string" );
				expect( result ).toMatch( "@ident" );
				expect( result ).notToMatch( "@newid" );
			});


			it( "returns a string of sql to set the new id for the create statement if it isn't an identity", function(){
				var result = testClass.getCreateSetNewId( isidentity=false, tablename="[users]", primarykeyfield="[userid]" );

				expect( result ).toBeTypeOf( "string" );
				expect( result ).notToMatch( "@ident" );
				expect( result ).toMatch( "@newid" );
			});


			// getCreateValues()
			it( "returns a string of sql to set the new id for the create statement if it is an identity", function(){
				var result = testClass.getCreateValues( isidentity=true, primarykeyfield="userid" );

				expect( result ).toBeTypeOf( "string" );
				expect( result ).toMatch( "@ident" );
				expect( result ).notToMatch( "@newid" );
			});


			it( "returns a string of sql to set the new id for the create statement if it isn't an identity", function(){
				var result = testClass.getCreateValues( isidentity=false, primarykeyfield="userid" );

				expect( result ).toBeTypeOf( "string" );
				expect( result ).notToMatch( "@ident" );
				expect( result ).toMatch( "@newid" );
			});


			// getOrderInfo()
			it( "returns a structure of parsed orderby information with default direction", function(){
				var result = testClass.getOrderInfo( orderby="email" );

				expect( result ).toBeTypeOf( "struct" );
				expect( result ).toHaveKey( "propname" );
				expect( result ).toHaveKey( "direction" );
				expect( result.propname ).toBe( "email" );
				expect( result.direction ).toBeWithCase( "ASC" );
			});


			it( "returns a structure of parsed orderby information with descending direction", function(){
				var result = testClass.getOrderInfo( orderby="email desc" );

				expect( result ).toBeTypeOf( "struct" );
				expect( result ).toHaveKey( "propname" );
				expect( result ).toHaveKey( "direction" );
				expect( result.propname ).toBe( "email" );
				expect( result.direction ).toBeWithCase( "DESC" );
			});


			it( "returns a structure of parsed orderby information with default direction if the string is invalid", function(){
				var result = testClass.getOrderInfo( orderby="email address" );

				expect( result ).toBeTypeOf( "struct" );
				expect( result ).toHaveKey( "propname" );
				expect( result ).toHaveKey( "direction" );
				expect( result.propname ).toBe( "email" );
				expect( result.direction ).toBeWithCase( "ASC" );
			});


			describe("uses beanmap information to", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getPropertyByColumnName" );
				});


				// getPropertyByColumnName()
				it( "return the property that matches a columnname", function(){
					beanmap.properties.email.columnname = "emailaddress";

					var result = testClass.getPropertyByColumnName( beanmap=beanmap, columnname="emailaddress" );

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).notToBeEmpty();
				});


				it( "return an empty structure if there isn't a property that matches a columnname", function(){
					var result = testClass.getPropertyByColumnName( beanmap=beanmap, columnname="emailaddress" );

					expect( result ).toBeTypeOf( "struct" );
					expect( result ).toBeEmpty();
				});


				// getPropertyField()
				it( "return the property name if a columnname isn't defined", function(){
					var result = testClass.getPropertyField( prop=beanmap.properties.email );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "[email]" );
				});


				it( "return the property's column name", function(){
					beanmap.properties.email.columnname = "emailaddress";

					var result = testClass.getPropertyField( prop=beanmap.properties.email );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "[emailaddress]" );
				});


				// getSelectAsField()
				it( "return the just the column name if the property isn't an integer", function(){
					var result = testClass.getSelectAsField( propname="name", columnname="[fullname]", sqltype="cf_sql_varchar", isNull=true );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "[fullname] AS [name]" );
				});


				it( "return the just the column name if the property is an integer but isn't null", function(){
					var result = testClass.getSelectAsField( propname="name", columnname="[fullname]", sqltype="cf_sql_integer", isNull=false );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "[fullname] AS [name]" );
				});


				it( "return the column name defaulted to 0 if the property is an integer and it is null", function(){
					var result = testClass.getSelectAsField( propname="name", columnname="[fullname]", sqltype="cf_sql_integer", isNull=true );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "ISNULL([fullname],0) AS [name]" );
				});


				// getTableName()
				it( "return the table name sql string with the default schema", function(){
					var result = testClass.getTableName( beanmap=beanmap );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "[dbo].[users]" );
				});


				it( "return the table name sql string with a declared schema", function(){
					beanmap.schema = "security";

					var result = testClass.getTableName( beanmap=beanmap );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "[security].[users]" );
				});


				describe("calls other private functions and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getPrimaryKeyField" );

						testClass.$( "getPropertyField", "[email]" );
					});


					// getPrimaryKeyField()
					it( "returns the primarykey's property field", function(){
						var result = testClass.getPrimaryKeyField( beanmap=beanmap );

						expect( testClass.$once("getPropertyField") ).toBeTrue();

						expect( result ).toBeTypeOf( "string" );
						expect( result ).toMatch( "(email)" );
					});


					// getFieldByType()
					describe("calls getFieldByType() and", function(){

						beforeEach(function( currentSpec ){
							makePublic( testClass, "getFieldByType" );

							testClass.$( "getPropertyField", "[emailaddress]" )
								.$( "getSelectAsField", "[id]" );

							args = {
								type="",
								prop=beanmap.properties.email,
								propname="email",
								columnname="[emailaddress]"
							};
						});


						it( "returns a field string for the select statement if a type isn't passed in", function(){
							var result = testClass.getFieldByType( argumentCollection=args );

							expect( testClass.$never("getSelectAsField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(email)" );
						});


						it( "returns a field string for the insert statement", function(){
							args.type = "insert";

							var result = testClass.getFieldByType( argumentCollection=args );

							expect( testClass.$never("getSelectAsField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(emailaddress)" );
						});


						it( "returns a field string for the insert values statement", function(){
							args.type = "values";

							var result = testClass.getFieldByType( argumentCollection=args );

							expect( testClass.$never("getSelectAsField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(email)" );
						});


						it( "returns a field string for the update statement", function(){
							args.type = "update";

							var result = testClass.getFieldByType( argumentCollection=args );

							expect( testClass.$never("getSelectAsField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(emailaddress)" );
							expect( result ).toMatch( "(email)" );
						});


						it( "returns a field string for the select statement if it doesn't have a columnname and isn't a null integer", function(){
							args.type = "select";

							var result = testClass.getFieldByType( argumentCollection=args );

							expect( testClass.$never("getSelectAsField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(email)" );
						});


						it( "returns a field string for the select statement if it has a columnname", function(){
							beanmap.properties.email.columnname = "id";
							args.type = "select";

							var result = testClass.getFieldByType( argumentCollection=args );

							expect( testClass.$once("getSelectAsField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(id)" );
						});


						it( "returns a field string for the select statement if it is null and an integer", function(){
							beanmap.properties.id.null = true;
							args.prop=beanmap.properties.id;
							args.type = "select";

							var result = testClass.getFieldByType( argumentCollection=args );

							expect( testClass.$once("getSelectAsField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(id)" );
						});

					});


					// getFields()
					describe("calls getFields() and", function(){

						beforeEach(function( currentSpec ){
							makePublic( testClass, "getFields" );

							SQLService = createEmptyMock("cfmlDataMapper.model.services.sql");
							testClass.$property( propertyName="SQLService", mock=SQLService );

							testClass.$( "getPropertyField", "[email]" )
								.$( "getTableName", "[users]" );

							testClass.$( "getFieldByType" )
								.$args( type="select", prop=beanmap.properties.id, propname="id", columnname="[users].[id]", tablename="[users]" )
								.$results( "[users].[id]" );
							testClass.$( "getFieldByType" )
								.$args( type="select", prop=beanmap.properties.email, propname="email", columnname="[users].[email]", tablename="[users]" )
								.$results( "[users].[email]" );

							testClass.$( "getPropertyField" ).$args( prop=beanmap.properties.id ).$results( "[id]" );
							testClass.$( "getPropertyField" ).$args( prop=beanmap.properties.email ).$results( "[email]" );

							SQLService.$( "isPropertyIncluded" )
								.$args( prop=beanmap.properties.id, primarykey=beanmap.primarykey, includepk=true, type="select", pkOnly=false )
								.$results( true );
							SQLService.$( "isPropertyIncluded" )
								.$args( prop=beanmap.properties.email, primarykey=beanmap.primarykey, includepk=true, type="select", pkOnly=false )
								.$results( true );
						});


						it( "returns the field list with all the properties if the type is select", function(){
							var result = testClass.getFields( type="select", beanmap=beanmap, pkOnly=false );

							expect( testClass.$once("getTableName") ).toBeTrue();
							expect( SQLService.$count("isPropertyIncluded") ).toBe( 2 );
							expect( testClass.$count("getPropertyField") ).toBe( 2 );
							expect( testClass.$count("getFieldByType") ).toBe( 2 );

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(email)" );
							expect( result ).toMatch( "(,)" );
							expect( result ).toMatch( "(id)" );
						});


						it( "returns the field list without the primarykey if the type isn't select", function(){
							testClass.$( "getFieldByType" )
								.$args( type="update", prop=beanmap.properties.email, propname="email", columnname="[users].[email]", tablename="[users]" )
								.$results( "[users].[email]" );

							SQLService.$( "isPropertyIncluded" )
								.$args( prop=beanmap.properties.id, primarykey=beanmap.primarykey, includepk=false, type="update", pkOnly=false )
								.$results( false );
							SQLService.$( "isPropertyIncluded" )
								.$args( prop=beanmap.properties.email, primarykey=beanmap.primarykey, includepk=false, type="update", pkOnly=false )
								.$results( true );

							var result = testClass.getFields( type="update", beanmap=beanmap, pkOnly=false );

							expect( testClass.$once("getTableName") ).toBeTrue();
							expect( SQLService.$count("isPropertyIncluded") ).toBe( 2 );
							expect( testClass.$once("getPropertyField") ).toBeTrue();
							expect( testClass.$once("getFieldByType") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(email)" );
						});


						it( "returns the field list with only the primarykey if the type is select and the pkOnly flag is true", function(){
							SQLService.$( "isPropertyIncluded" )
								.$args( prop=beanmap.properties.id, primarykey=beanmap.primarykey, includepk=true, type="select", pkOnly=true )
								.$results( true );
							SQLService.$( "isPropertyIncluded" )
								.$args( prop=beanmap.properties.email, primarykey=beanmap.primarykey, includepk=true, type="select", pkOnly=true )
								.$results( false );

							var result = testClass.getFields( type="select", beanmap=beanmap, pkOnly=true );

							expect( testClass.$once("getTableName") ).toBeTrue();
							expect( SQLService.$count("isPropertyIncluded") ).toBe( 2 );
							expect( testClass.$once("getPropertyField") ).toBeTrue();
							expect( testClass.$once("getFieldByType") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(id)" );
						});


					});

					// getWhereStatement()
					describe("calls getWhereStatement() and", function(){

						beforeEach(function( currentSpec ){
							makePublic( testClass, "getWhereStatement" );

							testClass.$( "getPropertyField", "[email]" );
						});


						it( "returns an empty string if there are no params passed in", function(){
							var result = testClass.getWhereStatement( beanmap=beanmap, sqlparams={}, tablename="[users]" );

							expect( testClass.$never("getPropertyField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toBeEmpty();
						});


						it( "returns a where sql statement with one filter", function(){
							var result = testClass.getWhereStatement( beanmap=beanmap, sqlparams={ email="test" }, tablename="[users]" );

							expect( testClass.$once("getPropertyField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(WHERE)" );
							expect( result ).notToMatch( "(AND)" );
						});


						it( "returns a where sql statement with two filters", function(){
							var result = testClass.getWhereStatement( beanmap=beanmap, sqlparams={ id=1, email="test" }, tablename="[users]" );

							expect( testClass.$count("getPropertyField") ).toBe( 2 );

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(WHERE)" );
							expect( result ).toMatch( "(AND)" );
						});


						it( "throws an error if the param isn't in the beanmap properties", function(){
							expect( function(){ testClass.getWhereStatement( beanmap=beanmap, sqlparams={ name="test" }, tablename="[users]" ); } )
								.toThrow(type="application", regex="(name)");
						});

					});


					// getFullOrderBy()
					describe("calls getFullOrderBy() and", function(){

						beforeEach(function( currentSpec ){
							makePublic( testClass, "getFullOrderBy" );

							testClass.$( "getOrderInfo", { propname="email", direction="ASC" } )
								.$( "getPropertyByColumnName", {} )
								.$( "getPrimaryKeyField", "[id]" );
						});


						it( "returns the primarykey sort if no orderby is passed in and it doesn't exist in the beanmap", function(){
							beanmap.orderby = "";

							var result = testClass.getFullOrderBy( beanmap=beanmap, orderby="" );

							expect( testClass.$never("getOrderInfo") ).toBeTrue();
							expect( testClass.$never("getPropertyByColumnName") ).toBeTrue();
							expect( testClass.$never("getPropertyField") ).toBeTrue();
							expect( testClass.$once("getPrimaryKeyField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(id)" );
							expect( result ).toMatch( "(ASC)" );
						});


						it( "returns the default if no orderby is passed in", function(){
							var result = testClass.getFullOrderBy( beanmap=beanmap, orderby="" );

							expect( testClass.$once("getOrderInfo") ).toBeTrue();
							expect( testClass.$never("getPropertyByColumnName") ).toBeTrue();
							expect( testClass.$once("getPropertyField") ).toBeTrue();
							expect( testClass.$never("getPrimaryKeyField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(email)" );
							expect( result ).toMatch( "(ASC)" );
						});


						it( "returns the default orderby if it doesn't match any properties", function(){
							testClass.$( "getOrderInfo", { propname="emailaddress", direction="ASC" } );

							var result = testClass.getFullOrderBy( beanmap=beanmap, orderby="emailaddress" );

							expect( testClass.$once("getOrderInfo") ).toBeTrue();
							expect( testClass.$once("getPropertyByColumnName") ).toBeTrue();
							expect( testClass.$never("getPropertyField") ).toBeTrue();
							expect( testClass.$once("getPrimaryKeyField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(id)" );
							expect( result ).toMatch( "(ASC)" );
						});


						it( "returns the proper orderby string if it matches a property name", function(){
							var result = testClass.getFullOrderBy( beanmap=beanmap, orderby="email" );

							expect( testClass.$once("getOrderInfo") ).toBeTrue();
							expect( testClass.$never("getPropertyByColumnName") ).toBeTrue();
							expect( testClass.$once("getPropertyField") ).toBeTrue();
							expect( testClass.$never("getPrimaryKeyField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(email)" );
							expect( result ).toMatch( "(ASC)" );
						});


						it( "returns the proper orderby string if it matches a property column name", function(){
							testClass.$( "getOrderInfo", { propname="emailaddress", direction="ASC" } )
								.$( "getPropertyByColumnName", { name="email" } );

							var result = testClass.getFullOrderBy( beanmap=beanmap, orderby="emailaddress" );

							expect( testClass.$once("getOrderInfo") ).toBeTrue();
							expect( testClass.$once("getPropertyByColumnName") ).toBeTrue();
							expect( testClass.$once("getPropertyField") ).toBeTrue();
							expect( testClass.$never("getPrimaryKeyField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(email)" );
							expect( result ).toMatch( "(ASC)" );
						});


						it( "returns the proper orderby string if it matches multiple property names", function(){
							testClass.$( "getOrderInfo" ).$args( orderby="email desc" ).$results({ propname="email", direction="DESC" })
								.$( "getOrderInfo" ).$args( orderby="id" ).$results({ propname="id", direction="ASC" })
								.$( "getPropertyField" ).$args( prop=beanmap.properties.id ).$results( "[id]" )
								.$( "getPropertyField" ).$args( prop=beanmap.properties.email ).$results( "[email]" );

							var result = testClass.getFullOrderBy( beanmap=beanmap, orderby="email desc, id" );

							expect( testClass.$count("getOrderInfo") ).toBe( 2 );
							expect( testClass.$never("getPropertyByColumnName") ).toBeTrue();
							expect( testClass.$count("getPropertyField") ).toBe( 2 );
							expect( testClass.$never("getPrimaryKeyField") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toMatch( "(email)" );
							expect( result ).toMatch( "(DESC)" );
							expect( result ).toMatch( "(,)" );
							expect( result ).toMatch( "(id)" );
							expect( result ).toMatch( "(ASC)" );
						});

					});

				});

			});

		});

	}

}

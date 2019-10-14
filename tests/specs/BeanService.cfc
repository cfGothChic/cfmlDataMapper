component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = createMock("cfmlDataMapper.model.services.bean");
	}

	function run() {

		describe("The Bean Service", function(){

			beforeEach(function( currentSpec ){

				beanmap = {
					name = "test",
					primarykey = "id",
					database = "",
					relationships = {
						test = {
							bean = "user",
							joinType = "one",
							fkName = "testid",
							contexts = []
						}
					}
				};

				BaseBean = createMock("cfmlDataMapper.model.base.bean");
				BaseBean.$( "getBeanMap", beanmap )
					.$( "getBeanName", "test" )
					.$( "getPropertyValue", 1 )
					.$( "populate" )
					.$( "setBeanName" )
					.$( "setPrimaryKey" );

			});


			describe("initializes and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getSprocContext" );

					qRecords = querySim("id
						1");

					UtilityService = createEmptyMock("cfmlDataMapper.model.services.utility");
					UtilityService.$( "getResultStruct", { "success"=true, "code"=001, "messages"=[] } );
					testClass.$property( propertyName="UtilityService", mock=UtilityService );
				});


				// getSprocContext()
				it( "returns the context that was passed into it", function(){
					var result = testClass.getSprocContext( context="test" );

					expect( result ).toBeString();
					expect( result ).toBe( "test" );
				});


				it( "returns the root bean context if the context was passed in but doesn't have a length", function(){
					var result = testClass.getSprocContext( context="" );

					expect( result ).toBeString();
					expect( result ).toBe( "_bean" );
				});


				it( "returns and empty string if the context doesn't exist", function(){
					var result = testClass.getSprocContext();

					expect( result ).toBeString();
					expect( result ).toBeEmpty();
				});


				// populateByQuery()
				it( "processes a query and injects it into the bean", function(){
					testClass.populateByQuery( bean=BaseBean, qRecord=qRecords );

					expect( BaseBean.$once("populate") ).toBeTrue();
				});


				describe("uses the DataFactory and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getOneToManyRelationship" );
						makePublic( testClass, "getManyToManyRelationship" );
						makePublic( testClass, "getRelationshipBean" );
						makePublic( testClass, "getSprocRelationship" );

						DataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");

						DataFactory.$( "get", BaseBean )
							.$( "getBeanMap", beanmap )
							.$( "getBeansFromQuery", [BaseBean] )
							.$( "list", [BaseBean] );
						testClass.$property( propertyName="DataFactory", mock=DataFactory );

						SQLService = createEmptyMock("cfmlDataMapper.model.services.sql");
						SQLService.$( "readByJoin", querySim("") );
						testClass.$property( propertyName="SQLService", mock=SQLService );

						testClass.$( "getBeanName", "test" );
					});


					// getOneToManyRelationship()
					it( "returns an array of beans representing a one-to-many relationship", function(){
						var result = testClass.getOneToManyRelationship( primarykeyid=1, relationship=beanmap.relationships.test );

						expect( DataFactory.$once("list") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "cfmlDataMapper.model.base.bean" );
					});


					it( "returns an empty array for the one-to-many relationship if the bean record does not exist", function(){
						var result = testClass.getOneToManyRelationship( primarykeyid=0, relationship=beanmap.relationships.test );

						expect( DataFactory.$never("list") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toBeEmpty();
					});


					// getManyToManyRelationship()
					it( "returns an array of beans representing a many-to-many relationship", function(){
						var result = testClass.getManyToManyRelationship( primarykeyid=1, relationship=beanmap.relationships.test );

						expect( SQLService.$once("readByJoin") ).toBeTrue();
						expect( DataFactory.$once("getBeansFromQuery") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "cfmlDataMapper.model.base.bean" );
					});


					it( "returns an empty array for the many-to-many relationship if the bean record does not exist", function(){
						var result = testClass.getManyToManyRelationship( primarykeyid=0, relationship=beanmap.relationships.test );

						expect( SQLService.$never("readByJoin") ).toBeTrue();
						expect( DataFactory.$never("getBeansFromQuery") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toBeEmpty();
					});


					// getRelationshipBean()
					it( "returns a bean for a one-to-one or many-to-one relationship", function(){
						var result = testClass.getRelationshipBean( bean=BaseBean, relationship=beanmap.relationships.test );

						expect( BaseBean.$once("getPropertyValue") ).toBeTrue();
						expect( DataFactory.$once("get") ).toBeTrue();

						expect( result ).toBeComponent();
						expect( result ).toBeInstanceOf( "cfmlDataMapper.model.base.bean" );
					});


					// getSprocRelationship()
					describe("calls getSprocRelationship() and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "populateByQuery" );
						});


						it( "returns a bean from the stored procedure data if the joinType is one", function(){
							var result = testClass.getSprocRelationship( beanname="test", joinType="one", qRecords=qRecords );

							expect( DataFactory.$once("get") ).toBeTrue();
							expect( testClass.$once("populateByQuery") ).toBeTrue();
							expect( DataFactory.$never("getBeansFromQuery") ).toBeTrue();

							expect( result ).toBeComponent();
							expect( result ).toBeInstanceOf( "cfmlDataMapper.model.base.bean" );
						});


						it( "returns an array from the stored procedure data if the joinType is many", function(){
							var result = testClass.getSprocRelationship( beanname="test", joinType="many", qRecords=qRecords );

							expect( DataFactory.$never("get") ).toBeTrue();
							expect( testClass.$never("populateByQuery") ).toBeTrue();
							expect( DataFactory.$once("getBeansFromQuery") ).toBeTrue();

							expect( result ).toBeArray();
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "cfmlDataMapper.model.base.bean" );
						});


						it( "returns an array from the stored procedure data if the joinType is one-to-many", function(){
							var result = testClass.getSprocRelationship( beanname="test", joinType="one-to-many", qRecords=qRecords );

							expect( DataFactory.$never("get") ).toBeTrue();
							expect( testClass.$never("populateByQuery") ).toBeTrue();
							expect( DataFactory.$once("getBeansFromQuery") ).toBeTrue();

							expect( result ).toBeArray();
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "cfmlDataMapper.model.base.bean" );
						});


						it( "returns an array from the stored procedure data if the joinType is many-to-many", function(){
							var result = testClass.getSprocRelationship( beanname="test", joinType="many-to-many", qRecords=qRecords );

							expect( DataFactory.$never("get") ).toBeTrue();
							expect( testClass.$never("populateByQuery") ).toBeTrue();
							expect( DataFactory.$once("getBeansFromQuery") ).toBeTrue();

							expect( result ).toBeArray();
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "cfmlDataMapper.model.base.bean" );
						});

					});

				});


				describe("uses the beanmap and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getPrimaryKeyFromSprocData" );
						makePublic( testClass, "getRelationshipKeys" );
					});


					// getPrimaryKeyFromSprocData()
					it( "returns the bean's id from the populated primary key", function(){
						var result = testClass.getPrimaryKeyFromSprocData( bean=BaseBean, primarykey="id", data={ "_bean"=qRecords } );

						expect( BaseBean.$once("getPropertyValue") ).toBeTrue();

						expect( result ).toBeNumeric();
						expect( result ).toBe( 1 );
					});


					it( "returns 0 for the bean's id if the stored procedure had no bean data", function(){
						var result = testClass.getPrimaryKeyFromSprocData( bean=BaseBean, primarykey="id", data={ "_bean"=querySim("") } );

						expect( BaseBean.$never("getPropertyValue") ).toBeTrue();

						expect( result ).toBeNumeric();
						expect( result ).toBe( 0 );
					});


					// getRelationshipKeys()
					it( "returns an array of the bean key and relationship keys for the stored procedure context", function(){
						var result = testClass.getRelationshipKeys( beanmap=beanmap, context="test" );

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 2 );
					});


					it( "returns an array with the bean key for the stored procedure when there isn't a context", function(){
						var result = testClass.getRelationshipKeys( beanmap=beanmap, context="" );

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
					});


					it( "returns an array with the bean key for the stored procedure when the context is '_bean'", function(){
						var result = testClass.getRelationshipKeys( beanmap=beanmap, context="_bean" );

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
					});


					it( "returns an array with the bean key for the stored procedure when there are no relationships", function(){
						beanmap.relationships = {};

						var result = testClass.getRelationshipKeys( beanmap=beanmap, context="test" );

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
					});

				});


				// populateRelationship()
				describe("calls populateRelationship() and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "getManyToManyRelationship", [] )
							.$( "getOneToManyRelationship", [] )
							.$( "getRelationshipBean", BaseBean )
							.$( "getNext" )
							.$( "getTest" );
					});


					it( "populates a one-to-one or many-to-one relationship", function(){
						var result = testClass.populateRelationship( bean=BaseBean, relationshipName="test" );

						expect( BaseBean.$count("getPropertyValue") ).toBe( 2 );
						expect( BaseBean.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("getRelationshipBean") ).toBeTrue();
						expect( testClass.$never("getOneToManyRelationship") ).toBeTrue();
						expect( testClass.$never("getManyToManyRelationship") ).toBeTrue();
						expect( BaseBean.$once("populate") ).toBeTrue();

						expect( result ).toBeComponent();
					});


					it( "populates a one-to-many relationship", function(){
						beanmap.relationships.test.joinType = "one-to-many";

						var result = testClass.populateRelationship( bean=BaseBean, relationshipName="test" );

						expect( BaseBean.$count("getPropertyValue") ).toBe( 2 );
						expect( BaseBean.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$never("getRelationshipBean") ).toBeTrue();
						expect( testClass.$once("getOneToManyRelationship") ).toBeTrue();
						expect( testClass.$never("getManyToManyRelationship") ).toBeTrue();
						expect( BaseBean.$once("populate") ).toBeTrue();

						expect( result ).toBeArray();
					});


					it( "populates a many-to-many relationship", function(){
						beanmap.relationships.test.joinType = "many-to-many";

						var result = testClass.populateRelationship( bean=BaseBean, relationshipName="test" );

						expect( BaseBean.$count("getPropertyValue") ).toBe( 2 );
						expect( BaseBean.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$never("getRelationshipBean") ).toBeTrue();
						expect( testClass.$never("getOneToManyRelationship") ).toBeTrue();
						expect( testClass.$once("getManyToManyRelationship") ).toBeTrue();
						expect( BaseBean.$once("populate") ).toBeTrue();

						expect( result ).toBeArray();
					});


					it( "errors if the relationship isn't defined in the bean map", function(){
						expect( function(){ testClass.populateRelationship( bean=BaseBean, relationshipName="next" ); } )
							.toThrow(type="application", regex="(relationship)");
					});

				});


				// populateSprocData()
				describe("calls populateSprocData() and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "populateSprocData" );

						testClass.$( "getBeanMap", beanmap )
							.$( "getSprocRelationship", [] )
							.$( "populateByQuery" );
					});


					it( "populates the bean properties from stored procedure data", function(){
						testClass.populateSprocData( bean=BaseBean, beanmap=beanmap, data={ "_bean"=qRecords }, resultkeys=["_bean"] );

						expect( testClass.$once("populateByQuery") ).toBeTrue();
						expect( testClass.$never("getSprocRelationship") ).toBeTrue();
						expect( BaseBean.$never("populate") ).toBeTrue();
					});


					it( "doesn't populate the bean properties when the stored procedure bean query has no results", function(){
						testClass.populateSprocData( bean=BaseBean, beanmap=beanmap, data={ "_bean"=querySim("") }, resultkeys=["_bean"] );

						expect( testClass.$never("populateByQuery") ).toBeTrue();
						expect( testClass.$never("getSprocRelationship") ).toBeTrue();
						expect( BaseBean.$never("populate") ).toBeTrue();
					});


					it( "populates a bean relationship from stored procedure data", function(){
						testClass.populateSprocData( bean=BaseBean, beanmap=beanmap, data={ "test"=qRecords }, resultkeys=["test"] );

						expect( testClass.$never("populateByQuery") ).toBeTrue();
						expect( testClass.$once("getSprocRelationship") ).toBeTrue();
						expect( BaseBean.$once("populate") ).toBeTrue();
					});

				});


				// populateById()
				describe("calls populateById() and", function(){

					beforeEach(function( currentSpec ){
						SQLService.$( "read" ).$args( beanname="test", methodname="populate", params={ id = 1 } ).$results( qRecords );
						SQLService.$( "read" ).$args( beanname="test", methodname="populate", params={ id = 2 } ).$results( querySim("id") );

						testClass.$( "populateByQuery" );
					});


					it( "gets the bean record from the database and populates the data", function(){
						testClass.populateById( bean=BaseBean, id=1, beanname="test" );

						expect( BaseBean.$once("setBeanName") ).toBeTrue();
						expect( SQLService.$once("read") ).toBeTrue();
						expect( BaseBean.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("populateByQuery") ).toBeTrue();
					});


					it( "doesn't get the bean record if the id is 0", function(){
						testClass.populateById( bean=BaseBean, id=0, beanname="test" );

						expect( BaseBean.$once("setBeanName") ).toBeTrue();
						expect( SQLService.$never("read") ).toBeTrue();
						expect( BaseBean.$never("getBeanName") ).toBeTrue();
						expect( testClass.$never("populateByQuery") ).toBeTrue();
					});


					it( "doesn't populate the bean data if the there isn't a record", function(){
						testClass.populateById( bean=BaseBean, id=2, beanname="test" );

						expect( BaseBean.$once("setBeanName") ).toBeTrue();
						expect( SQLService.$once("read") ).toBeTrue();
						expect( BaseBean.$once("getBeanName") ).toBeTrue();
						expect( testClass.$never("populateByQuery") ).toBeTrue();
					});

				});


				// populateBySproc()
				describe("calls populateBySproc() and", function(){

					beforeEach(function( currentSpec ){
						sprocData = {
							_bean = qRecords
						};

						DataGateway = createEmptyMock("cfmlDataMapper.model.gateways.data");
						DataGateway.$( "readSproc", sprocData );
						testClass.$property( propertyName="DataGateway", mock=DataGateway );

						testClass.$( "getPrimaryKeyFromSprocData", 0 )
							.$( "getRelationshipKeys", [] )
							.$( "getSprocContext", "" )
							.$( "populateSprocData" );
					});


					it( "doesn't populate from a stored procedure if the primary key is 0 and there are no params", function(){
						testClass.populateBySproc( bean=BaseBean, sproc="getTest", id=0, beanname="test", params=[], resultkeys=[] );

						expect( BaseBean.$once("setBeanName") ).toBeTrue();
						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( BaseBean.$never("getBeanMap") ).toBeTrue();
						expect( testClass.$never("getRelationshipKeys") ).toBeTrue();
						expect( DataGateway.$never("readSproc") ).toBeTrue();
						expect( testClass.$never("populateSprocData") ).toBeTrue();
						expect( testClass.$never("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( BaseBean.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "doesn't populate from a stored procedure if the primary key is blank", function(){
						testClass.populateBySproc( bean=BaseBean, sproc="getTest", id="", beanname="test", params=[], resultkeys=[] );

						expect( BaseBean.$once("setBeanName") ).toBeTrue();
						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( BaseBean.$never("getBeanMap") ).toBeTrue();
						expect( testClass.$never("getRelationshipKeys") ).toBeTrue();
						expect( DataGateway.$never("readSproc") ).toBeTrue();
						expect( testClass.$never("populateSprocData") ).toBeTrue();
						expect( testClass.$never("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( BaseBean.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "populates the data and relationships from a stored procedure", function(){
						testClass.populateBySproc( bean=BaseBean, sproc="getTest", id=1, beanname="test", params=[], resultkeys=[] );

						expect( BaseBean.$once("setBeanName") ).toBeTrue();
						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( BaseBean.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("getRelationshipKeys") ).toBeTrue();
						expect( DataGateway.$once("readSproc") ).toBeTrue();
						expect( testClass.$once("populateSprocData") ).toBeTrue();
						expect( testClass.$once("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( BaseBean.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "populates the data and relationships from a stored procedure using params", function(){
						testClass.populateBySproc( bean=BaseBean, sproc="getTest", id=0, beanname="test", params=[{ name="Test" }], resultkeys=[] );

						expect( BaseBean.$once("setBeanName") ).toBeTrue();
						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( BaseBean.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("getRelationshipKeys") ).toBeTrue();
						expect( DataGateway.$once("readSproc") ).toBeTrue();
						expect( testClass.$once("populateSprocData") ).toBeTrue();
						expect( testClass.$once("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( BaseBean.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "populates the data and relationships from a stored procedure using resultkeys", function(){
						testClass.populateBySproc( bean=BaseBean, sproc="getTest", id=1, beanname="test", params=[], resultkeys=["test"] );

						expect( BaseBean.$once("setBeanName") ).toBeTrue();
						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( BaseBean.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$never("getRelationshipKeys") ).toBeTrue();
						expect( DataGateway.$once("readSproc") ).toBeTrue();
						expect( testClass.$once("populateSprocData") ).toBeTrue();
						expect( testClass.$once("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( BaseBean.$once("setPrimaryKey") ).toBeTrue();
					});

				});

			});

		});

	}

}

component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = createMock("cfmlDataMapper.model.base.bean");

		userBean = createMock("model.beans.user");

		beanFactory = createEmptyMock("framework.ioc");
		testClass.$property( propertyName="beanFactory", mock=beanFactory );

		cacheService = createEmptyMock("cfmlDataMapper.model.services.cache");
		testClass.$property( propertyName="cacheService", mock=cacheService );

		dataGateway = createEmptyMock("cfmlDataMapper.model.gateways.data");
		testClass.$property( propertyName="dataGateway", mock=dataGateway );

		validationService = createEmptyMock("cfmlDataMapper.model.services.validation");
		testClass.$property( propertyName="validationService", mock=validationService );
	}

	function run() {

		describe("The Base Bean", function(){

			beforeEach(function( currentSpec ){

				beanmap = {
					name = "test",
					primarykey = "id",
					relationships = {
						test = {
							bean = "user",
							joinType = "one",
							fkName = "testid",
							contexts = []
						}
					}
				};

			});


			describe("exposes private methods and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "clearCache" );
					makePublic( testClass, "getBeanMetaDataName" );
					makePublic( testClass, "getBeanName" );
					makePublic( testClass, "getDerivedFields" );
					makePublic( testClass, "getForeignKeyId" );
					makePublic( testClass, "getOneToManyValue" );
					makePublic( testClass, "getManyToManyValue" );
					makePublic( testClass, "getPrimaryKeyFromSprocData" );
					makePublic( testClass, "getRelationshipKeys" );
					makePublic( testClass, "getSingularBean" );
					makePublic( testClass, "getSingularSprocBean" );
					makePublic( testClass, "getSprocContext" );
					makePublic( testClass, "getSprocRelationship" );
					makePublic( testClass, "populate" );
					makePublic( testClass, "populateBySproc" );
					makePublic( testClass, "populateRelationship" );
					makePublic( testClass, "populateSprocData" );
					makePublic( testClass, "setBeanName" );
					makePublic( testClass, "setPrimaryKey" );

					qRecords = querySim("id
						1");
				});


				// clearCache()
				it( "calls the cache service to clear the bean", function(){

				});


				// getDerivedFields()
				it( "returns an empty string", function(){

				});


				// getSprocContext()
				it( "returns the context that was passed into it", function(){
					var result = testClass.getSprocContext( context="test" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "test" );
				});


				it( "returns the root bean context if the context was passed in but doesn't have a length", function(){
					var result = testClass.getSprocContext( context="" );

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBe( "_bean" );
				});


				it( "returns and empty string if the context doesn't exist", function(){
					var result = testClass.getSprocContext();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				describe("uses bean metadata and", function(){

					beforeEach(function( currentSpec ){

					});


					// getBeanMetaDataName()
					it( "get's the bean's name from the metadata", function(){
						var result = testClass.getBeanMetaDataName();

						expect( result ).notToBeEmpty();
					});


					describe("has the bean metadata and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "getBeanMetaDataName", "test" );
						});


						// getBeanName()
						it( "returns the bean's name from the metadata", function(){
							testClass.getBeanName();

							expect( testClass.$once("getBeanMetaDataName") ).toBeTrue();
						});


						// setBeanName()
						it( "updates the cached bean name with the argument", function(){
							testClass.setBeanName( bean="test" );

							expect( testClass.$never("getBeanMetaDataName") ).toBeTrue();
						});


						it( "updates the cached bean name with the metadata", function(){
							testClass.setBeanName( bean="" );

							expect( testClass.$once("getBeanMetaDataName") ).toBeTrue();
						});

					});

				});


				describe("uses bean properties and", function(){

					beforeEach(function( currentSpec ){

					});


					// getForeignKeyId()
					it( "returns 0 for the relationship foreign key id from the bean's properties if it doesn't exist", function(){
						var result = testClass.getForeignKeyId( fkName="testid" );

						expect( result ).toBeTypeOf( "numeric" );
						expect( result ).toBe( 0 );
					});


					it( "returns the relationship foreign key id from the bean's properties if it exists", function(){
						testClass.$property( propertyName="testid", mock=1 );

						var result = testClass.getForeignKeyId( fkName="testid" );

						expect( result ).toBeTypeOf( "numeric" );
						expect( result ).toBe( 1 );
					});

				});


				describe("uses the dataFactory and", function(){

					beforeEach(function( currentSpec ){
						dataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");

						dataFactory.$( "get", userBean )
							.$( "getBeanMap", beanmap )
							.$( "getBeans", [userBean] )
							.$( "list", [userBean] );
						testClass.$property( propertyName="dataFactory", mock=dataFactory );

						dataGateway.$( "readByJoinTable", querySim("") );

						testClass.$( "getBeanName", "test" )
							.$( "getForeignKeyId", 1 );
					});


					// getBeanMap()
					it( "returns a structure with the bean's data factory beanmap", function(){
						var result = testClass.getBeanMap();

						expect( dataFactory.$once("getBeanMap") ).toBeTrue();

						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( dataFactory.$once("getBeanMap") ).toBeTrue();
					});


					// getOneToManyValue()
					it( "returns an array of beans representing a one-to-many relationship", function(){
						testClass.$property( propertyName="id", mock=1 );

						var result = testClass.getOneToManyValue( primarykey="id", relationship=beanmap.relationships.test );

						expect( dataFactory.$once("list") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns an empty array for the one-to-many relationship if the bean record does not exist", function(){
						testClass.$property( propertyName="id", mock=0 );

						var result = testClass.getOneToManyValue( primarykey="id", relationship=beanmap.relationships.test );

						expect( dataFactory.$never("list") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toBeEmpty();
					});


					// getManyToManyValue()
					it( "returns an array of beans representing a many-to-many relationship", function(){
						testClass.$property( propertyName="id", mock=1 );

						var result = testClass.getManyToManyValue( primarykey="id", relationship=beanmap.relationships.test );

						expect( dataGateway.$once("readByJoinTable") ).toBeTrue();
						expect( dataFactory.$once("getBeans") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns an empty array for the many-to-many relationship if the bean record does not exist", function(){
						testClass.$property( propertyName="id", mock=0 );

						var result = testClass.getManyToManyValue( primarykey="id", relationship=beanmap.relationships.test );

						expect( dataGateway.$never("readByJoinTable") ).toBeTrue();
						expect( dataFactory.$never("getBeans") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toBeEmpty();
					});


					// getSingularBean()
					it( "returns a bean for a one-to-one or many-to-one relationship", function(){
						var result = testClass.getSingularBean( primarykey="id", relationship=beanmap.relationships.test );

						expect( dataFactory.$once("get") ).toBeTrue();
						expect( testClass.$once("getForeignKeyId") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					// getSingularSprocBean()
					it( "returns a bean populated from the stored procedure query", function(){
						var result = testClass.getSingularSprocBean( bean="test", qRecords=qRecords );

						expect( dataFactory.$once("getBeans") ).toBeTrue();
						expect( dataFactory.$never("get") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns an empty bean if the stored procedure query has no results", function(){
						dataFactory.$( "getBeans", [] );

						var result = testClass.getSingularSprocBean( bean="test", qRecords=querySim("") );

						expect( dataFactory.$once("getBeans") ).toBeTrue();
						expect( dataFactory.$once("get") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					// getSprocRelationship()
					describe("calls getSprocRelationship() and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "getSingularSprocBean", userBean );
						});


						it( "returns a bean from the stored procedure data if the joinType is one", function(){
							var result = testClass.getSprocRelationship( bean="test", joinType="one", qRecords=qRecords );

							expect( testClass.$once("getSingularSprocBean") ).toBeTrue();
							expect( dataFactory.$never("getBeans") ).toBeTrue();

							expect( result ).toBeTypeOf( "component" );
							expect( result ).toBeInstanceOf( "model.beans.user" );
						});


						it( "returns an array from the stored procedure data if the joinType is many", function(){
							var result = testClass.getSprocRelationship( bean="test", joinType="many", qRecords=qRecords );

							expect( testClass.$never("getSingularSprocBean") ).toBeTrue();
							expect( dataFactory.$once("getBeans") ).toBeTrue();

							expect( result ).toBeTypeOf( "array" );
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});


						it( "returns an array from the stored procedure data if the joinType is one-to-many", function(){
							var result = testClass.getSprocRelationship( bean="test", joinType="one-to-many", qRecords=qRecords );

							expect( testClass.$never("getSingularSprocBean") ).toBeTrue();
							expect( dataFactory.$once("getBeans") ).toBeTrue();

							expect( result ).toBeTypeOf( "array" );
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});


						it( "returns an array from the stored procedure data if the joinType is many-to-many", function(){
							var result = testClass.getSprocRelationship( bean="test", joinType="many-to-many", qRecords=qRecords );

							expect( testClass.$never("getSingularSprocBean") ).toBeTrue();
							expect( dataFactory.$once("getBeans") ).toBeTrue();

							expect( result ).toBeTypeOf( "array" );
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});

					});

				});


				describe("uses the beanmap and", function(){

					beforeEach(function( currentSpec ){
						testClass.$property( propertyName="id", mock=1 );

						testClass.$( "getBeanMap", beanmap );
					});


					// getPrimaryKeyFromSprocData()
					it( "returns the bean's id from the populated primary key", function(){
						var result = testClass.getPrimaryKeyFromSprocData( sprocData={ "_bean"=qRecords } );

						expect( testClass.$once("getBeanMap") ).toBeTrue();

						expect( result ).toBeTypeOf( "numeric" );
						expect( result ).toBe( 1 );
					});


					it( "returns 0 for the bean's id if the stored procedure had no bean data", function(){
						var result = testClass.getPrimaryKeyFromSprocData( sprocData={ "_bean"=querySim("") } );

						expect( testClass.$never("getBeanMap") ).toBeTrue();

						expect( result ).toBeTypeOf( "numeric" );
						expect( result ).toBe( 0 );
					});


					// getRelationshipKeys()
					it( "returns an array of the bean key and relationship keys for the stored procedure context", function(){
						var result = testClass.getRelationshipKeys( context="test" );

						expect( testClass.$once("getBeanMap") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toHaveLength( 2 );
					});


					it( "returns an array with the bean key for the stored procedure when there isn't a context", function(){
						var result = testClass.getRelationshipKeys( context="" );

						expect( testClass.$once("getBeanMap") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toHaveLength( 1 );
					});


					it( "returns an array with the bean key for the stored procedure when the context is '_bean'", function(){
						var result = testClass.getRelationshipKeys( context="_bean" );

						expect( testClass.$once("getBeanMap") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toHaveLength( 1 );
					});


					it( "returns an array with the bean key for the stored procedure when there are no relationships", function(){
						beanmap.relationships = {};

						var result = testClass.getRelationshipKeys( context="test" );

						expect( testClass.$once("getBeanMap") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toHaveLength( 1 );
					});


					// setPrimaryKey()
					it( "set's the bean's primary key from the bean map data", function(){
						testClass.setPrimaryKey( primarykey=1 );

						expect( testClass.$once("getBeanMap") ).toBeTrue();
					});

				});


				describe("uses the beanFactory and", function(){

					beforeEach(function( currentSpec ){
						beanFactory.$( "injectProperties" );
					});


					// populateBean()
					it( "processes a query and injects it into the bean", function(){
						testClass.populateBean( qRecord=qRecords );

						expect( beanFactory.$once("injectProperties") ).toBeTrue();
					});


					// populateRelationship()
					describe("calls populateRelationship() and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "getBeanMap", beanmap )
								.$( "getManyToManyValue", [] )
								.$( "getOneToManyValue", [] )
								.$( "getSingularBean", userBean )
								.$( "getNext" )
								.$( "getTest" );
						});


						it( "populates a one-to-one or many-to-one relationship", function(){
							testClass.populateRelationship( relationshipName="test" );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$once("getSingularBean") ).toBeTrue();
							expect( testClass.$never("getOneToManyValue") ).toBeTrue();
							expect( testClass.$never("getManyToManyValue") ).toBeTrue();
							expect( beanFactory.$once("injectProperties") ).toBeTrue();
						});


						it( "populates a one-to-many relationship", function(){
							beanmap.relationships.test.joinType = "one-to-many";

							testClass.populateRelationship( relationshipName="test" );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$never("getSingularBean") ).toBeTrue();
							expect( testClass.$once("getOneToManyValue") ).toBeTrue();
							expect( testClass.$never("getManyToManyValue") ).toBeTrue();
							expect( beanFactory.$once("injectProperties") ).toBeTrue();
						});


						it( "populates a many-to-many relationship", function(){
							beanmap.relationships.test.joinType = "many-to-many";

							testClass.populateRelationship( relationshipName="test" );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$never("getSingularBean") ).toBeTrue();
							expect( testClass.$never("getOneToManyValue") ).toBeTrue();
							expect( testClass.$once("getManyToManyValue") ).toBeTrue();
							expect( beanFactory.$once("injectProperties") ).toBeTrue();
						});


						it( "errors if the relationship isn't defined in the bean map", function(){
							expect( function(){ testClass.populateRelationship( relationshipName="next" ); } ).toThrow(type="application", regex="(relationship)");
						});

					});


					// populateSprocData()
					describe("calls populateSprocData() and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "getBeanMap", beanmap )
								.$( "getSprocRelationship", [] )
								.$( "populateBean" );
						});


						it( "populates the bean properties from stored procedure data", function(){
							testClass.populateSprocData( data={ "_bean"=qRecords }, resultkeys=["_bean"] );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$once("populateBean") ).toBeTrue();
							expect( testClass.$never("getSprocRelationship") ).toBeTrue();
							expect( beanFactory.$never("injectProperties") ).toBeTrue();
						});


						it( "doesn't populate the bean properties when the stored procedure bean query has no results", function(){
							testClass.populateSprocData( data={ "_bean"=querySim("") }, resultkeys=["_bean"] );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$never("populateBean") ).toBeTrue();
							expect( testClass.$never("getSprocRelationship") ).toBeTrue();
							expect( beanFactory.$never("injectProperties") ).toBeTrue();
						});


						it( "populates a bean relationship from stored procedure data", function(){
							testClass.populateSprocData( data={ "test"=qRecords }, resultkeys=["test"] );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$never("populateBean") ).toBeTrue();
							expect( testClass.$once("getSprocRelationship") ).toBeTrue();
							expect( beanFactory.$once("injectProperties") ).toBeTrue();
						});

					});

				});


				// populate()
				describe("calls populate() and", function(){

					beforeEach(function( currentSpec ){
						dataGateway.$( "read" ).$args( bean="test", params={ id = 1 } ).$results( qRecords );
						dataGateway.$( "read" ).$args( bean="test", params={ id = 2 } ).$results( querySim("id") );

						testClass.$( "getBeanName", "test" )
							.$( "populateBean" )
							.$( "setBeanName" );
					});


					it( "gets the bean record from the database and populates the data", function(){
						testClass.populate( id=1, bean="test" );

						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( dataGateway.$once("read") ).toBeTrue();
						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("populateBean") ).toBeTrue();
					});


					it( "doesn't get the bean record if the id is 0", function(){
						testClass.populate( id=0, bean="test" );

						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( dataGateway.$never("read") ).toBeTrue();
						expect( testClass.$never("getBeanName") ).toBeTrue();
						expect( testClass.$never("populateBean") ).toBeTrue();
					});


					it( "doesn't populate the bean data if the there isn't a record", function(){
						testClass.populate( id=2, bean="test" );

						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( dataGateway.$once("read") ).toBeTrue();
						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$never("populateBean") ).toBeTrue();
					});

				});


				// populateBySproc()
				describe("calls populateBySproc() and", function(){

					beforeEach(function( currentSpec ){
						sprocData = {
							_bean = qRecords
						};

						dataGateway.$( "readSproc", sprocData );

						testClass.$( "getPrimaryKeyFromSprocData", 0 )
							.$( "getRelationshipKeys", [] )
							.$( "getSprocContext", "" )
							.$( "populateSprocData" )
							.$( "setBeanName" )
							.$( "setPrimaryKey" );
					});


					it( "doesn't populate from a stored procedure if the primary key is 0 and there are no params", function(){
						testClass.populateBySproc( sproc="getTest", id=0, bean="test", params=[], resultkeys=[] );

						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( testClass.$never("getRelationshipKeys") ).toBeTrue();
						expect( dataGateway.$never("readSproc") ).toBeTrue();
						expect( testClass.$never("populateSprocData") ).toBeTrue();
						expect( testClass.$never("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "doesn't populate from a stored procedure if the primary key is blank", function(){
						testClass.populateBySproc( sproc="getTest", id="", bean="test", params=[], resultkeys=[] );

						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( testClass.$never("getRelationshipKeys") ).toBeTrue();
						expect( dataGateway.$never("readSproc") ).toBeTrue();
						expect( testClass.$never("populateSprocData") ).toBeTrue();
						expect( testClass.$never("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "populates the data and relationships from a stored procedure", function(){
						testClass.populateBySproc( sproc="getTest", id=1, bean="test", params=[], resultkeys=[] );

						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( testClass.$once("getRelationshipKeys") ).toBeTrue();
						expect( dataGateway.$once("readSproc") ).toBeTrue();
						expect( testClass.$once("populateSprocData") ).toBeTrue();
						expect( testClass.$once("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "populates the data and relationships from a stored procedure using params", function(){
						testClass.populateBySproc( sproc="getTest", id=0, bean="test", params=[{ name="Test" }], resultkeys=[] );

						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( testClass.$once("getRelationshipKeys") ).toBeTrue();
						expect( dataGateway.$once("readSproc") ).toBeTrue();
						expect( testClass.$once("populateSprocData") ).toBeTrue();
						expect( testClass.$once("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "populates the data and relationships from a stored procedure using resultkeys", function(){
						testClass.populateBySproc( sproc="getTest", id=1, bean="test", params=[], resultkeys=["test"] );

						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( testClass.$never("getRelationshipKeys") ).toBeTrue();
						expect( dataGateway.$once("readSproc") ).toBeTrue();
						expect( testClass.$once("populateSprocData") ).toBeTrue();
						expect( testClass.$once("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
					});

				});

			});


			describe("initializes and", function(){

				beforeEach(function( currentSpec ){

				});


				// delete()
				it( "deletes the record from the database", function(){

				});


				it( "returns an error if there was an issue deleting the record from the database", function(){

				});


				// exists()
				it( "returns true if the bean has an id", function(){

				});


				it( "returns false if the bean's id is 0", function(){

				});


				it( "returns false if the bean has been soft deleted", function(){

				});


				// getId()
				it( "returns a number representing the bean's primary key", function(){

				});


				// getIsDeleted()
				it( "returns a boolean representing the bean soft delete status", function(){

				});


				// getPropertyValue()
				it( "returns a string with the value of the property", function(){

				});


				it( "returns a string with the default value of the property", function(){

				});


				// getSessionData()
				it( "returns a structure of the bean's property values and derived fields", function(){

				});


				// onMissingMethod()
				it( "ignores function names starting with 'set'", function(){

				});


				it( "errors if the function name does not start with 'set'", function(){

				});


				// save()
				it( "successfully creates a bean", function(){

				});


				it( "successfully updates a bean", function(){

				});


				it( "is unsuccessful if the bean validation process errors", function(){

				});


				it( "is unsuccessful if the save process errors", function(){

				});


				// validate()
				it( "returns an array from the validation service", function(){

				});

			});


			describe("on initialization", function(){

				beforeEach(function( currentSpec ){
					testClass.$( "getBeanMap", beanmap );
				});


				// setPrimaryKey()
				it( "set's the bean's primary key when the dataFactory doesn't exist", function(){
					testClass.setPrimaryKey( primarykey=1 );

					expect( testClass.$never("getBeanMap") ).toBeTrue();
				});


				// init()
				it( "populates the bean", function(){

				});

			});

		});

	}

}

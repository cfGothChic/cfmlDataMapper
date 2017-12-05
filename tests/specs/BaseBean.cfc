component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = createMock("cfmlDataMapper.model.base.bean");

		userBean = createMock("model.beans.user");

		beanFactory = createEmptyMock("framework.ioc");
		testClass.$property( propertyName="beanFactory", mock=beanFactory );

		cacheService = createEmptyMock("cfmlDataMapper.model.services.cache");
		testClass.$property( propertyName="cacheService", mock=cacheService );

		dataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");
		testClass.$property( propertyName="dataFactory", mock=dataFactory );

		dataGateway = createEmptyMock("cfmlDataMapper.model.gateways.data");
		testClass.$property( propertyName="dataGateway", mock=dataGateway );

		validationService = createEmptyMock("cfmlDataMapper.model.services.validation");
		testClass.$property( propertyName="validationService", mock=validationService );
	}

	function run() {

		describe("The Base Bean", function(){

			beforeEach(function( currentSpec ){

			});


			describe("exposes private methods and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getBeanMetaDataName" );
					makePublic( testClass, "getBeanName" );
					makePublic( testClass, "getForeignKeyId" );
					makePublic( testClass, "getOneToManyValue" );
					makePublic( testClass, "getManyToManyValue" );
					makePublic( testClass, "getSingularValue" );
					makePublic( testClass, "populate" );
					makePublic( testClass, "populateRelationship" );
					makePublic( testClass, "setBeanName" );

					qRecords = querySim("id
						1");

					beanmap = {
						name = "test",
						primarykey = "id",
						relationships = {
							test = {
								bean = "user",
								joinType = "one",
								fkName = "testid"
							}
						}
					};
				});


				// clearCache()
				it( "calls the cache service to clear the bean", function(){

				});


				// getDerivedFields()
				it( "returns an empty string", function(){

				});


				// getRelationshipKeys()
				it( "returns an array of the bean key and relationship keys for the stored procedure context", function(){

				});


				it( "returns an array of with the bean key for the stored procedure when there isn't a context", function(){

				});


				// populateBySproc()
				it( "calls a stored procedure representing the bean data and populates its data and relationships", function(){

				});


				// populateSprocData()
				it( "loops around resulting sproc data and populates the bean and its relationships", function(){

				});


				// setPrimaryKey()
				it( "set's the bean's primary key when the dataFactory doesn't exist", function(){

				});


				it( "set's the bean's primary key from the bean map data", function(){

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
						dataFactory.$( "get", userBean )
							.$( "getBeanMap", beanmap )
							.$( "getBeans", [userBean] )
							.$( "list", [userBean] );

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

					// getSingularValue()
					it( "returns a bean for a one-to-one or many-to-one relationship", function(){
						var result = testClass.getSingularValue( primarykey="id", relationship=beanmap.relationships.test );

						expect( dataFactory.$once("get") ).toBeTrue();
						expect( testClass.$once("getForeignKeyId") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});

				});


				describe("uses the beanFactory and", function(){

					beforeEach(function( currentSpec ){
						beanFactory.$( "injectProperties" );
					});


					// populateBean()
					it( "processes a query and injects it into the bean", function(){qRecords
						testClass.populateBean( qRecord=qRecords );

						expect( beanFactory.$once("injectProperties") ).toBeTrue();
					});


					// populateRelationship()
					describe("calls populateRelationship() and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "getBeanMap", beanmap )
								.$( "getManyToManyValue", [] )
								.$( "getOneToManyValue", [] )
								.$( "getSingularValue", userBean )
								.$( "getNext" )
								.$( "getTest" );
						});


						it( "populates a one-to-one or many-to-one relationship", function(){
							testClass.populateRelationship( relationshipName="test" );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$once("getSingularValue") ).toBeTrue();
							expect( testClass.$never("getOneToManyValue") ).toBeTrue();
							expect( testClass.$never("getManyToManyValue") ).toBeTrue();
							expect( beanFactory.$once("injectProperties") ).toBeTrue();
						});


						it( "populates a one-to-many relationship", function(){
							beanmap.relationships.test.joinType = "one-to-many";

							testClass.populateRelationship( relationshipName="test" );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$never("getSingularValue") ).toBeTrue();
							expect( testClass.$once("getOneToManyValue") ).toBeTrue();
							expect( testClass.$never("getManyToManyValue") ).toBeTrue();
							expect( beanFactory.$once("injectProperties") ).toBeTrue();
						});


						it( "populates a many-to-many relationship", function(){
							beanmap.relationships.test.joinType = "many-to-many";

							testClass.populateRelationship( relationshipName="test" );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$never("getSingularValue") ).toBeTrue();
							expect( testClass.$never("getOneToManyValue") ).toBeTrue();
							expect( testClass.$once("getManyToManyValue") ).toBeTrue();
							expect( beanFactory.$once("injectProperties") ).toBeTrue();
						});


						it( "errors if the relationship isn't defined in the bean map", function(){
							expect( function(){ testClass.populateRelationship( relationshipName="next" ); } ).toThrow(type="application", regex="(relationship)");
						});

					});

				});


				describe("calls populate() and", function(){

					beforeEach(function( currentSpec ){
						dataGateway.$( "read" ).$args( bean="test", params={ id = 1 } ).$results( qRecords );
						dataGateway.$( "read" ).$args( bean="test", params={ id = 2 } ).$results( querySim("id") );

						testClass.$( "getBeanName", "test" )
							.$( "populateBean" )
							.$( "setBeanName" );
					});


					// populate()
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


			// init()
			describe("on initialization", function(){

				it( "populates the bean", function(){

				});

			});

		});

	}

}

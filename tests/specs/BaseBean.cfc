component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = createMock("cfmlDataMapper.model.base.bean");

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

				});


				// clearCache()
				it( "calls the cache service to clear the bean", function(){

				});


				// getBeanName()
				it( "returns the bean's name from the metadata", function(){

				});


				// getDerivedFields()
				it( "returns an empty string", function(){

				});


				// getManyToManyValue()
				it( "returns an array of beans representing a many-to-many relationship", function(){

				});


				it( "returns an empty array for the many-to-many relationship if the bean record does not exist", function(){

				});


				// getOneToManyValue()
				it( "returns an array of beans representing a one-to-many relationship", function(){

				});


				it( "returns an empty array for the one-to-many relationship if the bean record does not exist", function(){

				});


				// getRelationshipKeys()
				it( "returns an array of the bean key and relationship keys for the stored procedure context", function(){

				});


				it( "returns an array of with the bean key for the stored procedure when there isn't a context", function(){

				});


				// getSingularValue()
				it( "returns a bean for a one-to-one or many-to-one relationship", function(){

				});


				// populate()
				it( "gets the bean record from the database and populates the data", function(){

				});


				// populateBySproc()
				it( "calls a stored procedure representing the bean data and populates its data and relationships", function(){

				});


				// populateRelationship()
				it( "populates a one-to-one or many-to-one relationship", function(){

				});


				it( "populates a one-to-many relationship", function(){

				});


				it( "populates a many-to-many relationship", function(){

				});


				it( "errors if the relationship isn't defined in the bean map", function(){

				});


				// populateSprocData()
				it( "loops around resulting sproc data and populates the bean and its relationships", function(){

				});


				// setBeanName()
				it( "updates the cached bean name", function(){

				});


				// setPrimaryKey()
				it( "set's the bean's primary key when the dataFactory doesn't exist", function(){

				});


				it( "set's the bean's primary key from the bean map data", function(){

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


				// getBeanMap()
				it( "returns a structure with the bean's data factory beanmap", function(){

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


				// populateBean()
				it( "processes a query and injects it into the bean", function(){

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

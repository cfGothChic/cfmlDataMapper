component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = createMock("cfmlDataMapper.model.base.bean");
	}

	function run() {

		describe("The Base Bean", function(){

			beforeEach(function( currentSpec ){

				beanmap = {
					name = "test",
					primarykey = "id",
					cached = false,
					properties = {
						test = {
							defaultvalue = "test"
						}
					}
				};

			});


			describe("initializes and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getDerivedFields" );

					qRecords = querySim("id
						1");

					UtilityService = createEmptyMock("cfmlDataMapper.model.services.utility");
					UtilityService.$( "getResultStruct", { "success"=true, "code"=001, "messages"=[] } );
					testClass.$property( propertyName="UtilityService", mock=UtilityService );
				});


				// getDerivedFields()
				it( "returns an empty string of derived fields", function(){
					var result = testClass.getDerivedFields();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
				});


				describe("uses bean metadata and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getBeanMetaDataName" );
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
							testClass.setBeanName( beanname="test" );

							expect( testClass.$never("getBeanMetaDataName") ).toBeTrue();
						});


						it( "updates the cached bean name with the metadata", function(){
							testClass.setBeanName( beanname="" );

							expect( testClass.$once("getBeanMetaDataName") ).toBeTrue();
						});

					});

				});


				describe("uses bean properties and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getBeanPropertyValue" );

						userBean = createMock("model.beans.user");
					});


					// getId()
					it( "returns 0 if the id property doesn't exist", function(){
						var result = testClass.getId();

						expect( result ).toBeTypeOf( "numeric" );
						expect( result ).toBe( 0 );
					});


					it( "returns a number representing the bean's id property", function(){
						testClass.$property( propertyName="id", mock=1 );

						var result = testClass.getId();

						expect( result ).toBeTypeOf( "numeric" );
						expect( result ).toBe( 1 );
					});


					// getIsDeleted()
					it( "returns false if the bean doesn't have a soft delete property defined", function(){
						var result = testClass.getIsDeleted();

						expect( result ).toBeTypeOf( "boolean" );
						expect( result ).toBeFalse();
					});


					it( "returns a boolean representing the bean soft delete status", function(){
						testClass.$property( propertyName="isDeleted", mock=1 );

						var result = testClass.getIsDeleted();

						expect( result ).toBeTypeOf( "boolean" );
						expect( result ).toBeTrue();
					});


					// getBeanPropertyValue()
					describe("calls getBeanPropertyValue() and", function(){

						it( "returns an array value of a property", function(){
							testClass.$property( propertyName="test", mock=[] );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "array" );
							expect( result ).toBeEmpty();
						});


						it( "returns a binary value of a property", function(){
							var test = toBinary("dGVzdA==");
							testClass.$property( propertyName="test", mock=test );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "binary" );
							expect( result ).toBe( test );
						});


						it( "returns a boolean value of a property", function(){
							testClass.$property( propertyName="test", mock="yes" );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "boolean" );
							expect( result ).toBeTrue();
						});


						it( "returns a component value of a property", function(){
							testClass.$property( propertyName="test", mock=userBean );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "component" );
							expect( result ).toBeInstanceOf( "model.beans.user" );
						});


						it( "returns a date value of a property", function(){
							testClass.$property( propertyName="test", mock=now() );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "date" );
							expect( result ).notToBeEmpty();
						});


						it( "returns a float value of a property", function(){
							testClass.$property( propertyName="test", mock=1.1 );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "float" );
							expect( result ).toBe( 1.1 );
						});


						it( "returns a integer value of a property", function(){
							testClass.$property( propertyName="test", mock=1 );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "integer" );
							expect( result ).toBe( 1 );
						});


						it( "returns a numeric value of a property", function(){
							testClass.$property( propertyName="test", mock=1 );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "numeric" );
							expect( result ).toBe( 1 );
						});


						it( "returns a query value of a property", function(){
							testClass.$property( propertyName="test", mock=querySim("") );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "query" );
							expect( result ).toBeEmpty();
						});


						it( "returns a string value of a property", function(){
							testClass.$property( propertyName="test", mock="test" );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toBe( "test" );
						});


						it( "returns a struct value of a property", function(){
							testClass.$property( propertyName="test", mock={} );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "struct" );
							expect( result ).toBeEmpty();
						});


						it( "returns a time value of a property", function(){
							testClass.$property( propertyName="test", mock=createTime(1, 0, 0) );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "time" );
							expect( result ).notToBeEmpty();
						});


						it( "returns a url value of a property", function(){
							testClass.$property( propertyName="test", mock="http://12.0.0.1" );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "url" );
							expect( result ).notToBeEmpty();
						});


						it( "returns a uuid value of a property", function(){
							testClass.$property( propertyName="test", mock=createUUID() );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "uuid" );
							expect( result ).notToBeEmpty();
						});


						it( "returns a xml value of a property", function(){
							testClass.$property( propertyName="test", mock="<root><test>1</test></root>" );

							var result = testClass.getBeanPropertyValue( propertyname="test" );

							expect( result ).toBeTypeOf( "xml" );
							expect( result ).notToBeEmpty();
						});

					});


					// exists()
					describe("calls exists() and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "getId", 1 )
								.$( "getIsDeleted", 0 );
						});


						it( "returns true if the bean has an id and isn't soft deleted", function(){
							var result = testClass.exists();

							expect( testClass.$once("getId") ).toBeTrue();
							expect( testClass.$once("getIsDeleted") ).toBeTrue();

							expect( result ).toBeTypeOf( "boolean" );
							expect( result ).toBeTrue();
						});


						it( "returns false if the bean's id is 0", function(){
							testClass.$( "getId", 0 );

							var result = testClass.exists();

							expect( testClass.$once("getId") ).toBeTrue();
							expect( testClass.$never("getIsDeleted") ).toBeTrue();

							expect( result ).toBeTypeOf( "boolean" );
							expect( result ).toBeFalse();
						});


						it( "returns false if the bean has been soft deleted", function(){
							testClass.$( "getIsDeleted", 1 );

							var result = testClass.exists();

							expect( testClass.$once("getId") ).toBeTrue();
							expect( testClass.$once("getIsDeleted") ).toBeTrue();

							expect( result ).toBeTypeOf( "boolean" );
							expect( result ).toBeFalse();
						});

					});

				});


				describe("uses the DataFactory and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "clearCache" );

						DataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");

						DataFactory.$( "get", userBean )
							.$( "getBeanMap", beanmap )
							.$( "getBeans", [userBean] )
							.$( "list", [userBean] );
						testClass.$property( propertyName="DataFactory", mock=DataFactory );

						SQLService = createEmptyMock("cfmlDataMapper.model.services.sql");
						SQLService.$( "readByJoin", querySim("") );
						testClass.$property( propertyName="SQLService", mock=SQLService );

						testClass.$( "getBeanName", "test" );
					});


					// clearCache()
					it( "calls the cache service to clear the bean", function(){
						var CacheService = createEmptyMock("cfmlDataMapper.model.services.cache");
						CacheService.$( "clearBean" );
						testClass.$property( propertyName="CacheService", mock=CacheService );

						testClass.clearCache();

						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( CacheService.$once("clearBean") ).toBeTrue();
					});


					// getBeanMap()
					it( "returns a structure with the bean's data factory beanmap", function(){
						var result = testClass.getBeanMap();

						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( DataFactory.$once("getBeanMap") ).toBeTrue();

						expect( result ).toBeTypeOf( "struct" );
						expect( result ).notToBeEmpty();
					});


					// delete()
					describe("calls delete() and", function(){

						beforeEach(function( currentSpec ){
							SQLService.$( "delete" );

							testClass.$( "getBeanMap", beanmap )
								.$( "getBeanName", "test" );
						});


						afterEach(function( currentSpec ){
							expect( deleteResult ).toBeTypeOf( "struct" );

							expect( deleteResult ).toHaveKey( "success" );
							expect( deleteResult.success ).toBeTypeOf( "boolean" );

							expect( deleteResult ).toHaveKey( "code" );
							expect( deleteResult.code ).toBeTypeOf( "numeric" );

							expect( deleteResult ).toHaveKey( "messages" );
							expect( deleteResult.messages ).toBeTypeOf( "array" );

							for ( var key in deleteResult ) {
								expect( key ).toBeWithCase( lCase(key) );
							}
						});


						it( "deletes the record from the database", function(){
							var result = testClass.delete();

							expect( UtilityService.$once("getResultStruct") ).toBeTrue();
							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( SQLService.$once("delete") ).toBeTrue();
							expect( testClass.$once("getBeanName") ).toBeTrue();

							expect( result.success ).toBeTrue();
							expect( result.code ).toBe( 001 );
							expect( result.messages ).toBeEmpty();

							deleteResult = result;
						});


						it( "returns an error if there was an issue deleting the record from the database", function(){
							testClass.$( "getBeanMap" ).$throws( type="application" );

							var result = testClass.delete();

							expect( UtilityService.$once("getResultStruct") ).toBeTrue();
							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( SQLService.$never("delete") ).toBeTrue();
							expect( testClass.$once("getBeanName") ).toBeTrue();

							expect( result.success ).toBeFalse();
							expect( result.code ).toBe( 500 );
							expect( result.messages ).notToBeEmpty();

							expect( result ).toHaveKey( "error" );
							if ( structKeyExists(server, "lucee") ) {
								expect( result.error ).toBeTypeOf( "struct" );
							}

							deleteResult = result;
						});

					});

				});


				describe("uses the beanmap and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getPropertyDefault" );

						testClass.$property( propertyName="id", mock=1 );

						testClass.$( "getBeanMap", beanmap );
					});


					// getPropertyDefault()
					it( "returns the property default defined in the beanmap", function(){
						var result = testClass.getPropertyDefault( propertyname="test" );

						expect( testClass.$once("getBeanMap") ).toBeTrue();

						expect( result ).toBeTypeOf( "string" );
						expect( result ).toBe( "test" );
					});


					it( "returns an empty string if the property doesn't have a default defined in the beanmap", function(){
						beanmap.properties.test.defaultvalue = "";

						var result = testClass.getPropertyDefault( propertyname="test" );

						expect( testClass.$once("getBeanMap") ).toBeTrue();

						expect( result ).toBeTypeOf( "string" );
						expect( result ).toBeEmpty();
					});


					// setPrimaryKey()
					it( "set's the bean's primary key from the bean map data", function(){
						testClass.setPrimaryKey( primarykey=1 );

						expect( testClass.$once("getBeanMap") ).toBeTrue();
					});


					// validate()
					it( "returns an array from the validation service", function(){
						var ValidationService = createEmptyMock("cfmlDataMapper.model.services.validation");
						ValidationService.$( "validateBean", [] );
						testClass.$property( propertyName="ValidationService", mock=ValidationService );

						var result = testClass.validate();

						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( ValidationService.$once("validateBean") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toBeEmpty();
					});

					// getPropertyValue()
					describe("calls getPropertyValue() and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "getBeanPropertyValue", "test" )
								.$( "getPropertyDefault", "user" );
						});


						it( "returns the value of the property", function(){
							var result = testClass.getPropertyValue( propertyname="test" );

							expect( testClass.$once("getBeanPropertyValue") ).toBeTrue();
							expect( testClass.$never("getPropertyDefault") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toBe( "test" );
						});


						it( "returns the default value of the property if the bean property is empty", function(){
							testClass.$( "getBeanPropertyValue", "" );

							var result = testClass.getPropertyValue( propertyname="test" );

							expect( testClass.$once("getBeanPropertyValue") ).toBeTrue();
							expect( testClass.$once("getPropertyDefault") ).toBeTrue();

							expect( result ).toBeTypeOf( "string" );
							expect( result ).toBe( "user" );
						});

					});


					// getProperties()
					describe("calls getProperties() and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "getDerivedFields", "" );

							testClass.$( "getPropertyValue" ).$args( propertyname="test" ).$results( "test" );
							testClass.$( "getPropertyValue" ).$args( propertyname="user" ).$results( userBean );
						});


						it( "returns a structure of the bean's property values", function(){
							var result = testClass.getProperties( data={} );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$once("getPropertyValue") ).toBeTrue();
							expect( testClass.$once("getDerivedFields") ).toBeTrue();

							expect( result ).toBeTypeOf( "struct" );
							expect( result ).toHaveLength( 1 );
						});


						it( "returns a structure of the bean's property values and derived fields", function(){
							testClass.$( "getDerivedFields", "user" );

							var result = testClass.getProperties( data={} );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$count("getPropertyValue") ).toBe( 2 );
							expect( testClass.$count("getDerivedFields") ).toBe( 2 );

							expect( result ).toBeTypeOf( "struct" );
							expect( result ).toHaveLength( 2 );
						});


						it( "returns a structure of the bean's property values appended to the data structure", function(){
							var result = testClass.getProperties( data={ "foo"="bar" } );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$once("getPropertyValue") ).toBeTrue();
							expect( testClass.$once("getDerivedFields") ).toBeTrue();

							expect( result ).toBeTypeOf( "struct" );
							expect( result ).toHaveLength( 2 );
						});

					});

				});


				// save()
				describe("calls save() and", function(){

					beforeEach(function( currentSpec ){
						SQLService.$( "create", 1 )
							.$( "update" );

						testClass.$( "clearCache" )
							.$( "getBeanMap", beanmap )
							.$( "getBeanName", "test" )
							.$( "setPrimaryKey" )
							.$( "validate", [] );

						testClass.$property( propertyName="id", mock=1 );
					});


					afterEach(function( currentSpec ){
						expect( saveResult ).toBeTypeOf( "struct" );

						expect( saveResult ).toHaveKey( "success" );
						expect( saveResult.success ).toBeTypeOf( "boolean" );

						expect( saveResult ).toHaveKey( "code" );
						expect( saveResult.code ).toBeTypeOf( "numeric" );

						expect( saveResult ).toHaveKey( "messages" );
						expect( saveResult.messages ).toBeTypeOf( "array" );

						for ( var key in saveResult ) {
							expect( key ).toBeWithCase( lCase(key) );
						}
					});


					it( "successfully creates a bean", function(){
						testClass.$property( propertyName="id", mock=0 );

						var result = testClass.save( validate=true );

						expect( UtilityService.$once("getResultStruct") ).toBeTrue();
						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("validate") ).toBeTrue();
						expect( SQLService.$never("update") ).toBeTrue();
						expect( SQLService.$once("create") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
						expect( testClass.$never("clearCache") ).toBeTrue();

						expect( result.success ).toBeTrue();
						expect( result.code ).toBe( 001 );
						expect( result.messages ).toBeEmpty();

						saveResult = result;
					});


					it( "successfully updates a bean", function(){
						var result = testClass.save( validate=true );

						expect( UtilityService.$once("getResultStruct") ).toBeTrue();
						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("validate") ).toBeTrue();
						expect( SQLService.$once("update") ).toBeTrue();
						expect( SQLService.$never("create") ).toBeTrue();
						expect( testClass.$never("setPrimaryKey") ).toBeTrue();
						expect( testClass.$never("clearCache") ).toBeTrue();

						expect( result.success ).toBeTrue();
						expect( result.code ).toBe( 001 );
						expect( result.messages ).toBeEmpty();

						saveResult = result;
					});


					it( "successfully updates a bean without validating it", function(){
						var result = testClass.save( validate=false );

						expect( UtilityService.$once("getResultStruct") ).toBeTrue();
						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$never("validate") ).toBeTrue();
						expect( SQLService.$once("update") ).toBeTrue();
						expect( SQLService.$never("create") ).toBeTrue();
						expect( testClass.$never("setPrimaryKey") ).toBeTrue();
						expect( testClass.$never("clearCache") ).toBeTrue();

						expect( result.success ).toBeTrue();
						expect( result.code ).toBe( 001 );
						expect( result.messages ).toBeEmpty();

						saveResult = result;
					});


					it( "is unsuccessful if the bean validation process errors", function(){
						testClass.$( "validate", ["error"] );

						var result = testClass.save( validate=true );

						expect( UtilityService.$once("getResultStruct") ).toBeTrue();
						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("validate") ).toBeTrue();
						expect( SQLService.$never("update") ).toBeTrue();
						expect( SQLService.$never("create") ).toBeTrue();
						expect( testClass.$never("setPrimaryKey") ).toBeTrue();
						expect( testClass.$never("clearCache") ).toBeTrue();

						expect( result.success ).toBeFalse();
						expect( result.code ).toBe( 900 );
						expect( result.messages ).notToBeEmpty();

						saveResult = result;
					});


					it( "is unsuccessful if the save process errors", function(){
						testClass.$( "getBeanMap" ).$throws( type="application" );

						var result = testClass.save( validate=true );

						expect( UtilityService.$once("getResultStruct") ).toBeTrue();
						expect( testClass.$count("getBeanName") ).toBe( 2 );
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$never("validate") ).toBeTrue();
						expect( SQLService.$never("update") ).toBeTrue();
						expect( SQLService.$never("create") ).toBeTrue();
						expect( testClass.$never("setPrimaryKey") ).toBeTrue();
						expect( testClass.$never("clearCache") ).toBeTrue();

						expect( result.success ).toBeFalse();
						expect( result.code ).toBe( 500 );
						expect( result.messages ).notToBeEmpty();

						expect( result ).toHaveKey( "error" );
						if ( structKeyExists(server, "lucee") ) {
							expect( result.error ).toBeTypeOf( "struct" );
						}

						saveResult = result;
					});


					it( "clears the bean from the cache service if it is defined as cached", function(){
						beanmap.cached = true;

						var result = testClass.save( validate=true );

						expect( UtilityService.$once("getResultStruct") ).toBeTrue();
						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("validate") ).toBeTrue();
						expect( SQLService.$once("update") ).toBeTrue();
						expect( SQLService.$never("create") ).toBeTrue();
						expect( testClass.$never("setPrimaryKey") ).toBeTrue();
						expect( testClass.$once("clearCache") ).toBeTrue();

						expect( result.success ).toBeTrue();
						expect( result.code ).toBe( 001 );
						expect( result.messages ).toBeEmpty();

						saveResult = result;
					});

				});

			});


			describe("on initialization", function(){

				beforeEach(function( currentSpec ){
					BeanService = createEmptyMock("cfmlDataMapper.model.services.bean");
					BeanService.$( "populateById" );

					testClass.$( "getBeanMap", beanmap );
				});


				// onMissingMethod()
				it( "ignores function names starting with 'set' if the method doesn't exist", function(){
					testClass.onMissingMethod( missingMethodName="setLastName", missingMethodArguments={} );
				});


				it( "errors if the function doesn't exist and it's name does not start with 'set'", function(){
					expect( function(){ testClass.onMissingMethod( missingMethodName="getLastName", missingMethodArguments={} ); } )
						.toThrow(type="application", regex="(getLastName)");
				});


				// setPrimaryKey()
				it( "set's the bean's primary key when the DataFactory doesn't exist", function(){
					testClass.setPrimaryKey( primarykey=1 );

					expect( testClass.$never("getBeanMap") ).toBeTrue();
				});


				// init()
				it( "doesn't populate the bean on the initial DI/1 call", function(){
					var result = testClass.init();

					expect( BeanService.$once("populateById") ).toBeFalse();

					expect( result ).toBeTypeOf( "component" );
					expect( result ).toBeInstanceOf( "cfmlDataMapper.model.base.bean" );
				});

				it( "populates the bean", function(){
					testClass.$property( propertyName="BeanService", mock=BeanService );

					var result = testClass.init( id=0 );

					expect( BeanService.$once("populateById") ).toBeTrue();

					expect( result ).toBeTypeOf( "component" );
					expect( result ).toBeInstanceOf( "cfmlDataMapper.model.base.bean" );
				});

				xit( "errors if populateById() throws an error", function(){
					BeanService.$( "populateById" ).$throws( type="application", message="This is an error." );
					testClass.$property( propertyName="BeanService", mock=BeanService );

					expect( function(){ testClass.init( id=0 ); } )
						.toThrow( type="application" );
				});

			});

		});

	}

}

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
					},
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


			describe("initializes and", function(){

				beforeEach(function( currentSpec ){
					makePublic( testClass, "getDerivedFields" );
					makePublic( testClass, "getSprocContext" );

					qRecords = querySim("id
						1");
				});


				// getDerivedFields()
				it( "returns an empty string of derived fields", function(){
					var result = testClass.getDerivedFields();

					expect( result ).toBeTypeOf( "string" );
					expect( result ).toBeEmpty();
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
						makePublic( testClass, "getBeanMetaDataName" );
					});


					// getBeanMetaDataName()
					it( "get's the bean's name from the metadata", function(){
						var result = testClass.getBeanMetaDataName();

						expect( result ).notToBeEmpty();
					});


					describe("has the bean metadata and", function(){

						beforeEach(function( currentSpec ){
							makePublic( testClass, "getBeanName" );
							makePublic( testClass, "setBeanName" );

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
						makePublic( testClass, "getForeignKeyId" );

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
						makePublic( testClass, "getOneToManyValue" );
						makePublic( testClass, "getManyToManyValue" );
						makePublic( testClass, "getSingularBean" );
						makePublic( testClass, "getSingularSprocBean" );
						makePublic( testClass, "getSprocRelationship" );

						DataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");

						DataFactory.$( "get", userBean )
							.$( "getBeanMap", beanmap )
							.$( "getBeans", [userBean] )
							.$( "list", [userBean] );
						testClass.$property( propertyName="DataFactory", mock=DataFactory );

						SQLService = createEmptyMock("cfmlDataMapper.model.services.sql");
						SQLService.$( "readByJoin", querySim("") );
						testClass.$property( propertyName="SQLService", mock=SQLService );

						testClass.$( "getBeanName", "test" )
							.$( "getForeignKeyId", 1 );
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


					// getOneToManyValue()
					it( "returns an array of beans representing a one-to-many relationship", function(){
						testClass.$property( propertyName="id", mock=1 );

						var result = testClass.getOneToManyValue( primarykey="id", relationship=beanmap.relationships.test );

						expect( DataFactory.$once("list") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns an empty array for the one-to-many relationship if the bean record does not exist", function(){
						testClass.$property( propertyName="id", mock=0 );

						var result = testClass.getOneToManyValue( primarykey="id", relationship=beanmap.relationships.test );

						expect( DataFactory.$never("list") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toBeEmpty();
					});


					// getManyToManyValue()
					it( "returns an array of beans representing a many-to-many relationship", function(){
						testClass.$property( propertyName="id", mock=1 );

						var result = testClass.getManyToManyValue( primarykey="id", relationship=beanmap.relationships.test );

						expect( SQLService.$once("readByJoin") ).toBeTrue();
						expect( DataFactory.$once("getBeans") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns an empty array for the many-to-many relationship if the bean record does not exist", function(){
						testClass.$property( propertyName="id", mock=0 );

						var result = testClass.getManyToManyValue( primarykey="id", relationship=beanmap.relationships.test );

						expect( SQLService.$never("readByJoin") ).toBeTrue();
						expect( DataFactory.$never("getBeans") ).toBeTrue();

						expect( result ).toBeTypeOf( "array" );
						expect( result ).toBeEmpty();
					});


					// getSingularBean()
					it( "returns a bean for a one-to-one or many-to-one relationship", function(){
						var result = testClass.getSingularBean( primarykey="id", relationship=beanmap.relationships.test );

						expect( DataFactory.$once("get") ).toBeTrue();
						expect( testClass.$once("getForeignKeyId") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					// getSingularSprocBean()
					it( "returns a bean populated from the stored procedure query", function(){
						var result = testClass.getSingularSprocBean( beanname="test", qRecords=qRecords );

						expect( DataFactory.$once("getBeans") ).toBeTrue();
						expect( DataFactory.$never("get") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns an empty bean if the stored procedure query has no results", function(){
						DataFactory.$( "getBeans", [] );

						var result = testClass.getSingularSprocBean( beanname="test", qRecords=querySim("") );

						expect( DataFactory.$once("getBeans") ).toBeTrue();
						expect( DataFactory.$once("get") ).toBeTrue();

						expect( result ).toBeTypeOf( "component" );
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					// getSprocRelationship()
					describe("calls getSprocRelationship() and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "getSingularSprocBean", userBean );
						});


						it( "returns a bean from the stored procedure data if the joinType is one", function(){
							var result = testClass.getSprocRelationship( beanname="test", joinType="one", qRecords=qRecords );

							expect( testClass.$once("getSingularSprocBean") ).toBeTrue();
							expect( DataFactory.$never("getBeans") ).toBeTrue();

							expect( result ).toBeTypeOf( "component" );
							expect( result ).toBeInstanceOf( "model.beans.user" );
						});


						it( "returns an array from the stored procedure data if the joinType is many", function(){
							var result = testClass.getSprocRelationship( beanname="test", joinType="many", qRecords=qRecords );

							expect( testClass.$never("getSingularSprocBean") ).toBeTrue();
							expect( DataFactory.$once("getBeans") ).toBeTrue();

							expect( result ).toBeTypeOf( "array" );
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});


						it( "returns an array from the stored procedure data if the joinType is one-to-many", function(){
							var result = testClass.getSprocRelationship( beanname="test", joinType="one-to-many", qRecords=qRecords );

							expect( testClass.$never("getSingularSprocBean") ).toBeTrue();
							expect( DataFactory.$once("getBeans") ).toBeTrue();

							expect( result ).toBeTypeOf( "array" );
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});


						it( "returns an array from the stored procedure data if the joinType is many-to-many", function(){
							var result = testClass.getSprocRelationship( beanname="test", joinType="many-to-many", qRecords=qRecords );

							expect( testClass.$never("getSingularSprocBean") ).toBeTrue();
							expect( DataFactory.$once("getBeans") ).toBeTrue();

							expect( result ).toBeTypeOf( "array" );
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});

					});

					// delete()
					describe("calls delete() and", function(){

						beforeEach(function( currentSpec ){
							SQLService.$( "delete" );

							testClass.$( "getBeanMap", beanmap )
								.$( "getBeanName", "test" );
						});


						it( "deletes the record from the database", function(){
							var result = testClass.delete();

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( SQLService.$once("delete") ).toBeTrue();
							expect( testClass.$once("getBeanName") ).toBeTrue();

							expect( result ).toBeTypeOf( "struct" );
							expect( result ).toHaveKey( "success" );
							expect( result.success ).toBeTypeOf( "boolean" );
							expect( result.success ).toBeTrue();

							expect( result ).toHaveKey( "code" );
							expect( result.code ).toBeTypeOf( "numeric" );
							expect( result.code ).toBe( 001 );

							expect( result ).toHaveKey( "messages" );
							expect( result.messages ).toBeTypeOf( "array" );
							expect( result.messages ).toBeEmpty();
						});


						it( "returns an error if there was an issue deleting the record from the database", function(){
							testClass.$( "getBeanMap" ).$throws( type="application" );

							var result = testClass.delete();

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( SQLService.$never("delete") ).toBeTrue();
							expect( testClass.$once("getBeanName") ).toBeTrue();

							expect( result ).toBeTypeOf( "struct" );
							expect( result ).toHaveKey( "success" );
							expect( result.success ).toBeTypeOf( "boolean" );
							expect( result.success ).toBeFalse();

							expect( result ).toHaveKey( "code" );
							expect( result.code ).toBeTypeOf( "numeric" );
							expect( result.code ).toBe( 500 );

							expect( result ).toHaveKey( "messages" );
							expect( result.messages ).toBeTypeOf( "array" );
							expect( result.messages ).notToBeEmpty();

							expect( result ).toHaveKey( "error" );
							if ( structKeyExists(server, "lucee") ) {
								expect( result.error ).toBeTypeOf( "struct" );
							}
						});

					});

				});


				describe("uses the beanmap and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getPrimaryKeyFromSprocData" );
						makePublic( testClass, "getPropertyDefault" );
						makePublic( testClass, "getRelationshipKeys" );
						makePublic( testClass, "setPrimaryKey" );

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


					// getSessionData()
					describe("calls getSessionData() and", function(){

						beforeEach(function( currentSpec ){
							testClass.$( "getDerivedFields", "" );

							testClass.$( "getPropertyValue" ).$args( propertyname="test" ).$results( "test" );
							testClass.$( "getPropertyValue" ).$args( propertyname="user" ).$results( userBean );
						});


						it( "returns a structure of the bean's property values", function(){
							var result = testClass.getSessionData( data={} );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$once("getPropertyValue") ).toBeTrue();
							expect( testClass.$once("getDerivedFields") ).toBeTrue();

							expect( result ).toBeTypeOf( "struct" );
							expect( result ).toHaveLength( 1 );
						});


						it( "returns a structure of the bean's property values and derived fields", function(){
							testClass.$( "getDerivedFields", "user" );

							var result = testClass.getSessionData( data={} );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$count("getPropertyValue") ).toBe( 2 );
							expect( testClass.$count("getDerivedFields") ).toBe( 2 );

							expect( result ).toBeTypeOf( "struct" );
							expect( result ).toHaveLength( 2 );
						});


						it( "returns a structure of the bean's property values appended to the data structure", function(){
							var result = testClass.getSessionData( data={ "foo"="bar" } );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$once("getPropertyValue") ).toBeTrue();
							expect( testClass.$once("getDerivedFields") ).toBeTrue();

							expect( result ).toBeTypeOf( "struct" );
							expect( result ).toHaveLength( 2 );
						});

					});

				});


				describe("uses the BeanFactory and", function(){

					beforeEach(function( currentSpec ){
						BeanFactory = createEmptyMock("framework.ioc");
						BeanFactory.$( "injectProperties" );
						testClass.$property( propertyName="BeanFactory", mock=BeanFactory );
					});


					// populateBean()
					it( "processes a query and injects it into the bean", function(){
						testClass.populateBean( qRecord=qRecords );

						expect( BeanFactory.$once("injectProperties") ).toBeTrue();
					});


					// populateRelationship()
					describe("calls populateRelationship() and", function(){

						beforeEach(function( currentSpec ){
							makePublic( testClass, "populateRelationship" );

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
							expect( BeanFactory.$once("injectProperties") ).toBeTrue();
						});


						it( "populates a one-to-many relationship", function(){
							beanmap.relationships.test.joinType = "one-to-many";

							testClass.populateRelationship( relationshipName="test" );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$never("getSingularBean") ).toBeTrue();
							expect( testClass.$once("getOneToManyValue") ).toBeTrue();
							expect( testClass.$never("getManyToManyValue") ).toBeTrue();
							expect( BeanFactory.$once("injectProperties") ).toBeTrue();
						});


						it( "populates a many-to-many relationship", function(){
							beanmap.relationships.test.joinType = "many-to-many";

							testClass.populateRelationship( relationshipName="test" );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$never("getSingularBean") ).toBeTrue();
							expect( testClass.$never("getOneToManyValue") ).toBeTrue();
							expect( testClass.$once("getManyToManyValue") ).toBeTrue();
							expect( BeanFactory.$once("injectProperties") ).toBeTrue();
						});


						it( "errors if the relationship isn't defined in the bean map", function(){
							expect( function(){ testClass.populateRelationship( relationshipName="next" ); } )
								.toThrow(type="application", regex="(relationship)");
						});

					});


					// populateSprocData()
					describe("calls populateSprocData() and", function(){

						beforeEach(function( currentSpec ){
							makePublic( testClass, "populateSprocData" );

							testClass.$( "getBeanMap", beanmap )
								.$( "getSprocRelationship", [] )
								.$( "populateBean" );
						});


						it( "populates the bean properties from stored procedure data", function(){
							testClass.populateSprocData( data={ "_bean"=qRecords }, resultkeys=["_bean"] );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$once("populateBean") ).toBeTrue();
							expect( testClass.$never("getSprocRelationship") ).toBeTrue();
							expect( BeanFactory.$never("injectProperties") ).toBeTrue();
						});


						it( "doesn't populate the bean properties when the stored procedure bean query has no results", function(){
							testClass.populateSprocData( data={ "_bean"=querySim("") }, resultkeys=["_bean"] );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$never("populateBean") ).toBeTrue();
							expect( testClass.$never("getSprocRelationship") ).toBeTrue();
							expect( BeanFactory.$never("injectProperties") ).toBeTrue();
						});


						it( "populates a bean relationship from stored procedure data", function(){
							testClass.populateSprocData( data={ "test"=qRecords }, resultkeys=["test"] );

							expect( testClass.$once("getBeanMap") ).toBeTrue();
							expect( testClass.$never("populateBean") ).toBeTrue();
							expect( testClass.$once("getSprocRelationship") ).toBeTrue();
							expect( BeanFactory.$once("injectProperties") ).toBeTrue();
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


					it( "successfully creates a bean", function(){
						testClass.$property( propertyName="id", mock=0 );

						var result = testClass.save( validate=true );

						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("validate") ).toBeTrue();
						expect( SQLService.$never("update") ).toBeTrue();
						expect( SQLService.$once("create") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
						expect( testClass.$never("clearCache") ).toBeTrue();

						expect( result ).toBeTypeOf( "struct" );
						expect( result ).toHaveKey( "success" );
						expect( result.success ).toBeTypeOf( "boolean" );
						expect( result.success ).toBeTrue();

						expect( result ).toHaveKey( "code" );
						expect( result.code ).toBeTypeOf( "numeric" );
						expect( result.code ).toBe( 001 );

						expect( result ).toHaveKey( "message" );
						expect( result.message ).toBeTypeOf( "array" );
						expect( result.message ).toBeEmpty();
					});


					it( "successfully updates a bean", function(){
						var result = testClass.save( validate=true );

						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("validate") ).toBeTrue();
						expect( SQLService.$once("update") ).toBeTrue();
						expect( SQLService.$never("create") ).toBeTrue();
						expect( testClass.$never("setPrimaryKey") ).toBeTrue();
						expect( testClass.$never("clearCache") ).toBeTrue();

						expect( result ).toBeTypeOf( "struct" );
						expect( result ).toHaveKey( "success" );
						expect( result.success ).toBeTypeOf( "boolean" );
						expect( result.success ).toBeTrue();

						expect( result ).toHaveKey( "code" );
						expect( result.code ).toBeTypeOf( "numeric" );
						expect( result.code ).toBe( 001 );

						expect( result ).toHaveKey( "message" );
						expect( result.message ).toBeTypeOf( "array" );
						expect( result.message ).toBeEmpty();
					});


					it( "successfully updates a bean without validating it", function(){
						var result = testClass.save( validate=false );

						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$never("validate") ).toBeTrue();
						expect( SQLService.$once("update") ).toBeTrue();
						expect( SQLService.$never("create") ).toBeTrue();
						expect( testClass.$never("setPrimaryKey") ).toBeTrue();
						expect( testClass.$never("clearCache") ).toBeTrue();

						expect( result ).toBeTypeOf( "struct" );
						expect( result ).toHaveKey( "success" );
						expect( result.success ).toBeTypeOf( "boolean" );
						expect( result.success ).toBeTrue();

						expect( result ).toHaveKey( "code" );
						expect( result.code ).toBeTypeOf( "numeric" );
						expect( result.code ).toBe( 001 );

						expect( result ).toHaveKey( "message" );
						expect( result.message ).toBeTypeOf( "array" );
						expect( result.message ).toBeEmpty();
					});


					it( "is unsuccessful if the bean validation process errors", function(){
						testClass.$( "validate", ["error"] );

						var result = testClass.save( validate=true );

						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("validate") ).toBeTrue();
						expect( SQLService.$never("update") ).toBeTrue();
						expect( SQLService.$never("create") ).toBeTrue();
						expect( testClass.$never("setPrimaryKey") ).toBeTrue();
						expect( testClass.$never("clearCache") ).toBeTrue();

						expect( result ).toBeTypeOf( "struct" );
						expect( result ).toHaveKey( "success" );
						expect( result.success ).toBeTypeOf( "boolean" );
						expect( result.success ).toBeFalse();

						expect( result ).toHaveKey( "code" );
						expect( result.code ).toBeTypeOf( "numeric" );
						expect( result.code ).toBe( 900 );

						expect( result ).toHaveKey( "message" );
						expect( result.message ).toBeTypeOf( "array" );
						expect( result.message ).notToBeEmpty();
					});


					it( "is unsuccessful if the save process errors", function(){
						testClass.$( "getBeanMap" ).$throws( type="application" );

						var result = testClass.save( validate=true );

						expect( testClass.$count("getBeanName") ).toBe( 2 );
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$never("validate") ).toBeTrue();
						expect( SQLService.$never("update") ).toBeTrue();
						expect( SQLService.$never("create") ).toBeTrue();
						expect( testClass.$never("setPrimaryKey") ).toBeTrue();
						expect( testClass.$never("clearCache") ).toBeTrue();

						expect( result ).toBeTypeOf( "struct" );
						expect( result ).toHaveKey( "success" );
						expect( result.success ).toBeTypeOf( "boolean" );
						expect( result.success ).toBeFalse();

						expect( result ).toHaveKey( "code" );
						expect( result.code ).toBeTypeOf( "numeric" );
						expect( result.code ).toBe( 500 );

						expect( result ).toHaveKey( "message" );
						expect( result.message ).toBeTypeOf( "array" );
						expect( result.message ).notToBeEmpty();

						expect( result ).toHaveKey( "error" );
						if ( structKeyExists(server, "lucee") ) {
							expect( result.error ).toBeTypeOf( "struct" );
						}
					});


					it( "clears the bean from the cache service if it is defined as cached", function(){
						beanmap.cached = true;

						var result = testClass.save( validate=true );

						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("validate") ).toBeTrue();
						expect( SQLService.$once("update") ).toBeTrue();
						expect( SQLService.$never("create") ).toBeTrue();
						expect( testClass.$never("setPrimaryKey") ).toBeTrue();
						expect( testClass.$once("clearCache") ).toBeTrue();

						expect( result ).toBeTypeOf( "struct" );
						expect( result ).toHaveKey( "success" );
						expect( result.success ).toBeTypeOf( "boolean" );
						expect( result.success ).toBeTrue();

						expect( result ).toHaveKey( "code" );
						expect( result.code ).toBeTypeOf( "numeric" );
						expect( result.code ).toBe( 001 );

						expect( result ).toHaveKey( "message" );
						expect( result.message ).toBeTypeOf( "array" );
						expect( result.message ).toBeEmpty();
					});

				});


				// populate()
				describe("calls populate() and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "populate" );

						SQLService.$( "read" ).$args( beanname="test", methodname="populate", params={ id = 1 } ).$results( qRecords );
						SQLService.$( "read" ).$args( beanname="test", methodname="populate", params={ id = 2 } ).$results( querySim("id") );

						testClass.$( "getBeanName", "test" )
							.$( "populateBean" )
							.$( "setBeanName" );
					});


					it( "gets the bean record from the database and populates the data", function(){
						testClass.populate( id=1, beanname="test" );

						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( SQLService.$once("read") ).toBeTrue();
						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$once("populateBean") ).toBeTrue();
					});


					it( "doesn't get the bean record if the id is 0", function(){
						testClass.populate( id=0, beanname="test" );

						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( SQLService.$never("read") ).toBeTrue();
						expect( testClass.$never("getBeanName") ).toBeTrue();
						expect( testClass.$never("populateBean") ).toBeTrue();
					});


					it( "doesn't populate the bean data if the there isn't a record", function(){
						testClass.populate( id=2, beanname="test" );

						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( SQLService.$once("read") ).toBeTrue();
						expect( testClass.$once("getBeanName") ).toBeTrue();
						expect( testClass.$never("populateBean") ).toBeTrue();
					});

				});


				// populateBySproc()
				describe("calls populateBySproc() and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "populateBySproc" );

						sprocData = {
							_bean = qRecords
						};

						DataGateway = createEmptyMock("cfmlDataMapper.model.gateways.data");
						DataGateway.$( "readSproc", sprocData );
						testClass.$property( propertyName="DataGateway", mock=DataGateway );

						testClass.$( "getPrimaryKeyFromSprocData", 0 )
							.$( "getRelationshipKeys", [] )
							.$( "getSprocContext", "" )
							.$( "populateSprocData" )
							.$( "setBeanName" )
							.$( "setPrimaryKey" );
					});


					it( "doesn't populate from a stored procedure if the primary key is 0 and there are no params", function(){
						testClass.populateBySproc( sproc="getTest", id=0, beanname="test", params=[], resultkeys=[] );

						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( testClass.$never("getRelationshipKeys") ).toBeTrue();
						expect( DataGateway.$never("readSproc") ).toBeTrue();
						expect( testClass.$never("populateSprocData") ).toBeTrue();
						expect( testClass.$never("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "doesn't populate from a stored procedure if the primary key is blank", function(){
						testClass.populateBySproc( sproc="getTest", id="", beanname="test", params=[], resultkeys=[] );

						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( testClass.$never("getRelationshipKeys") ).toBeTrue();
						expect( DataGateway.$never("readSproc") ).toBeTrue();
						expect( testClass.$never("populateSprocData") ).toBeTrue();
						expect( testClass.$never("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "populates the data and relationships from a stored procedure", function(){
						testClass.populateBySproc( sproc="getTest", id=1, beanname="test", params=[], resultkeys=[] );

						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( testClass.$once("getRelationshipKeys") ).toBeTrue();
						expect( DataGateway.$once("readSproc") ).toBeTrue();
						expect( testClass.$once("populateSprocData") ).toBeTrue();
						expect( testClass.$once("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "populates the data and relationships from a stored procedure using params", function(){
						testClass.populateBySproc( sproc="getTest", id=0, beanname="test", params=[{ name="Test" }], resultkeys=[] );

						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( testClass.$once("getRelationshipKeys") ).toBeTrue();
						expect( DataGateway.$once("readSproc") ).toBeTrue();
						expect( testClass.$once("populateSprocData") ).toBeTrue();
						expect( testClass.$once("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
					});


					it( "populates the data and relationships from a stored procedure using resultkeys", function(){
						testClass.populateBySproc( sproc="getTest", id=1, beanname="test", params=[], resultkeys=["test"] );

						expect( testClass.$once("getSprocContext") ).toBeTrue();
						expect( testClass.$once("setBeanName") ).toBeTrue();
						expect( testClass.$never("getRelationshipKeys") ).toBeTrue();
						expect( DataGateway.$once("readSproc") ).toBeTrue();
						expect( testClass.$once("populateSprocData") ).toBeTrue();
						expect( testClass.$once("getPrimaryKeyFromSprocData") ).toBeTrue();
						expect( testClass.$once("setPrimaryKey") ).toBeTrue();
					});

				});

			});


			describe("on initialization", function(){

				beforeEach(function( currentSpec ){
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
				it( "populates the bean", function(){
					testClass.$( "populate" );

					var result = testClass.init( id=0 );

					expect( testClass.$once("populate") ).toBeTrue();

					expect( result ).toBeTypeOf( "component" );
					expect( result ).toBeInstanceOf( "cfmlDataMapper.model.base.bean" );
				});

			});

		});

	}

}

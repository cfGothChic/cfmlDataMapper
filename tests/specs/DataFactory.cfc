component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll() {
		BeanService = createEmptyMock("cfmlDataMapper.model.services.bean");
		BeanService.$( "populateById" )
			.$( "populateByQuery" );

		CacheService = createEmptyMock("cfmlDataMapper.model.services.cache");
		SQLService = createEmptyMock("cfmlDataMapper.model.gateways.data");

		UtilityService = createEmptyMock("cfmlDataMapper.model.services.utility");
		UtilityService.$( "upperFirst", "Test" );

		departmentBean = createMock("model.beans.department");

		userBean = createMock("model.beans.user");
		userBean.$property( propertyName="BeanService", mock=BeanService );

		userTypeBean = createMock("model.beans.userType");
		userTypeBean.$property( propertyName="BeanService", mock=BeanService );

		BeanFactory = createEmptyMock("framework.ioc");
		BeanFactory.$( "getBean" ).$args( "departmentBean" ).$results( departmentBean )
			.$( "getBean" ).$args( "userBean" ).$results( userBean )
			.$( "getBean" ).$args( "userTypeBean" ).$results( userTypeBean );
	}

	function run() {

		describe("The Data Factory", function(){

			beforeEach(function( currentSpec ){
				frameworkone = createEmptyMock("framework.one");

				testClass = createMock("cfmlDataMapper.model.factory.data");

				testClass.$property( propertyName="BeanService", mock=BeanService );
				testClass.$property( propertyName="CacheService", mock=CacheService );
				testClass.$property( propertyName="SQLService", mock=SQLService );
				testClass.$property( propertyName="UtilityService", mock=UtilityService );
				testClass.$property( propertyName="BeanFactory", mock=BeanFactory );
			});


			describe("initializes and", function(){

				beforeEach(function( currentSpec ){
					testClass.init(frameworkone,UtilityService);
				});


				describe("uses the beanmap and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "addInheritanceMapping" );
						makePublic( testClass, "checkBeanExists" );
					});


					// getBeanMap()
					it( "returns a structure of metadata related to a bean", function(){
						var result = testClass.getBeanMap( bean="user" );

						expect( result ).toBeStruct();
						expect( result ).toHaveKey( "bean" );
						expect( result.bean ).toBe( "user" );
					});


					// checkBeanExists()
					it( "returns true if the bean is in the bean map", function(){
							var result = testClass.checkBeanExists( beanname="user" );

							expect( result ).toBeBoolean();
							expect( result ).toBeTrue();
					});


					it( "errors if the bean is not in the bean map", function(){
						expect( function(){ testClass.checkBeanExists( beanname="test" ); } ).toThrow(type="application", regex="(test)");
					});

				});


				// getModuleBean()
				describe("uses fw1 and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getModuleBean" );

						frameworkone.$( "getDefaultBeanFactory", BeanFactory )
							.$( "getSubsystemBeanFactory", BeanFactory );

						testClass.$property( propertyName="fw", mock=frameworkone );

						testClass.$( "checkBeanExists", true );
					});


					it( "returns a bean from the model", function(){
						var result = testClass.getModuleBean( bean="user" );

						expect( testClass.$once("checkBeanExists") ).toBeTrue();
						expect( frameworkone.$once("getDefaultBeanFactory") ).toBeTrue();
						expect( frameworkone.$once("getSubsystemBeanFactory") ).toBeFalse();

						expect( result ).toBeComponent();
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns a bean from a subsystem", function(){
						var result = testClass.getModuleBean( bean="security.userType" );

						expect( testClass.$once("checkBeanExists") ).toBeTrue();
						expect( frameworkone.$once("getDefaultBeanFactory") ).toBeFalse();
						expect( frameworkone.$once("getSubsystemBeanFactory") ).toBeTrue();

						expect( result ).toBeComponent();
						expect( result ).toBeInstanceOf( "model.beans.userType" );
					});

				});


				describe("takes", function(){

					beforeEach(function( currentSpec ){
						userBean.$( "getId", 1 )
							.$( "populate" );

						testClass.$( "getModuleBean", userBean );
					});


					describe("a custom query and", function(){

						beforeEach(function( currentSpec ){
							qRecords = querySim("id
								1");
						});


						// getBeansFromQuery()
						it( "returns an array of beans", function(){
							var result = testClass.getBeansFromQuery( bean="user", qRecords=qRecords );

							expect( testClass.$once("getModuleBean") ).toBeTrue();
							expect( userBean.$atLeast(1, "populate") ).toBeTrue();

							expect( result ).toBeArray();
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});


						// getBeansFromQueryAsStruct() {
						it( "returns a structure by id of beans", function(){
							var result = testClass.getBeansFromQueryAsStruct( bean="user", qRecords=qRecords );

							expect( testClass.$once("getModuleBean") ).toBeTrue();
							expect( userBean.$atLeast(1, "populate") ).toBeTrue();

							expect( result ).toBeStruct();
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});

					});


					// getBeansFromArray()
					describe("an array of structures and", function(){

						beforeEach(function( currentSpec ){
							beansArray = [{ id = 1 }];
						});


						it( "returns an array of beans", function(){
							var result = testClass.getBeansFromArray( bean="user", beansArray=beansArray );

							expect( testClass.$once("getModuleBean") ).toBeTrue();
							expect( userBean.$atLeast(1, "populate") ).toBeTrue();

							expect( result ).toBeArray();
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeInstanceOf( "model.beans.user" );
						});

					});

					// getBeanListProperties()
					describe("an array of beans and", function(){

						beforeEach(function( currentSpec ){
							userBean.$( "getProperties", {} );
							beans = [userBean];
						});

						it( "returns an array of bean property structures", function(){
							var result = testClass.getBeanListProperties( beans=beans, eagerFetch=false );

							expect( result ).toBeArray();
							expect( result ).toHaveLength( 1 );
							expect( result[1] ).toBeStruct();

							expect( userBean.$once("getProperties") ).toBeTrue();
						});

						it( "errors if the array doesn't contain objects", function(){
							expect( function(){
								testClass.getBeanListProperties( beans=[1], eagerFetch=false );
							})
								.toThrow(type="application", regex="(beans)");
						});

						it( "errors if the array doesn't contain data factory beans", function(){
							expect( function(){
								testClass.getBeanListProperties( beans=[createStub()], eagerFetch=false );
							})
								.toThrow(regex="(beans)");
						});

					});

				});


				// get()
				describe("calls get() and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "getByParams", departmentBean );
						testClass.$( "getModuleBean", userBean );
					});


					it( "returns a bean from the CacheService", function(){
						CacheService.$( "get", {
							success = true,
							bean = userTypeBean
						});

						var result = testClass.get( bean="userType" );

						expect( CacheService.$once("get") ).toBeTrue();
						expect( testClass.$never("getByParams") ).toBeTrue();
						expect( testClass.$never("getModuleBean") ).toBeTrue();

						expect( result ).toBeComponent();
						expect( result ).toBeInstanceOf( "model.beans.userType" );
					});


					it( "returns a bean filtered by params", function(){
						CacheService.$( "get", { success = false });

						var result = testClass.get( bean="userType", params={ foo="bar" } );

						expect( CacheService.$once("get") ).toBeTrue();
						expect( testClass.$once("getByParams") ).toBeTrue();
						expect( testClass.$never("getModuleBean") ).toBeTrue();

						expect( result ).toBeComponent();
						expect( result ).toBeInstanceOf( "model.beans.department" );
					});


					it( "returns a bean from the model", function(){
						CacheService.$( "get", { success = false });

						var result = testClass.get( bean="userType" );

						expect( CacheService.$once("get") ).toBeTrue();
						expect( testClass.$never("getByParams") ).toBeTrue();
						expect( testClass.$once("getModuleBean") ).toBeTrue();

						expect( result ).toBeComponent();
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});

				});


				// getByParams()
				describe("calls getByParams() and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "getByParams" );

						testClass.$( "checkBeanExists", true )
							.$( "get", userBean );
					});


					it( "returns an empty bean when nothing matches the param criteria", function(){
						SQLService.$( "read", querySim("") );

						var result = testClass.getByParams( beanname="user", methodname="test", params={} );

						expect( testClass.$once("checkBeanExists") ).toBeTrue();
						expect( SQLService.$once("read") ).toBeTrue();
						expect( testClass.$once("get") ).toBeTrue();
						expect( BeanService.$never("populateByQuery") ).toBeTrue();

						expect( result ).toBeComponent();
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns a populated bean that meets the param criteria", function(){
						SQLService.$( "read", querySim("id
							1") );

						testClass.$( "get", userTypeBean );

						var result = testClass.getByParams( beanname="userType", methodname="test", params={} );

						expect( testClass.$once("checkBeanExists") ).toBeTrue();
						expect( SQLService.$once("read") ).toBeTrue();
						expect( testClass.$once("get") ).toBeTrue();
						expect( BeanService.$once("populateByQuery") ).toBeTrue();

						expect( result ).toBeComponent();
						expect( result ).toBeInstanceOf( "model.beans.userType" );
					});

				});


				// list()
				describe("calls list() and", function(){

					beforeEach(function( currentSpec ){
						SQLService.$( "read", querySim("") );

						testClass.$( "getBeansFromQuery", [userBean] );
					});


					it( "errors if the singular argument is passed in", function(){
						expect( function(){ testClass.list( bean="userType", singular=true ); } )
							.toThrow(type="application", regex="(singular)");
					});


					it( "returns an array of beans from the CacheService", function(){
						CacheService.$( "list", {
							success = true,
							beans = [userTypeBean]
						});

						var result = testClass.list( bean="userType" );

						expect( CacheService.$once("list") ).toBeTrue();
						expect( testClass.$once("getBeansFromQuery") ).toBeFalse();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.userType" );
					});


					it( "returns an array of beans from the model", function(){
						CacheService.$( "list", { success = false });

						var result = testClass.list( bean="userType" );

						expect( CacheService.$once("list") ).toBeTrue();
						expect( testClass.$once("getBeansFromQuery") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.user" );
					});

				});

				// listWithProperties()
				describe("gets a list of beans and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "getBeanListProperties", [{}] )
							.$( "list", [userBean] );
					});

					it( "returns an array of bean property structures", function(){
						var result = testClass.listWithProperties( bean="beanname" );

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeStruct();

						expect( testClass.$once("list") ).toBeTrue();
						expect( testClass.$once("getBeanListProperties") ).toBeTrue();
					});

				});

				// hasBean()
				describe("calls hasBean() and", function(){

					it( "returns true when a bean exists in the model", function(){
						var result = testClass.hasBean( beanname="userType" );

						expect( result ).toBeTrue();
					});


					it( "returns false when a bean doesn't exist in the model", function(){
						var result = testClass.hasBean( beanname="test" );

						expect( result ).toBeFalse();
					});

				});

			});


			describe("uses bean metadata and", function(){

				beforeEach(function( currentSpec ){
					testClass.init(frameworkone,UtilityService);

					metadata = {
						table = "users",
						primarykey = "id",
						name = "model.beans.adminuser",
						fullname = "model.beans.adminuser",
						extends = {
							fullname = "cfmlDataMapper.model.base.bean"
						},
						properties = [{
							name = "id",
							cfsqltype = "integer"
						},{
							name = "userType",
							bean = "userType"
						}]
					};

					propertyMetadata = {
						name = "user",
						insert = true,
						isidentity = true,
						isrequired = false,
						valtype = "",
						cfsqltype = "cf_sql_integer",
						minvalue = 0,
						maxvalue = 0,
						minlength = 0,
						maxlength = 0,
						regex = "",
						regexlabel = ""
					};

					relationshipMetadata = {
						name = "test",
						joinType = "many-to-many",
						fkColumn = "test",
						fksqltype = "test",
						joinColumn = "test",
						joinTable = "test"
					};

					makePublic( testClass, "addInheritanceMapping" );
					makePublic( testClass, "createBeanMap" );
					makePublic( testClass, "getBeanMapMetadata" );
					makePublic( testClass, "getCfSqlType" );
					makePublic( testClass, "getDatatype" );
					makePublic( testClass, "getInheritanceMetadata" );
					makePublic( testClass, "getPropertyMetadata" );
					makePublic( testClass, "getRelationshipMetadata" );
					makePublic( testClass, "validatePropertyMetadata" );
					makePublic( testClass, "validateRelationshipMetadata" );
				});


				afterEach(function( currentSpec ){
					metadata.fullname = "model.beans.adminuser";
				});


				// addInheritanceMapping()
				it( "adds inheritance mapping to a bean", function(){
					testClass.$( "getBeanMap", {
						bean = "user",
						properties = {
							name = "id"
						},
						relationships = {
							name = "userType"
						}
					});

					testClass.addInheritanceMapping( bean="adminuser" );

					expect( testClass.$once("getBeanMap") ).toBeTrue();
				});


				// getInheritanceMetadata()
				it( "returns an empty string if nothing is being inherited", function(){
					var result = testClass.getInheritanceMetadata( metadata=metadata );

					expect( result ).toBeString();
					expect( result ).toBeEmpty();
				});


				it( "returns the bean name being inherited", function(){
					metadata.extends.fullname = "model.beans.user";

					var result = testClass.getInheritanceMetadata( metadata=metadata );

					expect( result ).toBeString();
					expect( result ).toBe( "user" );
				});


				it( "returns the subsystem bean name being inherited", function(){
					metadata.fullname = "security.model.beans.adminuser";
					metadata.extends.fullname = "security.model.beans.user";

					var result = testClass.getInheritanceMetadata( metadata=metadata );

					expect( result ).toBeString();
					expect( result ).toBe( "security.user" );
				});


				// validatePropertyMetadata()
				it( "errors if the insert attribute of a property is not a boolean", function(){
					propertyMetadata.insert = "test";

					expect( function(){ testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(insert)");
				});


				it( "errors if the isidentity attribute of a property is not a boolean", function(){
					propertyMetadata.isidentity = "test";

					expect( function(){ testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(isidentity)");
				});


				it( "errors if the isrequired attribute of a property is not a boolean", function(){
					propertyMetadata.isrequired = "test";

					expect( function(){ testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(isrequired)");
				});


				it( "errors if the valtype attribute of a property is foreignkey and sqltype isn't integer", function(){
					propertyMetadata.valtype = "foreignkey";
					propertyMetadata.sqltype = "cf_sql_varchar";

					expect( function(){ testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(foreignkey)");
				});


				it( "errors if the minvalue attribute of a property is not numeric", function(){
					propertyMetadata.minvalue = "test";

					expect( function(){ testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(minvalue)");
				});


				it( "errors if the maxvalue attribute of a property is not numeric", function(){
					propertyMetadata.maxvalue = "test";

					expect( function(){ testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(maxvalue)");
				});


				it( "errors if the minlength attribute of a property is not numeric", function(){
					propertyMetadata.minlength = "test";

					expect( function(){ testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(minlength)");
				});


				it( "errors if the maxlength attribute of a property is not numeric", function(){
					propertyMetadata.maxlength = "test";

					expect( function(){ testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(maxlength)");
				});


				it( "errors if a property has a regex attribute but not a regexlabel attribute", function(){
					propertyMetadata.regex = "(test)";

					expect( function(){ testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(required)");
				});


				it( "errors if a property has a regexlabel attribute but not a regex attribute", function(){
					propertyMetadata.regexlabel = "test";

					expect( function(){ testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(required)");
				});


				it( "validates a property successfully if all fields are correct", function(){
					testClass.validatePropertyMetadata( metadata=propertyMetadata, beanname="test" );
				});


				// validateRelationshipMetadata()
				it( "errors if the fkColumn attribute of a many-to-many relationship is blank", function(){
					relationshipMetadata.fkColumn = "";

					expect( function(){ testClass.validateRelationshipMetadata( relationship=relationshipMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(join)");
				});


				it( "errors if the fksqltype attribute of a many-to-many relationship is blank", function(){
					relationshipMetadata.fksqltype = "";

					expect( function(){ testClass.validateRelationshipMetadata( relationship=relationshipMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(join)");
				});


				it( "errors if the joinColumn attribute of a many-to-many relationship is blank", function(){
					relationshipMetadata.joinColumn = "";

					expect( function(){ testClass.validateRelationshipMetadata( relationship=relationshipMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(join)");
				});


				it( "errors if the joinTable attribute of a many-to-many relationship is blank", function(){
					relationshipMetadata.joinTable = "";

					expect( function(){ testClass.validateRelationshipMetadata( relationship=relationshipMetadata, beanname="test" ); } )
						.toThrow(type="application", regex="(join)");
				});


				it( "doesn't error if the relationship is a many-to-many and has the required fields", function(){
					testClass.validateRelationshipMetadata( relationship=relationshipMetadata, beanname="test" );
				});


				it( "doesn't error if the relationship isn't a many-to-many", function(){
					relationshipMetadata.joinType = "one";

					testClass.validateRelationshipMetadata( relationship=relationshipMetadata, beanname="test" );
				});


				// todo: mock private methods in getPropertyMetadata() and getRelationshipMetadata()
				// getPropertyMetadata()
				it( "returns an empty structure if the property is not a data factory column definition", function(){
					testClass.$( "validatePropertyMetadata" );

					var result = testClass.getPropertyMetadata( prop={}, beanname="test" );

					expect( result ).toBeStruct();
					expect( result ).toBeEmpty();
				});


				it( "returns a structure of a bean column property's metadata", function(){
					testClass.$( "validatePropertyMetadata" );

					var result = testClass.getPropertyMetadata( prop=metadata.properties[1], beanname="test" );

					expect( result ).toBeStruct();
					expect( result ).toHaveLength( 16 );
					expect( result ).toHaveKey( "name" );
					expect( result ).toHaveKey( "defaultvalue" );
					expect( result ).toHaveKey( "displayname" );
					expect( result ).toHaveKey( "columnName" );
					expect( result ).toHaveKey( "insert" );
					expect( result ).toHaveKey( "isidentity" );
					expect( result ).toHaveKey( "isrequired" );
					expect( result ).toHaveKey( "sqltype" );
					expect( result ).toHaveKey( "valtype" );
					expect( result ).toHaveKey( "regex" );
					expect( result ).toHaveKey( "regexlabel" );
					expect( result ).toHaveKey( "minvalue" );
					expect( result ).toHaveKey( "maxvalue" );
					expect( result ).toHaveKey( "minlength" );
					expect( result ).toHaveKey( "maxlength" );
					expect( result ).toHaveKey( "datatype" );
				});


				// getCfSqlType()
				it( "returns the full queryparam cfsqltype declaration", function(){
					var result = testClass.getCfSqlType( sqltype="int" );

					expect( result ).toBeString();
					expect( result ).toBe( "cf_sql_integer" );
				});


				// getDatatype()
				it( "returns the datatype when there is a valtype property declaration", function(){
					var result = testClass.getDatatype( valtype="email", sqltype="cf_sql_varchar" );

					expect( result ).toBeString();
					expect( result ).toBe( "email" );
				});


				it( "returns the boolean datatype for the cf_sql_bit sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_bit" );

					expect( result ).toBeString();
					expect( result ).toBe( "boolean" );
				});


				it( "returns the string datatype for the cf_sql_varchar sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_varchar" );

					expect( result ).toBeString();
					expect( result ).toBe( "string" );
				});


				it( "returns the string datatype for the cf_sql_nvarchar sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_nvarchar" );

					expect( result ).toBeString();
					expect( result ).toBe( "string" );
				});


				it( "returns the string datatype for the cf_sql_text sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_text" );

					expect( result ).toBeString();
					expect( result ).toBe( "string" );
				});


				it( "returns the string datatype for the cf_sql_ntext sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_ntext" );

					expect( result ).toBeString();
					expect( result ).toBe( "string" );
				});


				it( "returns the numeric datatype for the cf_sql_bigint sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_bigint" );

					expect( result ).toBeString();
					expect( result ).toBe( "numeric" );
				});


				it( "returns the numeric datatype for the cf_sql_integer sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_integer" );

					expect( result ).toBeString();
					expect( result ).toBe( "numeric" );
				});


				it( "returns the numeric datatype for the cf_sql_float sqltype", function(){
					var result = testClass.getDatatype( valtype="", sqltype="cf_sql_float" );

					expect( result ).toBeString();
					expect( result ).toBe( "numeric" );
				});


				it( "returns the any datatype when no types are passed in", function(){
					var result = testClass.getDatatype( valtype="", sqltype="" );

					expect( result ).toBeString();
					expect( result ).toBe( "any" );
				});


				// getRelationshipMetadata()
				it( "returns an empty structure if the property is not a data factory relationship definition", function(){
					//testClass.$( "getCfSqlType", "cf_sql_integer" );
					testClass.$( "validateRelationshipMetadata" );

					var result = testClass.getRelationshipMetadata( prop={}, beanname="test" );

					//expect( testClass.$never("getCfSqlType") ).toBeTrue();
					expect( testClass.$never("validateRelationshipMetadata") ).toBeTrue();

					expect( result ).toBeStruct();
					expect( result ).toBeEmpty();
				});


				it( "returns a structure of a bean relationship's metadata", function(){
					//testClass.$( "getCfSqlType", "cf_sql_integer" );
					testClass.$( "validateRelationshipMetadata" );

					var result = testClass.getRelationshipMetadata( prop=metadata.properties[2], beanname="test" );

					//expect( testClass.$once("getCfSqlType") ).toBeTrue();
					expect( testClass.$once("validateRelationshipMetadata") ).toBeTrue();

					expect( result ).toBeStruct();
					expect( result ).toHaveLength( 10 );
					expect( result ).toHaveKey( "name" );
					expect( result ).toHaveKey( "bean" );
					expect( result ).toHaveKey( "joinType" );
					expect( result ).toHaveKey( "contexts" );
					expect( result ).toHaveKey( "fkColumn" );
					expect( result ).toHaveKey( "fkName" );
					expect( result ).toHaveKey( "fksqltype" );
					expect( result ).toHaveKey( "joinSchema" );
					expect( result ).toHaveKey( "joinTable" );
					expect( result ).toHaveKey( "joinColumn" );
				});


				// getBeanMapMetadata()
				it( "creates a basic structure of object metadata for a bean without a table definition", function(){
					var result = testClass.getBeanMapMetadata( metadata={} );

					expect( result ).toBeStruct();
					expect( result ).toHaveLength( 1 );
					expect( result ).toHaveKey( "cached" );
				});


				it( "creates a structure of object metadata for a bean with a table definition", function(){
					var result = testClass.getBeanMapMetadata( metadata=metadata );

					expect( result ).toBeStruct();
					expect( result ).toHaveLength( 10 );
					expect( result ).toHaveKey( "table" );
					expect( result ).toHaveKey( "primarykey" );
					expect( result ).toHaveKey( "database" );
					expect( result ).toHaveKey( "sproc" );
					expect( result ).toHaveKey( "orderby" );
					expect( result ).toHaveKey( "schema" );
					expect( result ).toHaveKey( "cached" );
					expect( result ).toHaveKey( "cacheparams" );
					expect( result ).toHaveKey( "cacheparamdefault" );
					expect( result ).toHaveKey( "cacheparamwild" );
				});


				it( "errors if the cacheparams are not a json array of structures", function(){
					metadata.cached = true;
					metadata.cacheparams = "[]";

					expect( function(){ testClass.getBeanMapMetadata( metadata=metadata ); } )
						.toThrow(type="application", regex="(cacheparams)");
				});


				// createBeanMap()
				it( "creates a basic structure of metadata for a bean", function(){
					testClass.$( "getBeanMapMetadata", {} )
						.$( "getInheritanceMetadata", "" );

					testClass.createBeanMap( name="user", metadata={} );

					expect( testClass.$once("getBeanMapMetadata") ).toBeTrue();
					expect( testClass.$once("getInheritanceMetadata") ).toBeTrue();
				});


				it( "creates a complex structure of metadata for a bean", function(){
					testClass.$( "getBeanMapMetadata", {} )
						.$( "getInheritanceMetadata", "" )
						.$( "getPropertyMetadata", {} )
						.$( "getRelationshipMetadata", {} );

					testClass.createBeanMap( name="user", metadata=metadata );

					expect( testClass.$once("getBeanMapMetadata") ).toBeTrue();
					expect( testClass.$once("getInheritanceMetadata") ).toBeTrue();
					expect( testClass.$atLeast(1, "getPropertyMetadata") ).toBeTrue();
					expect( testClass.$atLeast(1, "getRelationshipMetadata") ).toBeTrue();
				});

			});


			describe("interacts with the file system and", function(){

				beforeEach(function( currentSpec ){
					testClass.init(frameworkone,UtilityService);

					makePublic( testClass, "cacheBeanMetadata" );
					makePublic( testClass, "readBeanDirectory" );
				});


				// readBeanDirectory()
				it( "reads a model bean directory to find beans setup for the data factory", function(){
					testClass.$( "createBeanMap" );

					testClass.readBeanDirectory( beanpath="/model/beans/" );

					expect( testClass.$atLeast(1, "createBeanMap") ).toBeTrue();
				});


				// cacheBeanMetadata()
				it( "calls a function to read the bean directory", function(){
					testClass.$( "readBeanDirectory" );

					testClass.cacheBeanMetadata();

					expect( testClass.$once("readBeanDirectory") ).toBeTrue();
				});

			});


			// init()
			describe("on initialization", function(){

				it( "should cache the model's bean metadata", function(){
					testClass.$( "cacheBeanMetadata" );

					var result = testClass.init(frameworkone,UtilityService);

					expect( testClass.$once("cacheBeanMetadata") ).toBeTrue();
					expect( result ).toBeInstanceOf( "cfmlDataMapper.model.factory.data" );
				});

			});

		});

	}

}

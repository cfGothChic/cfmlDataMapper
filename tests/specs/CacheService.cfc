component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = createMock("cfmlDataMapper.model.services.cache");

		userBean = createMock("model.beans.user");
		userBean.$( "getPropertyValue" ).$args( item="id" ).$results( 1 );
		userBean.$( "getPropertyValue" ).$args( item="isDeleted" ).$results( 1 );
		userBean.$( "getProperties", {} );

		userTypeBean = createMock("model.beans.userType");
		userTypeBean.$( "getPropertyValue" ).$args( item="id" ).$results( 2 );
		userTypeBean.$( "getPropertyValue" ).$args( item="isDeleted" ).$results( 0 );

		departmentBean = createMock("model.beans.department");
		departmentBean.$( "getPropertyValue" ).$args( item="id" ).$results( 3 );
		departmentBean.$( "getPropertyValue" ).$args( item="isDeleted" ).$results( 1 );
	}

	function run() {

		describe("The Cache Service", function(){

			beforeEach(function( currentSpec ){
				DataFactory = createEmptyMock("cfmlDataMapper.model.factory.data");
				testClass.$property( propertyName="DataFactory", mock=DataFactory );

				beanmap = {
					bean = "user",
					primarykey = "id",
					orderby = "name",
					cached = true,
					cacheparams = [{}],
					cacheparamdefault = "{}",
					cacheparamwild = [],
					properties = {
						email = {
							name = "email",
							columnname = ""
						}
					}
				};

				paramjson = "[{isDeleted=0}]";
				params = { isDeleted=0 };
			});


			describe("populates the service cache and", function(){

				beforeEach(function( currentSpec ){
					SQLService = createEmptyMock("cfmlDataMapper.model.services.sql");
					SQLService.$( "read", querySim("id
						1") );
					testClass.$property( propertyName="SQLService", mock=SQLService );
				});


				// cacheDefaultParams()
				it( "caches a bean list by default params and sort order", function(){
					makePublic( testClass, "cacheDefaultParams" );

					DataFactory.$( "getBeansFromQueryAsStruct", {
						"1" = {
							id = 1
						}
					});

					testClass.cacheDefaultParams( beanname="user", methodname="test", beanmap=beanmap );

					expect( SQLService.$once("read") ).toBeTrue();
					expect( DataFactory.$once("getBeansFromQueryAsStruct") ).toBeTrue();
				});


				describe("has a param string and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "cacheParamString" );
						makePublic( testClass, "getParamJson" );
						makePublic( testClass, "paramsAreNotCached" );

						UtilityService = createEmptyMock("cfmlDataMapper.model.services.utility");
						testClass.$property( propertyName="UtilityService", mock=UtilityService );
					});


					// getParamJson()
					it( "returns an empty json string if no params are passed in", function(){
						var result = testClass.getParamJson( beanmap=beanmap, params={} );

						expect( result ).toBeEmpty();
					});


					it( "returns an empty json string if the beanmap doesn't have cacheparams", function(){
						var result = testClass.getParamJson( beanmap=beanmap, params=params );

						expect( result ).toBeEmpty();
					});


					it( "returns an empty json string if the passed in params do not match the bean's cacheparams", function(){
						beanmap.cacheparams = [{},{ isDeleted=0 }];

						UtilityService.$( "structCompare", false );

						var result = testClass.getParamJson( beanmap=beanmap, params={ name="Moe" } );

						expect( result ).toBeEmpty();
						expect( UtilityService.$atleast(2, "structCompare") ).toBeTrue();
					});


					it( "returns a json string if the passed in params match the bean's cacheparams", function(){
						beanmap.cacheparams = [{},{ isDeleted=0 }];

						UtilityService.$( "structCompare" ).$args( LeftStruct={ isDeleted=0 }, RightStruct=params ).$results( true );
						UtilityService.$( "structCompare" ).$args( LeftStruct={}, RightStruct=params ).$results( false );

						var result = testClass.getParamJson( beanmap=beanmap, params=params );

						expect( result ).notToBeEmpty();
						expect( isJSON(result) ).toBeTrue();
						expect( UtilityService.$atleast(2, "structCompare") ).toBeTrue();
					});


					it( "returns an empty json string if the passed in params do not match the bean's cacheparam wildcard", function(){
						beanmap.cacheparams = [{},{ userTypeID="*" }];

						UtilityService.$( "structCompare", false );

						var result = testClass.getParamJson( beanmap=beanmap, params={ name="Moe" } );

						expect( result ).toBeEmpty();
						expect( UtilityService.$atleast(2, "structCompare") ).toBeTrue();
					});


					it( "returns a json string if the passed in params match the bean's cacheparam wildcard", function(){
						beanmap.cacheparams = [{},{ userTypeID="*" }];
						beanmap.cacheparamwild = ["userTypeID"];

						UtilityService.$( "structCompare", false );

						var result = testClass.getParamJson( beanmap=beanmap, params={ userTypeID=1 } );

						expect( result ).notToBeEmpty();
						expect( result ).toBeJSON();
						expect( UtilityService.$atleast(2, "structCompare") ).toBeTrue();
					});


					// cacheParamString()
					it( "caches a param string's bean id's", function(){
						testClass.$( "getParamBeanIds", [1] );

						testClass.cacheParamString( beanname="user", paramjson=paramjson, params=params );

						expect( testClass.$once("getParamBeanIds") ).toBeTrue();
					});


					// paramsAreNotCached()
					it( "returns false if there are only default bean cacheparams", function(){
						var result = testClass.paramsAreNotCached( beanmap=beanmap, beanname="user", paramjson=paramjson );

						expect( result ).toBeFalse();
					});


					it( "returns false if the params are already cached", function(){
						beanmap.cacheparams = [{},{ isDeleted=0 }];

						var result = testClass.paramsAreNotCached( beanmap=beanmap, beanname="user", paramjson=paramjson );

						expect( result ).toBeFalse();
					});


					it( "returns true if the params are not cached", function(){
						beanmap.cacheparams = [{},{ isDeleted=0 }];

						var result = testClass.paramsAreNotCached( beanmap=beanmap, beanname="user", paramjson="[{name='Moe'}]" );

						expect( result ).toBeTrue();
					});


				});


				describe("has a sort order and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "cacheSortOrder" );
						makePublic( testClass, "sortOrderIsNotCached" );
					});


					// cacheSortOrder()
					it( "caches bean ids by sort order", function(){
						testClass.cacheSortOrder( beanmap=beanmap, beanname="user", methodname="test", orderby="id" );

						expect( SQLService.$once("read") ).toBeTrue();
					});


					// sortOrderIsNotCached()
					it( "returns false if the sort order is cached", function(){
						var result = testClass.sortOrderIsNotCached( beanmap=beanmap, beanname="user", orderby="id" );

						expect( result ).toBeFalse();
					});


					it( "returns true if the sort order is not cached", function(){
						var result = testClass.sortOrderIsNotCached( beanmap=beanmap, beanname="user", orderby="lastName" );

						expect( result ).toBeTrue();
					});

				});


				// checkBeanCache()
				describe("calls checkBeanCache() and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "checkBeanCache" );
					});


					it( "returns false if the bean should not be cached", function(){
						var result = testClass.checkBeanCache( beanmap={ cached=false }, paramjson="", orderby="" );

						expect( result ).toBeFalse();
					});


					it( "returns true if the bean should be cached with default params", function(){
						var result = testClass.checkBeanCache( beanmap=beanmap, paramjson="", orderby="" );

						expect( result ).toBeTrue();
					});


					it( "returns true if there is a paramjson string", function(){
						var result = testClass.checkBeanCache( beanmap=beanmap, paramjson=paramjson, orderby="" );

						expect( result ).toBeTrue();
					});


					it( "returns true if the bean's first cache param is not empty", function(){
						beanmap.cacheparams = [{ isDeleted=0 }];
						var result = testClass.checkBeanCache( beanmap=beanmap, paramjson="", orderby="" );

						expect( result ).toBeTrue();
					});


					it( "returns true if the bean has multiple cache params", function(){
						beanmap.cacheparams = [{ name="Curly" },{ isDeleted=0 }];
						var result = testClass.checkBeanCache( beanmap=beanmap, paramjson="", orderby="" );

						expect( result ).toBeTrue();
					});


					it( "returns true if the bean should be cached with a sort order", function(){
						beanmap.cacheparams = [{ isDeleted=0 }];
						var result = testClass.checkBeanCache( beanmap=beanmap, paramjson="", orderby="name" );

						expect( result ).toBeTrue();
					});

				});


				// cacheBeans()
				describe("calls cacheBeans() and", function(){

					beforeEach(function( currentSpec ){
						makePublic( testClass, "cacheBeans" );

						testClass.$( "checkBeanCache", true )
							.$( "cacheDefaultParams")
							.$( "paramsAreNotCached", false )
							.$( "cacheParamString" )
							.$( "sortOrderIsNotCached", false )
							.$( "cacheSortOrder" );
					});

					it( "doesn't cache a bean if it should not be cached", function(){
						testClass.$( "checkBeanCache", false );

						testClass.cacheBeans( beanmap=beanmap, beanname="name", params={}, paramjson="", orderby="" );

						expect( testClass.$once("checkBeanCache") ).toBeTrue();
						expect( testClass.$never("cacheDefaultParams") ).toBeTrue();
					});


					it( "caches a bean with the default params and sort", function(){
						testClass.cacheBeans( beanmap=beanmap, beanname="name", params={}, paramjson="", orderby="" );

						expect( testClass.$once("checkBeanCache") ).toBeTrue();
						expect( testClass.$once("cacheDefaultParams") ).toBeTrue();
						expect( testClass.$once("paramsAreNotCached") ).toBeTrue();
						expect( testClass.$never("cacheParamString") ).toBeTrue();
						expect( testClass.$once("sortOrderIsNotCached") ).toBeTrue();
						expect( testClass.$never("cacheSortOrder") ).toBeTrue();
					});


					it( "caches a bean with passed in params", function(){
						testClass.$( "paramsAreNotCached", true );

						testClass.cacheBeans( beanmap=beanmap, beanname="name", params={}, paramjson="", orderby="" );

						expect( testClass.$once("checkBeanCache") ).toBeTrue();
						expect( testClass.$once("cacheDefaultParams") ).toBeTrue();
						expect( testClass.$once("paramsAreNotCached") ).toBeTrue();
						expect( testClass.$once("cacheParamString") ).toBeTrue();
						expect( testClass.$once("sortOrderIsNotCached") ).toBeTrue();
						expect( testClass.$never("cacheSortOrder") ).toBeTrue();
					});


					it( "caches a bean with passed in sort", function(){
						testClass.$( "sortOrderIsNotCached", true );

						testClass.cacheBeans( beanmap=beanmap, beanname="name", params={}, paramjson="", orderby="" );

						expect( testClass.$once("checkBeanCache") ).toBeTrue();
						expect( testClass.$once("cacheDefaultParams") ).toBeTrue();
						expect( testClass.$once("paramsAreNotCached") ).toBeTrue();
						expect( testClass.$never("cacheParamString") ).toBeTrue();
						expect( testClass.$once("sortOrderIsNotCached") ).toBeTrue();
						expect( testClass.$once("cacheSortOrder") ).toBeTrue();
					});

				});

			});


			describe("uses the service cache and", function(){

				beforeEach(function( currentSpec ){
					beanCache.user.params = {};
					beanCache.user.beans = {
						"1" = userBean,
						"2" = userTypeBean,
						"3" = departmentBean
					};
					beanCache.user.sortorder.default = [1,2,3];

					makePublic( testClass, "beanCacheCheck" );
					makePublic( testClass, "beanParamsAreInCache" );
					makePublic( testClass, "getCachedBean" );
					makePublic( testClass, "getBeansByParams" );
					makePublic( testClass, "getParamBeanIds" );

					testClass.$( "getParamJson", "" )
						.$( "cacheBeans" );

					if ( !structKeyExists(server, "lucee") ) {
						testClass.$( "getCachedBean", userBean );
					}

					DataFactory.$( "getBeanMap", beanmap );
				});


				// beanCacheCheck()
				it( "returns true if the bean is not cached", function(){
					testClass.$property( propertyName="beanCache", mock={} );

					var result = testClass.beanCacheCheck( beanname="user", params={} );

					expect( result ).toBeTrue();
				});


				// beanParamsAreInCache()
				it( "returns false if the bean is not cached when checking for cached params", function(){
					testClass.$property( propertyName="beanCache", mock={} );

					var result = testClass.beanParamsAreInCache( beanmap=beanmap, paramjson="" );

					expect( result ).toBeFalse();
				});


				// getParamBeanIds()
				it( "returns an array of bean ids for the params", function(){
					var result = testClass.getParamBeanIds( beanname="user", params=params );

					expect( result ).toBeArray();
					expect( result ).toHaveLength( 1 );
				});


				describe("caches the user bean and", function(){

					beforeEach(function( currentSpec ){
						userBean.$( "populate" );
						DataFactory.$( "get", userBean );

						testClass.$property( propertyName="beanCache", mock=beanCache );
					});


					// beanCacheCheck()
					it( "returns true if the bean is cached but there are params", function(){
						var result = testClass.beanCacheCheck( beanname="user", params={ isDeleted=0 } );

						expect( result ).toBeTrue();
					});


					it( "returns true if the bean is cached but there is a sort order", function(){
						var result = testClass.beanCacheCheck( beanname="user", params={}, orderby="name" );

						expect( result ).toBeTrue();
					});


					it( "returns false if the bean is cached and there are no params or a sort order", function(){
						var result = testClass.beanCacheCheck( beanname="user", params={} );

						expect( result ).toBeFalse();
					});


					// getCachedBean()
					it( "returns a bean from the service cache", function(){
						if ( !structKeyExists(server, "lucee") ) {
							DataFactory.$( "get", userBean );
						}

						var result = testClass.getCachedBean( beanname="user", beanData=beanCache.user, primaryKey=1 );

						expect( result ).toBeComponent();
						expect( result ).toBeInstanceOf( "model.beans.user" );
					});


					// clearBean()
					it( "removes a bean from the cache", function(){
						testClass.clearBean( beanname="user" );
						var result = testClass.beanCacheCheck( beanname="user", params={} );

						expect( result ).toBeTrue();
					});

				});


				describe("caches the user bean params and sort order and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "getParamBeanIds", [3] );

						beanCache.user.params = {
							"#paramjson#" = [2]
						};
						beanCache.user.sortorder[ "email asc" ] = [2];

						testClass.$property( propertyName="beanCache", mock=beanCache );
					});


					// beanParamsAreInCache()
					it( "returns true if the bean params are cached", function(){
						var result = testClass.beanParamsAreInCache( beanmap=beanmap, paramjson=paramjson );

						expect( result ).toBeTrue();
					});


					it( "returns false if the bean params are not cached", function(){
						var result = testClass.beanParamsAreInCache( beanmap=beanmap, paramjson="[{name='Moe'}]" );

						expect( result ).toBeFalse();
					});


					// getBeansByParams()
					it( "returns an array of cached beans for default params", function(){
						var result = testClass.getBeansByParams( beanname="user", paramjson="", params={}, orderby="" );

						expect( testClass.$never("getParamBeanIds") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 3 );
						expect( result[1] ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns an array of cached beans for the paramjson", function(){
						if ( !structKeyExists(server, "lucee") ) {
							testClass.$( "getCachedBean", userTypeBean );
						}

						var result = testClass.getBeansByParams( beanname="user", paramjson=paramjson, params={}, orderby="" );

						expect( testClass.$never("getParamBeanIds") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.userType" );
					});


					it( "returns an array of cached beans for the params", function(){
						if ( !structKeyExists(server, "lucee") ) {
							testClass.$( "getCachedBean", departmentBean );
						}

						var result = testClass.getBeansByParams( beanname="user", paramjson="", params=params, orderby="" );

						expect( testClass.$once("getParamBeanIds") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.department" );
					});


					it( "returns an array of cached beans for the sort order", function(){
						if ( !structKeyExists(server, "lucee") ) {
							testClass.$( "getCachedBean", userTypeBean );
						}

						var result = testClass.getBeansByParams( beanname="user", paramjson="", params={}, orderby="email asc" );

						expect( testClass.$never("getParamBeanIds") ).toBeTrue();

						expect( result ).toBeArray();
						expect( result ).toHaveLength( 1 );
						expect( result[1] ).toBeInstanceOf( "model.beans.userType" );
					});

				});


				// get()
				describe("calls get() and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "beanCacheCheck", true )
							.$( "beanParamsAreInCache", true )
							.$( "getCachedBean", userBean );

						testClass.$property( propertyName="beanCache", mock=beanCache );
					});


					it( "does not return a bean if the id is 0 and there are no params", function(){
						var result = testClass.get( beanname="user", id=0 );

						expect( result.success ).toBeFalse();
						expect( structKeyExists(result, "bean") ).toBeFalse();
						expect( DataFactory.$never("getBeanMap") ).toBeTrue();
					});


					it( "does not return a bean if the bean is not defined as cached", function(){
						DataFactory.$( "getBeanMap", { cached=false } );

						var result = testClass.get( beanname="user", id=1 );

						expect( result.success ).toBeFalse();
						expect( structKeyExists(result, "bean") ).toBeFalse();
						expect( DataFactory.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$never("getParamJson") ).toBeTrue();
					});


					it( "returns a bean from the cache", function(){
						var result = testClass.get( beanname="user", id=1 );

						expect( DataFactory.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("getParamJson") ).toBeTrue();
						expect( testClass.$once("beanCacheCheck") ).toBeTrue();
						expect( testClass.$once("cacheBeans") ).toBeTrue();
						expect( testClass.$never("beanParamsAreInCache") ).toBeTrue();
						expect( testClass.$once("getCachedBean") ).toBeTrue();

						expect( result.success ).toBeTrue();
						expect( result ).toHaveKey( "bean" );
						expect( result.bean ).toBeComponent();
						expect( result.bean ).toBeInstanceOf( "model.beans.user" );
					});


					it( "returns a bean from the cache by params", function(){
						testClass.$( "getCachedBean", userTypeBean )
							.$( "getParamJson", paramjson );

						beanCache.user.params = {
							"#paramjson#" = [2]
						};

						var result = testClass.get( beanname="user", id=0, params=params );

						expect( DataFactory.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("getParamJson") ).toBeTrue();
						expect( testClass.$once("beanCacheCheck") ).toBeTrue();
						expect( testClass.$once("cacheBeans") ).toBeTrue();
						expect( testClass.$once("beanParamsAreInCache") ).toBeTrue();
						expect( testClass.$once("getCachedBean") ).toBeTrue();

						expect( result.success ).toBeTrue();
						expect( result ).toHaveKey( "bean" );
						expect( result.bean ).toBeComponent();
						expect( result.bean ).toBeInstanceOf( "model.beans.userType" );
					});

				});


				// list()
				describe("calls list() and", function(){

					beforeEach(function( currentSpec ){
						testClass.$( "beanCacheCheck", true )
							.$( "beanParamsAreInCache", true )
							.$( "getBeansByParams", [userBean] );
						testClass.$property( propertyName="beanCache", mock=beanCache );
					});


					it( "returns an empty bean array if the bean is not defined as cached", function(){
						DataFactory.$( "getBeanMap", { cached=false } );

						var result = testClass.list( beanname="user" );

						expect( DataFactory.$once("getBeanMap") ).toBeTrue();

						expect( result.success ).toBeFalse();
						expect( result.beans ).toBeEmpty();
					});


					it( "returns and array of beans from the cache", function(){
						var result = testClass.list( beanname="user" );

						expect( DataFactory.$once("getBeanMap") ).toBeTrue();
						expect( testClass.$once("beanCacheCheck") ).toBeTrue();
						expect( testClass.$once("cacheBeans") ).toBeTrue();
						expect( testClass.$once("beanParamsAreInCache") ).toBeTrue();
						expect( testClass.$once("getBeansByParams") ).toBeTrue();

						expect( result.success ).toBeTrue();
						expect( result.beans ).toHaveLength( 1 );
						expect( result.beans[1] ).toBeInstanceOf( "model.beans.user" );
					});

				});

			});

		});

	}

}

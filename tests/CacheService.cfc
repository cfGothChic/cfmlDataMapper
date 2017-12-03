component accessors="true" extends="testbox.system.BaseSpec"{

	function beforeAll(){
		testClass = createMock("cfmlDataMapper.model.services.cache");
	}

	function run() {

		describe("The Cache Service", function(){

			// clearBean()
			it( "removes a bean from the cache", function(){

			});


			// get()
			it( "returns a bean from the cache", function(){

			});


			// list()
			it( "returns and array of beans from the cache", function(){

			});


			// beanCacheCheck()
			it( "returns true if the bean is cached", function(){

			});


			it( "returns false if the bean is not cached", function(){

			});


			// beanParamsAreInCache()
			it( "returns true if the bean params are cached", function(){

			});


			it( "returns false if the bean params are not cached", function(){

			});


			// cacheBeans()
			it( "caches beans", function(){

			});


			// cacheDefaultParams()
			it( "caches beans by default params and sort order", function(){

			});


			// cacheParamString()
			it( "caches the param string", function(){

			});


			// cacheSortOrder()
			it( "caches beans by sort order", function(){

			});


			// checkBeanCache()
			it( "returns true if the bean should be cached", function(){

			});


			it( "returns false if the bean should not be cached", function(){

			});


			// getBeansByParams()
			it( "returns an array of beans for the params", function(){

			});


			// getCachedBean()
			it( "returns a bean from the service cache", function(){

			});


			// getFullOrderBy()
			it( "returns an order by string for the bean", function(){

			});


			// getParamBeanIds()
			it( "returns an array of bean ids for the params", function(){

			});


			// getParamJson()
			it( "returns a json string of the params", function(){

			});


			// paramsAreNotCached()
			it( "returns true if the params are not cached", function(){

			});


			it( "returns false if the params are cached", function(){

			});


			// sortOrderIsNotCached()
			it( "returns true if the sort order is not cached", function(){

			});


			it( "returns false if the sort order is cached", function(){

			});

		});

	}

}

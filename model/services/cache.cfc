component accessors="true" {

	property BeanFactory;
	property DataFactory;
	property SQLService;
	property UtilityService;

	variables.beanCache = {};

	public function init() {
		return this;
	}

	public void function clearBean( required string beanname ) {
		structDelete(variables.beanCache, arguments.beanname);
	}

	public struct function get(
		required string beanname,
		required numeric id,
		struct params={}
	) {
		var result = { success = false };

		if ( arguments.id || structCount(arguments.params) ) {
			var beanmap = variables.DataFactory.getBeanMap( bean=arguments.beanname );

			if ( beanmap.cached ) {
				var paramjson = getParamJson( beanmap, arguments.params );

				if ( beanCacheCheck( argumentCollection=arguments ) ) {
					cacheBeans( beanmap=beanmap, beanname=arguments.beanname, params=arguments.params, paramjson=paramjson );
				}

				var beanData = variables.beanCache[ arguments.beanname ];

				if ( arguments.id && structKeyExists(beanData.beans,arguments.id) ) {
					result.bean = getCachedBean( beanname=arguments.beanname, beanData=beanData, primarykey=arguments.id );
					result.success = true;

				} else if ( beanParamsAreInCache(beanmap, paramjson) ) {
					var paramids = structKeyExists(beanData.params, paramjson) ? beanData.params[paramjson] : [];
					if ( arrayLen(paramids) ) {
						result.bean = getCachedBean( beanname=arguments.beanname, beanData=beanData, primarykey=paramids[1] );
						result.success = true;
					}
				}
			}
		}

		return result;
	}

	public struct function list(
		required string beanname,
		struct params={},
		string orderby=""
	) {
		var result = { success = false, beans = [] };
		var beanmap = variables.DataFactory.getBeanMap( bean=arguments.beanname );

		if ( beanmap.cached ) {
			var paramjson = getParamJson( beanmap, arguments.params );

			if ( beanCacheCheck( argumentCollection=arguments ) ) {
				cacheBeans( beanmap=beanmap, beanname=arguments.beanname, params=arguments.params, paramjson=paramjson, orderby=arguments.orderby );
			}

			if ( beanParamsAreInCache(beanmap, paramjson) ) {
				result.beans = getBeansByParams( beanname=arguments.beanname, paramjson=paramjson, params=arguments.params, orderby=arguments.orderby );
				result.success = true;
			}
		}

		return result;
	}

	private boolean function beanCacheCheck(
		required string beanname,
		required struct params,
		string orderby=""
	) {
		return (
			!structKeyExists(variables.beanCache, arguments.beanname)
			|| !structIsEmpty(arguments.params)
			|| len(arguments.orderby)
		);
	}

	private boolean function beanParamsAreInCache( required struct beanmap, required string paramjson ) {
		return (
			structKeyExists(variables.beanCache,arguments.beanmap.bean)
			&& (
				!len(arguments.paramjson)
				|| structKeyExists(variables.beanCache[arguments.beanmap.bean].params,arguments.paramjson)
				|| arguments.paramjson == arguments.beanmap.cacheparamdefault
			)
		);
	}

	private void function cacheBeans(
		required struct beanmap,
		required string beanname,
		struct params={},
		string paramjson="",
		string orderby=""
	) {
		if ( checkBeanCache( argumentCollection=arguments ) ) {
			arguments.methodname = "cacheBeans";

			if ( !structKeyExists(variables.beanCache, arguments.beanname) ) {
				cacheDefaultParams( argumentCollection=arguments );
			}

			if ( paramsAreNotCached( argumentCollection=arguments ) ) {
				cacheParamString( argumentCollection=arguments );
			}

			if ( sortOrderIsNotCached( argumentCollection=arguments ) ) {
				cacheSortOrder( argumentCollection=arguments );
			}
		}
	}

	private void function cacheDefaultParams( required string beanname, required string methodname, required struct beanmap ) {
		lock timeout="60" scope="application" type="exclusive" {
			var qRecords = variables.SQLService.read(
				beanname=arguments.beanname,
				methodname=arguments.methodname,
				params=arguments.beanmap.cacheparams[1]
			);

			var beanStruct = variables.DataFactory.getBeanStruct( bean=arguments.beanname, qRecords=qRecords );

			// todo: figure out a better way to do this
			var idlist = evaluate("valueList(qRecords.#arguments.beanmap.primarykey#)");

			variables.beanCache[ arguments.beanname ] = {
				beans = beanStruct,
				sortorder = { "default" = listToArray(idlist) },
				params = {}
			};
		}
	}

	private void function cacheParamString(
		required string beanname,
		required string paramjson,
		required struct params
	) {
		var beanids = getParamBeanIds( beanname=arguments.beanname, params=arguments.params );
		variables.beanCache[ arguments.beanname ].params[ arguments.paramjson ] = beanids;
	}

	private void function cacheSortOrder(
		required struct beanmap,
		required string beanname,
		required string methodname,
		required string orderby
	) {
		var qRecords = variables.SQLService.read(
			beanname = arguments.beanname,
			methodname = arguments.methodname,
			params = arguments.beanmap.cacheparams[1],
			orderby = arguments.orderby,
			pkOnly = true
		);

		// todo: figure out a better way to do this
		var idlist = evaluate("valueList(qRecords.#arguments.beanmap.primarykey#)");

		variables.beanCache[ arguments.beanmap.bean ].sortorder[ arguments.orderby ] = listToArray(idlist);
	}

	private boolean function checkBeanCache( required struct beanmap, required string paramjson, required string orderby ) {
		return arguments.beanmap.cached && (
			(
				structIsEmpty(arguments.beanmap.cacheparams[1])
				&& !len(arguments.paramjson)
			)
			|| len(arguments.paramjson)
			|| arrayLen(arguments.beanmap.cacheparams) > 1
			|| !structIsEmpty(arguments.beanmap.cacheparams[1])
			|| len(arguments.orderby)
		);
	}

	private array function getBeansByParams( required string beanname, required string paramjson, required struct params, required string orderby ) {
		var beanData = variables.beanCache[ arguments.beanname ];
		var beans = [];

		var sortorder = structKeyExists(beanData.sortorder, arguments.orderby) ? beanData.sortorder[arguments.orderby] : beanData.sortorder.default;
		var paramids = len(arguments.paramjson) && structKeyExists(beanData.params, arguments.paramjson) ? beanData.params[arguments.paramjson] : sortorder;

		if ( !len(arguments.paramjson) && structCount(arguments.params) ) {
			paramids = getParamBeanIds( beanname=arguments.beanname, params=arguments.params );
		}

		for ( var primarykey in sortorder ) {
			if (
				arrayFind(paramids,primarykey)
				&& structKeyExists(beanData.beans, primarykey)
			) {
				var cachedbean = getCachedBean( beanname=arguments.beanname, beanData=beanData, primaryKey=primaryKey );
				arrayAppend(beans, cachedbean);
			}
		}
		return beans;
	}

	private component function getCachedBean( required string beanname, required struct beanData, required numeric primaryKey ){
		// get the cached bean, but make a shallow copy so changes to the bean are not retained in cache
		if ( structKeyExists(server, "lucee") ) {
			var cachedbean = structCopy(arguments.beanData.beans[ arguments.primarykey ]);
		} else {
			var thisbean = arguments.beanData.beans[ arguments.primarykey ];
			var cachedStruct = thisbean.getPropertyData();
			var cachedbean = variables.DataFactory.get( bean=arguments.beanname );
			variables.BeanFactory.injectProperties(cachedbean, cachedStruct);
		}
		return cachedbean;
	}

	private array function getParamBeanIds( required string beanname, required struct params ) {
		var beanData = variables.beanCache[ arguments.beanname ];
		var beanids = [];
		for ( var primarykey in beanData.beans ) {
			var checkbean = beanData.beans[primarykey];
			var check = 0;
			for ( var item in arguments.params ) {
				var value = checkbean.getPropertyValue(item);
				if ( value == arguments.params[item] ) {
					check++;
				}
			}
			if ( check == structCount(arguments.params) ) {
				arrayAppend(beanids,primarykey);
			}
		}
		return beanids;
	}

	private string function getParamJson( required struct beanmap, required struct params ) {
		var json = "";
		if (
			!structIsEmpty(arguments.params)
			&& (
				arrayLen(arguments.beanmap.cacheparams) > 1
				|| !structIsEmpty(arguments.beanmap.cacheparams[1])
				|| arrayLen(arguments.beanmap.cacheparamwild)
			)
		) {
			for ( var cacheparam in arguments.beanmap.cacheparams ) {
				// check for exact match
				var success = variables.UtilityService.structCompare(cacheparam,arguments.params);
				if ( success ) {
					json = serializeJSON(cacheparam);
					break;
				}

				// check for wild card match
				if (
					!success
					&& arrayLen(arguments.beanmap.cacheparamwild)
					&& structCount(arguments.params) == 1
				) {
					var key = structKeyList(arguments.params);
					if (
						structKeyExists(cacheparam,key)
						&& arrayFindNoCase(arguments.beanmap.cacheparamwild,key)
					) {
						json = serializeJSON(arguments.params);
						break;
					}
				}
			}
		}
		return json;
	}

	private boolean function paramsAreNotCached( required struct beanmap, required string beanname, required string paramjson ) {
		return (
			arrayLen(arguments.beanmap.cacheparams) > 1
			&& len(arguments.paramjson)
			&& !structKeyExists(variables.beanCache[ arguments.beanname ].params,arguments.paramjson)
		);
	}

	private boolean function sortOrderIsNotCached( required struct beanmap, required string beanname, required string orderby ) {
		return (
			len(arguments.orderby)
			&& arguments.beanmap.orderby != arguments.orderby
			&& !structKeyExists(variables.beanCache[ arguments.beanname ].sortorder,arguments.orderby)
		);
	}

}

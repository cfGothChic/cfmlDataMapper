component accessors="true" {

	property beanFactory;
	property dataFactory;
	property dataGateway;
	property utilityService;

	variables.beanCache = {};

	public function init() {
		return this;
	}

	public void function clearBean( required string bean ) {
		structDelete(variables.beanCache,arguments.bean);
	}

	public struct function get(
		required string bean,
		required numeric id,
		struct params={}
	) {
		var result = { success = false };

		if ( arguments.id || structCount(arguments.params) ) {
			var beanmap = variables.dataFactory.getBeanMap(arguments.bean);

			if ( beanmap.cached ) {
				var paramjson = getParamJson(beanmap,arguments.params);

				if ( beanCacheCheck(arguments.bean, arguments.params) ) {
					cacheBeans(beanmap, arguments.bean, arguments.params, paramjson);
				}

				var beanData = variables.beanCache[ arguments.bean ];

				if ( arguments.id && structKeyExists(beanData.beans,arguments.id) ) {
					result.bean = getCachedBean(arguments.bean,beanData,arguments.id);
					result.success = true;

				} else if ( beanParamsAreInCache(beanmap, paramjson) ) {
					var paramids = structKeyExists(beanData.params,paramjson) ? beanData.params[paramjson] : [];
					if ( arrayLen(paramids) ) {
						result.bean = getCachedBean(arguments.bean,beanData,paramids[1]);
						result.success = true;
					}
				}
			}
		}

		return result;
	}

	public struct function list(
		required string bean,
		struct params={},
		string orderby=""
	) {
		var result = { success = false, beans = [] };
		var beanmap = variables.dataFactory.getBeanMap(arguments.bean);

		if ( beanmap.cached ) {
			var paramjson = getParamJson(beanmap,arguments.params);

			if ( beanCacheCheck(arguments.bean, arguments.params, arguments.orderby) ) {
				cacheBeans(beanmap, arguments.bean, arguments.params, paramjson, arguments.orderby);
			}

			if ( beanParamsAreInCache(beanmap, paramjson) ) {
				result.beans = getBeansByParams(arguments.bean, paramjson, arguments.params, arguments.orderby);
				result.success = true;
			}
		}

		return result;
	}

	private boolean function beanCacheCheck(
		required string bean,
		required struct params,
		string orderby=""
	) {
		return (
			!structKeyExists(variables.beanCache,arguments.bean)
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
		required string bean,
		struct params={},
		string paramjson="",
		string orderby=""
	) {
		if ( checkBeanCache(arguments.beanmap, arguments.paramjson, arguments.orderby) ) {

			if ( !structKeyExists(variables.beanCache,arguments.bean) ) {
				cacheDefaultParams(arguments.bean,arguments.beanmap);
			}

			if ( paramsAreNotCached(arguments.beanmap, arguments.bean, arguments.paramjson,arguments.params) ) {
				cacheParamString(arguments.bean,arguments.paramjson,arguments.params);
			}

			if ( sortOrderIsNotCached(arguments.beanmap, arguments.bean, arguments.orderby) ) {
				cacheSortOrder(arguments.beanmap, arguments.bean, arguments.orderby);
			}
		}
	}

	private void function cacheDefaultParams( required string bean, required struct beanmap ) {
		lock timeout="60" scope="application" type="exclusive" {
			var qRecords = variables.dataGateway.read(bean=arguments.bean, params=beanmap.cacheparams[1]);
			var beanStruct = variables.dataFactory.getBeanStruct(arguments.bean, qRecords);

			// todo: figure out a better way to do this
			var idlist = evaluate("valueList(qRecords.#beanmap.primarykey#)");

			variables.beanCache[ arguments.bean ] = {
				beans = beanStruct,
				sortorder = { "default" = listToArray(idlist) },
				params = {}
			};
		}
	}

	private void function cacheParamString(
		required string bean,
		required string paramjson,
		required struct params
	) {
		var beanids = getParamBeanIds(arguments.bean, arguments.params);
		variables.beanCache[ arguments.bean ].params[ arguments.paramjson ] = beanids;
	}

	private void function cacheSortOrder( required struct beanmap, required string bean, required string orderby ) {
		var fullorderby = getFullOrderBy(arguments.beanmap, arguments.orderby);

		var qRecords = variables.dataGateway.read(
			bean = arguments.bean,
			params = beanmap.cacheparams[1],
			orderby = fullorderby,
			pkOnly = true
		);

		// todo: figure out a better way to do this
		var idlist = evaluate("valueList(qRecords.#beanmap.primarykey#)");

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

	private array function getBeansByParams( required string bean, required string paramjson, required struct params, required string orderby ) {
		var beanData = variables.beanCache[ arguments.bean ];
		var beans = [];

		var sortorder = structKeyExists(beanData.sortorder,arguments.orderby) ? beanData.sortorder[arguments.orderby] : beanData.sortorder.default;
		var paramids = len(arguments.paramjson) && structKeyExists(beanData.params,arguments.paramjson) ? beanData.params[arguments.paramjson] : sortorder;

		if ( !len(arguments.paramjson) && structCount(arguments.params) ) {
			paramids = getParamBeanIds(arguments.bean, arguments.params);
		}

		for ( var primarykey in sortorder ) {
			if (
				arrayFind(paramids,primarykey)
				&& structKeyExists(beanData.beans,primarykey)
			) {
				var cachedbean = getCachedBean(arguments.bean,beanData,primaryKey);
				arrayAppend(beans,cachedbean);
			}
		}
		return beans;
	}

	private component function getCachedBean( required string bean, required struct beanData, required numeric primaryKey ){
		// get the cached bean, but make a shallow copy so changes to the bean are not retained in cache
		if ( structKeyExists(server, "railo") || structKeyExists(server, "lucee") ) {
			var cachedbean = structCopy(beanData.beans[primarykey]);
		} else {
			var thisbean = beanData.beans[primarykey];
			var cachedStruct = thisbean.getSessionData();
			var cachedbean = variables.dataFactory.get(bean=arguments.bean);
			variables.beanFactory.injectProperties(cachedbean, cachedStruct);
		}
		return cachedbean;
	}

	private string function getFullOrderBy( required struct beanmap, required string orderby ) {
		var fullorderby = "";
		var orderprops = listToArray(arguments.orderby);

		for ( var orderprop in orderprops ) {
			orderprop = trim(orderprop);

			var propname = orderprop;
			var direction = "ASC";
			if ( listLen(orderprop," ") > 1 ) {
				propname = ListFirst(orderprop," ");
				direction = ListLast(orderprop," ");
				direction =  arrayFindNoCase(["asc","desc"],direction) ? direction : "ASC";
			}

			var prop = structKeyExists(arguments.beanmap.properties,propname) ? arguments.beanmap.properties[propname] : {};

			if ( structIsEmpty(prop) ) {
				for ( var propname in arguments.beanmap.properties ) {
					if ( arguments.beanmap.properties[propname].columnname == propname ) {
						prop = arguments.beanmap.properties[propname];
						break;
					}
				}
			}

			if ( !structIsEmpty(prop) ) {
				fullorderby &= ( ( len(fullorderby) ? ", " : "" ) & len(prop.columnname) ? prop.columnname : prop.name ) & " " & direction;
			}
		}

		return fullorderby;
	}

	private array function getParamBeanIds( required string bean, required struct params ) {
		var beanData = variables.beanCache[ arguments.bean ];
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
				var success = variables.utilityService.structCompare(cacheparam,arguments.params);
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

	private boolean function paramsAreNotCached( required struct beanmap, required string bean, required string paramjson ) {
		return (
			arrayLen(arguments.beanmap.cacheparams) > 1
			&& len(arguments.paramjson)
			&& !structKeyExists(variables.beanCache[ arguments.bean ].params,arguments.paramjson)
		);
	}

	private boolean function sortOrderIsNotCached( required struct beanmap, required string bean, required string orderby ) {
		return (
			len(arguments.orderby)
			&& arguments.beanmap.orderby != arguments.orderby
			&& !structKeyExists(variables.beanCache[ arguments.bean ].sortorder,arguments.orderby)
		);
	}

}

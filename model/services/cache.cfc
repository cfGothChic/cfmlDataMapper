component accessors="true" {

	property dataFactory;
	property dataGateway;
	property udfService;

	variables.beanCache = {};

	public function init() {
		return this;
	}

	public void function clearBean( string bean ) {
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
					result.bean = structCopy(beanData.beans[ arguments.id ]);
					result.success = true;

				} else if ( beanParamsAreInCache(beanmap, paramjson) ) {
					var paramids = structKeyExists(beanData.params,paramjson) ? beanData.params[paramjson] : [];
					if ( arrayLen(paramids) ) {
						result.bean = structCopy(beanData.beans[ paramids[1] ]);
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

	private boolean function beanParamsAreInCache( struct beanmap, string paramjson ) {
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

	private void function cacheDefaultParams( string bean, struct beanmap ) {
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

	private void function cacheSortOrder( struct beanmap, string bean, string orderby ) {
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

	private boolean function checkBeanCache( struct beanmap, string paramjson, string orderby ) {
		return (
			(
				structIsEmpty(arguments.beanmap.cacheparams[1])
				&& !len(arguments.paramjson)
			)
			|| len(arguments.paramjson)
			|| arrayLen(arguments.beanmap.cacheparams)
			|| len(arguments.orderby)
		);
	}

	private array function getBeansByParams( string bean, string paramjson, struct params, string orderby ) {
		var beanData = variables.beanCache[ arguments.bean ];
		var beans = [];

		var sortorder = structKeyExists(beanData.sortorder,arguments.orderby) ? beanData.sortorder[arguments.orderby] : beanData.sortorder.default;
		var paramids = len(arguments.paramjson) && structKeyExists(beanData.params,arguments.paramjson) ? beanData.params[arguments.paramjson] : sortorder;

		if ( !len(arguments.paramjson) && !structIsEmpty(arguments.params) ) {
			paramids = getParamBeanIds(arguments.bean, arguments.params);
		}

		for ( var primarykey in sortorder ) {
			if (
				arrayFind(paramids,primarykey)
				&& structKeyExists(beanData.beans,primarykey)
			) {
				var cachedbean = structCopy(beanData.beans[primarykey]);
				arrayAppend(beans,cachedbean);
			}
		}
		return beans;
	}

	private string function getFullOrderBy( struct beanmap, string orderby ) {
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
				fullorderby &= ( len(fullorderby) ? ", " : "" ) & len(prop.columnname) ? prop.columnname : prop.name & " " & direction;
			}
		}

		return fullorderby;
	}

	private array function getParamBeanIds( string bean, struct params ) {
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

	private string function getParamJson( struct beanmap, struct params ) {
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
				var success = variables.udfService.structCompare(cacheparam,arguments.params);
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

	private boolean function paramsAreNotCached( struct beanmap, string bean, string paramjson ) {
		return (
			arrayLen(arguments.beanmap.cacheparams) > 1
			&& len(arguments.paramjson)
			&& !structKeyExists(variables.beanCache[ arguments.bean ].params,arguments.paramjson)
		);
	}

	private boolean function sortOrderIsNotCached( struct beanmap, string bean, string orderby ) {
		return (
			(
				len(arguments.orderby)
				&& arguments.beanmap.orderby != arguments.orderby
			)
			
			&& !structKeyExists(variables.beanCache[ arguments.bean ].sortorder,arguments.orderby)
		);
	}

}
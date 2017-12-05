component accessors=true {

	property beanFactory;
	property cacheService;
	property dataGateway;
	property utilityService;

	variables.moduleCache = [];
	variables.beanmaps = {};

	public any function init( fw, utilityService ) {
		variables.fw = arguments.fw;
		variables.utilityService = arguments.utilityService;
		lock timeout="10" scope="application" type="exclusive" {
			cacheBeanMetadata();
		}
		return this;
	}

	public any function get(
		required string bean,
		string id=0,
		struct params={}
	) {
		var result = variables.cacheService.get(bean=arguments.bean, id=trim(val(arguments.id)), params=arguments.params);

		if ( result.success ) {
			return result.bean;
		} else if ( !val(arguments.id) && !structIsEmpty(arguments.params) ) {
			return getByParams(arguments.bean, arguments.params);
		} else {
			return getModuleBean(arguments.bean).init(argumentCollection=arguments);
		}
	}

	public struct function getBeanMap( required string bean ) {
		checkBeanExists(arguments.bean);
		addInheritanceMapping(arguments.bean);
		return variables.beanmaps[ arguments.bean ];
	}

	public array function getBeans( required string bean, required query qRecords ) {
		var beans = [];
		var columns = listToArray(arguments.qRecords.columnList);

		if ( arguments.qRecords.recordCount ) {
			if ( structKeyExists(server, "railo") || structKeyExists(server, "lucee") ) {
				var recordbeantemplate = getModuleBean(arguments.bean);

				for ( var i=1; i lte arguments.qRecords.recordCount; i++ ) {
					var recordbean = structcopy(recordbeantemplate);

					var properties = {};
					for ( var columnname in columns ) {
						properties[columnname] = arguments.qRecords[columnname][i];
					}

					variables.beanFactory.injectProperties(recordbean, properties);

					arrayAppend(beans,recordbean);
				}
			} else {
				for ( var i=1; i lte arguments.qRecords.recordCount; i++ ) {
					var recordbean = getModuleBean(arguments.bean);

					var properties = {};
					for ( var columnname in columns ) {
						properties[columnname] = arguments.qRecords[columnname][i];
					}

					variables.beanFactory.injectProperties(recordbean, properties);

					arrayAppend(beans,recordbean);
				}
			}
		}

		return beans;
	}

	public array function getBeansFromArray( required string bean, required array beansArray ) {
		var beans = [];

		if ( arrayLen(arguments.beansArray) ) {
			if ( structKeyExists(server, "railo") || structKeyExists(server, "lucee") ) {
				var recordbeantemplate = getModuleBean(arguments.bean);

				for ( var beandata in arguments.beansArray ) {
					var recordbean = structcopy(recordbeantemplate);
					variables.beanFactory.injectProperties(recordbean, beandata);
					arrayAppend(beans,recordbean);
				}

			} else {
				for ( var beandata in arguments.beansArray ) {
					var recordbean = getModuleBean(arguments.bean);
					variables.beanFactory.injectProperties(recordbean, beandata);
					arrayAppend(beans,recordbean);
				}
			}
		}

		return beans;
	}

	public struct function getBeanStruct( required string bean, required query qRecords ) {
		var beans = {};
		var columns = listToArray(arguments.qRecords.columnList);
		var beanmap = getBeanMap(arguments.bean);

		if ( arguments.qRecords.recordCount ) {
			if ( structKeyExists(server, "railo") || structKeyExists(server, "lucee") ) {
				var recordbeantemplate = getModuleBean(arguments.bean);

				for ( var i=1; i lte arguments.qRecords.recordCount; i++ ) {
					var recordbean = structcopy(recordbeantemplate);

					var properties = {};
					for ( var columnname in columns ) {
						properties[columnname] = arguments.qRecords[columnname][i];
					}

					variables.beanFactory.injectProperties(recordbean, properties);

					beans[ recordbean.getPropertyValue(beanmap.primarykey) ] = recordbean;
				}
			} else {
				for ( var i=1; i lte arguments.qRecords.recordCount; i++ ) {
					var recordbean = getModuleBean(arguments.bean);

					var properties = {};
					for ( var columnname in columns ) {
						properties[columnname] = arguments.qRecords[columnname][i];
					}

					variables.beanFactory.injectProperties(recordbean, properties);

					beans[ recordbean.getId() ] = recordbean;
				}
			}
		}

		return beans;
	}

	public boolean function hasBean( required string beanname ) {
		lock timeout="10" scope="application" type="exclusive" {
			if ( !structKeyExists(variables.beanmaps,arguments.beanname) ) {
				var modulename = ( find(".",arguments.beanname) ? listFirst(arguments.beanname,".") : "" );
				if ( len(modulename) && !arrayFindNoCase(variables.moduleCache,modulename) ) {
					readBeanDirectory("/" & modulename & "/model/beans/",modulename);
				}
			}
		}
		return ( structKeyExists(variables.beanmaps,arguments.beanname) );
	}

	public array function list(
		required string bean,
		struct params={},
		string orderby=""
	) {
		if ( structKeyExists(arguments,"singular") ) {
			throw("The singular argument of dataFactory.list() is deprecated. Use get() with the params argument instead.");
		}
		var result = variables.cacheService.list(argumentCollection=arguments);

		if ( !result.success ) {
			var qRecords = variables.dataGateway.read(arguments.bean, arguments.params, arguments.orderby);
			result.beans = getBeans(arguments.bean, qRecords);
		}
		return result.beans;
	}

	private void function addInheritanceMapping( bean ) {
		var beanmap = variables.beanmaps[ arguments.bean ];
		if (
			!structKeyExists(beanmap,"table")
			&& len(beanmap.inherits)
		) {
			var parentbeanmap = getBeanMap(beanmap.inherits);
			if ( structCount(parentbeanmap.properties) ) {
				structAppend(beanmap.properties, parentbeanmap.properties, false);
			}
			if ( structCount(parentbeanmap.relationships) ) {
				structAppend(beanmap.relationships, parentbeanmap.relationships, false);
			}
			structAppend(beanmap, parentbeanmap, false);
		}
	}

	private void function cacheBeanMetadata() {
		if ( directoryExists( expandPath("/newmodel/beans/") ) ) {
			readBeanDirectory("/newmodel/beans/");
		} else {
			readBeanDirectory("/model/beans/");
		}
	}

	private boolean function checkBeanExists( beanname ) {
		if ( !hasBean(arguments.beanname) ) {
			throw ("Bean does not exist for: " & arguments.beanname);
		}
		return true;
	}

	private void function createBeanMap( name, metadata ) {
		var beanmap = getBeanMapMetadata(arguments.metadata);
		beanmap.bean = ( structKeyExists(arguments.metadata,"bean") ? arguments.metadata.bean : arguments.name );
		beanmap.inherits = getInheritanceMetadata(arguments.metadata);

		beanmap.properties = {};
		beanmap.relationships = {};

		if ( structKeyExists(arguments.metadata,"properties") ) {
			var proplen = arrayLen(arguments.metadata.properties);
			for ( var i=1; i lte proplen; i++ ) {
				prop = arguments.metadata.properties[i];

				beanmap.properties[ prop.name ] = getPropertyMetadata(prop);
				if ( !structCount( beanmap.properties[ prop.name ] ) ) {
					structDelete(beanmap.properties,prop.name);
				}

				beanmap.relationships[ prop.name ] = getRelationshipMetadata(prop);
				if ( !structCount( beanmap.relationships[ prop.name ] ) ) {
					structDelete(beanmap.relationships,prop.name);
				}
			}
		}

		variables.beanmaps[ beanmap.bean ] = beanmap;
	}

	private struct function getBeanMapMetadata( metadata ) {
		var beanmap = {};
		if ( structKeyExists(arguments.metadata,"table") && structKeyExists(arguments.metadata,"primarykey") ) {
			beanmap.table = arguments.metadata.table;
			beanmap.primarykey = arguments.metadata.primarykey;
			beanmap.orderby = ( structKeyExists(arguments.metadata,"orderby") ? arguments.metadata.orderby : "" );
			beanmap.schema = ( structKeyExists(arguments.metadata,"schema") ? arguments.metadata.schema : "" );
			beanmap.cached = ( structKeyExists(arguments.metadata,"cached") && isBoolean(arguments.metadata.cached) ? arguments.metadata.cached : false );
			beanmap.cacheparams = ( structKeyExists(arguments.metadata,"cacheparams") ? deserializeJSON(arguments.metadata.cacheparams) : [{}] );

			if ( !isArray(beanmap.cacheparams) || !arrayLen(beanmap.cacheparams) || !isStruct(beanmap.cacheparams[1]) ) {
				throw("Bean attribute cacheparams must be a json array of structures. Default is [{}]")
			}

			beanmap.cacheparamdefault = serializeJSON(beanmap.cacheparams[1]);

			beanmap.cacheparamwild = [];
			for ( var cacheparam in beanmap.cacheparams ) {
				var keys = structKeyList(cacheparam);
				if (
					structCount(cacheparam) == 1
					&& cacheparam[keys] == "*"
				) {
					arrayAppend(beanmap.cacheparamwild,keys);
				}
			}
		} else {
			beanmap.cached = false;
		}
		return beanmap;
	}

	private function getByParams( beanname, params ) {
		checkBeanExists(arguments.beanname);
		var qRecord = variables.dataGateway.read(arguments.beanname, arguments.params);
		var bean = get(arguments.beanname);
		if ( qRecord.recordCount ) {
			bean.populateBean(qRecord);
		}
		return bean;
	}

	private string function getCfSqlType( sqltype ) {
		arguments.sqltype = listLast(arguments.sqltype,"_") == "int" ? "integer" : arguments.sqltype;
		return ( findNoCase("cf_sql_",arguments.sqltype) ? arguments.sqltype : "cf_sql_" & arguments.sqltype );
	}

	private string function getDatatype(valtype,sqltype){
		var datatype = "any";

		if( len(trim(arguments.valtype)) ){
			datatype = arguments.valtype;
		} else if ( len(arguments.sqltype) ){
			switch(replacenocase(arguments.sqltype,"cf_sql_","")){
				case "bit":
					datatype = "boolean";
				break;

				case "varchar":
				case "nvarchar":
				case "text":
				case "ntext":
					datatype = "string";
				break;

				case "integer":
				case "float":
					datatype = "numeric";
				break;
			}
		}

		return datatype;
	}

	private string function getInheritanceMetadata( metadata ) {
		var inherits = "";
		if ( !findNoCase("model.base",arguments.metadata.extends.fullname) ) {
			if ( listFirst(arguments.metadata.extends.fullname,".") != "model" ) {
				inherits = listFirst(arguments.metadata.fullname,".") & ".";
			}
			inherits &= listLast(arguments.metadata.extends.fullname,".");
		}
		return inherits;
	}

	private function getModuleBean( bean ) {
		checkBeanExists(arguments.bean);

		var temp = listToArray(arguments.bean,".");
		var modulename = ( arrayLen(temp) == 2 ? temp[1] : "" );
		var beanname = ( arrayLen(temp) == 2 ? temp[2] : arguments.bean );

		if ( len(modulename) ) {
			return variables.fw.getSubsystemBeanFactory(modulename).getBean( beanname & "Bean" );
		} else {
			//return variables.beanFactory.getBean( beanname & "Bean" );
			return variables.fw.getDefaultBeanFactory().getBean( beanname & "Bean" );
		}
	}

	private struct function getPropertyMetadata( prop ) {
		var metadata = {};
		if ( structKeyExists(prop,"cfsqltype") ) {
			metadata.name = prop.name;
			metadata.defaultvalue = ( structKeyExists(prop,"default") ? prop.default : "" );
			metadata.displayname = ( structKeyExists(prop,"displayname") ? prop.displayname : variables.utilityService.upperFirst(prop.name) );
			metadata.columnName = ( structKeyExists(prop,"columnName") ? prop.columnName : "" );
			metadata.insert = ( structKeyExists(prop,"insert") && isBoolean(prop.insert) ? prop.insert : true );
			metadata.isidentity = ( structKeyExists(prop,"isidentity") && isBoolean(prop.isidentity) ? prop.isidentity : false );
			metadata.null = ( structKeyExists(prop,"null") && isBoolean(prop.null) ? prop.null : false );
			metadata.sqltype = getCfSqlType(prop.cfsqltype);
			metadata.valtype = ( structKeyExists(prop,"valtype") ? prop.valtype : "" );
			metadata.regex = ( structKeyExists(prop,"regex") ? prop.regex : "" );
			metadata.regexlabel = ( structKeyExists(prop,"regexlabel") ? prop.regexlabel : "" );
			metadata.minvalue = ( structKeyExists(prop,"minvalue") ? prop.minvalue : "" );
			metadata.maxvalue = ( structKeyExists(prop,"maxvalue") ? prop.maxvalue : "" );
			metadata.minlength = ( structKeyExists(prop,"minlength") ? prop.minlength : "" );
			metadata.maxlength = ( structKeyExists(prop,"maxlength") ? prop.maxlength : "" );
			metadata.datatype = getDatatype(metadata.valtype,metadata.sqltype);
		}
		return metadata;
	}

	private struct function getRelationshipMetadata( prop ) {
		var metadata = {};
		if ( structKeyExists(prop,"bean") ) {
			metadata.name = prop.name;
			metadata.bean = prop.bean;
			metadata.joinType = ( structKeyExists(prop,"joinType") ? prop.joinType : "" );
			metadata.contexts = ( structKeyExists(prop,"contexts") ? ( isArray(prop.contexts) ? prop.contexts : listToArray(prop.contexts) ) : [] );
			metadata.fkColumn = ( structKeyExists(prop,"fkColumn") ? prop.fkColumn : "" );
			metadata.fkName = ( structKeyExists(prop,"fkName") ? prop.fkName : "" );
			metadata.fksqltype = ( structKeyExists(prop,"fksqltype") ? getCfSqlType(prop.fksqltype) : "" );
			metadata.joinSchema = ( structKeyExists(prop,"joinSchema") ? prop.joinSchema : "" );
			metadata.joinTable = ( structKeyExists(prop,"joinTable") ? prop.joinTable : "" );
			metadata.joinColumn = ( structKeyExists(prop,"joinColumn") ? prop.joinColumn : "" );
		}
		return metadata;
	}

	private void function readBeanDirectory( beanpath, modulename="" ) {
		var cfcbeanpath = replace(right(arguments.beanpath,len(arguments.beanpath)-1),"/",".","all");
		var modelpath = findNoCase("newmodel",arguments.beanpath) ? "newmodel" : "model";
		var modulepath = ( len(arguments.modulename) ? arguments.modulename & "." : "" );
		var beanlist = directoryList( expandPath(arguments.beanpath), false, "name", "*.cfc");

		for ( var bean in beanlist ) {
			var beanname = listFirst(bean,".");
			var beanmetadata = getMetadata( createObject("component", modulepath & modelpath & ".beans." & beanname) );

			if (
				findNoCase("model.base", beanmetadata.extends.fullname)
				|| findNoCase("model.bean", beanmetadata.extends.fullname)
				|| findNoCase(cfcbeanpath, beanmetadata.extends.fullname)
			) {
				createBeanMap(modulepath & beanname, beanmetadata);
				if ( len(arguments.modulename) && !arrayFindNoCase(variables.moduleCache,arguments.modulename) ) {
					arrayAppend(variables.moduleCache,arguments.modulename);
				}
			}
		}
	}

}

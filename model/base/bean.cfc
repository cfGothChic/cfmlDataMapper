component accessors="true" {

	// bean metadata
	property beanMap;
	property beanName;

	// dependencies
	property beanFactory;
	property cacheService;
	property dataFactory;
	property dataGateway;
	property validationService;

	public function init( id=0 ) {
		populate(arguments.id);
		return this;
	}

	public struct function delete() {
		var result = { "success"=true, "code"=001, "messages"=[] };
		try {
			var beanmap = getBeanMap();
			variables.dataGateway.delete(getBeanName(), variables[ beanmap.primaryKey ]);
		} catch (any e) {
			arrayAppend(result.messages,"There was an issue deleting the " & getBeanName() & ".");
			result.success = false;
			result.code = 500;
			result["error"] = e;
		}
		return result;
	}

	public boolean function exists() {
		if ( isNull( getIsDeleted() ) ) {
			return ( getId() ? true : false );
		} else {
			return ( getId() && !getIsDeleted() );
		}
	}

	public struct function getBeanMap() {
		if ( isNull(variables.beanMap) ) {
			var bean = getBeanName();
			variables.beanMap = variables.dataFactory.getBeanMap(bean);
		}
		return variables.beanMap;
	}

	public numeric function getId(){
		return isNull(variables.id) || !isNumeric(variables.id) ? 0 : variables.id;
	}

	public boolean function getIsDeleted() {
		return isNull(variables.isDeleted) || !isBoolean(variables.isDeleted) ? false : variables.isDeleted;
	}

	public any function getPropertyValue(propertyname){
		var value = "";

		if(structKeyExists(variables,propertyname)){
			try {
				var getter = variables["get" & propertyname];
				value = getter();
			} catch (any e) {
				value = variables[arguments.propertyname];
			}
			if( isNull(value) ){
				value = "";
			}
		}

		if( !len(value) ){
			var beanmap = getBeanMap();
			if( structKeyExists(beanmap.properties,propertyname) ){
				value = beanmap.properties[propertyname].defaultvalue;
			}
		}

		return trim(value);
	}

	public struct function getSessionData( struct data={} ) {
		var beanmap = getBeanMap();

		for ( var prop IN beanmap.properties ) {
			arguments.data[ prop ] = getPropertyValue(prop);
		}

		if ( len(getDerivedFields()) ) {
			var derivedfields = listToArray(getDerivedFields());
			for ( var field in derivedfields ) {
				arguments.data[ field ] = getPropertyValue(field);
			}
		}

		return arguments.data;
	}

	public void function onMissingMethod(missingMethodName,missingMethodArguments){
		if ( left(arguments.missingMethodName,3) != "set" ) {
			throw(message="Method '" & arguments.missingMethodName & "' not defined in bean " & getBeanName() );
		}
	}

	public void function populateBean( required query qRecord ) {
		var columns = listToArray(qRecord.columnList);

		var properties = {};
		for ( var columnname in columns ) {
			properties[columnname] = qRecord[columnname][1];
		}

		variables.beanFactory.injectProperties(this, properties);
	}

	public struct function save( validate=true ) {
		var result = { "success"=true, "code"=001, "message"=[] };

		transaction {
			try {
				var bean = getBeanName();
				var beanmap = getBeanMap();

				if(arguments.validate){
					var errors = this.validate();
					if( arrayLen(errors) ){
						result.success = false;
						result.code = 900;// indicates validation error
						result.message = errors;
					}
				}

				if( result.success ){
					if ( variables[ beanmap.primarykey ] ) {
						variables.dataGateway.update(bean, this);
					} else {
						var newid = variables.dataGateway.create(bean, this);
						setPrimaryKey(newid);
					}

					if ( beanmap.cached ) {
						clearCache();
					}
				}

				transaction action="commit";
			} catch (any e) {
				transaction action="rollback";
				arrayAppend(result.message,"There was an issue saving the " & getBeanName() & ".");
				result.success = false;
				result.code = 500;
				result["error"] = e;
			}
		}

		return result;
	}

	/**
	 * @hint Validates an object based on the properties metadata
	 */
	public array function validate() {
		var beanMap = getBeanMap();
		return variables.validationService.validateBean(beanmap=beanmap,bean=this);
	}

	private void function clearCache() {
		var bean = getBeanName();
		variables.cacheService.clearBean(bean);
	}

	private string function getBeanMetaDataName() {
		var metadata = getMetaData(this);
		return structKeyExists(metadata,"bean") ? metadata.bean : listLast(metadata.name, ".");
	}

	private string function getBeanName() {
		if ( isNull(variables.beanname) ) {
			variables.beanname = getBeanMetaDataName();
		}
		return variables.beanname;
	}

	private string function getDerivedFields() {
		return "";
	}

	private numeric function getForeignKeyId( required string fkName ) {
		return (
			(
				structKeyExists(variables,arguments.fkName)
				&& isValid("integer", variables[ arguments.fkName ])
			)
			? variables[ arguments.fkName ] : 0
		);
	}

	private array function getManyToManyValue( required string primarykey, required struct relationship ) {
		if ( variables[ arguments.primarykey ] ) {
			var qRecords = variables.dataGateway.readByJoinTable(
				beanid = variables[ arguments.primarykey ],
				relationship = arguments.relationship
			);
			return variables.dataFactory.getBeans(arguments.relationship.bean, qRecords);
		} else {
			return [];
		}
	}

	private array function getOneToManyValue( required string primarykey, required struct relationship ) {
		if ( variables[ arguments.primarykey ] ) {
			return variables.dataFactory.list(
				bean = arguments.relationship.bean,
				params = { "#relationship.fkName#" = variables[ arguments.primarykey ] }
			);
		} else {
			return [];
		}
	}

	private function getRelationshipKeys( context="" ) {
		var relationshipkeys = [];
		arrayAppend(relationshipkeys,"_bean");

		var beanmap = getBeanMap();

		if ( len(arguments.context) && arguments.context != "_bean" && structKeyExists(beanmap,"relationships") ) {
			for ( var key in beanmap.relationships ) {
				var contexts = beanmap.relationships[key].contexts;
				if ( !arrayLen(contexts) || arrayFindNoCase(contexts,arguments.context) ) {
					arrayAppend(relationshipkeys,key);
				}
			}
			arraySort(relationshipkeys,"textnocase");
		}

		return relationshipkeys;
	}

	private component function getSingularValue( required string primarykey, required struct relationship ) {
		return variables.dataFactory.get(
			bean = arguments.relationship.bean,
			id = getForeignKeyId(arguments.relationship.fkName)
		);
	}

	private void function populate( numeric id=0, string bean="" ) {
		if ( !isNumeric(arguments.id) ) {
			arguments.id = 0;
		}
		setBeanName(arguments.bean);

		if ( arguments.id ) {
			var qRecord = variables.dataGateway.read( bean=getBeanName(), params={ id = arguments.id } );
			if ( qRecord.recordCount ) {
				populateBean(qRecord);
			} else {
				arguments.id = 0;
			}
		}

		variables.id = arguments.id;
		// todo: setPrimaryKey(arguments.id);
	}

	private void function populateBySproc( id=0, bean="", sproc="", params=[], resultkeys=[], context ) {
		if ( !isNumeric(arguments.id) ) {
			arguments.id = 0;
		}
		if ( !isNull(arguments.context) && !len(arguments.context) ) {
			arguments.context = "_bean";
		} else if ( isNull(arguments.context) ) {
			arguments.context = "";
		}
		setBeanName(arguments.bean);

		if ( arguments.id || arrayLen(arguments.params) ) {

			if ( arguments.id ) {
				arrayAppend(arguments.params, { value=arguments.id, cfsqltype="cf_sql_integer" });
			}
			if ( len(arguments.context) && arguments.context != "default" ) {
				arrayAppend(arguments.params, { value=arguments.context, cfsqltype="cf_sql_varchar" });
			}

			if ( !arrayLen(arguments.resultkeys) ) {
				arguments.resultkeys = getRelationshipKeys(arguments.context);
			}

			var sprocData = variables.dataGateway.readSproc(arguments.sproc, arguments.params, arguments.resultkeys);
			populateSprocData(sprocData, arguments.resultkeys);

			if ( sprocData._bean.recordCount ) {
				var beanmap = getBeanMap();
				arguments.id = variables[ beanmap.primarykey ];
			} else {
				arguments.id = 0;
			}
		}

		setPrimaryKey(arguments.id);
	}

	private void function populateRelationship( required string relationshipName ) {
		if ( isNull( evaluate("get" & arguments.relationshipName & "()") ) ) {
			var beanmap = getBeanMap();

			if ( !structKeyExists(beanmap,"relationships") || !structKeyExists(beanmap.relationships,arguments.relationshipName) ) {
				throw ("A " & arguments.relationshipName & " relationship is not defined in the " & beanmap.name & " bean map.");
			}

			var relationship = beanmap.relationships[ arguments.relationshipName ];

			var value = "";
			switch ( relationship.joinType ) {
				case "one":
					value = getSingularValue(beanmap.primarykey, relationship);
					break;
				case "one-to-many":
					value = getOneToManyValue(beanmap.primarykey, relationship);
					break;
				case "many-to-many":
					value = getManyToManyValue(beanmap.primarykey, relationship);
					break;
			}

			if ( !isSimpleValue(value) ) {
				variables.beanFactory.injectProperties(this, { "#arguments.relationshipName#" = value });
			}
		}
	}

	private function populateSprocData( data, resultkeys ) {
		var beanmap = getBeanMap();
		var properties = {};
		for ( var relationship in arguments.resultkeys ) {
			var isSingular = ( relationship != "_bean" && beanmap.relationships[relationship].joinType == "one" );
			if ( relationship == "_bean" ) {
				if ( arguments.data._bean.recordCount ) {
					populateBean(arguments.data._bean);
				}

			} else if ( arguments.data[relationship].recordCount ) {
				var beans = variables.dataFactory.getBeans( beanmap.relationships[relationship].bean, arguments.data[relationship] );
				if ( isSingular ) {
					properties[relationship] = beans[1];
				} else {
					properties[relationship] = beans;
				}
			} else if ( isSingular ) {
				properties[relationship] = variables.dataFactory.get( beanmap.relationships[relationship].bean );
			} else {
				properties[relationship] = [];
			}
		}

		if ( structCount(properties) ) {
			variables.beanFactory.injectProperties(this, properties);
		}
	}

	private void function setBeanName( string bean="" ) {
		variables.beanname = ( len(arguments.bean) ? arguments.bean : getBeanMetaDataName() );
	}

	private function setPrimaryKey(primarykey) {
		if ( isNull(variables.dataFactory) ) {
			// todo: make this dynamic so that the primary key does not have to be id for the pk to default to 0
			variables.id = arguments.primarykey;
		} else {
			var beanmap = getBeanMap();
			variables[ beanmap.primarykey ] = arguments.primarykey;
		}
	}

}

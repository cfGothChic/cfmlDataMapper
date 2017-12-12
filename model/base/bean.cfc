component accessors="true" {

	// bean metadata
	property beanMap;
	property beanName;

	// dependencies
	property BeanFactory;
	property CacheService;
	property DataFactory;
	property DataGateway;
	property SQLService;
	property ValidationService;

	public component function init( string id=0 ) {
		populate( id=arguments.id );
		return this;
	}

	public struct function delete() {
		var result = { "success"=true, "code"=001, "messages"=[] };
		try {
			var beanmap = getBeanMap();
			variables.SQLService.delete( beanname=getBeanName(), id=variables[ beanmap.primaryKey ] );
		} catch (any e) {
			arrayAppend(result.messages,"There was an issue deleting the " & getBeanName() & ".");
			result.success = false;
			result.code = 500;
			result["error"] = e;
		}
		return result;
	}

	public boolean function exists() {
		return ( getId() && !getIsDeleted() ? true : false );
	}

	public struct function getBeanMap() {
		if ( isNull(variables.beanMap) ) {
			var bean = getBeanName();
			variables.beanMap = variables.DataFactory.getBeanMap(bean);
		}
		return variables.beanMap;
	}

	public numeric function getId(){
		return isNull(variables.id) || !isNumeric(variables.id) ? 0 : variables.id;
	}

	public boolean function getIsDeleted() {
		return isNull(variables.isDeleted) || !isBoolean(variables.isDeleted) ? false : variables.isDeleted;
	}

	public any function getPropertyValue( required string propertyname ){
		var value = getBeanPropertyValue( propertyname=arguments.propertyname );

		if( !len(value) ){
			value = getPropertyDefault( propertyname=arguments.propertyname );
		}

		return value;
	}

	public struct function getSessionData( struct data={} ) {
		var beanmap = getBeanMap();

		for ( var prop in beanmap.properties ) {
			arguments.data[ prop ] = getPropertyValue(propertyname=prop);
		}

		if ( len(getDerivedFields()) ) {
			var derivedfields = listToArray(getDerivedFields());
			for ( var field in derivedfields ) {
				arguments.data[ field ] = getPropertyValue(propertyname=field);
			}
		}

		return arguments.data;
	}

	public void function onMissingMethod( required string missingMethodName, required struct missingMethodArguments ){
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

		variables.BeanFactory.injectProperties(this, properties);
	}

	public struct function save( validate=true ) {
		var result = { "success"=true, "code"=001, "message"=[] };

		transaction {
			try {
				var beanname = getBeanName();
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
						variables.SQLService.update( beanname=beanname, bean=this );
					} else {
						var newid = variables.SQLService.create( beanname=beanname, bean=this);
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
		return variables.ValidationService.validateBean( beanmap=beanmap, bean=this );
	}

	private void function clearCache() {
		var beanname = getBeanName();
		variables.CacheService.clearBean( beanname=beanname );
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

	private any function getBeanPropertyValue( required string propertyname ) {
		var value = "";

		if( structKeyExists(variables, propertyname) ){
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

		return isSimpleValue(value) ? trim(value) : value;
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
			var qRecords = variables.SQLService.readByJoin(
				beanid = variables[ arguments.primarykey ],
				relationship = arguments.relationship
			);
			return variables.DataFactory.getBeans(arguments.relationship.bean, qRecords);
		} else {
			return [];
		}
	}

	private array function getOneToManyValue( required string primarykey, required struct relationship ) {
		if ( variables[ arguments.primarykey ] ) {
			return variables.DataFactory.list(
				bean = arguments.relationship.bean,
				params = { "#relationship.fkName#" = variables[ arguments.primarykey ] }
			);
		} else {
			return [];
		}
	}

	private numeric function getPrimaryKeyFromSprocData( required struct sprocData ) {
		if ( arguments.sprocData._bean.recordCount ) {
			var beanmap = getBeanMap();
			return variables[ beanmap.primarykey ];
		} else {
			return 0;
		}
	}

	private any function getPropertyDefault( required string propertyname ) {
		var value = "";
		var beanmap = getBeanMap();
		if( structKeyExists(beanmap.properties, arguments.propertyname) ){
			value = beanmap.properties[ arguments.propertyname ].defaultvalue;
		}
		return value;
	}

	private array function getRelationshipKeys( string context="" ) {
		var relationshipkeys = [];
		arrayAppend(relationshipkeys,"_bean");

		var beanmap = getBeanMap();

		if ( len(arguments.context) && arguments.context != "_bean" && structCount(beanmap.relationships) ) {
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

	private component function getSingularBean( required string primarykey, required struct relationship ) {
		return variables.DataFactory.get(
			bean = arguments.relationship.bean,
			id = getForeignKeyId(arguments.relationship.fkName)
		);
	}

	private component function getSingularSprocBean( required string beanname, required query qRecords ) {
		var beans = variables.DataFactory.getBeans( bean=arguments.beanname, qRecords=arguments.qRecords );
		if ( arrayLen(beans) ) {
			return beans[1];
		} else {
			return variables.DataFactory.get( bean=arguments.beanname );
		}
	}

	private string function getSprocContext() {
		if ( structKeyExists(arguments, "context") && !len(arguments.context) ) {
			return "_bean";
		}
		else if ( !structKeyExists(arguments, "context") ) {
			return "";
		}
		else {
			return arguments.context;
		}
	}

	private any function getSprocRelationship( required string beanname, required string joinType, required query qRecords ) {
		var isSingular = ( arguments.joinType == "one" );
		if ( isSingular ) {
			return getSingularSprocBean( beanname=arguments.beanname, qRecords=arguments.qRecords );
		} else {
			return variables.DataFactory.getBeans( bean=arguments.beanname, qRecords=arguments.qRecords );
		}
	}

	private void function populate( numeric id=0, string beanname="" ) {
		if ( !isNumeric(arguments.id) ) {
			arguments.id = 0;
		}
		setBeanName( beanname=arguments.beanname );

		if ( arguments.id ) {
			var qRecord = variables.SQLService.read(
				beanname=getBeanName(),
				methodname="populate",
				params={ id = arguments.id }
			);

			if ( qRecord.recordCount ) {
				populateBean(qRecord);
			} else {
				arguments.id = 0;
			}
		}

		variables.id = arguments.id;
		// todo: setPrimaryKey(arguments.id);
	}

	private void function populateBySproc(
		required string sproc,
		string id="",
		string beanname="",
		array params=[],
		array resultkeys=[]
	) {
		if ( !isNumeric(arguments.id) ) {
			arguments.id = 0;
		}
		arguments.context = getSprocContext( argumentCollection=arguments );
		setBeanName( beanname=arguments.beanname );

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

			var sprocData = variables.DataGateway.readSproc(arguments.sproc, arguments.params, arguments.resultkeys);
			populateSprocData(sprocData, arguments.resultkeys);

			arguments.id = getPrimaryKeyFromSprocData( sprocData=sprocData );
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
					value = getSingularBean(beanmap.primarykey, relationship);
					break;
				case "one-to-many":
					value = getOneToManyValue(beanmap.primarykey, relationship);
					break;
				case "many-to-many":
					value = getManyToManyValue(beanmap.primarykey, relationship);
					break;
			}

			if ( !isSimpleValue(value) ) {
				variables.BeanFactory.injectProperties(this, { "#arguments.relationshipName#" = value });
			}
		}
	}

	private void function populateSprocData( required struct data, required array resultkeys ) {
		var beanmap = getBeanMap();
		var properties = {};
		for ( var relationship in arguments.resultkeys ) {

			if ( relationship == "_bean" ) {
				if ( arguments.data._bean.recordCount ) {
					populateBean(arguments.data._bean);
				}
			}

			else {
				properties[relationship] = getSprocRelationship(
					beanname=beanmap.relationships[relationship].bean,
					joinType=beanmap.relationships[relationship].joinType,
					qRecords=arguments.data[relationship]
				);
			}
		}

		if ( structCount(properties) ) {
			variables.BeanFactory.injectProperties(this, properties);
		}
	}

	private void function setBeanName( string beanname="" ) {
		variables.beanname = ( len(arguments.beanname) ? arguments.beanname : getBeanMetaDataName() );
	}

	private void function setPrimaryKey( required string primarykey ) {
		if ( isNull(variables.DataFactory) ) {
			// todo: make this dynamic so that the primary key does not have to be id for the pk to default to 0
			variables.id = arguments.primarykey;
		} else {
			var beanmap = getBeanMap();
			variables[ beanmap.primarykey ] = arguments.primarykey;
		}
	}

}

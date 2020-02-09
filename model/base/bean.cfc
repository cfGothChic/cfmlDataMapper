component accessors="true" {

	// bean metadata
	property beanMap;
	property beanName;

	// dependencies
	property BeanFactory;
	property BeanService;
	property CacheService;
	property DataFactory;
	property SQLService;
	property UtilityService;
	property ValidationService;

	public component function init( string id, string context="" ) {
		try {
			var beanmap = getBeanMap();
			if ( len(beanmap.sproc) ) {
				variables.BeanService.populateBySproc( bean=this, id=arguments.id, sproc=beanmap.sproc, context=arguments.context);
			}
			else {
				variables.BeanService.populateById( bean=this, id=arguments.id );
			}
		} catch (any e) {
			if ( !findNoCase("DataFactory", e.message) ) {
				rethrow;
			}
		}
		return this;
	}

	public struct function delete() {
		var result = variables.UtilityService.getResultStruct();
		try {
			var beanmap = getBeanMap();
			var id = getBeanPropertyValue( propertyname=beanmap.primaryKey );
			variables.SQLService.delete( beanname=getBeanName(), id=id );
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

	public array function getBeanArrayProperties( array beans=[], string relationshipName="", struct params={} ) {
		if ( arguments.relationshipName.len() && !arguments.beans.len() ) {
			var relationship = getRelationship( name=arguments.relationshipName );
			if ( isArray(relationship) ) {
				arguments.beans = relationship;
			}
		}

		if ( arguments.beans.len() ) {
			return variables.dataFactory.getBeanArrayProperties( beans=arguments.beans, params=arguments.params );
		}
		return [];
	}

	public struct function getBeanMap() {
		if ( isNull(variables.beanMap) ) {
			var beanname = getBeanName();
			variables.beanMap = variables.DataFactory.getBeanMap( bean=beanname );
		}
		return variables.beanMap;
	}

	public string function getBeanName() {
		if ( isNull(variables.beanname) ) {
			variables.beanname = getBeanMetaDataName();
		}
		return variables.beanname;
	}

	public numeric function getId(){
		return isNull(variables.id) || !isNumeric(variables.id) ? 0 : variables.id;
	}

	public boolean function getIsDeleted() {
		return isNull(variables.isDeleted) || !isBoolean(variables.isDeleted) ? false : variables.isDeleted;
	}

	public any function getPropertyValue( required string propertyname ){
		var value = getBeanPropertyValue( propertyname=arguments.propertyname );

		if( isSimpleValue(value) && !len(value) ){
			value = getPropertyDefault( propertyname=arguments.propertyname );
		}

		return value;
	}

	public struct function getProperties() {
		var data = {};
		var beanmap = getBeanMap();

		for ( var prop in beanmap.properties ) {
			var value = getPropertyValue( propertyname=prop );
			if ( beanmap.properties[prop].datatype == "boolean" ) {
				value = val(value) ? true : false;
			}
			data[ prop ] = value;
		}

		return data;
	}

	public void function onMissingMethod( required string missingMethodName, required struct missingMethodArguments ){
		if ( left(arguments.missingMethodName,3) != "set" ) {
			throw(message="Method '" & arguments.missingMethodName & "' not defined in bean " & getBeanName() );
		}
	}

	public void function populate( required struct properties ) {
		variables.BeanFactory.injectProperties(this, properties);
	}

	public struct function save( validate=true ) {
		var result = variables.UtilityService.getResultStruct();

		transaction {
			try {
				var beanname = getBeanName();
				var beanmap = getBeanMap();

				if(arguments.validate){
					var errors = this.validate();
					if( arrayLen(errors) ){
						result.success = false;
						result.code = 900;// indicates validation error
						result.messages = errors;
					}
				}

				if( result.success ){
					if ( variables[ beanmap.primarykey ] ) {
						variables.SQLService.update( beanname=beanname, bean=this );
					}
					else {
						var newid = variables.SQLService.create( beanname=beanname, bean=this );
						setPrimaryKey(newid);
					}

					if ( beanmap.cached ) {
						clearCache();
					}
				}

				transaction action="commit";
			} catch (any e) {
				transaction action="rollback";
				arrayAppend(result.messages,"There was an issue saving the " & getBeanName() & ".");
				result.success = false;
				result.code = 500;
				result["error"] = e;
			}
		}

		return result;
	}

	public void function setBeanName( string beanname="" ) {
		variables.beanname = ( len(arguments.beanname) ? arguments.beanname : getBeanMetaDataName() );
	}

	public void function setPrimaryKey( required string primarykey ) {
		if ( isNull(variables.DataFactory) ) {
			// todo: make this dynamic so that the primary key does not have to be id for the pk to default to 0
			variables.id = arguments.primarykey;
		}
		else {
			var beanmap = getBeanMap();
			variables[ beanmap.primarykey ] = arguments.primarykey;
		}
	}

	/**
	 * @hint Validates an object based on the property's metadata
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

	private any function getPropertyDefault( required string propertyname ) {
		var value = "";
		var beanmap = getBeanMap();
		if( structKeyExists(beanmap.properties, arguments.propertyname) ){
			value = beanmap.properties[ arguments.propertyname ].defaultvalue;
		}
		return value;
	}

	private any function getRelationship( required string name ) {
		return variables.BeanService.populateRelationship( bean=this, relationshipName=arguments.name );
	}

	private boolean function hasRelationship( required string name ){
		var value = getRelationship( name=arguments.name );
		var success = false;

		if ( isObject(value) ) {
			success = value.exists() ? true : false;
		}
		else if ( isArray(value) ) {
			success = arrayLen(value) ? true : false;
		}

		return success;
	}

}

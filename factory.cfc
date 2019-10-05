component accessors="true" output="false" {

	property struct factoryConfig;

	public component function init(struct config={}) {
		setFactoryConfig(arguments.config);
		validateConfig();
		return this;
	}

	public cfmlDataMapper.model.factory.data function getFactory() {
		return getBeanFactory().getBean("DataFactory");
	}

	public component function getBeanFactory() {
		_get_framework_one().onRequestStart("");
		return _get_framework_one().getDefaultBeanFactory();
	}

	private component function _get_framework_one() {
		if ( !structKeyExists( request, '_framework_one' ) ) {
			request._framework_one = new framework.one(getFrameworkConfig());
		}
		return request._framework_one;
	}

	private struct function getConstants() {
		var config = getFactoryConfig();

		var constants = {
			dsn = config.dsn,
			dataFactoryConfig = {
				serverType = config.serverType
			}
		};

		if ( config.keyExists("constants") ) {
			constants.append(config.constants);
		}

		return constants;
	}

	private struct function getFrameworkConfig() {
		return {
			applicationKey = 'framework.one',
			usingSubsystems = true,
			diConfig = {
				constants = getConstants()
			},
			diLocations = getLocations(),
			reloadApplicationOnEveryRequest = getFactoryConfig().reloadApplicationOnEveryRequest
		};
	}

	private string function getLocations() {
		var locations = "/cfmlDataMapper/model";
		locations = listAppend(locations, getFactoryConfig().locations);
		return locations;
	}

	private void function validateConfig() {
		var config = getFactoryConfig();

		if ( !structKeyExists(config, "dsn") || !len(config.dsn) ) {
			throw("The cfmlDataMapper Factory requires the dsn config variable.");
		}
		if ( !structKeyExists(config, "locations") || !len(config.locations) ) {
			throw("The cfmlDataMapper Factory requires the locations config variable.");
		}

		param name="config.reloadApplicationOnEveryRequest" default="false";
		param name="config.serverType" default="";

		setFactoryConfig(config);
	}

	// data mapper function passthroughs

	public component function get() {
		return getFactory().get( argumentCollection=arguments );
	}

	public struct function getBeanMap() {
		return getFactory().getBeanMap( argumentCollection=arguments );
	}

	public array function getBeansFromQuery() {
		return getFactory().getBeansFromQuery( argumentCollection=arguments );
	}

	public struct function getBeansFromQueryAsStruct() {
		return getFactory().getBeansFromQueryAsStruct( argumentCollection=arguments );
	}

	public array function getBeansFromArray() {
		return getFactory().getBeansFromArray( argumentCollection=arguments );
	}

	public array function getBeanListProperties() {
		return getFactory().getBeanListProperties( argumentCollection=arguments );
	}

	public struct function getResultStruct() {
		return getBeanFactory().getUtilityService().getResultStruct( argumentCollection=arguments );
	}

	public boolean function hasBean() {
		return getFactory().hasBean( argumentCollection=arguments );
	}

	public array function list() {
		return getFactory().list( argumentCollection=arguments );
	}

	public array function listWithProperties() {
		return getFactory().listWithProperties( argumentCollection=arguments );
	}

	public void function setFactoryConfig(factoryConfig){
		variables.factoryConfig = arguments.factoryConfig;
	}

	// fw1 functionality to use with beans

	public void function populate() {
		_get_framework_one().onRequestStart("");
		return _get_framework_one().populate( argumentCollection=arguments );
	}

}

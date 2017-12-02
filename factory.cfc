component accessors="true" output="false" {

  property struct factoryConfig;

  public component function init(struct config={}) {
    setFactoryConfig(arguments.config);
    validateConfig();
    return this;
  }

  private component function _get_framework_one() {
		if ( !structKeyExists( request, '_framework_one' ) ) {
			request._framework_one = new framework.one(getFrameworkConfig());
		}
		return request._framework_one;
	}

  private struct function getConstants() {
    var config = getFactoryConfig();

    var contants = {
      dsn = config.dsn
    };

    return contants;
  }

  public cfmlDataMapper.model.factory.data function getFactory() {
    _get_framework_one().onRequestStart("");
    return _get_framework_one().getDefaultBeanFactory().getBean("dataFactory");
  }

  private struct function getFrameworkConfig() {
    return {
      diConfig = {
        constants = getConstants()
      },
      diLocations = getLocations(),
      reloadApplicationOnEveryRequest = true
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
  }

  // data factory function passthroughs

  public function get() {
		return getFactory().get( argumentCollection=arguments );
	}

	public function getBeanMap() {
    return getFactory().getBeanMap( argumentCollection=arguments );
	}

	public function getBeans() {
    return getFactory().getBeanMap( argumentCollection=arguments );
	}

	public function getBeansFromArray() {
    return getFactory().getBeansFromArray( argumentCollection=arguments );
	}

	public function getBeanStruct() {
    return getFactory().getBeanStruct( argumentCollection=arguments );
	}

	public function hasBean() {
    return getFactory().hasBean( argumentCollection=arguments );
	}

	public function list() {
    return getFactory().list( argumentCollection=arguments );
	}

}

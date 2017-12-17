# cfmlDataMapper [![Build Status](https://travis-ci.org/cfGothChic/cfmlDataMapper.png)](https://travis-ci.org/cfGothChic/cfmlDataMapper)

CFML Data Mapper is a flexible transient bean factory that manages the relationship between an application's beans and the data layer, providing basic database functionality reducing the need for boilerplate code. It can also handle lazy loading specific relationship data for a request through the use of stored procedures. A standalone implementation is available, but it can also be integrated into a FW/1 application.

It can be used as an ORM alternative and the bean structure will be familiar if you have used it. The benefit of the Data Mapper is that it removes the overhead and performance hit of using the built in ORM functions available in CFML.

* Tested on CF 10, 11 & 2016 and Lucee 4.5 & 5
* Works with FW/1 3.1+ (Standalone version requires 3.5+)
* Works with SQL Server and MySQL

# Installation

Create a /cfmlDataMapper folder in your application using a server mapping or application specific mapping.

Example Application Specific Mapping:

```coldfusion
this.mappings[ "/cfmlDataMapper" ] = expandPath("../cfmlDataMapper/");
```

Add Framework One to the /cfmlDataMapper folder, or create a server mapping or application specific mapping to /framework.

# SQL Server and MySQL

By default the Data Mapper is setup to use SQL Server, but you can add a config variable to the bean factory constants to indicate to use MySQL.

```coldfusion
variables.framework = {
  diConfig = {
    constants = {
      dsn = "usermanager",
      dataFactoryConfig = {
        serverType = "mysql"
      }
    }
  }
};
```

# Standalone Factory

The Data Mapper can be setup as a standalone factory object and saved to the application scope.

```coldfusion
application.DataFactory = new cfmlDataMapper.factory({
  dsn = "usermanager",
  serverType = "mysql", // optional, defaults to mysql
  locations = "/model", // comma separated list of your application's model locations that contain a bean folder
  reloadApplicationOnEveryRequest = false // optional, defaults to framework default
});
```

While it is not necessary to use the factory in a FW/1 application, it does use the framework to create and manage the beans. You can use your own version or specify a location for the framework with a server mapping or application specific mapping. If you don't specify a location, the factory will use the framework included in this project's samples folder.

```coldfusion
this.mappings[ "/framework" ] = expandPath("../libs/framework/");
```

# FW/1 Integration

The Data Mapper can be seamlessly integrated into a FW/1 applicaion by updating the DI/1 locations to add the factory's model folder in the Application.cfc.

Add the factory's model folder to the list of DI/1 locations:

```coldfusion
diLocations = "model,/cfmlDataMapper/model"
```

# Model setup

For a guide to seting up your beans to use the Data Factory in your model, refer to the [Wiki](https://github.com/cfGothChic/cfmlDataMapper/wiki).

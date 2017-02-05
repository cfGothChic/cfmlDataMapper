# cfmlDataMapper

CFML Data Mapper is a flexible custom ORM implementation used in conjunction with FW/1 and DI/1. It manages the relationship between an application's beans and the data layer without the overhead and performance hit of using the built in ORM functions available in CFML.

Tested on CF9 and Lucee 4.5
Tested with FW/1 2.5, 3.0, 3.5
Works with SQL Server

Create a /cfmlDataMapper folder in your application and add the model folder to it. Use a server mapping or application specific mapping to simplify the path to the mapper.

Example Application Specific Mapping:
this.mappings[ "/cfmlDataMapper" ] = expandPath("../cfmlDataMapper/");

Add the model folder to the list of DI/1 locations

Example fw1 config variable:
diLocations = "/model,/cfmlDataMapper/model"

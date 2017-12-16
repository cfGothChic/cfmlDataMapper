component extends="framework.one" output="false" {

	this.name = "fw1-usermanager-mysql";
	this.applicationTimeout = createTimeSpan(3, 0, 0, 0);
	this.sessionManagement = true;
	this.sessionTimeout = CreateTimeSpan(0, 0, 30, 0);

	this.datasources["usermanager"] = {
		class: "org.gjt.mm.mysql.Driver",
		connectionString: "jdbc:mysql://localhost:3306/usermanager?useUnicode=true&characterEncoding=UTF-8&useLegacyDatetimeCode=true",
		username: "usermanager",
		password: "usermanager"
	};

	this.mappings[ "/cfmlDataMapper" ] = expandPath("../../");
	this.mappings[ "/model" ] = expandPath("../model");

	// use mssql fw1 sample files
	this.mappings[ "/samples/fw1-mysql/assets" ] = expandPath("../fw1/assets");
	this.mappings[ "/samples/fw1-mysql/controllers" ] = expandPath("../fw1/controllers");
	this.mappings[ "/samples/fw1-mysql/layouts" ] = expandPath("../fw1/layouts");
	this.mappings[ "/samples/fw1-mysql/views" ] = expandPath("../fw1/views");

	variables.framework = {
		diConfig = {
			constants = {
				dsn = "usermanager",
				dataFactoryConfig = {
					serverType = "mysql"
				}
			}
		},
		diLocations = "/model, /cfmlDataMapper/model",
		reloadApplicationOnEveryRequest = false
	};

	function before( struct rc ) {
		rc.jsScripts = [];
	}

}

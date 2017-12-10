component extends="framework.one" output="false" {

	this.name = "fw1-usermanager";
	this.applicationTimeout = createTimeSpan(3, 0, 0, 0);
	this.sessionManagement = true;
	this.sessionTimeout = CreateTimeSpan(0, 0, 30, 0);

	this.datasources["usermanager"] = {
		class: "net.sourceforge.jtds.jdbc.Driver",
		connectionString: "jdbc:jtds:sqlserver://localhost:1433/usermanager",
		username: "usermanager",
		password: "usermanager"
	};

	this.mappings[ "/cfmlDataMapper" ] = expandPath("../../");
	this.mappings[ "/model" ] = expandPath("../model");

	variables.framework = {
		diConfig = {
			constants = { dsn = "usermanager" }
		},
		diLocations = "/model, /cfmlDataMapper/model",
		reloadApplicationOnEveryRequest = false
	};

	function before( struct rc ) {
		rc.jsScripts = [];
	}

}

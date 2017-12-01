component extends="framework.one" output="false" {

	this.name = "fw1-usermanagersql";
	this.applicationTimeout = createTimeSpan(3, 0, 0, 0);

	this.datasources["usermanager"] = {
		class: "net.sourceforge.jtds.jdbc.Driver",
		connectionString: "jdbc:jtds:sqlserver://localhost:1433/usermanager",
		username: "usermanager",
		password: "usermanager"
	};

	this.mappings[ "/cfmlDataMapper" ] = expandPath("../");

	variables.framework = {
		diConfig = {
			constants = { dsn = "usermanager" },
			singulars = { factories = "factory" }
		},
		diLocations = "model, /cfmlDataMapper/model",
		environments = {
			local = { reloadApplicationOnEveryRequest = true },
			dev = { reloadApplicationOnEveryRequest = true },
			prod = { password = "supersecret" }
		}
	};

	public void function setupSession() {  }

	public void function setupRequest() {  }

	public void function setupView() {  }

	public void function setupResponse() {  }

	public string function onMissingView(struct rc = {}) {
		return "Error 404 - Page not found.";
	}

	public string function getEnvironment() {
		if ( findNoCase( "www", CGI.SERVER_NAME ) ) return "prod";
		if ( findNoCase( "dev", CGI.SERVER_NAME ) ) return "dev";
		else return "local";
	}

}

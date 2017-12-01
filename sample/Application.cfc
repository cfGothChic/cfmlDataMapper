component extends="framework.one" output="false" {

	this.name = "fw1-usermanagersql";
	this.applicationTimeout = createTimeSpan(3, 0, 0, 0);

	this.mappings[ "/cfmlDataMapper" ] = expandPath("../");

	variables.framework = {
		diConfig = { constants = { dsn = "usermanager" } },
		diLocations = "model, controllers, /cfmlDataMapper/model",
		environments = {
			local = { reloadApplicationOnEveryRequest = true, trace = true },
			dev = { reloadApplicationOnEveryRequest = true, trace = true },
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

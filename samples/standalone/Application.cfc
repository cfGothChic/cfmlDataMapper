component {

	this.name = "standalone-usermanager";
	this.applicationTimeout = createTimeSpan(3, 0, 0, 0);

	this.datasources["usermanager"] = {
		class: "net.sourceforge.jtds.jdbc.Driver",
		connectionString: "jdbc:jtds:sqlserver://localhost:1433/usermanager",
		username: "usermanager",
		password: "usermanager"
	};

	this.mappings[ "/cfmlDataMapper" ] = expandPath("../../");
	this.mappings[ "/model" ] = expandPath("../model");

	boolean function onApplicationStart() {
		application.dataFactory = new cfmlDataMapper.factory({
			dsn = "usermanager",
			locations = "/model",
			reloadApplicationOnEveryRequest = true
		});

		return true;
	}

	boolean function onRequestStart(string targetPage) {
		if ( structKeyExists(url, "reload") && isBoolean(url.reload) && url.reload ) {
			onApplicationStart();
		}

		request.jsScripts = [];

		return true;
	}

}

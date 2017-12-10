<cfscript>
	param name="url.id" type="integer" default=0;

	variables.user = application.DataFactory.get(bean="user", id=url.id);

	variables.result = {
		success = variables.user.exists()
	};

	if ( variables.result.success ) {
		variables.result = variables.user.delete();
	}

	if ( arrayLen(variables.result.message) ) {
		session.redirect.messages = variables.result.message;
	}

	location(url="userlist.cfm",addtoken=false);
</cfscript>

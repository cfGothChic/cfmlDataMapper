<cfscript>
	param name="url.id" type="integer" default=0;

	variables.user = application.DataFactory.get(bean="user", id=url.id);

	variables.result = {
		success = variables.user.exists(),
		messages = []
	};

	if ( variables.result.success ) {
		variables.result = variables.user.delete();
	}

	if ( arrayLen(variables.result.messages) ) {
		session.redirect.messages = variables.result.messages;
	}

	location(url="userlist.cfm",addtoken=false);
</cfscript>

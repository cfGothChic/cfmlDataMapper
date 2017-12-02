<cfscript>
	param name="url.id" type="integer" default=0;

	variables.user = application.dataFactory.get(bean="user", id=url.id);

	variables.success = ( variables.user.exists() ? true : false );

	if ( variables.success ) {
		variables.success = variables.user.delete();
	}

	location(url="userlist.cfm",addtoken=false);
</cfscript>

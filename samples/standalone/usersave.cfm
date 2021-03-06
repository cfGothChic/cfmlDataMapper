<cfscript>
	param name="form.id" type="integer" default=0;
	param name="form.firstName" default="";
	param name="form.lastName" default="";
	param name="form.email" default="";
	param name="form.departmentId" default="0";
	param name="form.userTypeId" default="0";

	variables.user = application.DataFactory.get(bean="user", id=form.id);
	application.DataFactory.populate( cfc = variables.user, trim = true );

	variables.result = variables.user.save();
	variables.id = variables.user.getId();

	if ( arrayLen(variables.result.messages) ) {
		session.redirect = duplicate(form);
		session.redirect.messages = variables.result.messages;
		location(url="useredit.cfm?id=#variables.id#",addtoken=false);

	} else {
		location(url="userdetail.cfm?id=#variables.id#",addtoken=false);
	}
</cfscript>

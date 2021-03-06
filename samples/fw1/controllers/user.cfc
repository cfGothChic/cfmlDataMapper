component accessors="true" {

	property DataFactory;

	function init(fw) {
		variables.framework = fw;
	}

 	function before(rc) {
		// url variable
		param name="rc.id" type="integer" default=0;
	}

	function delete(rc) {
		rc.user = variables.DataFactory.get(bean="user", id=rc.id);

		var result = {
			success = rc.user.exists(),
			messages = []
		};

		if ( result.success ) {
			result = rc.user.delete();
		}

		rc.messages = result.messages;
		variables.framework.redirect( action="user.list", preserve="messages" );
	}

	function detail(rc) {
		rc.user = variables.DataFactory.get(bean="user", id=rc.id);
		rc.pageTitle = "User Detail";
	}

	function edit(rc) {
		rc.user = variables.DataFactory.get(bean="user", id=rc.id);
		rc.departments = variables.DataFactory.list(bean="department");
		rc.types = variables.DataFactory.list(bean="usertype");

		// form variables from validation errors
		param name="rc.firstName" default=rc.user.getFirstName();
		param name="rc.lastName" default=rc.user.getLastName();
		param name="rc.email" default=rc.user.getEmail();
		param name="rc.departmentId" default=rc.user.getDepartmentId();
		param name="rc.userTypeId" default=rc.user.getUserTypeId();

		rc.pageTitle = ( rc.id ? "Edit" : "Add" ) & " User";
		variables.framework.setView("user.form");
    }

	function list(rc) {
		rc.users = variables.DataFactory.list( bean="user" );
		rc.admins = variables.DataFactory.list( bean="adminuser", params={ userTypeId=1 } );

		rc.pageTitle = "User List";
	}

	function save(rc) {
		// form variables
		param name="rc.firstName" default="";
		param name="rc.lastName" default="";
		param name="rc.email" default="";
		param name="rc.departmentId" default="0";
		param name="rc.userTypeId" default="0";

		var user = variables.DataFactory.get(bean="user", id=rc.id);
		variables.framework.populate( cfc = user, trim = true );

		var result = user.save();
		rc.messages = result.messages;

		if ( arrayLen(rc.messages) ) {
			variables.framework.redirect(action="user.edit",preserve="firstName,lastName,email,departmentId,userTypeId,messages",append="id");

		} else {
			rc.id = user.getId();
			variables.framework.redirect(action="user.detail",append="id");
		}
	}

}

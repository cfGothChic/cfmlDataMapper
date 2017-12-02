component accessors="true" {

	property dataFactory;

	function init(fw) {
		variables.framework = fw;
	}

 	function before(rc) {
		// url variable
		param name="rc.id" type="integer" default=0;
	}

	function delete(rc) {
		rc.user = variables.dataFactory.get(bean="user", id=rc.id);

		var success = ( rc.user.exists() ? true : false );

		if ( success ) {
			success = rc.user.delete();
		}

		variables.framework.redirect( "user.list" );
	}

	function detail(rc) {
		rc.user = variables.dataFactory.get(bean="user", id=rc.id);
		rc.pageTitle = "User Detail";
	}

	function edit(rc) {
		rc.user = variables.dataFactory.get(bean="user", id=rc.id);
		rc.departments = variables.dataFactory.list(bean="department");
		rc.types = variables.dataFactory.list(bean="usertype");

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
		rc.users = variables.dataFactory.list(bean="user");

		rc.pageTitle = "User List";
	}

	function save(rc) {
		// form variables
		param name="rc.firstName" default="";
		param name="rc.lastName" default="";
		param name="rc.email" default="";
		param name="rc.departmentId" default="0";
		param name="rc.userTypeId" default="0";

		var user = variables.dataFactory.get(bean="user", id=rc.id);
		variables.framework.populate( cfc = user, trim = true );

		var result = rc.user.save();
		rc.messages = result.message;

		if ( arrayLen(rc.messages) ) {
			variables.framework.redirect(action="user.edit",preserve="firstName,lastName,email,departmentId,userTypeId,messages",append="id");

		} else {
			rc.id = user.getId();
			variables.framework.redirect(action="user.detail",append="id");
		}
	}

}

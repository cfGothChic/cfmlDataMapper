component accessors=true {

	property departmentService;
	property userService;

	function init(fw) {
		variables.framework = fw;
	}

 	function before(rc) {
		// url variable
		param name="rc.id" type="integer" default=0; 
	}

	function delete(rc) {
		variables.userService.delete( rc.id );
		variables.framework.frameworkTrace( "deleted user", rc.id );
		variables.framework.redirect( "user.list" );
	}
	
	function detail(rc) {
		rc.user = variables.userService.get( rc.id );
		rc.pageTitle = "User Detail";
	}

	function edit(rc) {
		rc.user = variables.userService.get( rc.id );
		rc.departments = variables.departmentService.list();
		rc.types = variables.userService.listTypes();

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
		rc.users = variables.userService.list();

		rc.pageTitle = "User List";
	}

	function save(rc) {
		// form variables
		param name="rc.firstName" type="string" default="";
		param name="rc.lastName" type="string" default="";
		param name="rc.email" type="string" default="";
		param name="rc.departmentId" type="integer" default=0;
		param name="rc.userTypeId" type="integer" default=0;

		var user = variables.userService.get( rc.id );
		variables.framework.populate( cfc = user, trim = true );

		if ( rc.departmentId ) {
			user.setDepartmentId( rc.departmentId );
			user.setDepartment( variables.departmentService.get( rc.departmentId ) );
		}

		if ( rc.userTypeId ) {
			user.setUserTypeId( rc.userTypeId );
			user.setUserType( variables.userService.getType( rc.userTypeId ) );
		}

		rc.messages = user.validate();

		if ( arrayLen(rc.messages) ) {
			variables.framework.redirect(action="user.edit",preserve="firstName,lastName,email,departmentId,userTypeId,messages",append="id");

		} else {
			variables.userService.save( user );
			rc.id = user.getId();
			variables.framework.frameworkTrace( "added user", user );
			variables.framework.redirect(action="user.detail",append="id");
		}
	}

}

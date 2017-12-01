component accessors=true {

	property id;
	property firstName;
	property lastName;
	property email;
	property departmentId;
	property department;
	property userTypeId;
	property userType;
	property createdate;
	property updatedate;

	function init() {
		variables.id = 0;
		variables.firstName = "";
		variables.lastName = "";
		variables.email = "";
		variables.departmentId = 0;
		variables.userTypeId = 0;
		variables.createdate = now();
		variables.updatedate = "";
		return this;
	}

	function getSortName() {
		return getLastName() & ", " & getFirstName();
	}

	function validate() {
		var messages = [];

		if ( !len( getFirstName() ) ) {
			arrayAppend(messages, "First name is required");
		} else if ( len( getFirstName() ) > 50 ) {
			arrayAppend(messages, "First name can not be longer than 50 characters");
		}

		if ( !len( getLastName() ) ) {
			arrayAppend(messages, "Last name is required");
		} else if ( len( getLastName() ) > 50 ) {
			arrayAppend(messages, "Last name can not be longer than 50 characters");
		}

		if ( len( getEmail() ) > 50 ) {
			arrayAppend(messages, "Email can not be longer than 50 characters");
		} else if ( !isValid("email", getEmail() ) ) {
			arrayAppend(messages, "Email must be a valid email address");
		}

		if ( !getDepartmentId() ) {
			arrayAppend(messages, "Department is required");
		}

		if ( !getUserTypeId() ) {
			arrayAppend(messages, "Type is required");
		}

		return messages;
	}

}

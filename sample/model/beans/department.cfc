component accessors=true {

    property id;
    property name;
	property createdate;
	property updatedate;

	function init() {
		variables.id = 0;
		variables.name = "";
		variables.createdate = now();
		variables.updatedate = "";
		return this;
	}

	function validate() {
		var messages = [];

		if ( !len( getName() ) ) {
			arrayAppend(messages, "Name is required");
		} else if ( len( getName() ) > 50 ) {
			arrayAppend(messages, "Name can not be longer than 50 characters");
		}

		return messages;
	}

}

component accessors="true" {

	function init() {
		return this;
	}

	/**
	* @bean Required to access the calling beans data
	*/
	public array function validateBean( required struct beanmap, required component bean ){
		var errors = [];

		for(var name in arguments.beanMap.properties ){
			var beanProperty = arguments.beanMap.properties[name];

			if( !beanProperty.insert || beanProperty.isidentity ){
				continue;
			}

			var value = arguments.bean.getPropertyValue(propertyname=name);

			errors = validateBeanProperty( value=value, beanProperty=beanProperty );
		}

		return errors;
	}

	private array function validateBeanProperty( required string value, required struct beanProperty ) {
		var errors = [];
		var validationMessage = "";

		var displayname = arguments.beanProperty.displayname;
		var isRequired = !(arguments.beanProperty.null);

		if( isRequired ){
			validationMessage = validateRequired( value=arguments.value, displayname=displayname );
			if( len(trim(validationMessage)) ){
				arrayAppend(errors, validationMessage);
			}
		}

		if( len(trim(arguments.value)) && !arrayLen(errors) ) {

			// Handle datatype rules
			validationMessage = validateByDataType(
				datatype=arguments.beanproperty.datatype,
				value=arguments.value,
				displayname=displayname
			);
			if( len(trim(validationMessage)) ){
				arrayAppend(errors, validationMessage);
			}

			// Handle regex rules
			if ( len(arguments.beanProperty.regex) || len(arguments.beanProperty.regexlabel) ) {
				validationMessage = validateRegex(
					regex=arguments.beanProperty.regex,
					regexlabel=arguments.beanProperty.regexlabel,
					value=arguments.value,
					displayname=displayname
				);
				if( len(trim(validationMessage)) ){
					arrayAppend(errors, validationMessage);
				}
			}

			// Handle range rules
			if ( len(arguments.beanProperty.minvalue) || len(arguments.beanProperty.maxvalue) ) {
				validationMessage = validateRange(
					minvalue=arguments.beanProperty.minvalue,
					maxvalue=arguments.beanProperty.maxvalue,
					value=arguments.value,
					displayname=displayname
				);
				if( len(trim(validationMessage)) ){
					arrayAppend(errors, validationMessage);
				}
			}

			// Handle length rules
			if ( len(arguments.beanProperty.minlength) || len(arguments.beanProperty.maxlength) ) {
				validationMessage = validateLength(
					minlength=arguments.beanProperty.minlength,
					maxlength=arguments.beanProperty.maxlength,
					value=arguments.value,
					displayname=displayname
				);
				if( len(trim(validationMessage)) ){
					arrayAppend(errors, validationMessage);
				}
			}
		}

		return errors;
	}

	private string function validateByDataType( required string datatype, required string value, required string displayname ){
		var returnString = "";

		switch(arguments.datatype){
			case "boolean":
				if( !isBoolean(arguments.value) ){
					returnString = arguments.displayname & " must be a numeric value.";
				}
			break;

			case "date":
			case "timestamp":
				if( !isDate(arguments.value) ){
					returnString = arguments.displayname & " must be a date/time value.";
				}
			break;

			case "email":
				if( !isValid("email",arguments.value) ){
					returnString = arguments.displayname & " must be a valid email address.";
				}
			break;

			case "numeric":
				if( !isNumeric(arguments.value) ){
					returnString = arguments.displayname & " must be a numeric value.";
				}
			break;

			case "telephone":
				if ( !isValid("telephone",arguments.value) ) {
					returnString = arguments.displayname & " must be a valid telephone number.";
				}
			break;

			case "zip":
			case "zipcode":
				if( !validateZipCode(arguments.value) ){
					returnString = arguments.displayname & " must be a valid zipcode or postal code.";
				}
			break;
		}

		return returnString;
	}

	private string function validateLength( required string minlength, required string maxlength, required string value, required string displayname ){
		var returnString = "";

		if(
			len(arguments.minlength)
			&& len(arguments.maxlength)
			&& (
				arguments.minlength > len(arguments.value)
				|| arguments.maxlength < len(arguments.value)
			)
		){
			returnString = arguments.displayname & " must be between " & arguments.minlength & " and " & arguments.maxlength & " characters long.";
		} else if( len(arguments.minlength) && arguments.minlength > len(arguments.value)){
			returnString = arguments.displayname & " must be longer than " & arguments.minlength & " characters.";
		} else if( len(arguments.maxlength) && arguments.maxlength < len(arguments.value)){
			returnString = arguments.displayname & " must be less than " & arguments.maxlength & " characters.";
		}

		return returnString;
	}

	private string function validateRange( required string minvalue, required string maxvalue, required string value, required string displayname ){
		var returnString = "";

		returnString = validateByDataType( datatype="numeric", value=arguments.value, displayname=arguments.displayname );

		if ( !len(returnString) ) {
			if(
				len(arguments.minvalue)
				&& len(arguments.maxvalue)
				&& (
					arguments.minvalue > arguments.value
					|| arguments.maxvalue < arguments.value
				)
			){
				returnString = arguments.displayname & " must be a value between " & arguments.minvalue & " and " & arguments.maxvalue & ".";
			} else if( len(arguments.minvalue) && arguments.minvalue > arguments.value){
				returnString = arguments.displayname & " must be a value greater than " & arguments.minvalue & ".";
			} else if( len(arguments.maxvalue) && arguments.maxvalue < arguments.value){
				returnString = arguments.displayname & " must be a value less than " & arguments.maxvalue & ".";
			}
		}

		return returnString;
	}

	private string function validateRegex( required string regex, required string regexlabel, required string value, required string displayname ){
		var returnString = "";

		if( len(trim(arguments.regex)) && !arrayLen(REMatch( arguments.regex, arguments.value)) ){
			returnString = arguments.displayname & " must be a valid " & arguments.regexlabel & ".";
		}

		return returnString;
	}

	private string function validateRequired( required string value, required string displayname ){
		var returnString = "";

		// todo: add validation for a fkColumn related to a relationship join
		/*if( arguments.datatype == 'numeric' && arguments.value <= 0){
			returnString = arguments.displayname & " is required.";
		} else*/

		if( !len(trim(arguments.value)) ){
			returnString = arguments.displayname & " is required.";
		}

		return returnString;
	}

	private boolean function validateZipCode( required string value ){
		var valid = true;

		if ( !isValid("zipcode",arguments.value)
			&& !REFind("[a-zA-Z]\d[a-zA-Z]\s\d[a-zA-Z]\d|(^\d{4}$)", arguments.value)
		){
			valid = false;
		}
		return valid;
	}

}

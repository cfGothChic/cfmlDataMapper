component accessors="true" {

	function init() {
		return this;
	}

	/**
	* @bean Required to access the calling beans data
	*/
	public array function validateBean(beanmap,bean){
		var errors = [];

		for(var name in beanMap.properties ){
			var beanProperty = beanMap.properties[name];

			if( !beanProperty.insert || beanProperty.isidentity){
				continue;
			}

			var value = arguments.bean.getPropertyValue(propertyname=name);
			var displayname = beanProperty.displayname;
			var isRequired = !beanProperty.null;

			/*if( isRequired && beanproperty.datatype == 'numeric' && value <= 0){
				arrayAppend(errors, displayname & " must be greater than zero.");
			} else*/
			if( isRequired && !len(trim(value)) ){
				arrayAppend(errors, displayname & " is required.");
			} else if( !len(trim(value)) ){
				continue;
			} else {

				// Handle datatype rules
				var validationMessage = validateByDataType( datatype=beanproperty.datatype, value=value, displayname=displayname );
				if( len(trim(validationMessage)) ){
					arrayAppend(errors, validationMessage);
				}

				// Handle regex rules
				validationMessage = validateRegex(
					regex=beanProperty.regex,
					regexlabel=beanProperty.regexlabel,
					value=value,
					displayname=displayname
				);
				if( len(trim(validationMessage)) ){
					arrayAppend(errors, validationMessage);
				}

				// Handle range rules
				validationMessage = validateRange(
					minvalue=beanProperty.minvalue,
					maxvalue=beanProperty.maxvalue,
					value=value,
					displayname=displayname
				);
				if( len(trim(validationMessage)) ){
					arrayAppend(errors, validationMessage);
				}

				// Handle length rules
				validationMessage = validateLength(
					minvalue=beanProperty.minlength,
					maxvalue=beanProperty.maxlength,
					value=value,
					displayname=displayname
				);
				if( len(trim(validationMessage)) ){
					arrayAppend(errors, validationMessage);
				}
			}
		}

		return errors;
	}

	private string function validateByDataType( datatype, value, displayname ){
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

	private string function validateLength( minlength, maxlength, value, displayname ){
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

	private boolean function validateZipCode( string value ){
		var valid = true;

		if ( !isValid("zipcode",arguments.value)
			&& !REFind("[a-zA-Z]\d[a-zA-Z]\s\d[a-zA-Z]\d|(^\d{4}$)", arguments.value)
		){
			valid = false;
		}
		return valid;
	}

}

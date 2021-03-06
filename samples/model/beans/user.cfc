component accessors="true" extends="cfmlDataMapper.model.base.bean"
    table="users"
    primarykey="id"
    orderby="lastName, firstName"
{

	// columns
	property name="id" columnName="userId" cfsqltype="integer" isidentity="true" default="0";
	property name="firstName" cfsqltype="varchar" maxlength="50" isrequired="true" default="";
	property name="lastName" cfsqltype="varchar" maxlength="50" isrequired="true" default="";
	property name="email" cfsqltype="varchar" maxlength="50"default="";
	property name="createDate" cfsqltype="timestamp" insert="false" default="";
	property name="updateDate" cfsqltype="timestamp" isrequired="true" default="";

	// many-to-one relationships
	property name="departmentId" cfsqltype="integer" valtype="foreignkey" default="0";
	property name="department" bean="department" joinType="one" fkName="departmentId" default="";

	property name="userTypeId" cfsqltype="integer" isrequired="true" valtype="foreignkey" default="0";
	property name="userType" bean="userType" joinType="one" fkName="userTypeId" default="";

	// many-to-many relationships
	property name="roles"
		bean="role"
		joinType="many-to-many"
		joinTable="users_roles"
		joinColumn="roleId"
		fkColumn="userId"
		fksqltype="integer"
		default="";

	public string function getCreateDate() {
		return isDate(variables.createDate) ? variables.createDate : now();
	}

	public string function getCreateDateFormatted() {
		return dateformat(getCreateDate(), "m/d/yyyy");
	}

	public component function getDepartment() {
		return getRelationship( name="department" );
	}

	public string function getName() {
		return getFirstName() & " " & getLastName();
	}

	public array function getRoles(){
		return getRelationship( name="roles" );
	}

	public string function getSortName() {
		return getLastName() & ", " & getFirstName();
	}

	public string function getUpdateDate() {
		return isDate(variables.updateDate) ? variables.updateDate : now();
	}

	public string function getUpdateDateFormatted() {
		return dateformat(getUpdateDate(), "m/d/yyyy");
	}

	public component function getUserType() {
		return getRelationship( name="userType" );
	}

	public boolean function hasRoles() {
		return hasRelationship( name="roles" );
	}

	public struct function save() {
		var result = {"code" = 001};

		if ( !getId() ) {
			setCreateDate( now() );
		}
		setUpdateDate( now() );

		var messages = this.validate();
		if ( arrayLen(messages) ) {
			result = { "code"=900, "message"=messages };
		}

		if ( result.code == 001 ) {
			result = super.save();
		}

		return result;
	}

	public array function validate() {
		var errors = super.validate();

		if ( !getDepartmentId() ) {
			arrayAppend(errors, "Department is required");
		}

		if ( !getUserTypeId() ) {
			arrayAppend(errors, "Type is required");
		}

		return errors;
	}

}

component accessors="true" extends="cfmlDataMapper.model.base.bean"
    table="users"
    primarykey="id"
    orderby="lastName, firstName"
{

  // columns
	property name="id" columnName="userId" cfsqltype="integer" isidentity="true" default="0";
	property name="firstName" cfsqltype="varchar" maxlength="50" default="";
	property name="lastName" cfsqltype="varchar" maxlength="50" default="";
	property name="email" cfsqltype="varchar" maxlength="50" null="true" default="";
	property name="createDate" cfsqltype="timestamp" insert="false" default="";
	property name="updateDate" cfsqltype="timestamp" default="";

  // many-to-one relationships
	property name="departmentId" cfsqltype="integer" null="true" default="0";
	property name="departmentBean" bean="department" joinType="one" fkName="departmentId";

	property name="userTypeId" cfsqltype="integer" null="true" default="0";
	property name="userTypeBean" bean="userType" joinType="one" fkName="userTypeId";

  // many-to-many relationships
  property name="roleBeans"
    bean="role"
    joinType="many-to-many"
    joinTable="users_roles"
    joinColumn="roleId"
    fkColumn="userId"
    fksqltype="integer";

	public string function getCreateDate() {
		return isDate(variables.createDate) ? variables.createDate : now();
	}

  public string function getCreateDateFormatted() {
		return dateformat(getCreateDate(), "m/d/yyyy");
	}

	public component function getDepartment() {
		super.populateRelationship("departmentBean");
		return variables.departmentBean;
	}

  public string function getName() {
		return getFirstName() & " " & getLastName();
	}

  public array function getRoles(){
      super.populateRelationship("roleBeans");
      return variables.roleBeans;
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
		super.populateRelationship("userTypeBean");
		return variables.userTypeBean;
	}

  public boolean function hasRoles() {
      return ( arrayLen( getRoles() ) ? true : false );
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

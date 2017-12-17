component accessors="true" extends="cfmlDataMapper.model.base.bean"
    table="departments"
    primarykey="id"
    orderby="name"
    cached="true"
{

	property name="id" columnName="departmentId" cfsqltype="integer" isidentity="true" default="0";
	property name="name" cfsqltype="varchar" maxlength="50" default="";
	property name="createDate" cfsqltype="timestamp" insert="false" default="";
	property name="updateDate" cfsqltype="timestamp" default="";

	public string function getCreateDate() {
		return isDate(variables.createDate) ? variables.createDate : now();
	}

	public string function getUpdateDate() {
		return isDate(variables.updateDate) ? variables.updateDate : now();
	}

}

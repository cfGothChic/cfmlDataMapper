<cfscript>
	param name="url.id" type="integer" default=0;

	variables.activeItem = "useredit";
	variables.pageTitle = ( url.id ? "Edit" : "Add" ) & " User";

	variables.user = application.dataFactory.get(bean="user", id=url.id);
	variables.departments = application.dataFactory.list(bean="department");
	variables.types = application.dataFactory.list(bean="usertype");

	if ( structKeyExists(session, "redirect") ) {
		structAppend(form, session.redirect);
		variables.messages = form.messages;
		structDelete(session, "redirect");
	}

	// form variables from validation errors
	param name="form.firstName" default=variables.user.getFirstName();
	param name="form.lastName" default=variables.user.getLastName();
	param name="form.email" default=variables.user.getEmail();
	param name="form.departmentId" default=variables.user.getDepartmentId();
	param name="form.userTypeId" default=variables.user.getUserTypeId();
</cfscript>

<cfinclude template="common/header.cfm">

<cfoutput>
	<h1>#variables.pageTitle#</h1>

	<form id="userForm" action="usersave.cfm" method="post" class="form-horizontal" role="form">

		<input name="id" type="hidden" value="#url.id#" />

		<div class="form-group">
			<label for="firstName" class="col-sm-3 control-label">First Name:</label>
			<div class="col-sm-9">
				<input id="firstName" name="firstName" type="text" class="form-control" value="#form.firstName#" />
			</div>
		</div>

		<div class="form-group">
			<label for="lastName" class="col-sm-3 control-label">Last Name:</label>
			<div class="col-sm-9">
				<input id="lastName" name="lastName" type="text" class="form-control" value="#form.lastName#" />
			</div>
		</div>

		<div class="form-group">
			<label for="email" class="col-sm-3 control-label">Email:</label>
			<div class="col-sm-9">
				<input id="email" name="email" type="text" class="form-control" value="#form.email#" />
			</div>
		</div>

		<div class="form-group">
			<label for="departmentId" class="col-sm-3 control-label">Department:</label>
			<div class="col-sm-9">
				<select name="departmentId" id="departmentId" class="form-control">
					<cfloop array="#variables.departments#" index="local.department">
						<!--- when editing a user we need to set the dept that user currently has --->
						<cfif local.department.getId() is form.departmentId>
							<option value="#local.department.getId()#" selected="selected">#local.department.getName()#</option>
						<cfelse>
							<option value="#local.department.getId()#">#local.department.getName()#</option>
						</cfif>
					</cfloop>
				</select>
			</div>
		</div>

		<div class="form-group">
			<label for="userTypeId" class="col-sm-3 control-label">Type:</label>
			<div class="col-sm-9">
				<select name="userTypeId" id="userTypeId" class="form-control">
					<cfloop array="#variables.types#" index="local.type">
						<cfif local.type.getId() is form.userTypeId>
							<option value="#local.type.getId()#" selected="selected">#local.type.getName()#</option>
						<cfelse>
							<option value="#local.type.getId()#">#local.type.getName()#</option>
						</cfif>
					</cfloop>
				</select>
			</div>
		</div>

		<div class="form-group">
			<div class="col-sm-offset-3 col-sm-9">
				<button id="submit" type="submit" class="btn btn-primary">Save User</button>
			</div>
		</div>

	</form>
</cfoutput>

<cfinclude template="common/footer.cfm">

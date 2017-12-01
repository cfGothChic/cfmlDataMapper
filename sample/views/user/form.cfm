<cfoutput>
	<h1>#rc.pageTitle#</h1>

	<form id="userForm" action="#buildUrl('user.save')#" method="post" class="form-horizontal" role="form">

		<input name="id" type="hidden" value="#rc.id#" />

		<div class="form-group">
			<label for="firstName" class="col-sm-3 control-label">First Name:</label>
			<div class="col-sm-9">
				<input id="firstName" name="firstName" type="text" class="form-control" value="#rc.firstName#" />
			</div>
		</div>

		<div class="form-group">
			<label for="lastName" class="col-sm-3 control-label">Last Name:</label>
			<div class="col-sm-9">
				<input id="lastName" name="lastName" type="text" class="form-control" value="#rc.lastName#" />
			</div>
		</div>

		<div class="form-group">
			<label for="email" class="col-sm-3 control-label">Email:</label>
			<div class="col-sm-9">
				<input id="email" name="email" type="text" class="form-control" value="#rc.email#" />
			</div>
		</div>

		<div class="form-group">
			<label for="departmentId" class="col-sm-3 control-label">Department:</label>
			<div class="col-sm-9">
				<select name="departmentId" id="departmentId" class="form-control">
					<cfloop array="#rc.departments#" index="local.department">
						<!--- when editing a user we need to set the dept that user currently has --->
						<cfif local.department.getId() is rc.departmentId>
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
					<cfloop array="#rc.types#" index="local.type">
						<cfif local.type.getId() is rc.userTypeId>
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
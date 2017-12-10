<cfscript>
	variables.activeItem = "userlist";
	variables.pageTitle = "User List";
	arrayAppend(request.jsScripts,"user/list.js");

	variables.users = application.dataFactory.list(bean="user");
	variables.admins = application.dataFactory.list( bean="adminuser", params={ userTypeId=1 } );
</cfscript>

<cfinclude template="common/header.cfm">

<cfoutput>
	<div class="row">
		<div class="col-md-12"><h1>Users</h1></div>
	</div>
	<div class="row">
		<div class="col-md-12 text-right"><a href="useredit.cfm"><i class="fa fa-plus"></i> Add</a></div>
	</div>

	<cfif arrayLen(variables.admins)>
		<div class="row">
			<div class="col-md-12">
				<p>Administrators:
					<cfloop array="#variables.admins#" index="local.adminuser">
						<cfif variables.admins[1].getId() is not local.adminuser.getId()>, </cfif>
						#local.adminuser.getName()#
					</cfloop>
				</p>
			</div>
		</div>
	</cfif>

	<cfif !arrayLen(variables.users)>
		<div class="row">
			<div class="col-md-12">No users exist but <a href="useredit.cfm">new ones can be added</a>.</div>
		</div>
	<cfelse>
		<table class="table table-bordered table-striped">
			<thead>
				<tr>
					<th></th>
					<th>Name</th>
					<th>Email</th>
					<th>Department</th>
					<th>Type</th>
				</tr>
			</thead>
			<tbody>
				<cfloop array="#variables.users#" index="local.user">
					<tr>
						<td>
							<a href="useredit.cfm?id=#local.user.getID()#" title="Edit">
								<i class="fa fa-edit"></i>
							</a>
							<a href="userdelete.cfm?id=#local.user.getID()#" class="delete" title="Delete">
								<i class="fa fa-times fa-lg"></i>
							</a>
						</td>
						<td><a href="userdetail.cfm?id=#local.user.getId()#">#local.user.getSortName()#</a></td>
						<td>#local.user.getEmail()#</td>
						<td>#local.user.getDepartment().getName()#</td>
						<td>#local.user.getUserType().getName()#</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
	</cfif>
</cfoutput>

<cfinclude template="common/footer.cfm">

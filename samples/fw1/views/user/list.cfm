<cfscript>
	arrayAppend(rc.jsScripts,"user/list.js");
</cfscript>

<cfoutput>
	<div class="row">
		<div class="col-md-12"><h1>Users</h1></div>
	</div>
	<div class="row">
		<div class="col-md-12 text-right"><a href="#buildUrl('user.edit')#"><i class="fa fa-plus"></i> Add</a></div>
	</div>

	<cfif !arrayLen(rc.users)>
		<div class="row">
			<div class="col-md-12">No users exist but <a href="#buildUrl('user.edit')#">new ones can be added</a>.</div>
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
				<cfloop array="#rc.users#" index="local.user">
					<tr>
						<td>
							<a href="#buildUrl('user.edit?id=' & local.user.getID())#" title="Edit">
								<i class="fa fa-edit"></i>
							</a>
							<a href="#buildUrl('user.delete?id=' & local.user.getID())#" class="delete" title="Delete">
								<i class="fa fa-times fa-lg"></i>
							</a>
						</td>
						<td><a href="#buildUrl('user.detail?id=' & local.user.getId() )#">#local.user.getSortName()#</a></td>
						<td>#local.user.getEmail()#</td>
						<td>#local.user.getDepartment().getName()#</td>
						<td>#local.user.getUserType().getName()#</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
	</cfif>
</cfoutput>

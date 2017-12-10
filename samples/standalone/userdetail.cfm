<cfscript>
	param name="url.id" type="integer" default=0;

	variables.pageTitle = "User Detail";
	arrayAppend(request.jsScripts,"user/detail.js");

	variables.user = application.dataFactory.get(bean="user", id=url.id);
</cfscript>

<cfinclude template="common/header.cfm">

<cfoutput>
	<h1>User Detail</h1>

	<p>
		<a href="useredit.cfm?id=#variables.user.getID()#" title="Edit">
			<i class="fa fa-edit"></i>
		</a>
		<a href="userdelete.cfm?id=#variables.user.getID()#" class="delete" title="Delete">
			<i class="fa fa-times fa-lg"></i>
		</a>
	</p>

	<div class="row">
		<div class="col-md-3"><strong>Name:</strong></div>
		<div class="col-md-9">#variables.user.getFirstName()# #variables.user.getLastName()#</div>
	</div>

	<div class="row">
		<div class="col-md-3"><strong>Email:</strong></div>
		<div class="col-md-9">#variables.user.getEmail()#</div>
	</div>

	<div class="row">
		<div class="col-md-3"><strong>Department:</strong></div>
		<div class="col-md-9">#variables.user.getDepartment().getName()#</div>
	</div>

	<div class="row">
		<div class="col-md-3"><strong>Type:</strong></div>
		<div class="col-md-9">#variables.user.getUserType().getName()#</div>
	</div>

	<div class="row">
		<div class="col-md-3"><strong>Created:</strong></div>
		<div class="col-md-9">#variables.user.getCreateDateFormatted()#</div>
	</div>

	<div class="row">
		<div class="col-md-3"><strong>Updated:</strong></div>
		<div class="col-md-9">#variables.user.getUpdateDateFormatted()#</div>
	</div>
</cfoutput>

<cfinclude template="common/footer.cfm">

<cfoutput>
	<h1>User Detail</h1>

	<div class="row">
		<div class="col-md-3"><strong>Name:</strong></div>
		<div class="col-md-9">#rc.user.getFirstName()# #rc.user.getLastName()#</div>
	</div>

	<div class="row">
		<div class="col-md-3"><strong>Email:</strong></div>
		<div class="col-md-9">#rc.user.getEmail()#</div>
	</div>

	<div class="row">
		<div class="col-md-3"><strong>Department:</strong></div>
		<div class="col-md-9">#rc.user.getDepartment().getName()#</div>
	</div>

	<div class="row">
		<div class="col-md-3"><strong>Type:</strong></div>
		<div class="col-md-9">#rc.user.getUserType().getName()#</div>
	</div>

	<div class="row">
		<div class="col-md-3"><strong>Created:</strong></div>
		<div class="col-md-9">#dateformat( rc.user.getCreateDate(), "m/d/yyyy")#</div>
	</div>

	<div class="row">
		<div class="col-md-3"><strong>Updated:</strong></div>
		<div class="col-md-9">#dateformat( rc.user.getUpdateDate(), "m/d/yyyy")#</div>
	</div>
</cfoutput>
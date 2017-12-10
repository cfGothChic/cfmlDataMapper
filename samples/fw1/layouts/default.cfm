<cfparam name="rc.pageTitle" default="" />
<cfparam name="rc.messages" default="#[]#" />

<cfoutput>
	<!DOCTYPE html>
	<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="description" content="">
		<meta name="author" content="">

		<title>FW/1 User Manager<cfif len(rc.pageTitle)> - #rc.pageTitle#</cfif></title>

		<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
		<link rel="stylesheet" href="//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css">
	</head>

	<body>

		<nav class="navbar navbar-default" role="navigation">
			<div class="container-fluid">
				<!-- Brand and toggle get grouped for better mobile display -->
				<div class="navbar-header">
					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="##bs-example-navbar-collapse-1">
						<span class="sr-only">Toggle navigation</span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
					</button>
					<a class="navbar-brand" href="/samples/fw1/">FW/1 User Manager</a>
				</div>

				<!-- Collect the nav links, forms, and other content for toggling -->
				<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
					<ul class="nav navbar-nav">
						<li><a href="/samples/index.cfm">Samples Home</a></li>
						<li<cfif getSectionAndItem() is "user.list"> class="active"</cfif>><a href="#buildUrl('user.list')#" title="View the list of users">Users</a></li>
						<li<cfif getSectionAndItem() is "user.edit"> class="active"</cfif>><a href="#buildUrl('user.edit')#" title="Fill out form to add new user">Add User</a></li>
					</ul>
				</div><!-- /.navbar-collapse -->
			</div><!-- /.container-fluid -->
		</nav>

		<cfif arrayLen(rc.messages)>
			<div id="frmMessages" class="alert alert-danger">
				<span class="fa fa-exclamation-triangle"></span> Please correct the following form errors:
				<ul>
					<cfloop array="#rc.messages#" index="local.message">
						<li>#local.message#</li>
					</cfloop>
				</ul>
			</div>
		</cfif>

		<div class="container-fluid">
			#body#
		</div>

		<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
		<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
		<script src="assets/libs/bootbox.min.js"></script>
		<cfif rc.jsScripts.len()>
			<cfloop array="#rc.jsScripts#" index="local.script">
				<script src="assets/js/#local.script#"></script>
			</cfloop>
		</cfif>

	</body>
	</html>
</cfoutput>

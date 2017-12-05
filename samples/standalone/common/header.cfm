<cfparam name="variables.pageTitle" default="cfmlDataMapper Standalone Sample">
<cfparam name="variables.activeItem" default="main">
<cfparam name="variables.messages" default="#[]#">

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="description" content="">
	<meta name="author" content="">

	<title>User Manager<cfoutput><cfif len(variables.pageTitle)> - #variables.pageTitle#</cfif></cfoutput></title>

	<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
	<link rel="stylesheet" href="//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css">
</head>

<body>

	<div class="container-fluid">

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
					<a class="navbar-brand" href="index.cfm">User Manager</a>
				</div>

				<!-- Collect the nav links, forms, and other content for toggling -->
				<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
					<ul class="nav navbar-nav">
						<li<cfif variables.activeItem is "index"> class="active"</cfif>><a href="index.cfm">Home</a></li>
						<li<cfif variables.activeItem is "userlist"> class="active"</cfif>><a href="userlist.cfm" title="View the list of users">Users</a></li>
						<li<cfif variables.activeItem is "useredit"> class="active"</cfif>><a href="useredit.cfm" title="Fill out form to add new user">Add User</a></li>
					</ul>
				</div><!-- /.navbar-collapse -->
			</div><!-- /.container-fluid -->
		</nav>

		<cfif arrayLen(variables.messages)>
			<div id="frmMessages" class="alert alert-danger">
				<span class="fa fa-exclamation-triangle"></span> Please correct the following form errors:
				<ul>
					<cfoutput>
						<cfloop array="#variables.messages#" index="local.message">
							<li>#local.message#</li>
						</cfloop>
					</cfoutput>
				</ul>
			</div>
		</cfif>

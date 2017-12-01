component accessors=true {

	property beanFactory;
	property departmentService;

	variables.users = {};
	variables.userSort = [];
	variables.types = {};
	variables.typeSort = [];

	function init( dsn ) {
		variables.dsn = dsn;
		return this;
	}

	function delete( id ) {
		queryExecute("DELETE FROM users WHERE userId = :id", { id = { value=id, cfsqltype="cf_sql_integer" } }, { datasource=variables.dsn });
		structDelete( variables.users, id );
	}

	function get( id = "" ) {
		load();
		if ( len( id ) && structKeyExists( variables.users, id ) ) {
			var result = variables.users[ id ];
		} else {
			var result = variables.beanFactory.getBean( "userBean" );
		}
		return result;
	}

	function getType( id = "" ) {
		loadTypes();
		if ( len( id ) && structKeyExists( variables.types, id ) ) {
			var result = variables.types[ id ];
		} else {
			var result = variables.beanFactory.getBean( "usertypeBean" );
		}
		return result;
	}
	
	function list() {
		load();
		var users = [];
		for ( var id in variables.userSort ) {
			if ( structKeyExists(variables.users,id) ) {
				arrayAppend(users, variables.users[ id ] );
			}
		}
		return users;
	}

	function listTypes() {
		load();
		var types = [];
		for ( var id in variables.typeSort ) {
			if ( structKeyExists(variables.types,id) ) {
				arrayAppend(types, variables.types[ id ] );
			}
		}
		return types;
	}

	function save( user ) {
		user.setUpdateDate( now() );

		if ( user.getId() ) {
			update( user );
		} else {
			var newid = create( user );
			user.setId( newid );
		}

		variables.users = {};
		variables.userSort = [];

		return user;
	}

	private function create( user ) {
		var qUser = queryExecute("
				INSERT INTO users (firstName, lastName, email, departmentId, userTypeId, updateDate)
					VALUES (:firstName, :lastName, :email, :departmentId, :userTypeId, :updatedate)
				SELECT SCOPE_IDENTITY() AS newid
			",{
				firstName = { value=user.getFirstName(), cfsqltype="cf_sql_varchar" },
				lastName = { value=user.getLastName(), cfsqltype="cf_sql_varchar" },
				email = { value=user.getEmail(), null=( !len( user.getEmail() ) ), cfsqltype="cf_sql_varchar" },
				departmentId = { value=user.getDepartmentId(), cfsqltype="cf_sql_integer" },
				userTypeId = { value=user.getUserTypeId(), cfsqltype="cf_sql_integer" },
				updatedate = { value=user.getUpdateDate(), cfsqltype="cf_sql_timestamp" }
			},
			{ datasource=variables.dsn }
		);
		return qUser.newid;
	}

	private function load() {
		if ( structIsEmpty(variables.users) ) {
			// get the data
			var qUsers = queryExecute("
					SELECT userId AS id, firstName, lastName, email, departmentId, userTypeId, createdate, updatedate 
					FROM users
					ORDER BY lastName, firstName
				", {}, { datasource=variables.dsn }
			);

			// create beans and populate them
			for ( var row IN qUsers ) {        
				var user = variables.beanFactory.getBean( "userBean" );
				variables.beanFactory.injectProperties(user, {
					id = row.id, 
					firstName = row.firstName, 
					lastName = row.lastName, 
					email = row.email, 
					departmentId = row.departmentId, 
					userTypeId = row.userTypeId,
					createdate = row.createdate, 
					updatedate = row.updatedate
				});
				user.setDepartment( variables.departmentService.get( user.getDepartmentId() ) );
				user.setUserType( getType( user.getUserTypeId() ) );
				variables.users[ user.getId() ] = user;
				arrayAppend(variables.userSort, user.getId() );
			}
		}
	}

	private function loadTypes() {
		if ( structIsEmpty(variables.types) ) {
			// get the data
			var qUserTypes = queryExecute("
					SELECT userTypeId AS id, name, createdate, updatedate 
					FROM usertypes
					ORDER BY name
				", {}, { datasource=variables.dsn }
			);

			// create beans and populate them
			for ( var row IN qUserTypes ) {        
				var type = variables.beanFactory.getBean( "usertypeBean" );
				variables.beanFactory.injectProperties(type, row);
				variables.types[ type.getId() ] = type;
				arrayAppend(variables.typeSort, type.getId() );
			}
		}
	}

	private function update( user ) {
		var qUser = queryExecute("
				UPDATE users
				SET
					firstName = :firstName,
					lastName = :lastName,
					email = :email,
					departmentId = :departmentId,
					userTypeId = :userTypeId,
					updateDate = :updatedate
				WHERE
					userId = :id
			",{
				firstName = { value=user.getFirstName(), cfsqltype="cf_sql_varchar" },
				lastName = { value=user.getLastName(), cfsqltype="cf_sql_varchar" },
				email = { value=user.getEmail(), null=( !len( user.getEmail() ) ), cfsqltype="cf_sql_varchar" },
				departmentId = { value=user.getDepartmentId(), cfsqltype="cf_sql_integer" },
				userTypeId = { value=user.getUserTypeId(), cfsqltype="cf_sql_integer" },
				updatedate = { value=user.getUpdateDate(), cfsqltype="cf_sql_timestamp" },
				id = { value=user.getId(), cfsqltype="cf_sql_integer" }
			},
			{ datasource=variables.dsn }
		);
	}

}

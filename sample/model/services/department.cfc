component accessors=true {

	property beanFactory;

	variables.departments = {};
	variables.departmentSort = [];

	function init( dsn ) {
		variables.dsn = dsn;
		return this;
	}

	function get( id = "" ) {
		load();
		var result = "";
		if ( len( id ) && structKeyExists( variables.departments, id ) ) {
			result = variables.departments[ id ];
		} else {
			result = variables.beanFactory.getBean( "departmentBean" );
		}
		return result;
	}

	function list() {
		load();
		var departments = [];
		for ( var id in variables.departmentSort ) {
			if ( structKeyExists(variables.departments,id) ) {
				arrayAppend(departments, variables.departments[ id ] );
			}
		}
		return departments;
	}

	private function load() {
		if ( structIsEmpty(variables.departments) ) {
	       	// get the data
			var qDepartments = queryExecute("
					SELECT departmentId AS id, name, createdate, updatedate 
					FROM departments
					ORDER BY name
				", {}, { datasource=variables.dsn }
			);

			// create beans and populate them
			for ( var row IN qDepartments ) {        
				var department = variables.beanFactory.getBean( "departmentBean" );
				variables.beanFactory.injectProperties(department, row);
				variables.departments[ department.getId() ] = department;
				arrayAppend(variables.departmentSort, department.getId() );
	        }
        }
	}

}

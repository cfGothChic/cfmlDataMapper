<cfscript>
// use this file to help write unit tests for beans to mock functions in the base bean

function mockSuperDelete( required component testClass ){
	var SQLService = createStub().$( "delete" );
	testClass.$property( propertyName="sqlService", mock=SQLService );

	var UtilityService = createStub().$( "getResultStruct", { "success"=true, "code"=001, "messages"=[] } );
	testClass.$property( propertyName="UtilityService", mock=UtilityService );

	testClass.$( "getBeanMap", {
			primaryKey="id"
		} )
		.$( "getBeanName", "test" );

	testClass.$property( propertyName="id", mock=1 );
}

function mockSuperGetProperties( required component testClass ){
	testClass.$( "getBeanMap", { properties={} } )
		.$( "getPropertyValue", "value" );
}

function mockSuperSave( required component testClass ){
	var SQLService = createStub()
		.$( "create", 1 )
		.$( "update" );
	testClass.$property( propertyName="sqlService", mock=SQLService );

	var UtilityService = createStub().$( "getResultStruct", { "success"=true, "code"=001, "messages"=[] } );
	testClass.$property( propertyName="UtilityService", mock=UtilityService );

	testClass.$( "clearCache" )
		.$( "getBeanMap", {
			primarykey="id",
			cached=false
		} )
		.$( "getBeanName", "test" )
		.$( "setPrimaryKey" )
		.$( "validate", [] );

	testClass.$property( propertyName="id", mock=0 );
}

function mockSuperValidate( required component testClass ){
	var ValidationService = createStub().$( "validateBean", [] );
	testClass.$property( propertyName="validationService", mock=ValidationService );

	testClass.$( "getBeanMap", {} );
}
</cfscript>

<cfscript>
	function testResultStruct( required any result ) {
		expect( arguments.result ).toBeStruct();

		expect( arguments.result ).toHaveKey( "success" );
		expect( arguments.result.success ).toBeBoolean();

		expect( arguments.result ).toHaveKey( "code" );
		expect( arguments.result.code ).toBeNumeric();

		expect( arguments.result ).toHaveKey( "messages" );
		expect( arguments.result.messages ).toBeArray();

		for ( var key in arguments.result ) {
			expect( key ).toBeWithCase( lCase(key) );
		}
	}
</cfscript>

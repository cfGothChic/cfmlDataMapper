<cfscript>
	function testResultStruct( required any result ) {
		expect( arguments.result ).toBeTypeOf( "struct" );

		expect( arguments.result ).toHaveKey( "success" );
		expect( arguments.result.success ).toBeTypeOf( "boolean" );

		expect( arguments.result ).toHaveKey( "code" );
		expect( arguments.result.code ).toBeTypeOf( "numeric" );

		expect( arguments.result ).toHaveKey( "messages" );
		expect( arguments.result.messages ).toBeTypeOf( "array" );

		for ( var key in arguments.result ) {
			expect( key ).toBeWithCase( lCase(key) );
		}
	}
</cfscript>

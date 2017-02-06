<cfcomponent output="false">

	<cffunction name="init" access="public" >
		<cfargument name="dsn" type="string" required="true" >
		<cfset variables.dsn = arguments.dsn >
		<cfreturn this >
	</cffunction>

	<cffunction name="storedproc" access="public" returntype="struct">
		<cfargument name="sprocname" type="string" required="true" >
		<cfargument name="params" type="array" default="#[]#">
		<cfargument name="resultkeys" type="array" default="#[]#">
		<cfset var result = {} >
		<cfset var param = "" >
		<cfset var k = 0 >
		<cfset var key = "" >

		<cfstoredproc procedure="#arguments.sprocname#" datasource="#variables.dsn#" >
			<cfloop array="#arguments.params#" index="param">
				<cfif isStruct(param) and structKeyExists(param,"cfsqltype") and structKeyExists(param,"value")>
					<cfprocparam cfsqltype="#param.cfsqltype#" value="#param.value#" type="in" >
				</cfif>
			</cfloop>

			<cfloop array="#arguments.resultkeys#" index="key">
				<cfset k++ >
				<cfprocresult name="result.#key#" resultset="#k#" >
			</cfloop>
		</cfstoredproc>

		<cfreturn result >
	</cffunction>

</cfcomponent>
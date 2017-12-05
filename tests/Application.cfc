/**
* Copyright Since 2005 Ortus Solutions, Corp
* www.ortussolutions.com
**************************************************************************************
*/
component{
	this.name = "A TestBox Runner Suite " & hash( getCurrentTemplatePath() );
	this.sessionManagement = true;

	this.mappings[ "/testbox" ] = expandPath("../tests/testbox");
	this.mappings[ "/cfmlDataMapper" ] = expandPath("../");
	this.mappings[ "/model" ] = expandPath("../samples/model");

	public boolean function onRequestStart( String targetPage ){
		return true;
	}
}

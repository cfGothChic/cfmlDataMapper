component{
	this.name = "cfmlDataMapper";
	this.sessionManagement = true;

	this.mappings[ "/cfmlDataMapper" ] = expandPath("/");
	this.mappings[ "/model" ] = expandPath("/samples/model");

	public boolean function onRequestStart( String targetPage ){
		return true;
	}
}

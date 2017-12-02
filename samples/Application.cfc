component {

	this.name = "cfmlDataMapperSamples";
	this.applicationTimeout = createTimeSpan(1, 0, 0, 0);

	boolean function onApplicationStart(){
		return true;
	}

	boolean function onRequestStart(string targetPage) {
		return true;
	}

}

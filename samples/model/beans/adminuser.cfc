component accessors="true" extends="user" {

	public function init( id=0 ) {
		setUserTypeId(1);
		super.init(id=arguments.id);
		return this;
	}

}

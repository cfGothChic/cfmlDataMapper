component accessors="true" output="false" {

	public component function init() {
		return this;
	}

	public string function getCreateNewId( required boolean isidentity ) {
		var sql = "";

		if ( arguments.isidentity ) {
			sql &= "); SELECT LAST_INSERT_ID() AS newid;";
		} else {
			sql &= "); SELECT @newid AS newid;";
		}

		return sql;
	}

	public string function getCreateSetNewId(
		required boolean isidentity,
		required string tablename,
		required string primarykeyfield
	) {
		var sql = "";

		if ( !arguments.isidentity ) {
			sql &= "SET @newid = (SELECT MAX(" & arguments.tablename & "." & arguments.primarykeyfield & ") ";
			sql &= "FROM " & arguments.tablename & ") ";
			sql &= "SET @newid = @newid + 1; ";
		}

		return sql;
	}

	public string function getCreateValues( required boolean isidentity ) {
		var sql = "";

		if ( arguments.isidentity ) {
			sql &= ") VALUES (";
		} else {
			sql &= ") VALUES (@newid, ";
		}

		return sql;
	}

	public string function getPropertyField( required struct prop ){
		return "`" & ( len(arguments.prop.columnname) ? arguments.prop.columnname : arguments.prop.name ) & "`";
	}

	public string function getSelectAsField(
		required string propname,
		required string columnname,
		required string sqltype,
		required boolean isNull
	) {
		var fieldresult = "";

		if ( arguments.sqltype == "cf_sql_integer" && arguments.isNull ) {
			fieldresult &= "IFNULL(";
		}

		fieldresult &= arguments.columnname;

		if ( arguments.sqltype == "cf_sql_integer" && arguments.isNull ) {
			fieldresult &= ",0)";
		}

		fieldresult &= " AS `" & arguments.propname & "`";

		return fieldresult;
	}

	public string function getTableName( required struct beanmap ) {
		return "`" & arguments.beanmap.table & "`";
	}

}

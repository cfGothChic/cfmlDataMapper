component output="false" {

	public component function init() {
		return this;
	}

	/**
	 * Recursive functions to compare structures and arrays.
	 * Fix by Jose Alfonso.
	 *
	 * @param LeftStruct 	 The first struct. (Required)
	 * @param RightStruct 	 The second structure. (Required)
	 * @return Returns a boolean.
	 * @author Ja Carter (ja@nuorbit.com)
	 * @version 2, October 14, 2005
	 */
	private boolean function structCompare(LeftStruct,RightStruct) {
		var result = true;
		var LeftStructKeys = "";
		var RightStructKeys = "";
		var key = "";

		//Make sure both params are structures
		if (NOT (isStruct(LeftStruct) AND isStruct(RightStruct))) return false;

		//Make sure both structures have the same keys
		LeftStructKeys = ListSort(StructKeyList(LeftStruct),"TextNoCase","ASC");
		RightStructKeys = ListSort(StructKeyList(RightStruct),"TextNoCase","ASC");
		if(LeftStructKeys neq RightStructKeys) return false;

		// Loop through the keys and compare them one at a time
		for (key in LeftStruct) {
			//Key is a structure, call structCompare()
			if (isStruct(LeftStruct[key])){
				result = structCompare(LeftStruct[key],RightStruct[key]);
				if (NOT result) return false;
			//Key is an array, call arrayCompare()
			} else if (isArray(LeftStruct[key])){
				result = arrayCompare(LeftStruct[key],RightStruct[key]);
				if (NOT result) return false;
			// A simple type comparison here
			} else {
				if(LeftStruct[key] IS NOT RightStruct[key]) return false;
			}
		}
		return true;
	}

	/**
	 * Upper cases the first letter of a string.
	 * Phil Arnold (philip.r.j.arnold@googlemail.com
	 *
	 * @param name 	 String to capitalize the first letter of (Required)
	 * @return Returns a string.
	 * @author Brian Meloche (brianmeloche@gmail.com)
	 * @version 0, March 17, 2010
	 */
	private string function upperFirst(required string name) {
		return uCase(left(arguments.name,1)) & right(arguments.name,len(arguments.name)-1);
	}

}

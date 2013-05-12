/*  
 * Library example made by kws4679
 * 	You can choose 3 types of class you want
 */
	
// 1. making normal json object example
LibKws4679 = {};

LibKws4679.init = function(){
	alert("LibKws4679 initialized");
}

LibKws4679.dummyFunction = function(){
	outln("LibKws4679.dummyFunction");
}



// 2. making classical javascript class object example
function LibKws4679Classic(){
	
	this.init = function(){
		alert("LibKws4679Classic initialized");
	}
	
	this.dummyFunction = function(){
		outln("LibKws4679Classic.dummyFunction");
	}
}


// 3. making coffee class example (need compile)
/*

class LibKws4679Coffee
	init : () ->
		alert "LibKws4679Coffee initialized"
		
	dummyFunction : () ->
		outln "LibKws4679Coffee.dummyFunction"


 */


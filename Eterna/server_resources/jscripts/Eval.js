Eval = {};

Eval.evaluate = function(_code){
	var _script_response = {};
	var _result;
	var out = function(msg) { _result += msg;}
	var outln = function(msg){ _result += msg;}

	var _global_timer = new Date();
	var __code = "";
	try{
		var Lib = new Library();
		__code = "function lambda(){"+_code+"};lambda();";
		_result = eval(__code);
		_script_response['result'] = true;
	}catch(e){
		_result = e.message;
		_script_response['result'] = false;
	}finally{
		_script_response['eval_time'] = (new Date()).getTime() - _global_timer.getTime();
		if(_result == undefined) _result = "undefined";
		_script_response['cause'] = _result;
		//Log.test("evaluate result : ");
		//Log.test(_script_response);
		return _script_response;
	}
}


//script timeout seconds
Eval.insert_timeout = function(source, timeout) {
	var inserted_code = "if((new Date()).getTime() - _global_timer.getTime() > " + timeout * 1000 + ") {outln(\""+timeout+"sec timeout\");return 'Timeout';};";
	var regexp = /while\s*\([^\)]*\)\s*\{?|for\s*\([^\)]*\)\s*\{?/;
	var code = "";
	while(source.search(regexp) != -1){
		var chunk = source.match(regexp)[0]
		var index = source.indexOf(chunk) + chunk.length

		// if while or for with no {}
		if((chunk.charAt(chunk.length-1)) != "{"){
			//var nextRegexp = /.*[\(.*\)|[^;]]*;/;
			var nextRegexp = /.*[\(.*\)|[^;]|\n]*;{0,1}/;
			//get nextline(until find ;)
			var nextline = source.substring(index);
			nextline = nextline.match(nextRegexp)[0];
			code += source.substring(0, index) + "{" + inserted_code + nextline + "}";
			index += nextline.length;
		} else 
			// if while or for with bracket 
			code += source.substring(0, index) + inserted_code;
		if(source.length > index) source = source.substring(index);
		else {
			source = "";
			break;
		}
	}
	code += source;
	return code;
}
$(document).ready(function(){
	BootStrap.initializeBuilder();
	BootStrap.initializeAjaxUrls();
	BootStrap.initializeLibraryLoader();
	BootStrap.initializeAjaxManager();
	BootStrap.initializeFold();
	BootStrap.initializeMocks();
});


BootStrap = {};
BootStrap.initializeBuilder = function(){
	// initialize builder
	var pageblock = BlockManager.get_pageblock("/web/script/create/");
	BootStrap.builder = Builder.prototype.on_build(pageblock, $('body'), {});
	
}
BootStrap.initializeAjaxUrls = function(){
	// hook url
	Application.GET_URI = "http://eterna.cmu.edu/get/";
	Application.POST_URI = "http://eterna.cmu.edu/post/";
}
BootStrap.initializeLibraryLoader = function(){
	// initialize library loader
	var LibLoader = window.LibLoader;
	BootStrap.builder[1].loader = new LibLoader();
	BootStrap.builder[1].loader.setUse(false);					// don't use loader
}
BootStrap.initializeAjaxManager = function(){
	// hook ajaxmanager for mock data
	window.AjaxManager.querySync = function(method, url, parameters) {
		var type = parameters.type;
		var data = eval("window."+type);
		if(data == undefined){
			alert(type + " mock doesn't exsists.");
		} else return data;
	};
}
BootStrap.initializeFold = function(){
	// hook fold with LibVrna211
	var vrna = new LibVrna211();
	var Library = window.Library;
	Library.prototype.fold = function(sequence){
		return vrna.fold(sequence)['mfe_structure'];
	};
}
BootStrap.initializeMocks = function(){
	var _init = function(type){
		$('#'+type+'_mock').val(JSON.stringify(eval("window."+type)));
		$('#'+type+'_apply').click(function(){
			try{
				window.puzzle = JSON.parse($('#'+type+'_mock').val());
				BootStrap.builder[1].outln(type+" apply success...");
			}catch(e){alert(e);}
		});	
	}
	_init("puzzle");
	_init("user");
}

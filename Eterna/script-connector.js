$(document).ready(function(){
	// initialize builder
	var pageblock = BlockManager.get_pageblock("/web/script/create/");
	var builder = Builder.prototype.on_build(pageblock, $('body'), {});
	
	// hook url
	Application.GET_URI = "http://eterna.cmu.edu/get/";
	Application.POST_URI = "http://eterna.cmu.edu/post/";
	
	// initialize library loader
	var LibLoader = window.LibLoader;
	builder[1].loader = new LibLoader();
	builder[1].loader.setUse(false);					// don't use loader
	
	
});
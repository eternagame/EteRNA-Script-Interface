$(document).ready(function(){
	var pageblock = BlockManager.get_pageblock("/web/script/create/");
	Builder.prototype.on_build(pageblock, $('body'), {});
	
	Application.GET_URI = "http://eterna.cmu.edu/get/";
	Application.POST_URI = "http://eterna.cmu.edu/post/";
});
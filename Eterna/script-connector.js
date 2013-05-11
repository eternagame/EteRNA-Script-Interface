$(document).ready(function(){
	//var block = BlockManager.get_pageblock("/web/script/create/");
	var pageblock = BlockManager.get_pageblock("/web/script/create/");
	Builder.prototype.on_build(pageblock, $('body'), {});
});
$(function(){
	$('#btn_go').click(
		function(){
			var wiki = $('#wiki_name').val();
			if(wiki.length < 1) wiki = 'GyazzWeb';
			location.href = app_root + '/' + wiki;
		}
	);
});

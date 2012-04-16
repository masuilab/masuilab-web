$(function(){
  $.getJSON(menuAPI,function(res){
    $.each(res, function(i, menu){
      var link = "#"+menu;
      var a  = $('<a>').attr('href',link).text(menu);
      var li = $('<li>').append(a);
      $('ul#menu').append(li);
    });
  });
});


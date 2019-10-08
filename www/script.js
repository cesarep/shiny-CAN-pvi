function resize(){
   if(window.innerWidth >= 768)
      valor = Math.min(window.innerHeight-115, Math.floor(2*window.innerWidth/3)-30);
   else
      valor = window.innerWidth-30;
   $('#plot').width(valor+'px').height(valor+'px');
}
window.onresize = function(){ resize(); };
$('#plot').ready(function(){ resize(); });
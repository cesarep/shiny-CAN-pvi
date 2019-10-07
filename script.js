function resize(){
   if(window.innerWidth >= 768)
      valor = Math.min(window.innerHeight-115, Math.floor(2*window.innerWidth/3)-30);
   else
      valor = window.innerWidth-30;
   $('#plot').width(valor+'px').height(valor+'px');
}
window.onresize = function(){ resize(); };
$('#plot').ready(function(){ resize(); });

function atualizar(X, Y){
   var RX = -Math.log10(X[1]-X[0]), RY = -Math.log10(Y[1]-Y[0]);
   console.log(RX);
   console.log(X[1]-X[0]);
   console.log("-------");
   
   if(RX > 1){
      RX = Math.ceil(RX);
      X[0] = parseFloat(X[0].toFixed(RX));
      X[1] = parseFloat(X[1].toFixed(RX));
   } else{
      X[0] = parseFloat(X[0].toFixed(1));
      X[1] = parseFloat(X[1].toFixed(1));
   }
   
   if(RY >= 1){
      RY = Math.ceil(RY);
      Y[0] = parseFloat(Y[0].toFixed(RY));
      Y[1] = parseFloat(Y[1].toFixed(RY));
   } else{
      Y[0] = parseFloat(Y[0].toFixed(1));
      Y[1] = parseFloat(Y[1].toFixed(1));
   }

   $('#x1')[0].value = X[0];
   Shiny.onInputChange('x1', X[0]);
   $('#x2')[0].value = X[1];
   Shiny.onInputChange('x2', X[1]);
   $('#y1')[0].value = Y[0];
   Shiny.onInputChange('y1', Y[0]);
   $('#y2')[0].value = Y[1];
   Shiny.onInputChange('y2', Y[1]);
}

$(document).keyup(function(e) {
   X = Array(parseFloat($('#x1').val()), parseFloat($('#x2').val()));
   Y = Array(parseFloat($('#y1').val()), parseFloat($('#y2').val()));
   DX = (X[1]-X[0])*0.25;
   DY = (Y[1]-Y[0])*0.25;
   if(e.which == 37){
      X[0]-=DX;
      X[1]-=DX;
      atualizar(X, Y);
   }
   if(e.which == 39){
      X[0]+=DX;
      X[1]+=DX;
      atualizar(X, Y);
   }
   if(e.which == 38){
      Y[0]+=DY;
      Y[1]+=DY;
      atualizar(X, Y);
   }
   if(e.which == 40){
      Y[0]-=DY;
      Y[1]-=DY;
      atualizar(X, Y);
   }
   if(e.which == 107 || e.which == 187){
      X[0]/=1.25;
      X[1]/=1.25;
      Y[0]/=1.25;
      Y[1]/=1.25;
      atualizar(X, Y);
   }
   if(e.which == 109 || e.which == 189){
      X[0]*=1.25;
      X[1]*=1.25;
      Y[0]*=1.25;
      Y[1]*=1.25;
      atualizar(X, Y);
   }
});
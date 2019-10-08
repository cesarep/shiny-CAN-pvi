library(shiny)
library(xtable)

shinyServer(function(input, output, session) {
   #define valores reativos
   rv <- reactiveValues(tabela=data.frame(), 
                        dydx = function(x, y) x + y^2,
                        plot=list(), 
                        intervalo = list(x=c(-5,5), y=c(-5,5)),
                        resultado = list(),
                        cabecario = ""
                        )
   
   #define funções
   fTest <- function(x, y) {}
   observeEvent(input$dydx, {
      #preenche * entre numero e x ou função
      if(grepl("(\\d)(\\w|\\()", input$dydx))
         updateTextInput(session, 'dydx', value = gsub("(\\d)(\\w|\\()", "\\1*\\2", input$dydx))
      
      try({
         body(fTest) <- parse(text = paste0(input$dydx))
         if( !is.primitive(fTest(1, 1)) )
            body(rv$dydx) <- parse(text = paste0(input$dydx))
      }, silent = T)
   })
   
   
   #atualiza ponto inicial e final
   observeEvent(input$plot_click, {
      x0 = input$plot_click$x
      y0 = input$plot_click$y
      updateNumericInput(session, 'x0', value = round(x0, 2))
      updateNumericInput(session, 'y0', value = round(y0, 2))
   })
   observeEvent(input$plot_dbclick, {
      xf = input$plot_dbclick$x
      updateNumericInput(session, 'xf', value = round(xf, 2))
   })
   
   
   #cuida do zoom do plot
   observeEvent(input$zoom, {
      dir = input$zoom$dir #direção do scroll do mouse
      usr = rv$plot$par$usr #coordenadas dos extremos da plotagem em unidades do plot
      pin = rv$plot$par$pin #tamanho da plotagem em pol
      mai = rv$plot$par$mai #tamanho das margens em pol
      din = rv$plot$par$din #tamanho da plotagem+margens em pol
      dev = rv$plot$dev #tamanho da plotagem+margens em px
      einpx = din/dev #escala pol/px
      #ponto clicado em pol com origem na plotagem
      ptoin = list(x=input$zoom$x*einpx[1]-mai[2], y=input$zoom$y*einpx[2]-mai[3])
      
      #verifica se mouse está nos eixos
      if(ptoin$x<0 && ptoin$y<din[2]-mai[1]) #mouse no eixo y
         k=list(x=0,y=.25)
      else if(ptoin$x>0 && ptoin$y>din[2]-mai[1]) #mouse no eixo x
         k=list(x=.25,y=0)
      else #mouse na plotagem
         k=list(x=.25,y=.25)
      
      dx=usr[2]-usr[1] #intervalo x em unidades
      dy=usr[4]-usr[3] #intervalo y em unidades
      ex=dx/pin[1] #escala x em unidades/pol
      ey=dy/pin[2] #escala y em unidades/pol
      
      pto = list(x=usr[1]+ptoin$x*ex, y=usr[4]-ptoin$y*ey)
      
      int = rv$intervalo #intervalo de plotagem em unidades
      Dx = pto$x-int$x #distancia entre pto clicado e extremos do intervalo
      Dy = pto$y-int$y
      
      #afasta ou aproxima (dir +/-1) num fator k
      int$x = int$x - Dx*k$x*dir
      int$y = int$y - Dy*k$y*dir
      
      #atualiza intervalo
      rv$intervalo = int
      
   })
   
   #faz calculos
   observeEvent({input$x0; input$y0; input$xf; input$metodo; input$N; rv$dydx}, { 
      #define função
      dydx = rv$dydx
      
      #faz calculos e tabela
      x0 = input$x0
      y0 = input$y0
      xf = input$xf
      N = input$N
      h = (xf-x0)/N
      tabela <- NULL #define variavel tabela local
      cab <- NULL
      if(input$metodo == 1)
         source('metodos/euler.R', local = T, encoding = 'UTF-8')
      if(input$metodo == 2)
         source('metodos/RK2.R', local = T, encoding = 'UTF-8')
      if(input$metodo == 3)
         source('metodos/RK3.R', local = T, encoding = 'UTF-8')
      if(input$metodo == 4)
         source('metodos/RK4.R', local = T, encoding = 'UTF-8')
      rv$tabela <- tabela #atribui tabela local à reativa
      rv$cabecario <- paste0("<tr><th>\\(",paste0(cab, collapse = '\\)</th><th>\\('),"\\)</tr></th>")
   })
   
   #imprime tabela
   observeEvent(rv$tabela, {
      tabela = rv$tabela
      modTab = list(pos=list(0), command=rv$cabecario)
      if(nrow(tabela)>10){
         modTab$pos[2] = nrow(tabela)
         modTab$command[2] = paste0("<tr id='tabexp'><td align='center' colspan='", ncol(tabela),"'></td></tr>")
      }
      tabela[,1] = as.integer(tabela[,1])
      output$tabela <- renderTable(tabela, align='c', digits=3, striped = T, 
                                   include.colnames=FALSE, add.to.row = modTab)
   })
   
   output$resultado <- renderUI({
      Result = rv$tabela[nrow(rv$tabela), 2:3]
      sprintf("$$y(%.3f)=%.3f$$", Result[1], Result[2])
   })

   #plota gráfico
   output$plot <- renderPlot({ 
      #inicializa gráfico
      intX = rv$intervalo$x
      intY = rv$intervalo$y
      par(mar=c(1,1,0,0)*2.5); plot.new(); plot.window(intX, intY)
      axis(1); axis(2)
      
      rv$plot = list(dev = dev.size('px'), par=par())
      
      #plotar campo de direções
      dydx = rv$dydx
      A = input$dens
      DX = (intX[2]-intX[1])/A
      DY = (intY[2]-intY[1])/A
      NX = seq(intX[1], intX[2], length.out = A)
      NY = seq(intY[1], intY[2], length.out = A)
      comp = 0.7*min(c(intX[2]-intX[1],intY[2]-intY[1]))/10
      for(i in NX) for(j in NY){
         xi = i
         yi = j
         theta = dydx(xi, yi)
         d = 0.5*0.5*comp/(2*sqrt(1+theta^2))
         lines(c(xi-d, xi+d), c(yi-d*theta, yi+d*theta))
      }
      
      #plota ponto inicial e flechas
      points(rv$tabela[1, 2], rv$tabela[1, 3], pch = 19, col='red')
      X = rv$tabela[,2]; Y = rv$tabela[,3]
      for(i in 2:length(X)){
         arrows(X[i-1], Y[i-1], X[i], Y[i], 0.1, col = 'blue')
      }
   })
})

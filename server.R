library(shiny)
library(xtable)

shinyServer(function(input, output, session) {
   #valor inicial de y'
   dydx <- function(x, y) {x + y^2} 
   
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
   
   #define tabela como um valor reativo
   rv <- reactiveValues(tabela=0) 
   
   #atualiza valor da tabela
   observeEvent({input$x0; input$y0; input$xf; input$metodo; input$N}, { 
      #define função
      body(dydx) <- parse(text = input$dydx)
      
      #faz calculos e tabela
      x0 = input$x0
      y0 = input$y0
      xf = input$xf
      N = input$N
      h = (xf-x0)/N
      tabela <- NULL #define variavel tabela local
      if(input$metodo == 1)
         source('euler.R', local = T, encoding = 'UTF-8')
      if(input$metodo == 2)
         source('RK2.R', local = T, encoding = 'UTF-8')
      if(input$metodo == 3)
         source('RK3.R', local = T, encoding = 'UTF-8')
      if(input$metodo == 4)
         source('RK4.R', local = T, encoding = 'UTF-8')
      rv$tabela <- tabela #atribui tabela local à reativa
   })
   
   #imprime tabela
   output$tabela <- renderTable({ 
      M = tail(rv$tabela, 10)
      M[,1] = as.integer(M[,1])
      M
   }, align='c', digits=3, striped = T)
   
   output$resultado <- renderUI({
      Result = rv$tabela[nrow(rv$tabela), 2:3]
      withMathJax(sprintf("$$y(%.3f)=%.3f$$", Result[1], Result[2]))
   })

   #plota gráfico
   output$plot <- renderPlot({ 
      #inicializa gráfico
      intX = c(input$x1, input$x2)
      intY = c(input$y1, input$y2)
      par(mar=c(1,1,0,0)*2.5); plot.new(); plot.window(intX, intY)
      axis(1); axis(2)
      
      #plotar campo de direções
      body(dydx) <- parse(text = input$dydx)
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

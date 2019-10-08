library(shiny)

source('katex.r', encoding = 'utf-8')

shinyUI(fluidPage(
   KaTeX(),
   includeScript('www/script.js'),
   titlePanel("Métodos Numéricos para PVIs"),
   sidebarLayout(
      sidebarPanel(
         fluidRow(
            column(2, HTML("\\(y'=\\)"), style="padding-top: 26px;text-align: right;padding-right: 0;"),
            column(10, textInput('dydx', '', 'x + y^2'))
         ),
         includeCSS('www/estilo.css'),
         includeHTML('www/ajuda.htm'),
         includeScript('www/tabela.js'),
         includeCSS('www/tabela.css'),
         selectInput('metodo', 'Método', 
            list('Euler' = 1,
                 'RK2 (Euler Modificado)' = 2,
                 'RK3' = 3,
                 'RK4' = 4
            )
         ),
         splitLayout(
            numericInput('x0', '\\(x_0\\)', -2, step = 0.5),
            numericInput('y0', '\\(y_0\\)', -1.5, step = 0.5),
            numericInput('xf', '\\(x_f\\)', 2, step = 0.5)
         ),
         splitLayout(
            numericInput('N', 'Nº de iterações', 4, 1, step = 1),
            sliderInput('dens', 'Nº de tangentes', 10, 40, 25)
         ),
         helpText(HTML("Use a roda do mouse para navegar pela plotagem, 
                       deixando ele sobre os eixos para mudar a escala dos mesmos."))
      ),
      mainPanel(
         tabsetPanel(
            tabPanel("Gráfico", 
               div(plotOutput('plot', height = '600px', click = 'plot_click', dblclick = 'plot_dbclick'), style="width:min-content", onwheel="
                  event.preventDefault();
                  console.log(this.offsetTop);
                  Shiny.setInputValue('zoom', {dir: event.deltaY/3, x:event.layerX-this.offsetLeft, y:event.layerY-this.offsetTop, ts: event.timeStamp%10000})
                  ")
            ),tabPanel("Resultados",
               tableOutput('tabela'),
               uiOutput('resultado'),
               tags$style(type='text/css', "#tabela table {margin: 10px auto;}")
            )
         )
      )
   ),
   hr(),
   flowLayout(id = "cabecario",
              p(strong("Apoio:"), br(), img(src="NEPESTEEM.png")),
              p(strong("Agradecimento:"), br(), img(src="FAPESC.png")),
              p(strong("Desenvolvido por:"), br(), "César Eduardo Petersen")
   )
))

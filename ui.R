library(shiny)

shinyUI(fluidPage(
   includeScript('script.js'),
   titlePanel("Métodos Numéricos para PVIs"),
   withMathJax(),
   sidebarLayout(
      sidebarPanel(
         fluidRow(
            column(2, HTML("\\(y'=\\)"), style="padding-top: 26px;text-align: right;padding-right: 0;"),
            column(10, textInput('dydx', '', 'x + y^2'))
         ),
         includeCSS("estilo.css"),
         includeHTML('ajuda.htm'),
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
         splitLayout(
            numericInput('x1', '\\(x_1\\)', -5, step = 0.5),
            numericInput('x2', '\\(x_2\\)', 5, step = 0.5)
         ),
         splitLayout(
            numericInput('y1', '\\(y_1\\)', -5, step = 0.5),
            numericInput('y2', '\\(y_2\\)', 5, step = 0.5)
         )
      ),
      mainPanel(
         tabsetPanel(
            tabPanel("Gráfico", 
               plotOutput('plot', height = '600px', click = 'plot_click', dblclick = 'plot_dbclick')
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

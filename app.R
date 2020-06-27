library(shiny)
library(mapdeck)

ui <- fluidPage(
  tags$head(
    tags$script(src = "https://api.tiles.mapbox.com/mapbox-gl-js/v1.9.1/mapbox-gl.js"),
    tags$link(href="https://api.tiles.mapbox.com/mapbox-gl-js/v1.9.1/mapbox-gl.css",
              rel="stylesheet"),
    tags$style(HTML("
      body {
        margin: 0;
        padding: 0;
      }
      #map-container {
        border: 2px solid blue;
        position: relative;
        z-index: 1;
        height: 400px;
        width: 100%;
      }
      #map {
        border: 2px solid black;
        z-index: 1;
        width: 100%;
        height: 100%;
      }
      #map img {
        max-width: none;
        min-width: 0px;
        height: auto;
      }
      .session-new{
/*   display: flex;
        //flex-direction: column; */
        position: absolute;
        width: 340px;
        left: 33%;
        top: 25px;
        //left: 500px;
        z-index: 2;
        padding: 20px;
        border-radius: 4px;
        //margin-top: 4vh;
        background-color: rgba(255, 255, 255, 0.85);
      }

      ")
    )
  ),
#  mainPanel(
  fluidRow(h2('Row0')),
  tags$div(class='row',
           tags$h2("Row 1")),
  tags$div(class='row', style="border: 2px solid black; height: 500px;",
    tags$div(class="col-lg-3", style="border: 2px solid black; ",tags$h2("Text")),
    tags$div(class="col-lg-9", style="border: 2px solid black; ",
      tags$div(id='map-container',
          tags$div(id="map"),
          tags$div(id='sliderbar',
                   class='session-new',
                   tags$p('Slider'),
                   tags$input(id="slider-new",
                              class='row-new',
                              type='range',
                              min='0',
                              max='14',
                              step='1',
                              value='0')),
      ),
      tags$script(src="map_simple.js")
    ) #close col
  ), #close row
tags$div(class='row',
         tags$h2("Row 3"),
         textOutput("text_output_test")),

               
)

server <- function(input, output) {
  output$text_output_test <- renderText(input$fromMap)
  
}


# Run the application 
shinyApp(ui = ui, server = server)

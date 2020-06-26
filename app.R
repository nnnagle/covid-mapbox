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
      #map-containter {
        position: inherited;
        left:400px;
        height: 600px;
        width: 400px;
      }
      #map {
        border: 2px solid black;
        left: 400px;
        height: 400px;
        margin-bottom: 10px;
      }
      #map img {
        max-width: none;
        min-width: 0px;
        height: auto;
}
      ")
    )
  ),
#  mainPanel(
  fluidRow(h2('Row0')),
  tags$div(class='row',
           tags$h2("Row 1")),
  tags$div(class='row', style="border: 2px solid black; height: 500px",
    tags$div(class="col", tags$h2("Text")),
    tags$div(class="col",
      tags$div(id='map-container',
          tags$div(id="map")
      ),
      tags$script(src="map_simple.js")
    ) #close col
  ), #close row
tags$div(class='row',
         tags$h2("Row 3")),

               
)

server <- function(input, output) {
}


# Run the application 
shinyApp(ui = ui, server = server)

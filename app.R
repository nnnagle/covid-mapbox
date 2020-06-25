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
      h2,
      h3 {
        margin: 10px;
        font-size: 1.2em;
      }
      h3 {
        font-size: 1em;
      }
      p {
        font-size: 0.85em;
        margin: 10px;
        text-align: left;
      }
      .map-overlay {
        position: absolute;
        bottom: 0;
        right: 0;
        background: rgba(255, 255, 255, 0.8);
        margin-right: 20px;
        font-family: Arial, sans-serif;
        overflow: auto;
        border-radius: 3px;
      }
      .mapboxgl-map {
        position: absolute;
        top: 0;
        bottom: 0;
        width: 100%;
      }
      #map {
        position: absolute;
        top: 0;
        bottom: 0;
        width: 100%;
      }
      #features {
        top: 0;
        height: 100px;
        margin-top: 20px;
        width: 250px;
      }
      #legend {
        padding: 10px;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        line-height: 18px;
        height: 150px;
        margin-bottom: 40px;
        width: 100px;
      }
      .legend-key {
        display: inline-block;
        border-radius: 20%;
        width: 10px;
        height: 10px;
        margin-right: 5px;
      }")
    )
  ),
#  mainPanel(
  tags$div(class='row',
    tags$div(class="col-lg-6", tags$h2("Text")),
    tags$div(class="col-sm",
      tags$div(id="map"),
      tags$div(class="map-overlay",
             id="features",
             tags$h2("Covid-19 population density")),
      tags$div(class="map-overlay",
             id="legend"),
      tags$script(src="map.js")
    ) #close col-sm
  ) #close row

               
)

server <- function(input, output) {
}


# Run the application 
shinyApp(ui = ui, server = server)

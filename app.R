library(shiny)
#library(mapdeck)
library(sf)
library(tidyverse)
library(plotly)

data <- geojsonsf::geojson_sf('www/counties_data.geojson') %>%
  sf::st_drop_geometry() %>%
  pivot_longer(cols=starts_with('2020'), names_to='date', values_to='lambda') %>%
  mutate(date = as.Date(date),
         lambda = as.numeric(lambda)) %>%
  arrange(geoid, date)

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
        border: 1px solid red;
        width: 340px;
        left: 33%;
        top: 10px;
        //left: 500px;
        z-index: 2;
        padding: 20px;
        border-radius: 4px;
        //margin-top: 4vh;
        background-color: rgba(255, 255, 255, 0.85);
      }
      #slider.row{
        margin-left: 30px;
        margin-top: -16px;
        width: 80%;
      }
      ///#slider{
      ///  border: 1px solid green;
      ///}
      #active-date{
        padding-bottom: 10px;
        display: block;
        font: 400 20px/20px 'Sofia Pro','Source Sans Pro', 'Helvetica Neue', Sans-serif;
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
          tags$div(id='sliderbar', class='session-new',
                   tags$label(id="active-date" ),
                   tags$img(src="play-button.png", id = "img_play_pause", alt="Play/Pause", height="20", width="20" ),
                   tags$input(id="slider",
                              class='row',
                              type='range',
                              min='0',
                              max='60',
                              step='1',
                              value='45'))
      )
    ) #close col
  ), #close row
  #HTML('<script> $( document ).on("shiny:sessioninitialized", function(event) { Shiny.onInputChange("selected_state", "47");            });</script>'),
  tags$div(class='row',
           tags$h2("Row 3"),
           textOutput("text_output_test"),
           plotlyOutput("plot")),
  tags$script(src="map_simple.js")

               
)

server <- function(input, output, session) {
  selected_data <- reactive({data %>% filter(STATE==input$selected_state)})
  counter <- reactiveValues(countervalue = 0) # Defining & initializing the reactiveValues object
  output$text_output_test <- 
    renderText(paste0('fromMap: ',input$fromMap, 
                      ' selectedState: ', input$selected_state,
                      ' number: ', nrow(selected_data()),
                      ' counter: ', counter$countervalue))
  
  log_counties_plot <- reactive({
    data %>%
#    selected_data() %>%
    filter(lambda>0) %>%
    plot_ly(x=~date, 
            y=~lambda, 
            name=~NAME, 
            text=~NAME,
            showlegend=FALSE)  
  })
  
  output$plot <- renderPlotly({
    #data %>% 
    #  filter(STATE==input$selected_state) %>%
    # selected_data() %>%
    #  plot_ly(
    #        x=~date,
    #        y=~lambda,
    #        split=~geoid,
    #        showlegend=FALSE)  %>% add_lines(color=I("grey40"))
    #add_lines(log_counties_plot(), hoverinfo='text')
    #log_counties_plot() %>%
    log_counties_plot() %>%
      filter(geoid=='47093') %>%
    add_lines( color=I("grey40"), hoverinfo='name') %>%
      layout(yaxis=list(type='log'))
  })
  observeEvent(input$selected_state,{
      dat <- data %>% filter(STATE==input$selected_state)
      plotlyProxy("plot",session) %>%
        plotlyProxyInvoke("deleteTraces",list(as.integer(-1)))
      plotlyProxy("plot",session) %>%
        plotlyProxyInvoke("addTraces",
                          x=dat$date,
                          y=dat$lambda,
                          text=dat$NAME,
                          name=dat$NAME,
                          mode='lines',
                          hoverinfo="text",
                          line=(list(color='#D0D0D0'))
                          )
    
  })
    
  
}


# Run the application 
shinyApp(ui = ui, server = server)

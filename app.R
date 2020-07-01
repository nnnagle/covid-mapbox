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

data <- read_csv('www/county_data.csv')

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
        height: 500px;
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
  #tags$div(class='row', style="border: 2px solid black; height: 500px;",
  fluidRow(
    #tags$div(class="col-lg-9", style="border: 2px solid black; ",
    column(7,
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
    ), #close col
    column(5,
           fluidRow(plotlyOutput("counties_plot", height='250px')),
           fluidRow(style="height:10px;"),
           fluidRow(plotlyOutput("county_fit_plot", height='250px'))
    )
  ), #close row
  #HTML('<script> $( document ).on("shiny:sessioninitialized", function(event) { Shiny.onInputChange("selected_state", "47");            });</script>'),
  tags$div(class='row',
           tags$h2("Row 3"),
           textOutput("text_output_test")
           #plotlyOutput("counties_plot")
           ),
  tags$script(src="map_simple.js"),
  tags$script("
    Shiny.addCustomMessageHandler('set_geoid', function(value) {
    Shiny.setInputValue('selected_geoid', value);
    });")

               
)

server <- function(input, output, session) {
  rValues <- reactiveValues()
  rValues$num_traces <- 1
  rValues$last_geoid <- '47093' # to create an unhover event for interactions from map.
  rValues$selectedData <- NULL
  selected_data <- reactive({data %>% filter(state==input$selected_state)})
  counter <- reactiveValues(countervalue = 0) # Defining & initializing the reactiveValues object
  output$text_output_test <- 
    renderText(paste0('fromMap: ',input$selected_geoid, 
                      ' selectedState: ', input$selected_state,
                      ' number: ', nrow(selected_data()),
                      ' counter: ', counter$countervalue,
                      ' traces: ', rValues$num_traces,
                      ' event data: ', paste(event_data('plotly_click', source='log_counties'),collapse=' ')))
  
  log_counties_plot <- reactive({
    data %>%
#    selected_data() %>%
    filter(lambda>0) %>%
    plot_ly(source = "log_counties",
            x=~date, 
            y=~lambda, 
            name=~NAME, 
            text=~NAME,
            showlegend=FALSE) %>%
      event_register('plotly_unhover')
  })
  
  output$counties_plot <- renderPlotly({
    log_counties_plot() %>%
      filter(geoid=='47093') %>%
    add_lines( color=I("grey40"), hoverinfo='name') %>%
      layout(yaxis=list(type='log', title='Cases per 10,000'),
             title='All Counties in State'
      ) %>% config(displaylogo = FALSE,
                   modeBarButtonsToRemove = list(
                     'sendDataToCloud',
                     'toImage',
                     'autoScale2d',
                     #'resetScale2d',
                     'lasso2d',
                     'select2d',
                     'toggleSpikelines',
                     'zoom2d',
                     'boxSelect',
                     'hoverClosestCartesian',
                     'hoverCompareCartesian'
                   ))
  })
  
  output$county_fit_plot <- renderPlotly({
    title <- sprintf('%s County', data %>% filter(geoid==input$selected_geoid) %>% pull(NAME) %>% .[1])
    log_counties_plot() %>%
      filter(geoid==input$selected_geoid) %>%
      add_ribbons(ymin=~mu_lo, ymax=~mu_hi, 
                  line = list(color = 'rgba(0, 0, 0, 0.05)'),
                  fillcolor = 'rgba(0, 0, 0, 0.2)'
                  ) %>%
      add_markers(y=~new_cases, color=I("red"),opacity=.5) %>%
      add_lines(y=~mu, color=I('black')) %>%
      layout(
        title=title,
        yaxis = list(title='Cases')
      ) %>% config(displaylogo = FALSE,
                   modeBarButtonsToRemove = list(
                     'sendDataToCloud',
                     'toImage',
                     'autoScale2d',
                     #'resetScale2d',
                     'lasso2d',
                     'select2d',
                     'toggleSpikelines',
                     'zoom2d',
                     'boxSelect',
                     'hoverClosestCartesian',
                     'hoverCompareCartesian'
                   ))
#      config(modeBarButtons=c("zoomIn2d"))
    #config(displayModeBar=FALSE)
  })
  
  observeEvent(input$selected_state,{
      rValues$selectedData <- data %>% filter(state==input$selected_state) %>% group_by(geoid) %>% nest()
      rValues$last_geoid <- input$geoid;
      #dat <- data %>% filter(state==input$selected_state) %>% group_by(geoid) %>% nest()
      geoids <- rValues$selectedData$geoid
      plotlyProxy("counties_plot",session) %>%
        plotlyProxyInvoke("deleteTraces",
                          as.integer(seq(0,rValues$num_traces-1)))
      rValues$num_traces <- length(geoids)
      alpha = ifelse(rValues$num_traces>150, .1, .25)
      plotlyProxy("counties_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces",
          lapply(rValues$selectedData$data,
                 function(xx) list(x=xx$date,
                                  y=xx$lambda,
                                  customdata=xx$NAME,
                                  text=xx$NAME,
                                  name=xx$NAME,
                                  type='scatter',
                                  hoverinfo='text',
                                  mode='lines',
                                  marker = list(size = 10,
                                                color= sprintf('rgba(0,0,0,%s)', alpha),
                                                line = list(
                                                            width = 1))
                 )
          )
        )
  })
  
  observeEvent(input$geoid, {
    if(is.null(rValues$last_geoid)) rValues$last_geoid <- input$geoid
    if(input$selected_state != substr(input$geoid,1,2)){
      return(NULL)
    } else{
      #browser()
      traceID <- which(rValues$selectedData$geoid==input$geoid)-1
      last_traceID <- which(rValues$selectedData$geoid==rValues$last_geoid)-1
      if(!is.numeric(last_traceID) | length(last_traceID)==0) last_traceID <- 0
      # highlight the current region
      plotlyProxy("counties_plot",session) %>%
        plotlyProxyInvoke(
          method='restyle',
          "line",
          list(color='rgba(0,0,0,1)',opacity=1, width=5),
          traceID
        ) 
      #unhighlight last region
      if(traceID != last_traceID) {
        plotlyProxy("counties_plot",session) %>%
        plotlyProxyInvoke(
          method='restyle',
          "line",
          list(color='rgba(0,0,0,.25)',opacity=1, width=1),
          last_traceID
        )
        rValues$last_geoid <- input$geoid
      }
    }
  })
  
  
  observeEvent(event_data('plotly_hover', source="log_counties"),{
    traceID = event_data('plotly_hover', source="log_counties")[[1]]
    plotlyProxy("counties_plot",session) %>%
      plotlyProxyInvoke(
        method='restyle',
        "line",
        list(color='rgba(0,0,0,1)',opacity=1, width=5),
        event_data('plotly_hover', source="log_counties")[[1]]
      ) 
  })
  
  observeEvent(event_data('plotly_unhover', source="log_counties"),{
    traceID = event_data('plotly_unhover', source="log_counties")[[1]]
    plotlyProxy("counties_plot",session) %>%
      plotlyProxyInvoke(
        method='restyle',
        "line",
        list(color='rgba(0,0,0,.25)'),
        traceID
      )
  })
    
  observeEvent(event_data('plotly_click', source="log_counties"),{
    traceID = event_data('plotly_click', source="log_counties")[[1]]
    clicked_geoid <- rValues$selectedData$geoid[traceID+1]
    session$sendCustomMessage("set_geoid", clicked_geoid)
  })
  
}


# Run the application 
shinyApp(ui = ui, server = server)

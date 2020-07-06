library(shiny)
#library(mapdeck)
#library(sf)
library(tidyverse)
library(plotly)


data <- read_csv('www/county_data.csv')
pal <- matrix(data=c('#FFE51A','#FF730D','#FF0000',
                     '#F2E57F','#FFB37F','#FF5499',
                     '#E5E5E5','#EEC3E5','#FF7FE5'),3,3,byrow=TRUE)
sprintf("['%s','%s','%s', '%s','%s','%s' ,'%s','%s','%s']", 
        pal[3,1],pal[3,2],pal[3,3],
        pal[2,1],pal[2,2],pal[2,3],
        pal[1,1],pal[1,2],pal[1,3])

ui <- fluidPage(
  tags$head(
    tags$script(src = "https://api.tiles.mapbox.com/mapbox-gl-js/v1.9.1/mapbox-gl.js"),
    tags$link(href="https://api.tiles.mapbox.com/mapbox-gl-js/v1.9.1/mapbox-gl.css",
              rel="stylesheet"),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
#  mainPanel(
  tags$div(class="jumbotron",
    fluidRow(
      column(8, h2('COVID-19 NOWcast')),
      column(4, tags$img(src='UTK_long_logo.png', height="60px"))
    )),
  tags$div(
    id="nav-tab",
    class="container-fluid",
    tags$ul(
      class="nav nav-pills",
      tags$li(
        class="active",
        tags$a(
          href="#home-pane",
          `data-toggle`="tab",
          "COVID-19 Map"
        )
      ),
      tags$li(
        tags$a(
          href="#change-pane",
          `data-toggle`="tab",
          "Danger Map"
        )
      ),
      tags$li(
        tags$a(
          href="#about-pane",
          `data-toggle`="tab",
          "About"
        )
      )
    ),#close ul,
    tags$div(
      class="tab-content clearfix",
      ## PANEL 1 ##############################################################
      # Panel 1
      tags$div(
        class="tab-pane active",
        id="home-pane",
        fluidRow(
          column(7,
                  tags$div(class='map-container-500',
                           tags$div(id="map-rate"),
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
                  ),
                 ),
          column(5,
                 fluidRow(
                   tags$div(class="plotly-container",
                            plotlyOutput("counties_plot", height='228px'))),
                 fluidRow(
                   tags$div(class="plotly-container",
                            plotlyOutput("county_fit_plot", height='228px'))),
            )
        )
      ),
      ## PANEL2 ##############################################################
      # Panel 2
      tags$div(
        class="tab-pane",
        id="change-pane",
        fluidRow(
          wellPanel(
          p("The COVID-19 Danger Map shows the ",strong("current rate"), " of new cases and the ", strong("acceleration")," in the number of new cases."),
          p("Red: Many cases now and rapidly accelerating."),
          p("Yellow: Many cases now, but not growing."),
          p("Magenta: Few cases now, but rapidly accelerating."),
          p("Gray: Few cases now and not growing")
          )
        ),
        fluidRow(
          column(7,
                 tags$h4(class="text-center", "COVID-19 Danger Map"),
                 tags$div(class='map-container-500',
                          tags$div(id="biv-map"),
                          tags$div(class="biv-leg",
                             tags$div(id="biv-div",
                             HTML(sprintf('<table style="width:60px">
  <tr height="20px">
    <td bgcolor="%s"></td>
    <td bgcolor="%s"></td>
    <td bgcolor="%s"></td>
  </tr>
  <tr height="20px">
    <td bgcolor="%s"></td>
    <td bgcolor="%s"></td>
    <td bgcolor="%s"></td>
  </tr>
  <tr height="20px">
    <td bgcolor="%s"></td>
    <td bgcolor="%s"></td>
    <td bgcolor="%s"></td>
  </tr>
 </table>',pal[1,1],pal[1,2],pal[1,3],pal[2,1],pal[2,2],pal[2,3],pal[3,1],pal[3,2],pal[3,3]))),
                             tags$div(style="position:absolute; right:5px; bottom:90px", tags$p("Acceleration")),
                             tags$div(class="rotate-90", style="position:absolute; bottom: 30px; right:100px", tags$p("Rate")),
                             tags$div(class="rotate-30",style="position:absolute; right:38px; bottom:65px", tags$p('Slow')),
                             tags$div(class="rotate-30",style="position:absolute; right:2px; bottom:65px",  tags$p('Fast')),
                             tags$div(style="position:absolute; right:75px; bottom:40px", tags$p('High')),
                             tags$div(style="position:absolute; right:75px; bottom:2px",  tags$p('Low'))),
                             tags$div(id='sliderbar2', class='session-new',
                                      tags$label(id="active-date2" ),
                                      #tags$img(src="play-button.png", id = "img_play_pause2", alt="Play/Pause", height="20", width="20" ),
                                      tags$input(id="slider2",
                                                 class='row',
                                                 type='range',
                                                 min='0',
                                                 max='60',
                                                 step='1',
                                                 value='45'))
                            
          )
          ),
          column(5,
                 tags$h6(class="text-center", "Current Rate"),
                 tags$div(class="map-container-250",
                          tags$div(id="biv-map1")),
                 tags$div(class="row", style="height:6px"),
                 tags$h6(class="text-center", "Acceleration"),
                 tags$div(class="map-container-250",
                          tags$div(id="biv-map2")))
        ),
      ),
      ## PANEL 3 ##############################################################
      # Panel 3
      tags$div(
        class="tab-pane",
        id="about-pane",
        tags$h3("Most counties are small. That doesn't mean they shouldn't have reliable COVID-19 data"),
	      tags$p("Most counties have so much day-to-day variation in reports of new COVID-19 cases that it can be difficult to identify the trends. The COVID-19 NOWcast produces stable trend estimates for every county in the US, even the small ones."),
	      tags$h5("Can I use the COVID-19 NOWcast for ranking counties?"),
	      tags$p("The COVID-19 NOWcast is better as a tool for understanding trends over time and is less apprropriate for ranking or comparing counties. Data reporting is different in each county, which makes it difficult to compare data across counties."),
	      tags$h5("Why are the daily counts different than what I've seen elsewhere?"),
	      tags$p("Most COVID-19 data are obtained from either 1) a county or local health agency, or b) from a state health agency. County reports are more immediate, but they undergo less verification. State reports are more extensivly verified and checked, but this may cause a delay before the data are reported. This delay varies greatly from place to place and week to week,  but can be as great as one week between when a case shows up first in the ounty data and then the state data. Many online data sources publish the state reports. THe NOWcast uses a data source that relies county reports when available because the county data are more timely."),
	      tags$h5("About the authors"),
	      tags$p("The COVID-19 NOWcast data are produced by Nicholas Nagle and Jesse Piburn. Nicholas Nagle is a Professor at the University of Tennessee, Knoxville, who specializes in research on developing data for small places and on the Census Bureau. Jesse Piburn is a Research Scientists in Geographic Data Sciences at Oak Ridge National Laboratory")
      )
    )#close tab-content
  ),
  #tags$div(class='row', style="border: 2px solid black; height: 500px;",
  fluidRow(
    #tags$div(class="col-lg-9", style="border: 2px solid black; ",
    column(7,
      tags$div(id='map-container',
      )
    ), #close col
    column(5,
           fluidRow(style="height:10px;"),
    )
  ), #close row
  tags$script(src="map_simple.js")
  #HTML('<script> $( document ).on("shiny:sessioninitialized", function(event) { Shiny.onInputChange("selected_state", "47");            });</script>'),
               
)

source('myserver.R', local=TRUE)

# Run the application 
shinyApp(ui = ui, server = myserver)

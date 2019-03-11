## ui.R

library(shiny)
library(shinydashboard)
library(data.table)
library(ggmap)
library(leaflet)
library(plotly)
library('RJSONIO')
library('geosphere')
library('purrr')
library(tidyverse)
library(leaflet)
library(geojsonio)
library(tigris)
library(parcoords)
library(GGally)
library(htmltools)
library(fmsb)

dashboardPage(
  
  ## dashboard header
  dashboardHeader( title = "Green Life in NYC" ),
  
  ## dashboard sidebar
  dashboardSidebar(
    sidebarMenu(
      
      ################################################################
      ## Introduction tab side
      ################################################################
      menuItem("Introduction", tabName = "intro"),
      

      
      ################################################################
      ## Maps tab side
      ################################################################
      # create Maps Tab with subitems
      menuItem("Map", tabName = "map"),
      
      
      
      ################################################################
      ## Statistics tab side
      ################################################################
      menuItem("Report",  tabName = "stats",
               menuSubItem('General',
                           tabName = 'general' ),
               menuSubItem('By Community',
                           tabName = 'location' ),
               menuSubItem('Overview',
                           tabName = 'housing' )),
      
      
      
      ################################################################
      ## Datasets tab side
      ################################################################
      # create Data Tab with subitems
      menuItem("Data", tabName = "data",
               menuSubItem('Air Quality',
                           tabName = 'tAirData' ),
               menuSubItem('Community Gardens',
                           tabName = 'tGardenData' ),
               menuSubItem('Citibike station',
                           tabName = 'tBikeData' ),
               menuSubItem('Housing rents',
                           tabName = 'rental' )
               ),
      
      
      ################################################################
      ## Contact tab side
      ################################################################
      # create Data Tab with subitems
      menuItem("Contact us", tabName = "contact")
      
      
    )),
  
  ## dashboard body
  dashboardBody(

    tabItems(
      
      ################################################################
      ## Introduction tab body
      ################################################################
      # Introduction tab content
      tabItem(tabName = "intro",
              
              h2("Welcome", align = "center"),
              
              h4(type="html", " As a result of rapid industrialization, 
                 urbanization and motorization, daily air quality has 
                 become a big environmental issue. One of the most obvious 
                 problems is global warming. Driving cars creates more greenhouse 
                 gases, which contributes to the problem. As a result, crops are yielding
                 less food, glaciers are melting causing the ocean levels to rise, and droughts 
                 are plaguing areas that once had plenty of water. In response to the air pollution 
                 issue, having a green life is important and crucial."),
              h3(""),
              h4("To deal with the air problem, people should all be involved in the \"green\" activities,
                 which help to reduce air pollution. For example, try to choose to ride a bike as a way 
                 of daily commuting instead of driving a car; join the community gardening program to 
                 learn more knowledge about plants and provide more important green space in the city."),
              h3(""),
              h4("Furthermore, people might be also concerned about their living conditions. In other words, 
                 it would be necessary for people to consider air quality when they choose to rent a place 
                 to live in New York City."),
              h3(""),
              h4("Hence, our shiny app will help you:"),
              h3(""),
              
              h4("-	  Combine the rental price and the distribution of air pollution in New York City
                 so you can find a place to live with higher price-performance (air quality) ratio \n"
              ),
              
              tags$h4("-   	Find a location of bike-share stations so you can get involved in dealing 
                      with the air problem and make your own choice on whether riding a bike based on
                      the local air quality \n"),
              tags$h4("-	  Get to community gardens in order to improve air quality, bio-diversity,
                      and also provide more \"green\" in New York City \n"),
              h3(""),
              
              h4("In addition, our app provides all kinds of comparison graphs based on what you
                 require, which would help you to make an easier decision on your living condition."),
              h3(""),
              
              h4("Living green is important, and we want to empower you to do your part. Enjoy our tool
                 and learn how to live an environmentally friendly life. Go ahead and live a green life
                 in New York City!"),
              
              HTML('<p><img src="image_nyc.jpg"/></p >')
              
              
              ),
      
     
      
      ################################################################
      ## Maps tab body
      ################################################################
      
      # Air quality map tab content
      
      
      tabItem(tabName = "map", 
              h2(" Map of Air Quality in New York City"),
              
              sidebarLayout(position = "right", 
                            sidebarPanel(
                              h4("Filter"),
                              checkboxGroupInput("show_icon", label = "Explore your green life",
                                                 choices = c("All","Rentals", "Citibike", "Garden")),
                              
                              selectInput("select_pollutant_type", label = h3("Pollutant Type"), 
                                          
                                          choices = c("All","Fine Particulate Matter (PM2.5)","Black Carbon","Ozone (O3)",                     
                                                               "Nitrogen Dioxide (NO2)","Nitric Oxide (NO)" ), selected = "All"),
                              
                              
                              
                              selectInput("select_CD", label = h3("Community District"), 
                                          
                                          choices = c("All","Financial District (CD1)","Greenwich Village and Soho (CD2)","Lower East Side and Chinatown (CD3)","Clinton and Chelsea (CD4)","Midtown (CD5)","Stuyvesant Town and Turtle Bay (CD6)","Upper West Side (CD7)","Upper East Side (CD8)","Morningside Heights and Hamilton Heights (CD9)","Central Harlem (CD10)","East Harlem (CD11)","Washington Heights and Inwood (CD12)","Mott Haven and Melrose (CD1)","Hunts Point and Longwood (CD2)","Morrisania and Crotona (CD3)","Highbridge and Concourse (CD4)","Fordham and University Heights (CD5)","Belmont and East Tremont (CD6)","Kingsbridge Heights and Bedford (CD7)","Riverdale and Fieldston (CD8)","Parkchester and Soundview (CD9)","Throgs Neck and Co-op City (CD10)","Morris Park and Bronxdale (CD11)","Williamsbridge and Baychester (CD12)","Greenpoint and Williamsburg (CD1)","Fort Greene and Brooklyn Heights (CD2)","Bedford Stuyvesant (CD3)","Bushwick (CD4)","East New York and Starrett City (CD5)","Park Slope and Carroll Gardens (CD6)","Sunset Park (CD7)","Crown Heights and Prospect Heights (CD8)","South Crown Heights and Lefferts Gardens (CD9)","Bay Ridge and Dyker Heights (CD10)","Bensonhurst (CD11)","Borough Park (CD12)","Coney Island (CD13)","Flatbush and Midwood (CD14)","Sheepshead Bay (CD15)","Brownsville (CD16)","East Flatbush (CD17)","Flatlands and Canarsie (CD18)","Long Island City and Astoria (CD1)","Woodside and Sunnyside (CD2)","Jackson Heights (CD3)","Elmhurst and Corona (CD4)","Ridgewood and Maspeth (CD5)","Rego Park and Forest Hills (CD6)","Flushing and Whitestone (CD7)","Hillcrest and Fresh Meadows (CD8)","Kew Gardens and Woodhaven (CD9)","South Ozone Park and Howard Beach (CD10)","Bayside and Little Neck (CD11)","Jamaica and Hollis (CD12)","Queens Village (CD13)","Rockaway and Broad Channel (CD14)","St. George and Stapleton (CD1)","South Beach and Willowbrook (CD2)","Tottenville and Great Kills (CD3)"), selected = "All")
                              
                              
                            ),
                            
                            mainPanel(
                              leafletOutput("airmap", width = "100%", height = 600)
                            )
              )
              
              
      ),
      
      
  
      
      
      
      
      ################################################################
      ## Statistics tab body
      ################################################################
      tabItem(tabName = "general",
              
              h2("Statistical Analysis for Each Air Pollutant"),
              
              uiOutput("uiEda1"),
              sliderInput("bins",
                          "Number of bins:",
                          min = 1,
                          max = 50,
                          value = 22),
              plotOutput("plot1EDA",width = "100%",height=600),
              h2(""),
              textOutput("analysis"),
              tags$style(type="text/css",
                         ".shiny-output-error { visibility: hidden; }",
                         ".shiny-output-error:before { visibility: hidden; }"
              )
              
              
              
              
      ),
      
      tabItem(
             
              tabName = "location",
              
              h2("Analysis for Each Community"),
              uiOutput("uiEda2"),
              uiOutput("uiEda3"),
              h3("Composition of Pollutants:"),
              position = "right",
              tabPanel("Radar Plot", plotOutput("radarplot"))
             # tabPanel("Pie Plot", plotlyOutput("plot2EDA"),position="right"),
             # h3("Nearest Bike Stations:"),
              
              #fluidRow(
                #column(12,
                     #  dataTableOutput('tableBikestations')
               # )
              ),
      
      
      tabItem(tabName = "housing",
              h2(" Exploring plots"),
              
          tabsetPanel(
              tabPanel("Parcoo",
                       fluidRow(
                       h2("Parcoords plot"),
                       parcoordsOutput( "parcoords", width = "100%", height = "600px" )
                       )),
                  
              tabPanel("Charts",
                       fluidRow(
                       h2("Air Pollution Overview of Five Boroughs"),
                       plotOutput("radar5b"),plotOutput("bar5b"))))),
      

 
      ################################################################
      ## Datasets tab body
      ################################################################
      
      ## air quality data tab content
      tabItem( tabName = "tAirData",
               fluidRow(
                 titlePanel('Select what you need'),
                 sidebarLayout(
                   sidebarPanel(
                     
                     checkboxGroupInput('show_vars', 'Columns in air to show:',
                                        choices = c("Unique.Id","indicator_id","geo_type_id","measurement_type_id",
                                                    "internal_id","subtopic_id","name","Measure","geo_type_name",
                                                    "description","geo_entity_id","geo_entity_name","year_description","data_value"),
                                        selected = c("Unique.Id","name","geo_type_name","data_value"))
                     
                     
                     
                   ),
                   mainPanel(
                     #fluidRow(
                     # column(12,
                     dataTableOutput('tableAir')
                   )
                 )
               )
      ),
      
      ## community garden data tab content
      tabItem( tabName = "tGardenData",
               
               fluidRow(
                 column(12,
                        dataTableOutput('tableGarden')
                 )
               )
      ),
      
      ## community bike data tab content
      tabItem( tabName = "tBikeData",
               
               fluidRow(
                 column(12,
                        dataTableOutput('tableBike')
                 )
               )
      ),
      
      ## rentals data
      tabItem(tabName = "rental",
              fluidRow(
                column(12,
                      dataTableOutput('tablerental'))
              )),
      
      
      
      
      
      ################################################################
      ## Contact  tab body
      ################################################################
      # Introduction tab content
      tabItem(tabName = "contact",
              
              h2("Contact us"),
              
              h3( "We are Group 5!"),
            
              h5("Hu, Yiyao yh3076@columbia.edu"),
              h5("Wang, Zixiao zw2513@columbia.edu"),
              h5("Xia, Xin xx2295@columbia.edu")
           
      )
      
    )
))

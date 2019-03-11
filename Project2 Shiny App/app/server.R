## server.R

library(shiny)
library(shinydashboard)
library(data.table)
library(ggmap)
library(plotly)
library(fmsb)
library(RJSONIO)
library(geosphere)
library(purrr)
library(tidyverse)
library(leaflet)
library(geojsonio)
library(tigris)
library(parcoords)
library(GGally)
library(htmltools)


# source auxiliary functions
source( "./helpers.R" )

shinyServer(
  
  function(input, output) 
  {
    
    ################################################################
    ## Reading input data
    ################################################################
    
    ## read all input data
    inputData <- readData()
    
    ## get community gardens data
    gardens <- inputData$gardens
    gardens<- gardens%>%select(Garden.Name,Latitude,Longitude)%>%na.omit()
    
    
    ## get map data
    nycd <- inputData$nycd
    
    ## get bike data
    bike <- inputData$bike
    
    ## get house data
    house <- inputData$house
    ## get air quality data
    air <- inputData$air
    
    # air      <- as.data.table( read.csv( "Air_Quality_new.csv" ) )
    air <- air%>%select(-c(message,X))%>%filter(geo_type_name == "CD")%>%na.omit()  
 
    # get report2 for parcoordinates
    data.report2<- inputData$data.report2
    names(data.report2)[9]="Boroughs"
    data.report2<-data.report2 %>%select(-X)
    Boroughs.order <- data.report2 %>% group_by(Boroughs)%>%summarize(n = n())%>%arrange(n)
    data.report2$Boroughs <- factor(data.report2$Boroughs,levels = Boroughs.order$Boroughs)
    
    
    # data for charts 
    geo5<-inputData$geo5
    colnames(geo5)[1]="Pollution"
    report5geo<-data.frame("geo_entity_name"=geo5[1:5,2],"PM2.5"=geo5[1:5,3],
                           "Black_Carbon"=geo5[6:10,3],"O3"=geo5[11:15,3],"NO2"=geo5[16:20,3],"NO"=geo5[21:25,3])

     
    maxmin <- data.frame(
      PM2.5=c(10,6),
      Black_Carbon=c(1.5, 0.5),
      O3=c(37, 27),
      NO2=c(30, 10),
      NO=c(30,5)
    )
    dat<-rbind(maxmin,report5geo[,-1])  
    
  
    
    
    ## create icon to display in map
    treeIcons <- icons(
      iconUrl = "./www/leaf.png",
      iconWidth = 45, iconHeight = 30,
      iconAnchorX =18, iconAnchorY = 18
    )
    
    bikeIcons <- icons(
      iconUrl = "./www/citiBike.png",
      iconWidth = 45, iconHeight = 30,
      iconAnchorX = 18, iconAnchorY = 18
    )
    
    houseIcons <- icons(
      iconUrl = ifelse(house$X2016 < 1800, "./www/low_rent.png",
                ifelse(house$X2016>= 1800 & house$X2016 <=2000,"./www/medium_rent.png",
                       "./www/high_rent.png")),
      iconWidth = 50, iconHeight = 35,
      iconAnchorX = 18, iconAnchorY =18)
    
    
    
   ## new air quality data for radar plot
    newair<-data.frame(matrix(rep(1,295),59,5))
    newair[,1] <- air[air$name=="Black Carbon",]$data_value
    newair[,2] <- air$data_value[air$name=="Fine Particulate Matter (PM2.5)"]
    newair[,3] <- air$data_value[air$name=="Nitric Oxide (NO)"]
    newair[,4] <- air$data_value[air$name=="Nitrogen Dioxide (NO2)"]
    newair[,5] <- air$data_value[air$name=="Ozone (O3)"]
    colnames(newair) <- c("Black Carbon","Fine Particulate Matter (PM2.5)",
                          "Nitric Oxide (NO)","Nitrogen Dioxide (NO2)","Ozone (O3)")
    rownames(newair) <- air[air$name=="Ozone (O3)",]$geo_entity_name
    

    

    ################################################################
    ## Exploratory Data Analysis Plot
    ################################################################
   
    
    ################################################################
    ## Maps
    ################################################################
    


    ## render air map
    
    output$airmap <-renderLeaflet({
      
      show_map(air_data = air, 
               map_data = nycd,
               house_data = house, 
               bike_data = bike,
               garden_data = gardens,
               air_choice = input$select_pollutant_type,
               CD_choice = input$select_CD,
               icon_choice = input$show_icon,
               treeIcons,
               bikeIcons,
               houseIcons)
    })

    
    
    
    
    
    ################################################################
    ## UI rendered
    ################################################################

 
    
    
    output$uiEda1 <- renderUI({
      
      selectInput( 'eda1Pollut', 'Choose pollutant', 
                   choices = c("ALL","Black Carbon","Fine Particulate Matter (PM2.5)",
                                         "Nitric Oxide (NO)","Nitrogen Dioxide (NO2)","Ozone (O3)"), selected = "ALL")
      
    })
    
    
    
    output$uiEda2 <- renderUI({
      
      selectInput( 'eda2Community', 'Choose Community', 
                   choices = c("ALL", unique(as.character(air$geo_entity_name))), selected = "Midtown (CD5)")
      
    })
    
    output$uiEda3 <- renderUI({
      
      selectInput( 'eda3Community', 'Choose Community', 
                   choices = c("ALL", unique(as.character(air$geo_entity_name))), selected = "Midtown (CD5)")
      
    })
    
    
    ###render histgram
    #output$plot1EDA <- renderPlotly({
      
     # hist_and_density( data = air, type = input$eda1Pollut, BIN = input$bins)
      
    #})
    output$plot1EDA <- renderPlot({
      
      
      if(input$eda1Pollut=="ALL"){
        x <- air$data_value
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        hist(x, breaks = bins, col = "steelblue3", border = 'white', probability = T,
             main = "Density for All Air Quality Index", xlab = "Index (Value)")
        lines(density(x, adjust=2), col="blue", lwd=2, lty = 3)
        lines(density(x), col="green", lwd=2) 
        legend("topright", title = "Density", legend = c("smoothed", "regular"), 
               lty = c(3, 1), col = c("blue", "green"), cex = 0.75)
        
      }
      else {
        x <- air[air$name==input$eda1Pollut,]$data_value
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        hist(x, breaks = bins, col = "steelblue3", border = 'white', probability = T,
             main = paste("Density for", input$eda1Pollut), xlab = "Index (Value)")
        lines(density(x, adjust=2), col="blue", lwd=2, lty = 3) 
        lines(density(x), col="green", lwd=2) 
        legend("topright", title = "Density", legend = c("smoothed", "regular"), 
               lty = c(3, 1), col = c("blue", "green"), cex = 0.75)
      }
      
    })
    ##
    
    output$analysis <- renderText({
    pollutantText( input$eda1Pollut )
    
  })
    
    
    
    ###render radar plot
    output$radarplot <- renderPlot({
      radar( data = newair, community = input$eda2Community, community1 = input$eda3Community)
      
    })
    
    ## render parcoordinates
    output$parcoords = renderParcoords(
      data.frame(data.report2)%>% arrange(Boroughs) %>% 
        parcoords(
          rownames = F 
          , brushMode = "1D-axes"
          , reorderable = T
          , queue = T
          , color = list(
            colorBy = "Boroughs"
            ,colorScale = htmlwidgets::JS("d3.scale.category10()") 
        )
    ))
    
    ## radar5b
      output$radar5b = renderPlot(
      radarchart(dat, axistype=2, plty=1, 
                 pangle=c(10, 45, 120), axislabcol="darkgrey")
        )
    
      
      output$bar5b = renderPlot(
        ggplot(data = geo5)+ 
          geom_col(mapping = aes(x = geo_entity_name, y = data_value, fill = Pollution), alpha = 5/7)+
          scale_fill_manual(values = alpha(c(4,5,6,7,11,2,1)))+xlab("Five Boroughs")+
          ylab("Pollution Value")
    
      )
    
    ################################################################
    ## Datasets
    ################################################################
    
    ## render community gardens datatable
    output$tableGarden <- renderDataTable( gardens )
    
    ## render air quality datatable
    output$tableAir    <- renderDataTable( 
      air[, input$show_vars]
    )
    
    ## render bike station datatable
    output$tableBike <- renderDataTable( bike )
    
    ## rentals datatable
    output$tablerental<- renderDataTable(house)
  }
  
)


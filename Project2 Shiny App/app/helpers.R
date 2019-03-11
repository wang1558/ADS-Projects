## helpers.R


## readData function
##
readData <- function(){
    
  
  list( gardens = as.data.table( read.csv( "./data/NYC_Greenthumb_Community_Gardens.csv" ) ),
        air     = as.data.table( read.csv( "./data/Air_Quality_2016_Data.csv" ) ), 
        bike    = as.data.table( read.csv( "./data/Citi_bike_Address_update.csv")),
        nycd    = geojsonio::geojson_read("./data/CD.json",what = "sp"),
        house   = as.data.table(read.csv("./data/Rental_Price.csv")),
        data.report2 =  read.csv("./data/data.report2.csv"),
        geo5=read.csv("./data/geo_5.csv")
        
        )
}


#########EDA--Histogram Plots to visualize each pollutant:
hist_and_density<-function(data,type,BIN){
  if(type=="ALL"){
    x <- data$data_value
    fit <- density(x)
    
    #Histogram and Density plot of overall pollutants
    plt<-plot_ly(x = x) %>% 
      add_histogram(name="Histogram") %>% 
      add_lines(x = fit$x, y = fit$y, fill = "tozeroy", yaxis = "y2",name="Density") %>% 
      layout(title = 'Level of All Pollutants Histogram',yaxis2 = list(overlaying = "y", side = "right"))
  }
  else {
    x <- data[data$name==type,]$data_value
    fit <- density(x)
    #Histogram and Density plot of each pollutant
    plt<-plot_ly(x = x) %>% 
      add_histogram(name="Histogram") %>% 
      add_lines(x = fit$x, y = fit$y, fill = "tozeroy", yaxis = "y2",name="Density") %>% 
      layout(title = paste("Level of", type, "Histogram",sep=" "),yaxis2 = list(overlaying = "y", side = "right"))
  }
  return(plt)
}



#########EDA--Radar Plot to visualize different pollutants in each Community:
####
radar<-function(data,community,community1){
  if(community=="ALL" | community1=="ALL"){
    p <- "Change the region for radar plots."
  }
  else if (community!=community1) {
    newdata <- data[rownames(data)==community,]
    newdata1 <- data[rownames(data)==community1,]
    max<-apply(data,2,max)
    dt <- data.frame(rbind(max,rep(0,5),newdata,newdata1))
    colnames(dt) <- c("BC","PM2.5","NO","NO2","03")
    p <- radarchart(dt,axistype = 2,
                    pcol=c(4,2) , pfcol=c(4,2) ,
                    #custom the grid
                    cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,100,20), cglwd=0.8, plty = c(1,1), pdensity=c(5,10),pangle=c(c(10),c(45)),
                    #custom labels
                    vlcex=0.8,
                    title = paste(community, "vs", community1))
  }
  else{
    newdata <- data[rownames(data)==community,]
    max<-apply(data,2,max)
    dt <- data.frame(rbind(max,rep(0,5),newdata))
    colnames(dt) <- c("BC","PM2.5","NO","NO2","03")
    p <- radarchart(dt,axistype = 2,
                    pcol=4, pfcol=4,
                    #custom the grid
                    cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,100,20), cglwd=0.8, plty = 1, pdensity=5,pangle=10,
                    #custom labels
                    vlcex=0.8,
                    title = paste("Radar chart for", community1))
    
  }
  return(p)
}

#########EDA--Map Plot to visualize quantile levels of each pollutant in each community:

show_map<-function(air_data,map_data,house_data,bike_data,
                   garden_data,air_choice,CD_choice,icon_choice,
                   treeIcons, bikeIcons,houseIcons){

  #Pollutant type selection
  if (air_choice == "All") {
   air1 <- air_data
  
  #Get community District
   CD <- air1 %>% select(geo_entity_id,geo_entity_name)%>%unique()
   air1 <- air1%>%group_by(geo_entity_id)%>%summarize(data_value = sum(data_value))%>%inner_join(CD)
  }
  else {
    air1 <- air_data[air_data$name==air_choice,]
  }
  
  #Define air quality level for measurement data
  air1$level <- 1+rank(air1$data_value,ties.method="random")%/%(length(air1$data_value)/4)
 
  #Define color for each air quality level
  air1$color <- rep(1,dim(air1)[1])
  for(i in 1:length(air1$level)){
    air1$color[i] <- ifelse(air1$level[i]==1,"green",ifelse(air1$level[i]==2,"yellow",
                     ifelse(air1$level[i]==3,"orange",ifelse(air1$level[i]==4,"red","magenta4"))))} 

  #Community district  selection
  if (CD_choice!="All" ) {
    air1 <- air1[air1$geo_entity_name==CD_choice,]
  }
  
  #Joining air data with map data
  nycd <- map_data
  mapdf <- geo_join(nycd, air1, "id", "geo_entity_id")
  
  #Set color for leaflet
  pal <- colorFactor(palette = c("green", "yellow", "orange","red","magenta4"), 
                     levels = c("1", "2", "3","4","5"))
  
  #leaflet
  m = leaflet(data = mapdf,options = leafletOptions(minZoom = 8, dragging = TRUE)) %>%
    addProviderTiles("Esri") %>% 
    addPolygons(color = ~pal(mapdf@data$level),stroke = FALSE,fillOpacity = 0.4)%>% 
    setView(-73.98, 40.75, zoom =10)%>%
    setMaxBounds(lng1 = -73.98 + .7,
                 lat1 = 40.75 + .7,
                 lng2 = -73.98 - .7,
                 lat2 = 40.75 - .7)
  
  
  #Set color for leaflet legend
  Leg_pal <- colorFactor(palette = c("green", "yellow", "orange","red","magenta4"),
                         levels = c("Low", "Below Medium","Medium", "Above Medium","High"))
  
  #leaflet with legend
  m = m %>%addLegend(colors = c("chartreuse", "yellow", "orange","red","magenta"),
                     labels=c("Low", "Below Medium","Medium", "Above Medium","High"),
                     opacity = 0.8, title = "Pollutant Level", position = "topright")
  
  
  #Icon selection

  if(is.null(icon_choice)==TRUE | length(icon_choice)>1){return(m)}
  
  else if (icon_choice =="Rentals") {
  m = m %>%addMarkers(lng = house_data$lon,lat = house_data$lat,
                      popup=paste("Rental Price:",house_data$markers,"<br>","Community:",house_data$Community.District),
                      
                      icon = houseIcons,clusterOptions = markerClusterOptions())
  
  }
  else if (icon_choice == "Citibike") {
  m = m %>%addMarkers(lng = bike_data$longitude,lat = bike_data$latitude, 
                      label =as.character(bike_data$stationName),
                      labelOptions = labelOptions(noHide = F,textsize = "15px",direction = "top"),
                      icon = bikeIcons,clusterOptions = markerClusterOptions())
  }
  
  else if (icon_choice == "Garden") {
    m = m %>%
      addMarkers(lng = garden_data$Longitude,lat = garden_data$Latitude, 
                 label =as.character(garden_data$Garden.Name),
                 labelOptions = labelOptions(noHide = F,textsize = "15px",direction = "top"),
                 icon =treeIcons,clusterOptions = markerClusterOptions())
    
    
  }
  
  else{
  m = m %>%addMarkers(lng = garden_data$Longitude,lat = garden_data$Latitude, 
                      label =as.character(garden_data$Garden.Name),
                      labelOptions = labelOptions(noHide = F,textsize = "15px",direction = "top"),
                      icon =treeIcons,clusterOptions = markerClusterOptions())%>%
    addMarkers(lng = house_data$lon,lat = house_data$lat,
               popup=paste("Rental Price:",house_data$markers,"<br>","Community:",house_data$Community.District),
               icon = houseIcons,clusterOptions = markerClusterOptions())%>%
    addMarkers(lng = bike_data$longitude,lat = bike_data$latitude,
               label =as.character(bike_data$stationName),
               labelOptions = labelOptions(noHide = F,textsize = "15px",direction = "top"),
               icon = bikeIcons,clusterOptions = markerClusterOptions())
  }
  
 return(m)

}

##

pollutantText <- function( pollutant ){
  
  if( pollutant == "Nitrogen Dioxide (NO2)" ){
    "Nitrogen Dioxide is an immediately dangerous pollutant. The EPA 
    has tied chronic exposure to nitrogen dioxide as causing lung irritation and eye irritation.
    Often, exposure to nitrogen dioxide from an indoor source, like a stove, is enough to send people 
    to the emergency room!"
    
  }
  
  else if( pollutant == "Ozone (O3)"){
    
    "Ozone in the Earth`s stratosphere absorbs radiation from the sun, and keeps the heat from 
    reaching our lower atmosphere. But ozone at low altitudes acts as a greenhouse gas, working to 
    raise global temperature by absorbing heat in the lower atmosphere."
    
  } 
  
  else if( pollutant =="Nitric Oxide (NO)"){
    " Nitric oxide reacts with oxygen to contribute to the depletion of the ozone layer, 
      exacerbating the effects caused by the increase in greenhouse gasses. Nitric oxide reacts with
      the oxygen in the atmosphere to create nitric dioxide, stripping away oxygen from the atmosphere. "
    
  }
  else if( pollutant == "Black Carbon"){
    "Chemically, black carbon (BC) is a component of fine particulate matter (PM2.5). Black carbon consists of pure carbon in several linked forms. It is formed through the incomplete combustion of fossil fuels, biofuel, and biomass, and is emitted in both anthropogenic and naturally occurring soot. Black carbon causes human morbidity and premature mortality."
  }
  
  else if (pollutant == "Fine Particulate Matter (PM2.5)"){
    "Fine particulate matter is composed of tiny aerosol particles that are 2.5 micrometers 
    or smaller in size. The particulates typically are created by power plants, factories, and in part
    from automobiles. This pollutant, rather than indirectly causing weather changes, poses an immediate 
     problem for human health. The EPA has linked exposure to FPM with increased chance for asthma, heart 
     attack, and difficulty breathing. Not to mention that this pollutant is responsible for the haze you 
    can see over the city on certain mornings. "
      
  }
  else{
    ""
  }
  
}
  

#####

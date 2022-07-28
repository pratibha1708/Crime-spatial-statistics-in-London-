# To run this code, set the work directory to folder containing the provided data.
# setwd('C:/Users/Lenovo/Documents/Report')
# setwd('C:/Users/offne/Documents/GitHub/CEGE0097_Crime_Spatial_Analysis')


# Load Packages
library(tmap)
library(ggplot2)
library(sp)
library(rgdal)
library(tidyverse)
library(leaflet)
library(spatialEco)
library(dplyr)

#### 1. LOAD DATA ####
# Open csv files
crime <- read.csv(file='Data/2016-06-metropolitan-street.csv', fileEncoding="UTF-8-BOM")

# Open shape files
proj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0" #set projections
ward <- readOGR(dsn="Data/London_Shapefiles/London_Ward.shp")
ward <- spTransform(ward, CRS(proj))
borough <- readOGR(dsn="Data/London_Shapefiles/London_Borough_Excluding_MHW.shp")
borough <- spTransform(borough, CRS(proj))
names(borough@data)[1] <- "DISTRICT" # change name of spatial delineation (col1) to match ward


#### 2. CLEAN & AGGREGATE DATA ####
# Check missing values
sapply(crime, function(x) sum(is.na(x)))
sapply(ss, function(x) sum(is.na(x)))
sapply(pp, function(x) sum(is.na(x)))
sapply(borough@data, function(x) sum(is.na(x)))
sapply(ward@data, function(x) sum(is.na(x)))

# Drop Columns where all instances are missing OR irrelevant 
crime <- subset (crime, select = -c(Crime.ID, Context, Reported.by, Falls.within, Location, LSOA.code, LSOA.name, Last.outcome.category))

# Drop Values with NA (831 in lat/long)
crime <- na.omit(crime)

# Add unique id's
crime$ID <- seq_along(crime[,1])

#### 2c. Crime ####
#_______________________________________________________________________________
# NOTE: Re-code all relevant categorical variables prior to aggregation
#_______________________________________________________________________________

# Create Point data from coordinate datasets
xy <- crime[,c('Longitude', 'Latitude')]
crime <- SpatialPointsDataFrame(coords= xy, data = crime, proj4string = CRS(proj))

# Join Polygon & Point information
crime <- point.in.poly(crime, ward)
# Remove point outside of polygon (NaN GSS_Code)
sapply(crime@data, function(x) sum(is.na(x)))
crime@data <- na.omit(crime@data)

#_______________________________________________________________________________
# Aggregate point data by ward NAME (COUNT points): Specific crime type will 
# need to be counted and examined separately, and this will be determined by 
# non spatial EDA
#_______________________________________________________________________________
crime_ag <- aggregate(crime@data$NAME, list(crime@data$NAME), length)
names(crime_ag) <- c('NAME', 'crime_occurance')

# Create polygon data from point count
crime_ward <- merge(ward, crime_ag, by='NAME') 

# There is no police perception data for city of London, so drop these points 
sapply(crime@data, function(x) sum(is.na(x)))

crime@data <- na.omit(crime@data)


#### 3. Visualize Data ####

# POINT DATA
crimemap <- leaflet(crime) %>% 
  addProviderTiles("CartoDB.Positron") %>%
  setView(-0.1257400, 51.5085300, zoom = 10) %>% 
  addPolygons(data=ward,
              col = 'dodgerblue',
              stroke = FALSE, 
              fillOpacity = 0.3, 
              smoothFactor = 0.5) %>% 
  addCircleMarkers(~Longitude, ~Latitude,
                   weight = 3,
                   radius=1,
                   color="#ffa500")
crimemap


# POLYGON DATA
# https://www.r-graph-gallery.com/183-choropleth-map-with-leaflet.html

# Choropleth maps
crime_choro <- leaflet(crime_ward) %>% 
  addProviderTiles("CartoDB.Positron")  %>% 
  setView(-0.1257400, 51.5085300, zoom = 10) %>%
  addPolygons( stroke = FALSE, fillOpacity = 0.7, smoothFactor = 0.5, color = ~colorQuantile("YlOrRd", crime_occurance)(crime_occurance) )
crime_choro




#### 4. NON-SPATIAL EDA ####

# Look at Crime data
colnames(crime@data)
head(crime@data)
summary(crime@data)
for (i in colnames(crime@data)){
  print(paste(i, sd(crime@data[[i]])))
}


#### 4b. Categorical Variables ####


# Examine categorical variables - NEEDS CATEGORICAL AGGREGATION!!
# Crime type: (25% Anti-social behaviour) (20% Violence and sexual offenSe)
x <- prop.table(table(crime@data$Crime.type))
par(fig=c(0,1,0.3,1), new=FALSE)
barplot(x[order(x, decreasing = TRUE)], ylab = "Frecuency (%)", las=2)

ggplot(data=crime@data, aes(x=Crime.type, y=mean_pp)) + 
  geom_boxplot()+
  coord_cartesian(ylim = quantile(crime@data$mean_pp, c(0, 0.97)))


#### ####

# install.packages("janitor")

# SPPA
library(spatstat)
library(ggplot2)
library(knitr)

# splitting the data according to crime type-a. anti social beh

library(sf)
library(readxl)
library(janitor)
library(tmap)
library(dplyr)
library(sp)
library(spdep)

crime_type <- split(crime@data, crime@data$Crime.type)
crime_type[[1]]

anti_beh <- crime_type[[1]]
anti_beh   # has district
plot(borough)  # has district


# Create Point data from coordinate datasets
ab <- anti_beh[,c('Longitude', 'Latitude')]
anti_social <- SpatialPointsDataFrame(coords= ab, data = anti_beh, proj4string = CRS(proj))
plot(anti_social)


# Join Polygon & Point information
anti_social_behaviour <- point.in.poly(anti_social, borough)

#Aggregate point data by ward NAME (COUNT points): Specific crime type will 
# need to be counted and examined separately, and this will be determined by 
# non spatial EDA

asb_ag <- aggregate(anti_social@data$DISTRICT, list(anti_social@data$DISTRICT), length)
names(asb_ag) <- c('DISTRICT', 'crime_occurance')
#names(asb_ag)
# Create polygon data from point count
asb_ward <- merge(borough, asb_ag, by='DISTRICT') 
asb_ward

# POINT DATA
asbmap <- leaflet(anti_social) %>% 
  addProviderTiles("CartoDB.Positron") %>%
  setView(-0.1257400, 51.5085300, zoom = 10) %>% 
  addPolygons(data=borough,
              col = 'dodgerblue',
              stroke = FALSE, 
              fillOpacity = 0.3, 
              smoothFactor = 0.5) %>% 
  addCircleMarkers(~Longitude, ~Latitude,
                   weight = 3,
                   radius=1,
                   color="#ffa500")
asbmap

# POLYGON DATA
# https://www.r-graph-gallery.com/183-choropleth-map-with-leaflet.html

# Choropleth maps
asb_choro <- leaflet(asb_ward) %>% 
  addProviderTiles("CartoDB.Positron")  %>% 
  setView(-0.1257400, 51.5085300, zoom = 10) %>%
  addPolygons( stroke = FALSE, fillOpacity = 0.7, smoothFactor = 0.5, color = ~colorQuantile("YlOrRd", crime_occurance)(crime_occurance) )
asb_choro

# from tutorial
tm_shape(asb_ward) + tm_polygons(col="crime_occurance", palette="YlOrRd", style="jenks") +
  tm_shape(anti_social_behaviour) + tm_dots( style="jenks") + tm_layout(legend.outside = TRUE, legend.text.size = 1)

library(spdep)
library(knitr)
nb <- poly2nb(asb_ward)
W <- nb2mat(nb, style="W")
colnames(W) <- rownames(W)
kable(W[1:10,1:10], digits=3, caption="First 10 rows and columns of W for London wards", booktabs=T)

# Add the row IDs as a column in the data matrix to plot using tmap
asb_ward$rowID <- rownames(asb_ward@data)

# plot the first 10 polygons in medianhpward and label with ID
tm_shape(asb_ward[1:33,])+tm_polygons()+tm_text(text="rowID")


nbrs <- which(W["4",]>0) # Find column indices of neighbours of ward 4 (result of which(W[,"4"]>0) would be identical)
tm_shape(asb_ward[nbrs,])+tm_polygons()+tm_text(text="rowID")

Wl <- nb2listw(nb) # a listw object is a weights list for use in autocorrelation measures.
moran(asb_ward$crime_occurance, Wl, n=length(Wl$neighbours), S0=Szero(Wl))
asb_ward$crime_occurance








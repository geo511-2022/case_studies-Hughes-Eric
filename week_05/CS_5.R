library(spData)
library(sf)
library(tidyverse)
library(units) 

#data used
data(world)  
data(us_states)

#crs
albers="+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

#convert to albers crs
worldData <- st_transform(world, crs = st_crs(albers))

#Canada prep

canada <- worldData %>% filter(name_long=="Canada")

canada <- st_buffer(canada, dist = 10000)

#NY prep

us <- st_transform(us_states, crs = st_crs(albers))

NY <- us %>% filter(NAME == "New York")

#combine Canada and NY

borderOb <- st_intersection(NY, canada)
ggplot(NY) +
  geom_sf() +
  geom_sf(data=borderOb, aes(fill = "red"))+
  labs(title = "New York Land within 10km") +
  theme(legend.position = "none", plot.title = element_text(size=22)) 

#Calculate area
  
area <- st_area(borderOb)
set_units(area,km^2)


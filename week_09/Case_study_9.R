library(sf)
library(tidyverse)
library(ggmap)
library(rnoaa)
library(spData)
data(world)
data(us_states)

# Download zipped data from noaa with storm track information
dataurl="https://www.ncei.noaa.gov/data/international-best-track-archive-for-climate-stewardship-ibtracs/v04r00/access/shapefile/IBTrACS.NA.list.v04r00.points.zip"

tdir=tempdir()
download.file(dataurl,destfile=file.path(tdir,"temp.zip"))
unzip(file.path(tdir,"temp.zip"),exdir = tdir)
list.files(tdir)
storm_data <- read_sf(list.files(tdir,pattern=".shp",full.names = T))

storm_data_1950_present = filter(storm_data, SEASON >= 1950) %>% mutate_if(is.numeric, function(x) ifelse(x==-999.0,NA,x)) %>% mutate(decade=(floor(year/10)*10)) 


region <- st_bbox(storm_data_1950_present)                                                 

ggplot(storm_data_1950_present) + facet_wrap(~decade) + stat_bin2d(data=storm_data_1950_present, aes(y=st_coordinates(storm_data_1950_present)[,2], x=st_coordinates(storm_data_1950_present)[,1]),bins=100) +
  scale_fill_distiller(palette="YlOrRd", trans="log", direction=-1, breaks = c(1,10,100,1000)) + coord_sf(ylim=region[c(2,4)], xlim=region[c(1,3)])

#Step 4

x = st_transform(us_states, 4326) %>% select(state=NAME)
storm_states <- st_join(storm_data_1950_present, x, join = st_intersects,left = F) %>% group_by(state) %>% 
  summarize(storms=length(unique(NAME))) %>% arrange(desc(storms)) %>% slice(1:5)

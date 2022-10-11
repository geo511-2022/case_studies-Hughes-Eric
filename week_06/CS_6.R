library(raster)
library(sp)
library(spData)
library(tidyverse)
library(sf)
library(ncdf4)
download.file("https://crudata.uea.ac.uk/cru/data/temperature/absolute.nc","absolute.nc",method = "curl")


tmean=raster("absolute.nc")

#Step 1
world_remove_ant <- world %>% filter(continent != "Antarctica")
world_sp <- as(world_remove_ant,"Spatial")

#Step 2
plot(tmean)
names(tmean) <- "tmean"

#Step 3
x <- raster::extract(tmean, world_sp,fun=max,na.rm=T, small=T, sp=T)
tmax_country <- st_as_sf(x)

#Step 4
ggplot(tmax_country, aes(fill =tmean )) + geom_sf()+scale_fill_viridis_c(name="Annual\nMaximum\nTemperature (C)") +
  theme(legend.position = 'bottom')
                                                     
hottest_country <- tmax_country %>%
  group_by(continent) %>%
  top_n(1, tmean) %>%
  select(name_long, continent, tmean) %>%
  st_set_geometry(NULL) %>%
  arrange(desc(tmean))

hottest_country
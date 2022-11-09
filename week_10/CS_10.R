library(raster)
library(rasterVis)
library(rgdal)
library(ggmap)
library(tidyverse)
library(knitr)

# New Packages
library(ncdf4) # to import data from netcdf format


# Create afolder to hold the downloaded data
dir.create("data",showWarnings = F) #create a folder to hold the data

lulc_url="https://github.com/adammwilson/DataScienceData/blob/master/inst/extdata/appeears/MCD12Q1.051_aid0001.nc?raw=true"
lst_url="https://github.com/adammwilson/DataScienceData/blob/master/inst/extdata/appeears/MOD11A2.006_aid0001.nc?raw=true"

# download them
download.file(lulc_url,destfile="data/MCD12Q1.051_aid0001.nc", mode="wb")
download.file(lst_url,destfile="data/MOD11A2.006_aid0001.nc", mode="wb")
lulc=stack("data/MCD12Q1.051_aid0001.nc",varname="Land_Cover_Type_1")
lst=stack("data/MOD11A2.006_aid0001.nc",varname="LST_Day_1km")
plot(lulc)
lulc=lulc[[13]]
plot(lulc)


Land_Cover_Type_1 = c(
  Water = 0, 
  `Evergreen Needleleaf forest` = 1, 
  `Evergreen Broadleaf forest` = 2,
  `Deciduous Needleleaf forest` = 3, 
  `Deciduous Broadleaf forest` = 4,
  `Mixed forest` = 5, 
  `Closed shrublands` = 6,
  `Open shrublands` = 7,
  `Woody savannas` = 8, 
  Savannas = 9,
  Grasslands = 10,
  `Permanent wetlands` = 11, 
  Croplands = 12,
  `Urban & built-up` = 13,
  `Cropland/Natural vegetation mosaic` = 14, 
  `Snow & ice` = 15,
  `Barren/Sparsely vegetated` = 16, 
  Unclassified = 254,
  NoDataFill = 255)

lcd=data.frame(
  ID=Land_Cover_Type_1,
  landcover=names(Land_Cover_Type_1),
  col=c("#000080","#008000","#00FF00", "#99CC00","#99FF99", "#339966", "#993366", "#FFCC99", "#CCFFCC", "#FFCC00", "#FF9900", "#006699", "#FFFF00", "#FF0000", "#999966", "#FFFFFF", "#808080", "#000000", "#000000"),
  stringsAsFactors = F)
# colors from https://lpdaac.usgs.gov/about/news_archive/modisterra_land_cover_types_yearly_l3_global_005deg_cmg_mod12c1
kable(head(lcd))


# convert to raster (easy)
lulc=as.factor(lulc)

# update the RAT with a left join
levels(lulc)=left_join(levels(lulc)[[1]],lcd)


offs(lst)=-273.15
plot(lst[[1:10]])

tdates=names(lst)%>%
  sub(pattern="X",replacement="")%>%
  as.Date("%Y.%m.%d")

names(lst)=1:nlayers(lst)
lst=setZ(lst,tdates)

# PART 1 
lw = SpatialPoints(data.frame(x= -78.791547,y=43.007211))
crs(lw) <- projection("+proj=longlat")
lw %>%
  spTransform(crs(lulc))
lst_trans <- t(raster::extract(lst,lw,buffer=1000,fun=mean,na.rm=T) )
step5 <- data.frame(getZ(lst), lst_trans)
colnames(step5) <- c("date", "value") 
graphics.off()
ggplot(step5, aes(date, value))+
  geom_point()+
  geom_smooth(n = 200, span = 0.05) +
  labs(x = "Date", y = "Monthly Mean Land Surface Temperatures")

# PART2
tmonth=as.numeric(format(getZ(lst),'%m'))
extract.df$tmonth=tmonth
lst_month=stackApply(lst,indices=tmonth,fun=mean)
names(lst_month)=month.name
lst_month@data@names
gplot(lst_month)+
  geom_raster(aes(fill = value))+
  facet_wrap(~ variable)+
  scale_fill_gradient(low='blue',high='red')+
  labs(x = "X", y = "Y")+
  theme(axis.text.x=element_blank(),axis.text.y=element_blank())



cellStats(lst_month, mean) %>% 
  as.data.frame() %>% 
  rename(Mean = ".") %>% 
  kable()


#PART 3 
lulc2 <- resample(lulc, lst, method="ngb")
lcds1=cbind.data.frame(
  values(lst_month),
  ID=values(lulc2[[1]]))%>%
  na.omit() %>%
  gather(key='month',value='value',-ID) %>%
  mutate(ID=as.numeric(ID)) %>%
  mutate(month=factor(month,levels=month.name,ordered=T)) %>%
  inner_join(lcd) %>%
  filter(landcover%in%c("Urban & Built-up","Deciduous Broadleaf Forest"))
ggplot(lcds1)+
  geom_point(aes(month,value))+
  theme_bw()+
  facet_wrap(~landcover)+
  labs(y = "Monthly Mean Land Surface Temperature (C)")+
  theme(axis.title.x=element_blank(),axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  

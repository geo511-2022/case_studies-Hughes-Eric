library(tidyverse)

# define the link to the data - you can try this in your browser too.  Note that the URL ends in .txt.
buff="https://data.giss.nasa.gov/tmp/gistemp/STATIONS/tmp_USW00014733_14_0_1/station.txt"

#the next line tells the NASA site to create the temporary file
httr::GET("https://data.giss.nasa.gov/cgi-bin/gistemp/stdata_show_v4.cgi?id=USW00014733&ds=14&dt=1")

# the next lines download the data
buff_temp=read_table(buff,
                     skip=3, #skip the first line which has column names
                     na="999.90", # tell R that 999.90 means missing in this dataset
                     col_names = c("YEAR","JAN","FEB","MAR", # define column names 
                                   "APR","MAY","JUN","JUL",  
                                   "AUG","SEP","OCT","NOV",  
                                   "DEC","DJF","MAM","JJA",  
                                   "SON","metANN"))

buff_plot <- ggplot(buff_temp, aes(YEAR,JJA)) + geom_line( colour = 'blue', size = 1.5) + geom_smooth(colour = 'red', size = 3) +
  ylab("Average Summer Temperatures (C)") + 
  labs(title = 'Average Summer Temperatures (C) in Buffalo,NY \n Summer months include June, July, and August \n Data from Global Historical Climate Network') + 
  theme(plot.title = element_text(hjust = 0.5, size = 20)) + theme(axis.title = element_text(size = 20))    

ggsave("CS_2.png")
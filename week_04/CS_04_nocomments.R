library(tidyverse)
library(nycflights13)

farthestDist <- flights %>%
  arrange(desc(distance)) %>%
  slice_head(n=1) %>%
  left_join(airports, by = c("dest" = "faa"))

view(farthestDist)

farthest_airport <- farthestDist %>% select(name) 

farthest_airport <- as.character(farthest_airport)


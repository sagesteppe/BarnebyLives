library(tidyverse)
library(sf)
library(BarnebyLives)

sites <- data.frame(
  name = c('area52', 'chill'),
  latitude_dd = c(38.0697, 38.079558 ),
  longitude_dd = c(-116.9984, -117.010688)
) %>% 
  st_as_sf(coords = c('longitude_dd', 'latitude_dd'), crs = 4326, remove = F)
# gather results from API


SoS_gkey = Sys.getenv("Sos_gkey")
test_gq <- directions_grabber(sites, api_key = SoS_gkey)

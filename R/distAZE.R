#' gather distance and azimuth from collection to GNIS named place
#'
#' Help provide some simple context between the building and the
#' @param x an sf/tibble/dataframe of locations with associated nearest locality data
#' @param path path to gnis_places
distAZE <- function(x, path){

  locality <- sf::st_drop_geometry(x)
  locality <- locality[1, 'Locality']

  focal <- gnis_places[grep(locality, gnis_places$NAME), ]
  if(nrow(focal) > 1){
    union_loc <- sf::st_union(x) |> sf::st_point_on_surface()
    focal <- focal[sf::st_nearest_feature(union_loc, focal),]
  }

  location_from <- sf::st_centroid(focal)
  location_from <- sf::st_transform(location_from, 5070)
  x_planar <- sf::st_transform(x, 5070)
  distances <- sf::st_distance(location_from, x_planar, which = 'Euclidean')

  azy <- nngeo::st_azimuth(
    location_from,
    x_planar
  )

  distances <- data.frame(
    sf::st_drop_geometry(x),
    Distance = round(as.numeric(distances / 1609.34), 1),
    Azimuth = round(as.numeric(azy), 0),
    geometry = x[,'geometry']
  )

}


library(BarnebyLives)
ce <- collection_examples |>
  sf::st_as_sf(coords = c('longitude_dd', 'latitude_dd'), crs = 4326) %>%
  mutate(UNIQUEID  = 'RCB12')
d1 <- ce[1,]

p2geo <- '/media/steppe/hdd/Barneby_Lives-dev/geodata'

d1 <- physical_grabber(d1, path = p2geo)

distAZE(d1, path = p2geo)

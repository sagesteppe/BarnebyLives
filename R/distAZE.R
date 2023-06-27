#' gather distance and azimuth from collection to GNIS named place
#'
#' Help provide some simple context between the building and the 
#' @param x an sf/tibble/dataframe of locations with associated nearest locality data
#' @param places_data an sf/tibble/dataframe which contains coordinates for the locations in the data
distAZE <- function(x, places_data){
  
  locality <- sf::st_drop_geometry(x)
  locality <- locality[1, 'Locality']
  
  focal <- places_data[grep(locality, places_data$NAME), ]
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
    st_drop_geometry(x),
    Distance = round(as.numeric(distances / 1609.34), 1),
    Azimuth = round(as.numeric(azy), 0),
    geometry = x[,'geometry']
  )
  
}

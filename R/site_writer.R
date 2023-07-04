#' gather distance and azimuth from shop to center of town
#'
#' Help provide some simple context between the building and the
#' @param x an sf/tibble/dataframe of locations with associated nearest locality data
#' @param path path to gnis_places
#' @examples
#' library(sf)
#' sites <- data.frame(
#'  longitude_dd = runif(15, min = -120, max = -100),
#'  latitude_dd = runif(15, min = 35, max = 48)
#'  ) |>
#'  sf::st_as_sf(coords = c('longitude_dd', 'latitude_dd'), crs = 4326)
#'
#' head(sites)
#' distaze_results <- distAZE(sites) # takes some time
#' head(distaze_results)
#' @export
site_writer <- function(x){


  nf <- sf::st_nearest_feature(sites, gnis_places)

  sites <- x |>
   dplyr::mutate(sf::st_drop_geometry(gnis_places[nf, 'ID']),
                 .before = geometry)

  locality <- sf::st_drop_geometry(sites)
  locality <- locality[1, 'ID']

  focal <- gnis_places[grep(locality, gnis_places$ID), ]
  location_from <- sf::st_centroid(focal)

  location_from <- sf::st_transform(location_from, 5070)
  x_planar <- sf::st_transform(x, 5070)
  distances <- sf::st_distance(location_from, x_planar, which = 'Euclidean')
  place <- data.frame('Place' =  st_drop_geometry(gnis_places[x$ID, 'fetr_nm']))

  azy <- nngeo::st_azimuth(
    location_from,
    x_planar
  )

  distances <- data.frame(
    sf::st_drop_geometry(x),
    Distance = round(as.numeric(distances / 1609.34), -1),
    Azimuth = round(as.numeric(azy), 0),
    Place = place
  )  |>
    dplyr::mutate(Site = if_else(
      Distance < 100, paste0('At ', fetr_nm, '.'),
      paste0(Distance, 'm', ' at ', format_degree(Azimuth), ' from ', fetr_nm, '.')),
      Site = stringr::str_replace(Site, '\\..$', '.')) |>
    dplyr::select(-any_of(c('Distance', 'Azimuth', 'Place', 'ID', 'fetr_nm')))

  out <- dplyr::bind_cols(x, distances) |>
    dplyr::relocate(Site, .before = geometry) |>
    dplyr::select(-any_of(c('ID')))

}

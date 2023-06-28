
#' identify a populated place near a collection and get directions from there
#'
#' This function identifies the closest populated place, and makes a google API call
#' via the 'googleway' package to get directions from it to the collection site.
#' @param x an sf/tibble/dataframe of locations
#' @param api_key a google developer api key for use with googleway
#' @examples
#' SoS_gkey = Sys.getenv("Sos_gkey") # import the key saved in the system environment
#' @export
get_gooogle_directions <- function(x, api_key){

  # identify unique sites
  sites <- split(x, f = list(x$latitude_dd, x$longitude_dd), drop=TRUE)
  sites <- lapply(sites,  '[' , 1,)

  # extract the coordinates to serve as the DESTINATION
  coords <- lapply(sites, '[', c( 'latitude_dd', 'longitude_dd'))
  coords <- lapply(coords, st_drop_geometry)
  coords <- do.call(rbind, coords)
  coords <- paste(coords$latitude_dd, coords$longitude_dd,  sep = ", ")

  # identify the ORIGIN
  load('../data/places.rda')

  sites <- dplyr::bind_rows(sites)
  origin <- places[ sf::st_nearest_feature(sites, places), c('CITY', 'NAME')] |>
    sf::st_drop_geometry()
  origin <- paste0(origin$CITY, ', ', origin$NAME)

  rm(places)

  # run query
  directions <- Map(f = googleway::google_directions, origin = origin,
                          destination = coords, key = api_key,
                          mode = "driving", simplify = TRUE)

  # rename output to reflect either ORIGIN-SITE_NAME, ORIGIN_DEST_COORDS
  names(directions) <- paste0(sites$Site_name, '-', origin )

  return(directions)

}


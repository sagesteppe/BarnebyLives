#' identify a populated place near a collection and get directions from there
#'
#' This function identifies the closest populated place, and makes a google API call
#' via the 'googleway' package to get directions from it to the collection site.
#' This function operates entirely within 'directions_grabber'
#' @param x an sf/tibble/dataframe of locations
#' @param api_key a google developer api key for use with googleway
#' @examples
#' SoS_gkey = Sys.getenv("Sos_gkey") # import the key saved in the system environment
#' df <- get_gooogle_directions(origin = "Reno, Nevada",
#"                        destination = "39.2558, -117.6827",
#'                        key = SoS_gkey,
#'                        mode = "driving",
#'                        simplify = TRUE)
#' specificDirections(df)
#' @export
get_gooogle_directions <- function(x, api_key){


  # extract the coordinates to serve as the DESTINATION
  coords <- lapply(x, '[', c( 'latitude_dd', 'longitude_dd'))
  coords <- lapply(coords, st_drop_geometry)
  coords <- do.call(rbind, coords)
  coords <- paste(coords$latitude_dd, coords$longitude_dd,  sep = ", ")

  # identify the ORIGIN
  load('../data/places.rda')

  x <- dplyr::bind_rows(x)
  origin <- places[ sf::st_nearest_feature(x, places), c('CITY', 'NAME')] |>
    sf::st_drop_geometry()
  origin <- paste0(origin$CITY, ', ', origin$NAME)

  rm(places)

  # run query
  directions <- Map(f = googleway::google_directions, origin = origin,
                          destination = coords, key = api_key,
                          mode = "driving", simplify = TRUE)

  # rename output to reflect either ORIGIN-SITE_NAME, ORIGIN_DEST_COORDS
  names(directions) <- paste0(x$Site_name, '-', origin )

  return(directions)

}


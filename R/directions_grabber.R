#' Have google maps help you write directions to a site
#'
#' This function helps users write directions to a site which is somewhat near roads.
#' @param x an sf/tibble/dataframe of locations
#' @param api_key a google developer api key for use with googleway
#' @examples
#' site_data <- tibble(
#'  Site_name = rep(LETTERS[1:3], each = 3),
#'  longitude_dd = rep(c(-120.1, -115.2, -117.3), each = 3),
#'  latitude_dd = rep(c(35.0, 36.1, 37.2), each = 3)
#' ) %>%
#'  sf::st_as_sf(coords = c('longitude_dd', 'latitude_dd'), crs = 4326, remove = F)
#'
#' directions2site <- directions_grabber(site_data, api_key = SoS_gkey)
#' head(directions2site)
#' @export
directions_grabber <- function(x, api_key){

    # identify unique sites
  sites <- split(x, f = list(x$latitude_dd, x$longitude_dd), drop=TRUE)
  sites <- lapply(sites,  '[' , 1,)

  # gather results from API
  test_gq <- get_gooogle_directions(sites, api_key = SoS_gkey)

  # extract an overview of the directions as well as the specifics
  dir_over <- lapply(test_gq, directions_overview) |> unlist()
  dir_specific <- lapply(test_gq, specificDirections) |> unlist()


  sites_out <- do.call(rbind, sites)
  sites_out <- sites_out[, c('latitude_dd', 'longitude_dd')]
  sites_out <- sf::st_drop_geometry(sites_out)
  sites_out$Directions_BL = paste(dir_over, dir_specific)
  out <- dplyr::left_join(x, sites_out, by = c('latitude_dd', 'longitude_dd')) %>%
    dplyr::relocate(Directions_BL, .before = geometry)

  return(out)
}

#' gather distance and azimuth from site to center of town
#'
#' Help provide some simple context between the building and the
#' @param x an sf/tibble/dataframe of locations with associated nearest locality data
#' @param path path to gnis_places
#' @examples
#' \dontrun{
#' library(sf)
#' sites <- data.frame(
#'  longitude_dd = runif(15, min = -120, max = -100),
#'  latitude_dd = runif(15, min = 35, max = 48)
#'  ) |>
#'  sf::st_as_sf(coords = c('longitude_dd', 'latitude_dd'), crs = 4326)
#'
#' head(sites)
#' distaze_results <- site_writer(sites) # takes some time
#' head(distaze_results)
#' }
#' @export
site_writer <- function(x, path) {
  gnis_places <- sf::st_read(file.path(path, 'places/places.shp'), quiet = T)
  nf <- sf::st_nearest_feature(x, gnis_places) # identify the row of the nearest GNIS feature

  sites <- gnis_places[nf, ]

  azimuth <- round(
    geosphere::bearingRhumb(
      sf::st_coordinates(sites),
      sf::st_coordinates(x)
    ),
    0
  )

  distance_miles <- as.numeric(
    round(
      sf::st_distance(sites, x, by_element = T) / 1609.34,
      1
    )
  )

  place <- data.frame(
    'Place' = sf::st_drop_geometry(gnis_places[nf, 'fetr_nm'])
  )

  distances_df <- data.frame(
    Distance = distance_miles,
    Azimuth = azimuth,
    Place = place
  ) |>
    dplyr::mutate(
      Site = dplyr::if_else(
        Distance < 0.25,
        paste0(fetr_nm, '.'),
        paste0(
          Distance,
          'mi',
          ' at ',
          format_degree(Azimuth),
          ' from ',
          fetr_nm,
          '.'
        )
      ),
      Site = stringr::str_replace(Site, '\\..$', '.')
    ) |>
    dplyr::select(
      -dplyr::any_of(c('Distance', 'Azimuth', 'Place', 'ID', 'fetr_nm'))
    )

  distances_df <- dplyr::bind_cols(x, distances_df) |>
    dplyr::relocate(dplyr::any_of(c('Site', 'Allotment')), .before = geometry) |>
    dplyr::select(-dplyr::any_of('ID'))

  distances_df
}

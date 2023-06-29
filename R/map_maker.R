#' make a quick county dot map to display the location of the collection
#'
#' @description use sf to create a 20th centtury style 'dot map' which features the state
#' boundary and county lines.
#'
#' @param x an sf dataframe of coordinates to make maps for, requires collection number and spatial attributes
#' @param path a directory to store the map images in before merging
#' @param collection_col column specify the collection number or other UNIQUE id for the collection
#' @param states an sf object of the united states ala tigris::states()
#' @examples see the package vignette
#' @export
map_maker <- function(x, states, path, collection_col){

  if(st_crs(x) == sf::st_crs(states)) {
    pts } else {pts <- sf::st_transform(x, sf::st_crs(states))}

  ints <- sf::st_intersection(pts, states)

  focal_state <- dplyr::filter(states, STATE == ints$STATE)

  p <- ggplot2::ggplot() +
    ggplot2::geom_sf(data = focal_state, fill = NA, color = 'grey15') +
    ggplot2::geom_sf(data = pts, size = 0.5) +
    ggplot2::theme_void()

  fname <- file.path(path, 'maps', paste0('map_', sf::st_drop_geometry(x[1,'collectionNo']), '.png'))
  ggplot2::ggsave(filename =  fname, plot = p, device = 'png', dpi = 300,
                  width = 1, height = 1, units = 'in', bg = 'transparent')
}

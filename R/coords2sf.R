#' create an sf object row by row to reflect different datum
#'
#' This function creates an sf/tibble/dataframe for supporting the spatial operations
#' which BarnebyLives implements
#' @param x a data frame which has undergone dms2dd function
#' @param datum a column, holding the datum values for each observation, works for WGS84, NAD83, NAD27
#' @returns an sf/tibble/data frame of points in the same WGS84 coordinate reference system
#' @examples mixed_datum <- data.frame(
#'  datum = (rep(c('nad27', 'NAD83', 'wGs84'), each = 5)),
#'  longitude_dd = runif(15, min = -120, max = -100),
#'  latitude_dd = runif(15, min = 35, max = 48)
#'  )
#'
#' wgs84_dat <- coords2sf( mixed_datum )
#' str(wgs84_dat)
#' sf::st_crs(wgs84_dat)
#' @export
coords2sf <- function(x, datum){

  # first verify that the points have coordinates.
  r <- sapply( x[c('latitude_dd', 'longitude_dd' )], is.na)
  lat <- which(r[,1] == TRUE); long <- which(r[,2] == TRUE)
  remove <- unique(c(lat, long))

  if(length(remove) > 0) {
    x <- x[-remove,]
    cat('Error with row(s): ', remove,
        ' continuing without.')
    return(x)
  }
  rm(r, lat, long, remove)

  if(missing(datum)){ # identify datum information
    if(length(colnames(x)[grep('datum', colnames(x), ignore.case = T)]) == 1){
      datum_name = colnames(x)[grep('datum', colnames(x), ignore.case = T)] } else {
        x$datum = 'WGS84'
      }
  }
  if(!exists('datum_name')){datum_name = 'datum'}

  dat_check <- function(x){if(grepl('nad.*27', ignore.case = T, x = x)) {
    x = "NAD27"} else if(grepl('nad.*83', ignore.case = T, x = x)) {
      x = 'NAD83'} else if(grepl('wgs', ignore.case = T, x = x)) {
        x = "WGS84"
      } else {x = 'WGS84'}
  }

  # now ensure the datum is appropriate for each point
  x[datum_name] <- sapply( as.character(x[datum_name]), dat_check)

  crs_lkp = data.frame(
    datum = c('NAD27', 'NAD83', 'WGS84'),
    crs = c(4267, 4269, 4326))
  colnames(crs_lkp)[1] <- datum_name


  x <- dplyr::left_join(x, crs_lkp, by = datum_name)

  # separate all points by there datum
  dat_list <- split(x, f = x[datum_name])

  if(length(dat_list) == 1) {

    dat_list <- dplyr::bind_rows(dat_list)
    crss <- dat_list$crs[1]
    dat_list <- dat_list |>
      sf::st_as_sf(coords = c(x = 'longitude_dd', y = 'latitude_dd'),
                   crs = crss, remove = F) |>
      sf::st_transform(4326) |>
      dplyr::select(-crs) |>
      dplyr::mutate(datum = 'WGS84', .before = geometry)

  } else {

    dat_list <- purrr::map(dat_list, . |>
                             sf::st_as_sf(., coords = c(x = 'longitude_dd', y = 'latitude_dd'),
                                          crs = .$crs[1], remove = F) |>
                             sf::st_transform(4326)) |>
      dplyr::bind_rows() %>%
      dplyr::select(-crs) %>%
      dplyr::mutate(datum = 'WGS84', .before = geometry)
  }
  return(dat_list)
}



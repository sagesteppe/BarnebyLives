#' create an sf object row by row to reflect different datum
#' 
#' @param x a dataframe which has undergone dms2dd function
#' @param datum a column, holding the datum values for each observation, works for WGS84, NAD83, NAD27
#' @param returns an sf/tibble/dataframe of points in the same WGS84 coordinate reference system
#' @param example mixed_datum <- data.frame(
#'  datum = (rep(c('nad27', 'NAD83', 'wGs84'), each = 5)), 
#'  longitude_dd = runif(15, min = -120, max = -100), 
#'  latitude_dd = runif(15, min = 35, max = 48)
#'  )
#' 
#' wgs84_dat <- coords2sf( mixed_datum )
#' str(wgs84_dat)
#' st_crs(wgs84_dat)
#' @param export 
coords2sf <- function(x, datum){
  
  library(magrittr)
  
  if(missing(datum)){ # identify datum information
    datum = colnames(x)[grep('datum', colnames(x))] }
  
  if(length(datum) == 0){x$datum = 'WGS84'} # if column doesn't exist create
  
  dat_check <- function(x){if(grepl('nad.*27', ignore.case = T, x = x)) {
    x = "NAD27"} else if(grepl('nad.*83', ignore.case = T, x = x)) {
      x = 'NAD83'} else if(grepl('wgs', ignore.case = T, x = x)) {
        x = "WGS84"
      } else {x = 'WGS84'}
  }
  # now ensure the datum is appropriate for each point
  x$datum <- sapply(x$datum, dat_check)
  
  crs_lkp = data.frame(
    datum = c('NAD27', 'NAD83', 'WGS84'), 
    crs = c(4267, 4269, 4326))
  
  x <- dplyr::left_join(x, crs_lkp, by = 'datum') 
  
  # separate all points by there datum
  dat_list <- split(x, f = x$datum)
  dat_list <- purrr::map(dat_list, . |>  
                           sf::st_as_sf(., coords = c(x = 'longitude_dd', y = 'latitude_dd'), 
                                        crs = .$crs[1], remove = F) |> 
                           sf::st_transform(4326)) |>
    dplyr::bind_rows() %>% 
    dplyr::select(-crs) %>% 
    dplyr::mutate(datum = 'WGS84', .before = geometry)
  
  return(dat_list)
}


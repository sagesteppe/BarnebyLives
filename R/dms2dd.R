#' this function parses coordinates from DMS to decimal degrees
#'
#' @param x an input data frame to apply operations too
#' @param lat a name of the column holding the latitude values
#' @param long a name of the colymn holding the longitude values
#' @param dms are coordinates in degrees minutes seconds? TRUE for yes, FALSE for decimal degrees
#' @returns dataframe(/tibble) with coordinates unambiguously labeled as being in both degress, minutes, seconds (_dms) and decimal degrees (_dd). 
#' @example 
#'  coords <- data.frame(
#'   longitude_dd = runif(15, min = -120, max = -100), 
#'   latitude_dd = runif(15, min = 35, max = 48)
#' )
#' 
#' coords_formatted <- dms2dd( coords )
#' head(coords_formatted)
#' colnames(coords_formatted)
#' @param export 
dms2dd <- function(x, lat, long, dms){
  
  # identify columns if they were not supplied
  if(missing(lat)){
    lat = colnames(x)[grep('lat', colnames(x))] }
  if(missing(long)){
    long = colnames(x)[grep('long', colnames(x))] }
  
  # test for DMS format if not supplied
  suppressWarnings(  if(missing(dms)){
    dms = long == parzer::parse_lon(long)
  })
  
  # convert dms to dd, or rename input columns to dd
  if(dms == T){
    x$latitude_dd = parzer::parse_lat(lat)
    x$longitude_dd = parzer::pase_lon(long)
  } else{
    colnames(x)[which(names(x) == lat)] <- 'latitude_dd'
    colnames(x)[which(names(x) == long)] <- 'longitude_dd'
  }
  # ensure the DD signs are appropriate for domain
  x$latitude_dd <- abs(x$latitude_dd)
  x$longitude_dd <- abs(x$longitude_dd) * -1
  
  # now overwrite the original DMS values in our exact formaty
  
  x$latitude_dms = paste0(
    'N ', parzer::pz_degree(x$latitude_dd),
    '°', round(parzer::pz_minute(x$latitude_dd), 2),
    "'", round(parzer::pz_second(x$latitude_dd), 2)
  )
  
  x$longitude_dms = paste0(
    'W ', parzer::pz_degree(x$longitude_dd), 
    '°', round(parzer::pz_minute(x$longitude_dd), 2), 
    "'", round(parzer::pz_second(x$longitude_dd), 2)
  )
  
  x$longitude_dms <- gsub('-', "", x$longitude_dms)
  
  return(x)
  
}

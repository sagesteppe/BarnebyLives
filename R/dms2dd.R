#' this function parses coordinates from DMS to decimal degrees
#'
#' @param x an input data frame to apply operations too
#' @param lat a name of the column holding the latitude values
#' @param long a name of the colymn holding the longitude values
#' @param dms are coordinates in degrees minutes seconds? TRUE for yes, FALSE for decimal degrees
#' @returns dataframe(/tibble) with coordinates unambiguously labeled as being in both degress, minutes, seconds (_dms) and decimal degrees (_dd).
#' @examples
#'  coords <- data.frame(
#'   longitude_dd = runif(15, min = -120, max = -100),
#'   latitude_dd = runif(15, min = 35, max = 48)
#' )
#' coords_formatted <- dms2dd( coords )
#' head(coords_formatted)
#' colnames(coords_formatted)
#' @export
dms2dd <- function(x, lat, long, dms){

  # identify columns if they were not supplied
  if(missing(lat)){
    lat = colnames(x)[grep('lat', colnames(x), ignore.case = T)] }
  if(missing(long)){
    long = colnames(x)[grep('long', colnames(x), ignore.case = T)] }

  # remove any N | E | S | W, or for that matter other alphabetical characters
  x[,long] <- gsub('[[:alpha:]]|\\s', "", x[,long])
  x[,lat] <- gsub('[[:alpha:]]|\\s', "", x[,lat])

   # we will need to perform this operation across every single row,
   # because some people will put dms and dd in the same column...

   x_spl <- split(x, f = 1:nrow(x))

  dmsbyrow <- function(x, long, lat){
      # test for DMS format if not supplied

    suppressWarnings(
      dms <- is.na( as.numeric(x[,long]) == as.numeric(parzer::parse_lon(x[,long])) ))
    # convert dms to dd, or rename input columns to dd#
    if(dms == T){
      x$latitude_dd = parzer::parse_lat(x[,lat])
      x$longitude_dd = parzer::parse_lon(x[,long])
      x <- x[, -which(names(x) %in% c(lat, long))]
    } else{
      colnames(x)[which(names(x) == lat)] <- 'latitude_dd'
      colnames(x)[which(names(x) == long)] <- 'longitude_dd'
    }
    return(x)
  }

  x <- lapply(x_spl, dmsbyrow, long = long, lat = lat) |>
    data.table::rbindlist(use.names = TRUE)

  x$latitude_dd <- as.numeric(x$latitude_dd)
  x$longitude_dd <- as.numeric(x$longitude_dd)

  # ensure the DD signs are appropriate for domain
  x$latitude_dd <- abs(x$latitude_dd)
  x$longitude_dd <- abs(x$longitude_dd) * -1

  # now overwrite the original DMS values in our exact format

  x$latitude_dms = paste0(
    'N ', format_degree(parzer::pz_degree(x$latitude_dd)),
    round(parzer::pz_minute(x$latitude_dd), 2),
    "'", round(parzer::pz_second(x$latitude_dd), 0)
  )

  x$longitude_dms = paste0(
    'W ', format_degree(parzer::pz_degree(x$longitude_dd)),
    round(parzer::pz_minute(x$longitude_dd), 2),
    "'", round(parzer::pz_second(x$longitude_dd), 0)
  )

  x$longitude_dms <- gsub('-', "", x$longitude_dms)

  return(x)

}

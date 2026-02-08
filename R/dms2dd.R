#' this function parses coordinates from DMS to decimal degrees
#'
#' @param x an input data frame to apply operations to
#' @param lat a name of the column holding the latitude values
#' @param long a name of the colymn holding the longitude values
#' @param dms are coordinates in degrees minutes seconds? TRUE for yes, FALSE for decimal degrees
#' @returns data frame(/tibble) with coordinates unambiguously labeled as being in both degrees, minutes, seconds (_dms) and decimal degrees (_dd).
#' @examples
#'  coords <- data.frame(
#'   input_longitude = runif(15, min = -120, max = -100),
#'   input_latitude = runif(15, min = 35, max = 48)
#' )
#' coords_formatted <- dms2dd( coords )
#' head(coords_formatted)
#' colnames(coords_formatted)
#'
#' rm(coords, coords_formatted)
#'
#' # example with tibble input
#' data(uncleaned_collection_examples)
#'
#' dms2dd(uncleaned_collection_examples) |>
#'   dplyr::select(latitude_dd, longitude_dd, latitude_dms, longitude_dms)
#'
#' @export
dms2dd <- function(x, lat, long, dms) {

  original_class <- class(x)[1]
  x <- as.data.frame(x)

  # identify columns if they were not supplied
    # detect lat column if missing
  if (missing(lat)) {
    lat <- colnames(x)[grep('lat', colnames(x), ignore.case = TRUE)][1]
    if (is.na(lat)) stop('Error, argument for `lat` not found. Please specify.')
    message(crayon::yellow('argument to `lat` found, using: ', lat))
  }

  # detect long column if missing
  if (missing(long)) {
    long <- colnames(x)[grep('long', colnames(x), ignore.case = TRUE)][1]
    if (is.na(long)) stop('Error, argument for `long` not found. Please specify.')
    message(crayon::yellow('argument to `long` found, using: ', long))
  }
  
  # defensive check if columns explicitly supplied but don't exist
  if (!lat %in% colnames(x)) stop('Column specified for lat does not exist')
  if (!long %in% colnames(x)) stop('Column specified for long does not exist')

  # remove any N | E | S | W, or for that matter other alphabetical characters
  x[, long] <- as.character(x[, long])
  x[, lat] <- as.character(x[, lat])

  x[, long] <- gsub('[[:alpha:]]|\\s', "", x[, long, drop = TRUE])
  x[, lat] <- gsub('[[:alpha:]]|\\s', "", x[, lat, drop = TRUE])

  # we will need to perform this operation across every single row,
  # because some people will put dms and dd in the same column...
  x_spl <- split(x, f = seq_len(nrow(x)))

 # return(x_spl)
  x <- lapply(x_spl, dmsbyrow, long = long, lat = lat) |>
    data.table::rbindlist(use.names = TRUE)

  x$latitude_dd <- as.numeric(x$latitude_dd, options(digits = 9))
  x$longitude_dd <- as.numeric(x$longitude_dd, options(digits = 9))

  # ensure the DD signs are appropriate for domain
  x$latitude_dd <- round(abs(x$latitude_dd), 5)
  x$longitude_dd <- round(abs(x$longitude_dd) * -1, 5)

  # now overwrite the original DMS values in our exact format
  x$latitude_dms = paste0(
    'N ',
    format_degree(parzer::pz_degree(x$latitude_dd)),
    round(parzer::pz_minute(x$latitude_dd), 2),
    "'",
    round(parzer::pz_second(x$latitude_dd), 0)
  )

  x$longitude_dms = paste0(
    'W ',
    format_degree(parzer::pz_degree(x$longitude_dd)),
    round(parzer::pz_minute(x$longitude_dd), 2),
    "'",
    round(parzer::pz_second(x$longitude_dd), 0)
  )

  x$longitude_dms <- gsub('-', "", x$longitude_dms)

  # return object
  if (original_class == "data.table") {
    x <- data.table::as.data.table(x)
  } else {
    x <- as.data.frame(x)
  }

  x
}

#' will operate row-wise in case of mixed coordinate system
#'
#' @param x an input data frame to apply operations to
#' @param long column holding longitude values
#' @param lat column holding latitude values.
#' @keywords internal
dmsbyrow <- function(x, long, lat) {
  # test for DMS format if not supplied

  suppressWarnings(
    dms <- is.na(
      as.numeric(x[,long]) == as.numeric(parzer::parse_lon(x[,long]))
    )
  )

  # convert dms to dd, or rename input columns to dd#
  if (dms) {
    x$latitude_dd = parzer::parse_lat(x[[lat]])
    x$longitude_dd = parzer::parse_lon(x[[long]])
    x <- x[, -which(names(x) %in% c(lat, long))]
  } else {
    colnames(x)[which(names(x) == lat)] <- 'latitude_dd'
    colnames(x)[which(names(x) == long)] <- 'longitude_dd'
  }
  x
}

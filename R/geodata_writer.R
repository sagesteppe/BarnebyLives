#' write out spatial data for collections to Google earth or QGIS
#'
#' This function will write out a simple labeled shapefile containing just collection number. More data (e.g. species) can be written out using sf::st_write directly.
#' @params x a dataframe which has at least undergone the 'dms2dd' and 'coords2sf' functions from BL
#' @params path a location to save the data to. If not supplied defaults to the current working directory.
#' @params filename, name of file. if not supplied defaults to appending todays date to 'Collections'
#' @params filetype a file format to save the data to. This is a wrapper for sf::st_write and will support all drivers used there. If not supplied defaults to kml for use with google earth.
geodata_writer <- function(x, path, filename, filetype){

  if(missing(filetype)){filetype <- 'kml'}
  if(missing(filename)){filename <- paste0('Collections-', Sys.Date)}
  if(missing(path)){fname <- paste0(filename, filetype)} else {
        fname <- file.path(path, paste0(filename, '.', filetype))
  }

  ifelse(!dir.exists(file.path(path)),
         dir.create(file.path(path)), FALSE)

  x <- x |>
    dplyr::select(Name = Collection_number) |>
    sf::st_write(dsn = fname, driver = filetype, delete_dsn = TRUE, quiet = T)

  return(x)
  cat('data written to: ', fname)

}

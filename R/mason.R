#' a wrapper around terra::makeTiles for setting the domain of a project
#'
#' @description for projects with large spatial domains or using relatively high resolution data, this will help
#'
#' you make virtual tiles which do not need to be held in memory for the project.
#' @param dirin the input directory, including path, with the dataset
#' @param dirout the output directory, including path, for the subset dataset to go
#' @param grid spatvector defining the tiles, should contain a column containing grid cell names
#' @param fnames name of column containing filenames in the grid
#' @param ... other arguments passed to file.path
#' @examples # see package vignette
#' @export
mason <- function(dirin, dirout, grid, fnames, ...){

  # identify the paths to the rasters
  dirin <- sub('/$', '', dirin)
  paths2rast <- file.path(dirin, list.files(path = paste0(dirin, '/'), recursive = T, ...))

  # create and crop the virtual raster
  virtualRast <- terra::vrt(paths2rast)
  virtualRast_sub <- terra::crop(virtualRast, terra::ext(grid))

  # set file names and write out product
  columns <- terra::values(grid)
  cellname <- columns[,fnames]
  dirout <- sub('/$', '', dirout)

  fname <- file.path(dirout, paste0(cellname, ".tif"))
  terra::makeTiles(virtualRast_sub, grid, filename = fname, na.rm = F)

  rm(virtualRast_sub)
  gc()

}

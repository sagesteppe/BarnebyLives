#' Download the data required to establish a BL instance
#'
#' @description this function will download the data which are required to set up an instance of BarnebyLives.
#' These data must then be processed by the `data_process` function to set up the directory structures appropriately.
#' Note that the function will test if the data already exist in the location, if they do they will not be downloaded again.
#'
#' Elevation data are available at http://hydro.iis.u-tokyo.ac.jp/~yamadai/MERIT_DEM/
#' and require a free and automatically approved account to download.
#' Download from the second set of data, under the 'GeoTiff format' header
#'
#' @param PADUS Boolean. Defaults to FALSE. Honestly, downloading this single
#'  object takes much more hassle than it is worth. You should just download from :
#' https://www.sciencebase.gov/catalog/item/652ef930d34edd15305a9b03 you'll have to
#' do a captcha, but just download the 'Geodatabase.zip' and place it in same
#' directory as other files. Rename it as 'PADUS.zip' and we are good to go.
#'
#' @param path The root directory to save all the data in. Please specify a location, we suggest you make a directory for this.
#' If not specified will default to your working directory.
#' @examples \dontrun{
#' # setwd('/media/steppe/hdd/BL_sandbox/geodata_raw')
#' # download_data(path = '/media/steppe/hdd/BL_sandbox')
#' }
#' @export
data_download <- function(path){

  if(missing(path)){path <- '.'}

  counties_dl(path)
  GMBA_dl(path)
  allotments_dl(path)
  GNIS_dl(path)

  PLSS_dl(path) # a slow one !
  SGMC_dl(path) # hardly ever works
}


#' download data
#' @description dl data.
#'
#' @keywords internal
counties_dl <- function(path){ # WORKS
  fp <- file.path(path, 'Counties.zip')

  if(file.exists(fp)){
    message('Product `Counties` already downloaded. Skipping.')} else{
    URL <- 'https://www2.census.gov/geo/tiger/TIGER2020/COUNTY/tl_2020_us_county.zip'
    httr::GET(URL, httr::progress(), httr::write_disk(path = fp, overwrite = TRUE))
  }
}

#' download data
#' @description dl data.
#'
#' @keywords internal
GMBA_dl <- function(path){ # WORKS
  fp <- file.path(path, 'GMBA.zip')
  if(file.exists(fp)){
    message('Product `GMBA` already downloaded. Skipping.')} else{
  URL <- 'https://data.earthenv.org/mountains/standard/GMBA_Inventory_v2.0_standard_basic.zip'
  httr::GET(URL, httr::progress(), httr::write_disk(path = fp, overwrite = TRUE))
  }
}

#' download data
#' @description dl data.
#'
#' @keywords internal
PLSS_dl <- function(path){ # WORKS

  fp <- file.path(path, 'PLSS.zip')
  if(file.exists(fp)){
    message('Product `PLSS` already downloaded. Skipping.')} else{
  URL <- 'https://blm-egis.maps.arcgis.com/sharing/rest/content/items/283939812bc34c11bad695a1c8152faf/data'
  message("PLSS - this one will take a minute (3.6 GB)")
  httr::GET(URL, httr::progress(), httr::write_disk(fp))
  }
}

#' download data
#' @description dl data.
#'
#' @keywords internal
allotments_dl <- function(path){ # works

  fp <- file.path(path, 'USFSAllotments.zip')
  if(file.exists(fp)){
    message('Product `USFSAllotments` already downloaded. Skipping.')} else{
  URL <- "https://data.fs.usda.gov/geodata/edw/edw_resources/shp/S_USA.Allotment.zip"
  httr::GET(URL, httr::progress(), httr::write_disk(fp, overwrite = TRUE))
  }

  fp <- file.path(path, 'BLMAllotments.zip')
  if(file.exists(fp)){
    message('Product `BLMAllotments` already downloaded. Skipping.')} else{
  URL <- "https://gbp-blm-egis.hub.arcgis.com/api/download/v1/items/0882acf7eada4b3bafee4dd673fbe8a0/shapefile?layers=1"
  httr::GET(URL, httr::progress(), httr::write_disk(path = fp, overwrite = TRUE))
    }
}

# we can grab states by using their abbreviations...
# 'https://mrdata.usgs.gov/geology/state/shp/IA.zip'

#' download data
#' @description dl data.
#'
#' @keywords internal
SGMC_dl <- function(path){ # WORKS

  fp <- file.path(path, 'SGMC.zip')
  if(file.exists(fp)){
    message('Product `SGMC` already downloaded. Skipping.')} else{

  URL <- 'https://www.sciencebase.gov/catalog/file/get/5888bf4fe4b05ccb964bab9d?name=USGS_SGMC_Geodatabase.zip'
  message("This website is slow, If it doesn't download.\nThen we recommend downloading the data by hand. https://mrdata.usgs.gov/geology/state/")
  httr::GET(URL, httr::progress(), httr::write_disk(path = fp, overwrite = TRUE))
    }
}

#' download data
#' @description dl data.
#'
#' @keywords internal
GNIS_dl <- function(path){ # WORKS

  fp <- file.path(path, 'GNIS.zip')
  if(file.exists('GNIS.zip')){
    message('Product `GNIS` already downloaded. Skipping.')} else{

      aws.s3::save_object(
        file = fp,
        object = "s3://prd-tnm/StagedProducts/GeographicNames/DomesticNames/DomesticNames_AllStates_Text.zip",
        bucket = "s3://prd-tnm/",
        region = "us-west-2",
        show_progress = TRUE
      )}
}

#' download data
#' @description dl data. Honestly, downloading this single object takes much
#' more hassle than it is worth. You should just dowload from :
#' https://www.sciencebase.gov/catalog/item/652ef930d34edd15305a9b03 you'll have to
#' do a captcha, but just download the 'Geodatabase.zip' and place it in same directory as other.
#'
#' @keywords internal
PAD_dl <- function(path){ # this is the wrong path

  if(file.exists('PAD.zip')){
    message('Product `PAD` already downloaded. Skipping.')} else{

      aws.s3::save_object(
        file = file.path(path, 'GNIS.zip'),
        object = "s3://prd-tnm/StagedProducts/GeographicNames/DomesticNames/DomesticNames_AllStates_Text.zip",
        bucket = "s3://prd-tnm/",
        region = "us-west-2",
        show_progress = TRUE
      )}
}


#' Determine which raster tiles to download for topographic variables
#'
#' @description
#' Given a bounding box, defining the spatial extent of the study area, return
#' a list of tiles names which need to be downloaded to cover this area.
#'
#' @param bound Data frame. 'x' and 'y' coordinates of the extent for which the BL instance will cover.
#' @examples \dontrun{
#' bound <- data.frame(
#'   y = c(30.1, 30.1, 49.5, 49.5, 30.1),
#'   x = c(-126, -82, -82, -126, -126)
#' )
#'
#' bound <- data.frame(
#'   y = c(15, 50, 75, 44, 15),
#'   x = c(-63, -64, -180, -180, -180)
#' )
#'
#' tileSelector(bound)
#' }
#' @keywords internal
tileSelector <- function(bound){

  bound.v <- bound |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc() |>
    terra::vect()

  # create a raster where the pixels represent the tiles of the full data set.
  gr <- terra::rast(
    nrows = 5, ncols = 12,
    xmin = -180, xmax = 180, ymin = -90, ymax = 90,
    crs = "epsg:4326"
  )

  # these tiles are named by the lower left (SW) coordinates, generate the names
  # for the raster object.
  lowerleft <- paste0(
    paste0(
      c(rep('n', 36), rep('s', 24)),
      sprintf("%02.f",rep(abs(seq(-60, 60, by = 30)), each = 12))
    ),
    paste0(
      c(rep('w', 6), rep('e', 6)),
      sprintf("%03.f", abs(rep(seq(-180, 150, by = 30), times = 5)))
    )
  )

  # place the names into the raster as values, allowing them to simple be extracted
  gr <- terra::setValues(gr, lowerleft)
  # extract values. these are the values we need to pad with resolution and
  # file extension
  touches <- terra::extract(gr, bound.v, touches= TRUE)$lyr.1
  # returned obs will still require the prefix specififying the product type
  # e.g. 'aspect'
  fnames <- paste0('_90M_', touches, '.tar.gz')

  return(fnames)

}




# library(sbtools)
# sbtools::query_sb_doi('10.5066/P96WBCHS', limit=1)
# item <- sbtools::item_get('65294599d34e44db0e2ed7cf')
# sbtools::item_file_download('https://www.sciencebase.gov/catalog/items?parentId=65294599d34e44db0e2ed7cf&format=json')

# 'prod-is-usgs-sb-prod-content.s3.amazonaws.com'

# aws.s3
# aws.s3::bucket_exists(
#   bucket = "s3://prod-is-usgs-sb-prod-content/",
#   region = 'us-west-2'
#   )

# library(minioclient)
#install_mc()
# mc_alias_set("anon", "s3.amazonaws.com", access_key = "", secret_key = "")
# mc_ls("anon/gbif-open-data-us-east-1")

# mc_alias_set(
#  alias = "minio",
#  endpoint = Sys.getenv("opentopography", "s3.amazonaws.com"),
#  access_key = "",
#  secret_key = "")

# mc_ls("OTDS.012020.4326.1", recursive = TRUE)

# gnis_products <- aws.s3::get_bucket_df(
#   bucket = "minio",
#   prefix = 'opentopography.s3.sdsc.edu',
#   region = "eu-north-1",
#   max = 200
# )

# aspect_dl <- function(x){

#   base <- 'https://opentopography.s3.sdsc.edu/minio/dataspace/OTDS.012020.4326.1/raster/aspect/'
#   f <- 'aspect_90M_s60w180.tar.gz'
#   httr::GET(paste0(base, f),
#             httr::write_disk(path = 'asp', overwrite = TRUE))
# }


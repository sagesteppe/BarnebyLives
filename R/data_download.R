#' Download the data required to establish a BL instance
#'
#' @description this function will download the data which are required to set up an instance of BarnebyLives.
#' These data must then be processed by the `data_process` function to set up the directory structures appropriately.
#' Note that the function will test if the data already exist in the location, if they do they will not be downloaded again.
#' @param path The root directory to save all the data in. Please specify a location, we suggest you make a directory for this.
#' If not specified will default to your working directory.
#' @examples \donttest{
#' # setwd('/media/steppe/hdd/BL_sandbox/geodata_raw')
#' # download_data(path = '/media/steppe/hdd/BL_sandbox')
#' }
#' @export
download_data <- function(path){

  if(missing(path)){path <- '.'}

  WCVP_dl(path)
  counties_dl(path)
  GMBA_dl(path)
  allotments_dl(path)
  GNIS_dl(path)

  PLSS_dl(path) # a slow one !
  SGMC_dl(path) # hardly ever works
}

# setwd('/media/steppe/hdd/BL_sandbox/geodata_raw')
# download_data()


WCVP_dl <- function(path){  #  WORKS

  if(file.exists('WCVP.zip')){
    message('Product `WCVP` already downloaded. Skipping.')} else{
  URL <- 'https://sftp.kew.org/pub/data-repositories/WCVP/wcvp_dwca.zip'
  httr::GET(URL,
            httr::write_disk(path = file.path(path, 'WCVP.zip'), overwrite = TRUE))
  }
}

counties_dl <- function(path){ # WORKS
  if(file.exists('Counties.zip')){
    message('Product `Counties` already downloaded. Skipping.')} else{
    URL <- 'https://www2.census.gov/geo/tiger/TIGER2020/COUNTY/tl_2020_us_county.zip'
    httr::GET(URL,
              httr::write_disk(path = file.path(path, 'Counties.zip'), overwrite = TRUE))
  }
}

GMBA_dl <- function(path){ # WORKS
  if(file.exists('GMBA.zip')){
    message('Product `GMBA` already downloaded. Skipping.')} else{
  URL <- 'https://data.earthenv.org/mountains/standard/GMBA_Inventory_v2.0_standard_basic.zip'
  httr::GET(URL,
            httr::write_disk(path = file.path(path, 'GMBA.zip'), overwrite = TRUE))
  }
}

PLSS_dl <- function(path){ # WORKS

  if(file.exists('PLSS.zip')){
    message('Product `PLSS` already downloaded. Skipping.')} else{
  cap_speed <- httr::config(max_recv_speed_large = 10000)
  URL <- 'https://blm-egis.maps.arcgis.com/sharing/rest/content/items/283939812bc34c11bad695a1c8152faf/data'
  message("PLSS - this one will take a minute (3.6 GB)")
  httr::GET(URL, httr::progress(), cap_speed,
            httr::write_disk(path = file.path(path, 'PLSS.zip')))
  }
}

allotments_dl <- function(path){ # works

  if(file.exists('USFSAllotments.zip')){
    message('Product `USFSAllotments` already downloaded. Skipping.')} else{
  URL <- "https://data.fs.usda.gov/geodata/edw/edw_resources/shp/S_USA.Allotment.zip"
  httr::GET(URL,
            httr::write_disk(path = file.path('USFSAllotments.zip'), overwrite = TRUE))
  }

  if(file.exists('BLMAllotments.zip')){
    message('Product `BLMAllotments` already downloaded. Skipping.')} else{
  URL <- "https://gbp-blm-egis.hub.arcgis.com/api/download/v1/items/0882acf7eada4b3bafee4dd673fbe8a0/shapefile?layers=1"
  httr::GET(URL,
            httr::write_disk(path = file.path('BLMAllotments.zip'), overwrite = TRUE))
    }
}

# we can grab states by using their abbreviations...
'https://mrdata.usgs.gov/geology/state/shp/IA.zip'

SGMC_dl <- function(path){ # WORKS

  if(file.exists('SGMC.zip')){
    message('Product `SGMC` already downloaded. Skipping.')} else{

#  cap_speed <- httr::config(max_recv_speed_large = 10000)
  URL <- 'https://www.sciencebase.gov/catalog/file/get/5888bf4fe4b05ccb964bab9d?name=USGS_SGMC_Geodatabase.zip'
  message("This website is slow.\nWe recommend downloading the geodata by hand. https://mrdata.usgs.gov/geology/state/")
  httr::GET(URL, httr::progress(),
            httr::write_disk(path = file.path(path, 'SGMC.zip'), overwrite = TRUE))
    }
}

SGMC_dl(path = '.')

GNIS_dl <- function(path){ # WORKS

  if(file.exists('GNIS.zip')){
    message('Product `GNIS` already downloaded. Skipping.')} else{

      aws.s3::save_object(
        file = file.path(path, 'GNIS.zip'),
        object = "s3://prd-tnm/StagedProducts/GeographicNames/DomesticNames/DomesticNames_AllStates_Text.zip",
        bucket = "s3://prd-tnm/",
        region = "us-west-2",
        show_progress = TRUE
      )}
}


PAD_dl <- function(path){ # WORKS

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


'prod-is-usgs-sb-prod-content.s3.amazonaws.com'

aws.s3
aws.s3::bucket_exists(
  bucket = "s3://prod-is-usgs-sb-prod-content/",
  region = 'us-west-2'
  )

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


library(sbtools)
sbtools::query_sb_doi('10.5066/P96WBCHS', limit=1)
item <- sbtools::item_get('65294599d34e44db0e2ed7cf')


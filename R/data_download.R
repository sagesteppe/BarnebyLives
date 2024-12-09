#' Download the data required to establish a BL instance
#'
#' @description this function will download the data which are required to set up an instance of BarnebyLives.
#' These data must then be processed by the `data_process` function to set up the directory structures appropriately.
#' Note that the function will test if the data already exist in the location, if they do they will not be downloaded again.
#' @param path The root directory to save all the data in. Please specify.

setwd('/media/steppe/hdd/BL_sandbox')
getwd()


WCVP_dl <- function(){  #  WORKS

  if(file.exists('WCVP')){
    message('Product `WCVP` already downloaded. Skipping.')} else{
  URL <- 'https://sftp.kew.org/pub/data-repositories/WCVP/wcvp_dwca.zip'
  httr::GET(URL,
            httr::write_disk(path = 'WCVP', overwrite = TRUE))
  }
}

# WCVP_dl()

counties_dl <- function(){ # WORKS
  if(file.exists('COUNTY')){
    message('Product `COUNTY` already downloaded. Skipping.')} else{
    URL <- 'https://www2.census.gov/geo/tiger/TIGER2020/COUNTY/tl_2020_us_county.zip'
    httr::GET(URL,
              httr::write_disk(path = 'COUNTY', overwrite = TRUE))
  }
}
# counties_dl()

GMBA_dl <- function(){ # WORKS
  if(file.exists('GMBA')){
    message('Product `GMBA` already downloaded. Skipping.')} else{
  URL <- 'https://data.earthenv.org/mountains/standard/GMBA_Inventory_v2.0_standard.zip'
  httr::GET(URL,
            httr::write_disk(path = 'GMBA', overwrite = TRUE))
  }
}

# GMBA_dl()

PLSS_dl <- function(){ # WORKS

  if(file.exists('PLSS')){
    message('Product `PLSS` already downloaded. Skipping.')} else{
  cap_speed <- httr::config(type = 'down')
  URL <- 'https://blm-egis.maps.arcgis.com/sharing/rest/content/items/283939812bc34c11bad695a1c8152faf/data'
  message("This one will take a minute (3.6 GB)")
  httr::GET(URL, httr::progress(), cap_speed,
            httr::write_disk(path = 'PLSS', overwrite = TRUE))
  }
}


# PLSS_dl()


allotments_dl <- function(){ # works

  if(file.exists('USFSAllotments')){
    message('Product `USFSAllotments` already downloaded. Skipping.')} else{
  URL <- "https://data.fs.usda.gov/geodata/edw/edw_resources/shp/S_USA.Allotment.zip"
  httr::GET(URL,
            httr::write_disk(path = 'USFSAllotments', overwrite = TRUE))
  }

  if(file.exists('BLMAllotments')){
    message('Product `BLMAllotments` already downloaded. Skipping.')} else{
  URL <- "https://gbp-blm-egis.hub.arcgis.com/api/download/v1/items/0882acf7eada4b3bafee4dd673fbe8a0/shapefile?layers=1"
  httr::GET(URL,
            httr::write_disk(path = 'BLMAllotments', overwrite = TRUE))
    }
}


# allotments_dl()


# we can grab states by using their abbreviations...

'https://mrdata.usgs.gov/geology/state/shp/IA.zip'

SGMC_dl <- function(){ # WORKS

  if(file.exists('SGMC')){
    message('Product `SGMC` already downloaded. Skipping.')} else{

  cap_speed <- httr::config(max_recv_speed_large = 10000)
  URL <- 'https://www.sciencebase.gov/catalog/file/get/5888bf4fe4b05ccb964bab9d?name=USGS_SGMC_Geodatabase.zip'
  message("This website is super slow.\nWe recommend downloading the geodata by hand. https://mrdata.usgs.gov/geology/state/")
  httr::GET(URL, httr::progress(), cap_speed,
            httr::write_disk(path = 'SGMC', overwrite = TRUE))
    }
}

# SGMC_dl()








library(minioclient)
#install_mc()
mc_alias_set("anon", "s3.amazonaws.com", access_key = "", secret_key = "")
mc_ls("anon/gbif-open-data-us-east-1")

mc_alias_set(
  alias = "minio",
  endpoint = Sys.getenv("opentopography", "s3.amazonaws.com"),
  access_key = "",
  secret_key = "")

mc_ls("OTDS.012020.4326.1", recursive = TRUE)
?mc_ls

?get_bucket_df
gnis_products <- aws.s3::get_bucket_df(
  bucket = "minio",
  prefix = 'opentopography.s3.sdsc.edu',
  region = "eu-north-1",
  max = 200
)



aspect_dl <- function(x){

  base <- 'https://opentopography.s3.sdsc.edu/minio/dataspace/OTDS.012020.4326.1/raster/aspect/'
  f <- 'aspect_90M_s60w180.tar.gz'
  httr::GET(paste0(base, f),
            httr::write_disk(path = 'asp', overwrite = TRUE))
}

# aspect_dl()


gnis_products <- aws.s3::get_bucket_df(
  bucket = "s3://prd-tnm/",
  region = "us-west-2",
  prefix = 'StagedProducts/GeographicNames/DomesticNames/',
  max = 200
) |>
  as.data.frame()
gnis_products <- gnis_products[ grep('[.]zip$', gnis_products$Key), ]

# aws.s3::save_object(
#  file = 'GNIS',
#  object = "s3://prd-tnm/StagedProducts/GeographicNames/DomesticNames/DomesticNames_AllStates_Text.zip",
#  bucket = "s3://prd-tnm/",
#  region = "us-west-2",
#  show_progress = TRUE
#)



GNIS_dl <- function(){ # WORKS

  if(file.exists('GNIS')){
    message('Product `GNIS` already downloaded. Skipping.')} else{

      aws.s3::save_object(
        file = 'GNIS',
        object = "s3://prd-tnm/StagedProducts/GeographicNames/DomesticNames/DomesticNames_AllStates_Text.zip",
        bucket = "s3://prd-tnm/",
        region = "us-west-2",
        show_progress = TRUE
      )}
}

GNIS_dl()

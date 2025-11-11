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
#' PADUS downloading this single  object takes much more hassle than it is worth. You should just download from :
#' https://www.sciencebase.gov/catalog/item/652ef930d34edd15305a9b03 you'll have to
#' do a captcha, but just download the 'Geodatabase.zip' and place it in same
#' directory as other files. Rename it as 'PADUS.zip' and we are good to go.
#'
#' @param path The root directory to save all the data in. Please specify a location,
#'  we suggest you make a directory for this.
#' If not specified will default to your working directory.
#' @examples \dontrun{
#' # setwd('/media/steppe/hdd/BL_sandbox/geodata_raw')
#' # download_data(path = '/media/steppe/hdd/BL_sandbox')
#' }
#' @export
data_download <- function(path) {
  if (missing(path)) {
    path <- '.'
  }

  success <- TRUE
  steps <- list(
    counties_dl   = function() counties_dl(path),
    GMBA_dl       = function() GMBA_dl(path),
    Valleys_dl    = function() Valleys_dl(path),
    allotments_dl = function() allotments_dl(path),
    GNIS_dl       = function() GNIS_dl(path),
    PLSS_dl       = function() PLSS_dl(path),
    SGMC_dl       = function() SGMC_dl(path)
  )

  for (nm in names(steps)) {
    message(crayon::blue("Downloading: ", nm))
    ok <- tryCatch(
      {
        steps[[nm]]()
        TRUE
      },
      error = function(e) {
        message(crayon::red("Error in ", nm, ": ", e$message))
        FALSE
      }
    )
    if (!ok) {
      success <- FALSE
      break
    }
  }

}


#' download data
#' @description dl data.
#'
#' @keywords internal
counties_dl <- function(path) {
  # WORKS
  fp <- file.path(path, 'Counties.zip')

  if (file.exists(fp)) {
    message(crayon::green('Product `Counties` already downloaded. Skipping.'))
  } else {
    URL <- 'https://www2.census.gov/geo/tiger/TIGER2020/COUNTY/tl_2020_us_county.zip'
    httr::GET(
      URL,
      httr::progress(),
      httr::write_disk(path = fp, overwrite = TRUE)
    )
  }
}


#' download data
#' @description dl data.
#'
#' @keywords internal
GMBA_dl <- function(path) {
  # WORKS
  fp <- file.path(path, 'GMBA.zip')
  if (file.exists(fp)) {
    message(crayon::green('Product `GMBA` already downloaded. Skipping.'))
  } else {
    URL <- 'https://data.earthenv.org/mountains/standard/GMBA_Inventory_v2.0_standard_basic.zip'
    httr::GET(
      URL,
      httr::progress(),
      httr::write_disk(path = fp, overwrite = TRUE)
    )
  }
}

#' download data
#' @description dl data.
#'
#' @keywords internal
Valleys_dl <- function(path) {
  # WORKS
  fp <- file.path(path, 'Named_Valleys.gpkg')
  if (file.exists(fp)) {
    message(crayon::green('Product `Named Valleys` already downloaded. Skipping.'))
  } else {
    URL <- 'https://github.com/sagesteppe/BarnebyLives_data/releases/download/v1.0/Named_Valleys.gpkg'
    httr::GET(
      URL,
      httr::progress(),
      httr::write_disk(path = fp, overwrite = TRUE)
    )
  }
}


#' download data
#' @description dl data.
#'
#' @keywords internal
PLSS_dl <- function(path) {
  # WORKS

  fp <- file.path(path, 'PLSS.zip')
  if (file.exists(fp)) {
    message(crayon::green('Product `PLSS` already downloaded. Skipping.'))
  } else {
    URL <- 'https://blm-egis.maps.arcgis.com/sharing/rest/content/items/283939812bc34c11bad695a1c8152faf/data'
    message("PLSS - this one will take a minute (3.6 GB)")
    httr::GET(URL, httr::progress(), httr::write_disk(fp))
  }
}

#' download data
#' @description dl data.
#'
#' @keywords internal
allotments_dl <- function(path) {
  # works

  prod <- c('USFSAllotments', 'BLMAllotments')
  fp <- file.path(path, paste0(prod, '.zip'))
  mss <- paste0('Product `', prod, '` already downloaded. Skipping.')
  URL <- c(
    'https://data-usfs.hub.arcgis.com/api/download/v1/items/f8872f1c70d34376b515e0ea90a868d5/shapefile?layers=0',
    'https://gbp-blm-egis.hub.arcgis.com/api/download/v1/items/0882acf7eada4b3bafee4dd673fbe8a0/shapefile?layers=1'
  )

  for (i in seq_along(prod)) {
    if (file.exists(fp[i])) {
      message(crayon::green(mss[i]))
    } else {
      httr::GET(
        URL[i],
        httr::progress(),
        httr::write_disk(path = fp[i], overwrite = TRUE)
      )
    }
  }
}


# we can grab states by using their abbreviations...
# 'https://mrdata.usgs.gov/geology/state/shp/IA.zip'

#' download data
#' @description dl data.
#'
#' @keywords internal
SGMC_dl <- function(path) {
  dir.create(path, showWarnings = FALSE, recursive = TRUE)

  fp <- file.path(path, 'SGMC.zip')
  if (file.exists(fp)) {
    message(crayon::green('Product `SGMC` already downloaded. Skipping.'))
    return(invisible(NULL))
  }

  url <- 'https://www.sciencebase.gov/catalog/file/get/5888bf4fe4b05ccb964bab9d?name=USGS_SGMC_Geodatabase.zip'

  message(
    crayon::cyan("Attempting to download SGMC data...\n"),
    "This server is slow and unreliable. If this fails,\n",
    "please download manually from:\n",
    crayon::blue("https://mrdata.usgs.gov/geology/state/\n")
  )

  download_sgmc(dest = fp, url = url)
}

#' use to try and download sgmc data
#' @param dest location to save data to
#' @param url location to try download from
#'
#' @keywords internal
download_sgmc <- function(dest, url) {
  os <- Sys.info()[["sysname"]]
  has_wget <- nzchar(Sys.which("wget"))
  has_curl <- nzchar(Sys.which("curl"))

  # --- Git Bash fallback on Windows ---
  if (os == "Windows" && !has_wget && !has_curl) {
    find_git_bash_tool <- function(tool = c("wget", "curl")) {
      tool <- match.arg(tool)
      default_paths <- c(
        file.path("C:/Program Files/Git/usr/bin", tool),
        file.path("C:/Program Files (x86)/Git/usr/bin", tool)
      )
      found <- Filter(file.exists, default_paths)
      if (length(found)) {
        return(shQuote(found[[1]]))
      }
      return(NULL)
    }
    wget_path <- find_git_bash_tool("wget")
    curl_path <- find_git_bash_tool("curl")
    if (!has_wget && !is.null(wget_path)) {
      has_wget <- TRUE
      Sys.setenv(WGET_CMD = wget_path)
    }
    if (!has_curl && !is.null(curl_path)) {
      has_curl <- TRUE
      Sys.setenv(CURL_CMD = curl_path)
    }
  }

  # --- Helper to try a CLI download ---
  try_cli_download <- function(cmd, label = "CLI") {
    message("Trying ", label, ": ", cmd)
    status <- system(cmd)
    if (status == 0) {
      message(crayon::green(label, " download completed successfully."))
      return(TRUE)
    } else {
      warning(label, " failed to download file.")
      return(FALSE)
    }
  }

  # --- Attempt download ---
  if (has_wget) {
    cmd <- sprintf(
      "%s --continue --tries=5 --timeout=30 -O \"%s\" \"%s\"",
      Sys.getenv("WGET_CMD", unset = "wget"),
      dest,
      url
    )
    if (try_cli_download(cmd, "wget")) return(invisible(dest))
  }

  if (has_curl) {
    cmd <- sprintf(
      "%s -L --retry 5 --retry-delay 5 -o \"%s\" \"%s\"",
      Sys.getenv("CURL_CMD", unset = "curl"),
      dest,
      url
    )
    if (try_cli_download(cmd, "curl")) return(invisible(dest))
  }

  # --- All attempts failed ---
  message(crayon::yellow(
    "\nAutomated download failed or required tools are missing.\n",
    "Please download the file manually:"
  ))
  message(crayon::blue(url))
  message(crayon::yellow("Then move it to:"))
  message(crayon::magenta(normalizePath(dest, mustWork = FALSE)))

  stop("Download must be completed by hand.")
}


#' download data
#' @description dl data.
#'
#' @keywords internal
GNIS_dl <- function(path) {
  fp <- file.path(path, 'GNIS.zip')
  if (file.exists(fp)) {
    message(crayon::green('Product `GNIS` already downloaded. Skipping.'))
  } else {
    aws.s3::save_object(
      file = fp,
      object =
        "s3://prd-tnm/StagedProducts/GeographicNames/DomesticNames/DomesticNames_AllStates_Text.zip",
      bucket = "s3://prd-tnm/",
      region = "us-west-2",
      show_progress = TRUE
    )
  }
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
#' @export
tileSelector <- function(bound) {
  bound.v <- bound |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc() |>
    terra::vect()

  # create a raster where the pixels represent the tiles of the full data set.
  gr <- terra::rast(
    nrows = 5,
    ncols = 12,
    xmin = -180,
    xmax = 180,
    ymin = -90,
    ymax = 90,
    crs = "epsg:4326"
  )

  # these tiles are named by the lower left (SW) coordinates, generate the names
  # for the raster object.
  lowerleft <- paste0(
    paste0(
      c(rep('n', 36), rep('s', 24)),
      sprintf("%02.f", rep(abs(seq(-60, 60, by = 30)), each = 12))
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
  touches <- terra::extract(gr, bound.v, touches = TRUE)$lyr.1
  # returned obs will still require the prefix specififying the product type
  # e.g. 'aspect'
  fnames <- paste0('_90M_', touches, '.tar.gz')

  cat(
    "The variables below can be downloaded from the following webpages:\n",
    "\n",
    crayon::green("Aspect data: "),
    "https://opentopography.s3.sdsc.edu/minio/dataspace/OTDS.012020.4326.1/raster/aspect/\n",
    crayon::blue("Geomorphology data: "),
    "https://opentopography.s3.sdsc.edu/minio/dataspace/OTDS.012020.4326.1/raster/geom/\n",
    crayon::red('Slope data: '),
    "https://opentopography.s3.sdsc.edu/minio/dataspace/OTDS.012020.4326.1/raster/slope/\n",
    crayon::magenta("Elevation data: "),
    "https://hydro.iis.u-tokyo.ac.jp/~yamadai/MERIT_DEM/\n",
    "\n",
    "full file name example: ",
    crayon::green(paste0('aspect', fnames[1])),
    '\n',

    "\n",
    "Files required:\n",
    fnames,
    sep = ""
  )

  return(fnames)
}

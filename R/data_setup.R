#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description Once all data are downloaded for BarnebyLives use this function
#' to set them up to be used by the pipeline.
#' @param path Character. path to the folder where output from `data_download` was downloaded.
#'  Defaults to a subfolder within the working directory ('./geodata_raw').
#' @param pathOut Character. Path to the folder where final spatial data should be placed.
#' Defaults to ('.'), and will create a 'geodata' directory within it to store results.
#' @param bound Data frame. 'x' and 'y' coordinates of the extent for which the BL instance will cover.
#' @param cleanup Boolean. Whether to remove the original zip files which were downloaded. Defaults to FALSE.
#' Either mode of running the function will delete the uncompressed zip files generated during the process.
#' @examples \donttest{
#' bound <- data.frame(
#' y = c(30, 30, 50, 50, 30),
#' x = c(-85, -125, -125, -85, -85)
#' )
#'
#' data_setup(path = './geodata_raw', bound = bound, cleanup = FALSE)
#' }
#' @export
data_setup <- function(path, pathOut, bound, cleanup){

  if(missing(path)){path <- './geodata_raw'}
  if(missing(pathOut)){pathOut <- '.'}
  dir.create(file.path(pathOut, 'geodata'), showWarnings = FALSE)
  if(missing(cleanup)){default = FALSE}

  # create the extent which we are operating in
  bb_vals <- c(min(bound$x), max(bound$x), min(bound$y), max(bound$y))
  bound <- bound |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()

  # use tiles to create many smaller rasters, rather than one really big raster.
  mt <- make_tiles(bound, bb_vals)
  tile_cells <- mt$tile_cells
  tile_cellsV <- mt$tile_cellsV

  # decompress all of the archives so we can readily read them into R.
  zzzs <- file.path(path, list.files(path = path, pattern = '*.[.]zip$'))
#  out_dirs <- gsub('[.]zip', '' , zzzs)
#  lapply(out_dirs, dir.create)
#  return(zzzs)

  lapply(zzzs, FUN = function(x){
    out <- gsub('[.]zip', '' , x)
    unzip(x, exdir = out)}
    )

  ##### now crop the data to the extents of analysis. ####

  # start by making tiles of the landform variables #
  mason(dirin = file.path(path,  'geomorphons'),
        dirout = file.path(path, 'geodata', 'geomorphons'),
        grid = tile_cellsV, fnames = 'cellname')

  mason(dirin = file.path(path, 'aspect'),
        dirout = file.path(path, 'geodata', 'aspect'),
        grid = tile_cellsV, fnames = 'cellname')

  mason(dirin = file.path(path, 'slope'),
        dirout = file.path(path, 'geodata', 'slope'),
        grid = tile_cellsV, fnames = 'cellname')

  mason(dirin = file.path(path, 'elevation'),
        dirout = file.path(path, 'geodata', 'elevation'),
        grid = tile_cellsV, fnames = 'cellname')

  ## now combine all of the administrative data into a single vector file.
  make_it_political(path, pathOut)

  # Set up Places data set, these are localities we can use google maps to get
  # directions from https://www.youtube.com/watch?v=skZPzx-XlD0
  places_and_spaces(path, pathOut, bound)

  #### process the GMBA data
  process_gmba(path, pathOut, tile_cells)

  ### crop geographic place name database to extent
  process_gnis(path, pathOut, tile_cells)

  ## crop PADUS to domain
  process_padus(path, pathOut, tile_cells)

  ## geological map
  geological_map(path, pathOut, tile_cells)

  ## Process grazing allotments
  process_grazing_allot(path, pathOut, tile_cells)

  ## Public land survey system
  process_plss(path, pathOut, tile_cells)

  if(cleanup==TRUE){
  # remove original zip files.
    zzzs <- list.files(path = path, pattern = '*.[.]zip$')
    file.remove(zzzs)
  }

}

library(magrittr)
# remotes::install_github('sagesteppe/BarnebyLives')
# library(BarnebyLives)
# setwd('/home/sagesteppe/Documents/BL_sandbox')
# data_setup(bound = bound)

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
process_gnis <- function(path, pathOut, tile_cells){
  ### crop geographic place name database to extent
  files <- file.path(path, 'GNIS', 'Text', DomesticNames_, states, '.txt.')
  cols <- c('feature_name', 'prim_lat_dec', 'prim_long_dec')

  places <- lapply(files, read.csv, sep = "|") %>%
    purrr::map(., ~ .x |> dplyr::select(all_of(cols))) %>%
    data.table::rbindlist() %>%
    sf::st_as_sf(coords = c('prim_long_dec', 'prim_lat_dec'), crs = 4269) %>%
    sf::st_transform(4326)

  places <- places[sf::st_intersects(places, sf::st_union(tile_cells)) %>% lengths > 0, ]
  places <- places %>%
    dplyr::mutate(ID = 1:nrow(.))

  sf::st_write(places, dsn = file.path(pathOut, 'geodata', 'places', 'place.shp'), quiet = T)

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
process_gmba <- function(path, pathOut, tile_cells){

  p <- file.path(path, 'GMBA', 'GMBA_Inventory_v2.0_standard_basic.shp')
  mtns <- sf::st_read(p, quiet = T) %>%
    sf::st_make_valid() %>%
    dplyr::select(MapName) %>%
    sf::st_crop(., sf::st_union(tile_cells))|>
    dplyr::rename(Mountains = MapName) |>
    dplyr::mutate(Mountains = stringr::str_remove(Mountains, '[(]nn[])]'))

  sf::st_write(mtns, dsn = file.path(path, 'geodata', 'mountains', 'mountains.shp'), quiet = T)
}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
make_tiles <- function(bound, bb_vals){

  ## need tiles to keep individual raster file tifs relatively small
  tile_cells <- sf::st_make_grid(
    bound,
    what = "polygons", square = T, flat_topped = F, crs = 4326,
    n = c(
      abs(round((bb_vals[2] - bb_vals[1]) / 5, 0)), # rows
      abs(round((bb_vals[3] - bb_vals[4]) / 5, 0))) #cols
  )  %>%
    sf::st_as_sf() %>%
    dplyr::rename(geometry = x) %>%
    dplyr::mutate(
      x = sf::st_coordinates(sf::st_centroid(.))[,1],
      y = sf::st_coordinates(sf::st_centroid(.))[,2],
      .before = geometry,
      dplyr::across(c('x', 'y'), \(x) round(x, 1)),
      cellname = paste0('n', abs(y), 'w', abs(x))
    )

  tile_cellsV <- terra::vect(tile_cells)

  return(
    list(
      'tile_cells' = tile_cells,
      'tile_cellsV' = tile_cellsV
      )
    )

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
make_it_political <- function(path, pathOut, tile_cells){

  ## now combine all of the administrative data into a single vector file.

  p <- file.path(path, 'Counties', 'tl_2020_us_county.shp')
  counties <- sf::st_read(p, quiet = T) %>%
    sf::st_transform(sf::st_crs(tile_cells)) %>%
    dplyr::select(STATEFP, County = NAME)

  states <- tigris::states() %>%
    dplyr::select(STATEFP, State = NAME, STUSPS) %>%
    sf::st_drop_geometry()

  counties <- counties[st_intersects(counties, st_union(tile_cells)) %>% lengths > 0, ]
  counties <- dplyr::left_join(counties, states, by = "STATEFP") %>%
    dplyr::select(-STATEFP) %>%
    dplyr::arrange(STATE)

  p <- file.path(pathOut, 'geodata', 'political', 'political.shp')
  sf::st_write(counties, dsn = p)

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
places_and_spaces <- function(path, pathOut, bound){

  bb <- sf::st_as_sf(bound)

  st <- tigris::states() %>%
    sf::st_transform(4326)
  st <- st[sf::st_intersects(st, bb) %>% lengths > 0, c('STATEFP', 'NAME', 'STUSPS') ]
  places <- lapply(st$STUSPS, tigris::places)

  places <- places %>%
    dplyr::bind_rows() %>%
    dplyr::filter(stringr::str_detect(NAMELSAD, 'city')) %>%
    dplyr::select(STATEFP, NAME) %>%
    sf::st_centroid() %>%
    sf::st_transform(4326)

  places <- places %>%
    dplyr::rename(CITY = NAME) %>%
    dplyr::left_join(., st %>%
                       sf::st_drop_geometry(), by = 'STATEFP') %>%
    dplyr::st_transform(4326)

  places <- places[sf::st_intersects(places, bb) %>% lengths > 0, ]
  places <- sf::st_set_precision(places, precision=10^3)
  # this will drop location coordinates to 3 decimal places.

  places <- places |>
    dplyr::filter(
      !stringr::str_detect(fetr_nm,
                           'Election Precinct| County|Ditch|Unorganized Territory|Canal|Lateral|Division|River Division|Drain Number|Waste Pond|Commissioner District'))|>
    dplyr::mutate(
      fetr_nm = stringr::str_remove(fetr_nm, ' Census Designated Place' ),
      fetr_nm = stringr::str_remove(fetr_nm, 'Township of '),
      fetr_nm = stringr::str_remove(fetr_nm, ' \\(historical\\)'),
      fetr_nm = stringr::str_remove(fetr_nm, 'Village of '),
      fetr_nm = stringr::str_remove(fetr_nm, 'Town of '),
      fetr_nm = stringr::str_remove(fetr_nm, 'City of ')
    )  |>
    dplyr::mutate(
      fetr_nm = stringr::str_replace(fetr_nm, ' Canyon', ' cnyn.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Campground', ' cmpgrnd.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Creek', ' crk.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Fork', ' fk.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Lake', ' lk.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Meadows', ' mdws.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Meadow', ' mdw.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Mountains', ' mtns.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Mountain', ' mtn.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Number', ' #'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Point', ' pt.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' Reservoir', ' rsvr.'),
      fetr_nm = stringr::str_replace(fetr_nm, ' River ', ' rvr.')
    )

  sf::st_write(pathOut, 'geodata', 'places.shp', append = F)
}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
process_padus <- function(path, pathOut, tile_cells){

  p <- file.path(path, 'PADUS3', 'PAD_US3_0.gdb')
  padus <- sf::st_read(
    dsn = p,
    layer = 'PADUS3_0Fee') %>%
    dplyr::filter(State_Nm %in% states) %>%
    dplyr::select(Mang_Name, Unit_Nm) %>%
    sf::st_cast('MULTIPOLYGON')

  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(padus))
  padus <- padus[sf::st_intersects(padus, sf::st_union(tile_cells)) %>% lengths > 0, ]
  padus <- sf::st_transform(padus, crs = 4326)

  sf::st_write(padus, dsn = file.path(path, 'geodata', 'pad.shp'), quiet = T)

  # replace really long state land board names with 'STATE SLB'
  padus <- sf::st_read('../../Barneby_Lives-dev/geodata/pad/pad.shp')

  padus <- padus %>% # this one is just a wild outlier.
    dplyr::mutate(Unit_Nm =
                    string::str_replace(
                      Unit_Nm,
                      'The State of Utah School and Institutional Trust Lands Administration', 'Utah')
    ) %>%
    dplyr::mutate(
      Unit_Nm = str_replace(Unit_Nm, "National Forest", "NF"),
      Unit_Nm = str_replace(Unit_Nm, "District Office", "DO"),
      Unit_Nm = str_replace(Unit_Nm, "Field Office", "FO"),
      Unit_Nm = str_replace(Unit_Nm, "National Park", "NP"),
      Unit_Nm = str_replace(Unit_Nm, 'National Grassland', 'NG'),
      Unit_Nm = str_replace(Unit_Nm, "National Wildlife Refuge|National Wildlife Range", "NWR"),
      Unit_Nm = str_replace(Unit_Nm, 'National Monument', 'NM'),
      Unit_Nm = str_replace(Unit_Nm, "National Recreation Area", "NRA"),
      Unit_Nm = str_replace(Unit_Nm, "State Resource Management Area", "SRMA"),
      Unit_Nm = str_replace(Unit_Nm, "State Trust Lands", "STL"),
      Unit_Nm = str_replace(Unit_Nm, "Department", "Dept."),
      Unit_Nm = str_replace(Unit_Nm, "Recreation Area", "Rec. Area"),
      Unit_Nm = str_replace(Unit_Nm, 'Wildlife Habitat Management Area', "WHMA"),
      Unit_Nm = str_replace(Unit_Nm, 'Wildlife Management Area', "WMA")
      )

  padus <- padus %>%
    sf::st_make_valid() %>%
    dplyr::filter(sf::st_is_valid(.)) %>%
    sf::st_write(padus, dsn = file.path(pathOut, 'pad.shp'), quiet = T, append = F)

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
geological_map <- function(path, pathOut, tile_cells){

  geological <- sf::st_read(
    file.path(path, 'SGMC', 'USGS_StateGeologicMapCompilation_ver1.1.gdb'),
    layer = 'SGMC_Geology', quiet = T) %>%
    dplyr::select(GENERALIZED_LITH, UNIT_NAME)

  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(geological))
  geological <- geological[sf::st_intersects(geological, sf::st_union(tile_cells)) %>% lengths > 0, ]
  geological <- sf::st_crop(geological, sf::st_union(tile_cells))
  geological <- sf::st_transform(geological, 4326)

  sf::st_write(geological, dsn = file.path(pathOut, 'geodata', 'geology.shp'), quiet = T)

  tile_cells <- sf::st_transform(tile_cells, crs = 4326)

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
process_grazing_allot <- function(path, pathOut, tile_cells){

  p <- file.path(path, 'BLMAllotments', 'BLM_Natl_Grazing_Allotment_Polygons.shp')
  p1 <- file.path(path, 'USFSAllotment', 'S_USA.Allotment.shp')
  blm <- sf::st_read(p, quiet = TRUE) %>%
    dplyr::select(ALLOT_NAME)

  usfs <- sf::st_read(p1, quiet = TRUE) %>%
    dplyr::select(ALLOT_NAME = ALLOTMENT_)

  allotments <- dplyr::bind_rows(blm, usfs) %>%
    sf::st_make_valid()
  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(allotments))
  allotments <- allotments[sf::st_intersects(allotments, sf::st_union(tile_cells)) %>% lengths > 0, ]
  allotments <- sf::st_crop(allotments, sf::st_union(tile_cells))
  allotments <- sf::st_transform(allotments, 4326) %>%
    dplyr::mutate(Allotment = stringr::str_to_title(ALLOT_NAME)) %>%
    dplyr::select(-ALLOT_NAME) %>%

  sf::st_write(
    allotments,  quiet = T,
    dsn = file.path(pathOut, 'geodata', 'allotments', 'allotments.shp')
    )

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
process_plss <- function(path, pathOut, tile_cells){

  p <- file.path(path, 'PLSS', 'ilmocplss.gdb')
  township <- sf::st_read(p, layer = 'PLSSTownship', quiet = T
  ) %>%
    sf::st_cast('POLYGON') %>%
    dplyr::select(TWNSHPLAB, PLSSID)

  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(township))
  township <- township[sf::st_intersects(township, tile_cells) %>% lengths > 0, ]
  township <- sf::st_drop_geometry(township)

  section <- sf::st_read(p, layer = 'PLSSFirstDivision', quiet = T
  ) %>%
    sf::st_cast('POLYGON') %>%
    dplr::select(FRSTDIVLAB, PLSSID, FRSTDIVID)

  section <- section[sf::st_intersects(section, tile_cells) %>% lengths > 0, ]

  trs <- dplyr::inner_join(section, township, 'PLSSID') %>%
    dplyr::mutate(TRS = paste(TWNSHPLAB, FRSTDIVLAB)) %>%
    dplyr::select(trs = TRS)

  sf::st_write(trs, dsn = file.path(pathOut, 'geodata', 'plss', 'plss.shp'), quiet = T)

}



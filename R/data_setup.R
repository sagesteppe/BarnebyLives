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
#' If FALSE, this will also bundle the downloaded topographic variables into their own directories,
#' e.g. all directories of 'aspect' rasters will go into a single 'aspect' directory.
#' @examples \dontrun{
#' bound <- data.frame(
#'   y = c(42, 42, 44, 44, 42),
#'   x = c(-117, -119, -119, -117, -117)
#' )
#'
#' data_setup(path = './geodata_raw', bound = bound, cleanup = FALSE)
#' }
#' @export
data_setup <- function(path, pathOut, bound, cleanup){

  if(missing(path)){path <- './geodata_raw'}
  if(missing(pathOut)){pathOut <- '.'}
  pathOut <- file.path(pathOut, 'geodata')
  dir.create(pathOut, showWarnings = FALSE)
  if(missing(cleanup)){cleanup = FALSE}

  # create the extent which we are operating in
  bb_vals <- c(min(bound$x), max(bound$x), min(bound$y), max(bound$y))
  bound <- bound |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()

  # decompress all of the archives so we can readily read them into R.
  zzzs <- file.path(path, list.files(path = path, pattern = '*.[.]zip$'))

  lapply(zzzs, FUN = function(x){
    out <- gsub('[.]zip', '' , x)
    unzip(x, exdir = out)}
    )

  # use tiles to create many smaller rasters, rather than one really big raster.
  mt <- make_tiles(bound, bb_vals)
  tile_cells <- mt$tile_cells
  tile_cellsV <- mt$tile_cellsV

  ##### now crop the data to the extents of analysis. ####
  mason(path, pathOut, tile_cellsV)

  ## now combine all of the administrative data into a single vector file.
  make_it_political(path, pathOut, tile_cells)

  #### process the GMBA data
  process_gmba(path, pathOut, tile_cells)

  ### crop geographic place name database to extent
  process_gnis(path, pathOut, bound)

  ## crop PADUS to domain
  process_padus(path, pathOut, tile_cells)

  ## geological map
  geological_map(path, pathOut, tile_cells)

  ## Process grazing allotments
  process_grazing_allot(path, pathOut, tile_cells)

  ## Public land survey system
  process_plss(path, pathOut, tile_cells)

  # remove the extracted zip files
  dirs <- list.dirs('geodata_raw', recursive = FALSE)
  lapply(dirs, unlink, recursive = TRUE)

  if(cleanup==TRUE){
  # remove original zip files.
    zzzs <- file.path(path, list.files(path = path, pattern = '*.[.]zip$'))
    lapply(zzzs, FUN = function(x){
      out <- gsub('[.]zip', '' , x)
      unzip(x, exdir = out)}
    )
  }

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
make_tiles <- function(bound, bb_vals){

  ## need tiles to keep individual raster file tifs relatively small
  tile_cells <- sf::st_make_grid(
    bound,
    what = "polygons", square = T, flat_topped = F, crs = 4326,
    n = c(
      # for a very small domain, both values need to be set to one
      ceiling(abs(bb_vals[2] - bb_vals[1]) / 5), # rows
      ceiling(abs(bb_vals[3] - bb_vals[4]) / 5)) #cols
  ) |>
    sf::st_as_sf() |>
    dplyr::rename(geometry = x) %>%
    dplyr::mutate(
      x = sf::st_coordinates(sf::st_centroid(.))[,1],
      y = sf::st_coordinates(sf::st_centroid(.))[,2],
      .before = geometry,
      dplyr::across(c('x', 'y'), \(x) round(x, 1)),
      cellname = paste0('n', abs(y), 'w', abs(x))
    )

  tile_cellsV <- terra::vect(tile_cells)

  list(
    'tile_cells' = tile_cells,
    'tile_cellsV' = tile_cellsV
  )

}

#' a wrapper around terra::makeTiles for setting the domain of a project
#'
#' @description for projects with large spatial domains or using relatively high resolution data, this will help
#'
#' you make virtual tiles which do not need to be held in memory for the project.
#' @param path the input directory with all geographic data.
#' @param pathOut the output directory for the final data product to go.
#' Fn will automatically create folders for each product type.
#' @param tile_cellsV output of `make_tiles`
#' @keywords internal
mason <- function(path, pathOut, tile_cellsV){

  paths2rast <- file.path(path, list.files(path,  recursive = T, pattern = '[.]tar'))

  prods <- c('aspect', 'dem', 'geom', 'slope')
  for (i in seq_along(1:length(prods))){

    outdir <- file.path(pathOut, prods[i])
    if(!dir.exists(outdir)){
      dir.create(outdir) # test the path works before running the big steps...

      # extract all data and temporarily dump into a single directory
      message(crayon::green('Beginning extraction of files:',
                            prods[i], format(Sys.time(), "%X")))
      f <- paths2rast[grep(prods[i], paths2rast)]
      temp <- file.path(dirname(f[i]), prods[i])
      sapply(X = f, FUN = untar, exdir = temp)

      # now form a VRT, meaning files don't need to be read into active memory (RAM)
      # all at once. Now crop all files to the extent of the spatial domain we are
      # setting the program up for.
      paths <- file.path(temp, list.files(temp, pattern = '[.]tif$', recursive = TRUE))
      virtualRast <- terra::vrt(paths)
      virtualRast_sub <- terra::crop(virtualRast, terra::ext(tile_cellsV))

      # set file names
      columns <- terra::values(tile_cellsV)
      cellname <- columns[,'cellname']

      # write out product
      message(crayon::green('Starting to write out final files for:',
                            prods[i], format(Sys.time(), "%X")))
      fname <- file.path(outdir, paste0(cellname, ".tif"))
      terra::makeTiles(virtualRast_sub, tile_cellsV, filename = fname, na.rm = F)

      # remove connection to the vrt
      rm(virtualRast_sub)
      # try and force garbage collection
      # remove extracted dir.
      unlink(file.path(dirname(f[i]), prods[i]), recursive = TRUE)
      gc()
    }
  }
}


#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
make_it_political <- function(path, pathOut, tile_cells){

  ## now combine all of the administrative data into a single vector file.

  p <- file.path(path, 'Counties', 'tl_2020_us_county.shp')
  counties <- sf::st_read(p, quiet = T) |>
    sf::st_transform(sf::st_crs(tile_cells))  |>
    dplyr::select(STATEFP, County = NAME)

  states <- tigris::states(progress_bar = FALSE, year = 2022) |>
    dplyr::select(STATEFP, State = NAME, STUSPS)  |>
    sf::st_drop_geometry()

  sf::st_agr(counties) <- 'constant'
  sf::st_agr(tile_cells) <- 'constant'
  counties <- counties[sf::st_intersects(counties, sf::st_union(tile_cells)) %>% lengths > 0, ]
  counties <- dplyr::left_join(counties, states, by = "STATEFP") |>
    dplyr::select(-STATEFP) |>
    dplyr::arrange(State)

  dir.create(file.path(pathOut, 'political'), showWarnings = FALSE)
  p <- file.path(pathOut, 'political', 'political.shp')
  sf::st_write(counties, dsn = p, quiet = TRUE, append = FALSE)

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
places_and_spaces <- function(path, pathOut, bound){

  bb <- sf::st_as_sf(bound)

  st <- tigris::states(progress_bar = FALSE, year = 2022) |>
    sf::st_transform(4326)
  st <- st[sf::st_intersects(st, bb) %>% lengths > 0, c('STATEFP', 'NAME', 'STUSPS') ]
  places <- lapply(st$STATEFP, tigris::places, progress_bar = FALSE, year = 2022)

  places <- places |>
    dplyr::bind_rows() |>
    dplyr::filter(stringr::str_detect(NAMELSAD, 'city')) |>
    dplyr::select(STATEFP, NAME)

  sf::st_agr(places) <- 'constant'
  places <- places |>
    sf::st_centroid() |>
    sf::st_transform(4326)

  places <- places  |>
    dplyr::rename(CITY = NAME)  |>
    dplyr::left_join(., st  |>
                       sf::st_drop_geometry(), by = 'STATEFP') |>
    sf::st_transform(4326)

  places <- places[sf::st_intersects(places, bb) %>% lengths > 0, ]
  places <- sf::st_set_precision(places, precision=10^3)
  # this will drop location coordinates to 3 decimal places.

  sf::st_write(pathOut, 'places.shp', append = FALSE)
}


#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
process_gmba <- function(path, pathOut, tile_cells){

  p <- file.path(path, 'GMBA', 'GMBA_Inventory_v2.0_standard_basic.shp')
  mtns <- sf::st_read(p, quiet = T) |>
    sf::st_make_valid()
  st_agr(mtns) = "constant"
  mtns <- mtns |>
    dplyr::select(MapName) |>
    sf::st_crop(sf::st_union(tile_cells))|>
    dplyr::rename(Mountains = MapName) |>
    dplyr::mutate(Mountains = stringr::str_remove(Mountains, '[(]nn[])]'))

  dir.create(file.path(pathOut, 'mountains'), showWarnings = FALSE)
  sf::st_write(mtns, dsn = file.path(pathOut, 'mountains', 'mountains.shp'),
               quiet = TRUE, append= FALSE)
}


#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
process_gnis <- function(path, pathOut, bound){

  bb <- sf::st_as_sf(bound)
  st <- tigris::states(progress_bar = FALSE, year = 2022) |>
    sf::st_transform(4326)
  st <- st[sf::st_intersects(st, bb) %>% lengths > 0, c('STATEFP', 'NAME', 'STUSPS') ]

  ### crop geographic place name database to extent
  p2dat <- file.path(path, 'GNIS', 'Text')
  files <- file.path(p2dat, list.files(p2dat))
  patterns <- paste0('DomesticNames_', st$STUSPS, '.txt', collapse = '|')

  files <- files[ grep(patterns, files)]
  cols <- c('feature_name', 'prim_lat_dec', 'prim_long_dec')

  places <- lapply(files, read.csv, sep = "|")  %>%
    purrr::map(., ~ .x |> dplyr::select(all_of(cols)))  |>
    data.table::rbindlist()  |>
    sf::st_as_sf(coords = c('prim_long_dec', 'prim_lat_dec'), crs = 4269) |>
    sf::st_transform(4326)

  sf::st_agr(places) <- 'constant'
  places <- places[sf::st_intersects(places, bb) %>% lengths > 0, ]
  places <- places  |>
    dplyr::mutate(ID = seq_len(dplyr::n())) |>
    dplyr::rename(fetr_nm = feature_name)

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


  dir.create(file.path(pathOut, 'places'), showWarnings = FALSE)
  sf::st_write(places,
               dsn = file.path(pathOut, 'places', 'place.shp'),
               quiet = TRUE, append = FALSE)

}


setwd('/media/steppe/hdd/BL_sandbox/geodata_raw')
path = '.'
#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
process_padus <- function(path, pathOut, tile_cells){

  states <- tigris::states(cb = TRUE, year = 2022, progress_bar = FALSE)
  states <- states[
    unlist(sf::st_intersects(
      sf::st_transform(bound, sf::st_crs(states)),
      states
    )),'STUSPS'
  ] |>
    sf::st_drop_geometry() |>
    dplyr::pull(STUSPS)

  p <- file.path(path, 'PADUS4_0Geodatabase', 'PADUS4_0_Geodatabase.gdb')
  padus <- sf::st_read(
    dsn = p, quiet = TRUE,
    layer = 'PADUS4_0Fee')  |>
    dplyr::filter(State_Nm %in% states)  |>
    dplyr::select(Mang_Name, Unit_Nm)  |>
    sf::st_cast('MULTIPOLYGON')

  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(padus))
  padus <- padus[sf::st_intersects(padus, sf::st_union(tile_cells)) %>% lengths > 0, ]
  padus <- sf::st_transform(padus, crs = 4326)
  padus <- sf::st_make_valid(padus)
  padus <- dplyr::filter(sf::st_is_valid(padus))

  # replace really long state land board names with 'STATE SLB'
  padus <- padus  |> # this one is just a wild outlier.
    dplyr::mutate(
      Unit_Nm =
        stringr::str_replace(
          Unit_Nm,
          'The State of Utah School and Institutional Trust Lands Administration',
          'Utah')
    )  |>
    dplyr::mutate(
      Unit_Nm = stringr::str_replace(Unit_Nm, "National Forest", "NF"),
      Unit_Nm = stringr::str_replace(Unit_Nm, "District Office", "DO"),
      Unit_Nm = stringr::str_replace(Unit_Nm, "Field Office", "FO"),
      Unit_Nm = stringr::str_replace(Unit_Nm, "National Park", "NP"),
      Unit_Nm = stringr::str_replace(Unit_Nm, 'National Grassland', 'NG'),
      Unit_Nm = stringr::str_replace(Unit_Nm, "National Wildlife Refuge|National Wildlife Range", "NWR"),
      Unit_Nm = stringr::str_replace(Unit_Nm, 'National Monument', 'NM'),
      Unit_Nm = stringr::str_replace(Unit_Nm, "National Recreation Area", "NRA"),
      Unit_Nm = stringr::str_replace(Unit_Nm, "State Resource Management Area", "SRMA"),
      Unit_Nm = stringr::str_replace(Unit_Nm, "State Trust Lands", "STL"),
      Unit_Nm = stringr::str_replace(Unit_Nm, "Department", "Dept."),
      Unit_Nm = stringr::str_replace(Unit_Nm, "Recreation Area", "Rec. Area"),
      Unit_Nm = stringr::str_replace(Unit_Nm, 'Wildlife Habitat Management Area', "WHMA"),
      Unit_Nm = stringr::str_replace(Unit_Nm, 'Wildlife Management Area', "WMA")
      )

    sf::st_write(
      padus,
      dsn = file.path(pathOut, 'pad.shp'),
      quiet = TRUE, append = FALSE)

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
geological_map <- function(path, pathOut, tile_cells){

  geological <- sf::st_read(
    file.path(path, 'SGMC', 'USGS_SGMC_Geodatabase',
              'USGS_StateGeologicMapCompilation_ver1.1.gdb'),
    layer = 'SGMC_Geology', quiet = T) |>
    dplyr::select(GENERALIZED_LITH, UNIT_NAME)

  st_agr(tile_cells) = "constant"
  st_agr(geological) = "constant"
  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(geological))
  geological <- geological[
    sf::st_intersects(geological, sf::st_union(tile_cells)) %>% lengths > 0, ]
  geological <- sf::st_crop(geological, sf::st_union(tile_cells))
  geological <- sf::st_transform(geological, 4326)


  dir.create(file.path(pathOut, 'geology'), showWarnings = FALSE)
  sf::st_write(
    geological,
    dsn = file.path(pathOut, 'geology', 'geology.shp'),
    quiet = TRUE, append = FALSE)

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
process_grazing_allot <- function(path, pathOut, tile_cells){

  p <- file.path(path, 'BLMAllotments', 'BLM_Natl_Grazing_Allotment_Polygons.shp')
  p1 <- file.path(path, 'USFSAllotments', 'S_USA.Allotment.shp')
  blm <- sf::st_read(p, quiet = TRUE) |>
    dplyr::select(ALLOT_NAME)

  usfs <- sf::st_read(p1, quiet = TRUE) |>
    dplyr::select(ALLOT_NAME = ALLOTMENT_)

  allotments <- dplyr::bind_rows(blm, usfs) |>
    sf::st_make_valid()
  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(allotments))
  st_agr(tile_cells) = "constant"
  st_agr(allotments) = "constant"

  allotments <- allotments[
    sf::st_intersects(allotments, sf::st_union(tile_cells)) %>% lengths > 0, ]
  allotments <- sf::st_crop(allotments, sf::st_union(tile_cells))
  allotments <- sf::st_transform(allotments, 4326) |>
    dplyr::mutate(Allotment = stringr::str_to_title(ALLOT_NAME)) |>
    dplyr::select(-ALLOT_NAME)

  dir.create(file.path(pathOut, 'allotments'), showWarnings = FALSE)
  sf::st_write(
    allotments,  quiet = TRUE, append = FALSE,
    dsn = file.path(pathOut, 'allotments', 'allotments.shp')
    )

}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
process_plss <- function(path, pathOut, tile_cells){

  p <- file.path(path, 'PLSS', 'ilmocplss.gdb')
  township <- sf::st_read(p, layer = 'PLSSTownship', quiet = TRUE
  ) |>
    sf::st_cast('POLYGON') |>
    dplyr::select(TWNSHPLAB, PLSSID)

  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(township))
  township <- township[sf::st_intersects(township, tile_cells) %>% lengths > 0, ]
  township <- sf::st_drop_geometry(township)

  section <- sf::st_read(p, layer = 'PLSSFirstDivision', quiet = TRUE) |>
    sf::st_cast('POLYGON') |>
    dplyr::select(FRSTDIVLAB, PLSSID, FRSTDIVID)

  section <- section[sf::st_intersects(section, tile_cells) %>% lengths > 0, ]

  trs <- dplyr::inner_join(section, township, 'PLSSID') |>
    dplyr::mutate(TRS = paste(TWNSHPLAB, FRSTDIVLAB)) |>
    dplyr::select(trs = TRS)

  sf::st_write(trs, dsn = file.path(pathOut, 'plss', 'plss.shp'), quiet = TRUE)

}


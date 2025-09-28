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
#' setwd('/media/steppe/hdd/BL_sandbox/geodata_raw')
#' data_setup(path = '.', pathOut = '../geodata', bound = bound, cleanup = FALSE)
#' }
#' @export
data_setup <- function(path, pathOut, bound, cleanup) {
  if (missing(path)) {
    path <- file.path('.', 'geodata_raw')
  }
  if (missing(pathOut)) {
    pathOut <- file.path('..', 'geodata')
  }
  dir.create(pathOut, showWarnings = FALSE)
  if (missing(cleanup)) {
    cleanup = FALSE
  }

  # create the extent which we are operating in
  bb_vals <- c(min(bound$x), max(bound$x), min(bound$y), max(bound$y))
  bound <- bound |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()

  # decompress all of the archives so we can readily read them into R.
  zzzs <- file.path(path, list.files(path = path, pattern = '*.[.]zip$'))

  message(
    crayon::green(
      'Beginning extraction  ("unzipping") of raw download directories:',
      format(Sys.time(), "%X")
    )
  )

  lapply(zzzs, function(x) {
    out <- gsub('[.]zip$', '', x)
    if (dir.exists(out) && length(list.files(out)) > 0) {
      message(crayon::yellow(
        "Skipping already-unzipped archive: ",
        basename(x)
      ))
    } else {
      message(crayon::green("Extracting: ", basename(x)))
      unzip(x, exdir = out)
    }
  })

  safe_run <- function(step_name, expr) {
    tryCatch(
      expr,
      error = function(e) {
        message(crayon::red(paste0("Error in ", step_name, ": ", e$message)))
      }
    )
  }

  # use tiles to create many smaller rasters, rather than one really big raster.
  mt <- make_tiles(bound, bb_vals)
  tile_cells <- mt$tile_cells
  tile_cellsV <- mt$tile_cellsV

  success <- TRUE
  steps <- list(
    mason = function() mason(path, pathOut, tile_cellsV),
    make_it_political = function() make_it_political(path, pathOut, tile_cells),
    process_gmba = function() process_gmba(path, pathOut, tile_cells),
    process_gnis = function() process_gnis(path, pathOut, bound),
    process_padus = function() process_padus(path, pathOut, bound, tile_cells),
    geological_map = function() geological_map(path, pathOut, tile_cells),
    process_grazing_allot = function() {
      process_grazing_allot(path, pathOut, tile_cells)
    },
    process_plss = function() process_plss(path, pathOut, tile_cells)
  )

  for (nm in names(steps)) {
    message(crayon::blue("Running step: ", nm))
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

  # --- Cleanup ---
  if (success) {
    message(crayon::green("All steps succeeded. Cleaning up unzipped data..."))
    dirs <- list.dirs(path, recursive = FALSE)
    lapply(dirs, unlink, recursive = TRUE)
  } else {
    message(crayon::yellow(
      "Not all steps succeeded. Preserving unzipped data for debugging."
    ))
  }

  if (cleanup && success) {
    # remove original zip files too
    zzzs <- file.path(path, list.files(path = path, pattern = '*.[.]zip$'))
    lapply(zzzs, unlink)
    message(crayon::green(
      "all steps succeeded. Original data downloads removed to save memory."
    ))
  }
}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
make_tiles <- function(bound, bb_vals) {
  ## need tiles to keep individual raster file tifs relatively small
  tile_cells <- sf::st_make_grid(
    bound,
    what = "polygons",
    square = T,
    flat_topped = F,
    crs = 4326,
    n = c(
      # for a very small domain, both values need to be set to one
      ceiling(abs(bb_vals[2] - bb_vals[1]) / 5), # rows
      ceiling(abs(bb_vals[3] - bb_vals[4]) / 5)
    ) #cols
  ) |>
    sf::st_as_sf() |>
    dplyr::rename(geometry = x) %>%
    dplyr::mutate(
      x = sf::st_coordinates(sf::st_centroid(.))[, 1],
      y = sf::st_coordinates(sf::st_centroid(.))[, 2],
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
mason <- function(path, pathOut, tile_cellsV) {
  paths2rast <- file.path(
    path,
    list.files(path, recursive = TRUE, pattern = '[.]tar(\\.gz)?$')
  )

  prods <- c('aspect', 'dem', 'geom', 'slope')
  for (i in seq_len(length(prods))) {
    outdir <- file.path(pathOut, prods[i])
    if (!dir.exists(outdir)) {
      dir.create(outdir) # ensure output dir exists

      # extract all data and temporarily dump into a single directory
      message(crayon::green(
        "Beginning extraction of raster files:",
        prods[i],
        format(Sys.time(), "%X")
      ))

      f <- paths2rast[grep(prods[i], paths2rast)]
      if (length(f) == 0) {
        message(crayon::yellow(
          "No archives found for ",
          prods[i],
          ". Skipping."
        ))
        next
      }

      temp <- file.path(dirname(f[1]), prods[i])
      if (!dir.exists(temp)) {
        dir.create(temp, recursive = TRUE)
      }

      invisible(lapply(f, function(x) {
        tryCatch(
          safe_untar(x, exdir = temp, verbose = TRUE),
          error = function(e) {
            message(crayon::red("Problem extracting ", x, ": ", e$message))
          }
        )
      }))

      # now form a VRT, meaning files don't need to be read into active memory (RAM)
      paths <- file.path(
        temp,
        list.files(temp, pattern = '[.]tif$', recursive = TRUE)
      )
      virtualRast <- terra::vrt(paths)
      virtualRast_sub <- terra::crop(virtualRast, terra::ext(tile_cellsV))

      # set file names
      columns <- terra::values(tile_cellsV)
      cellname <- columns[, "cellname"]

      # write out product
      message(crayon::green(
        "Starting to write out final raster files for:",
        prods[i],
        format(Sys.time(), "%X")
      ))
      fname <- file.path(outdir, paste0(cellname, ".tif"))
      terra::makeTiles(
        virtualRast_sub,
        tile_cellsV,
        filename = fname,
        na.rm = FALSE
      )

      # clean up
      rm(virtualRast_sub)
      unlink(temp, recursive = TRUE)
      gc()
    }
  }

  message(crayon::green(
    "Done with processing raster data. ",
    format(Sys.time(), "%X")
  ))
}


#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
make_it_political <- function(path, pathOut, tile_cells) {
  ## now combine all of the administrative data into a single vector file.

  p <- file.path(path, 'Counties', 'tl_2020_us_county.shp')
  counties <- sf::st_read(p, quiet = T) |>
    sf::st_transform(sf::st_crs(tile_cells)) |>
    dplyr::select(STATEFP, County = NAME)

  states <- tigris::states(progress_bar = FALSE, year = 2022) |>
    dplyr::select(STATEFP, State = NAME, STUSPS) |>
    sf::st_drop_geometry()

  sf::st_agr(counties) <- 'constant'
  sf::st_agr(tile_cells) <- 'constant'
  counties <- counties[
    sf::st_intersects(counties, sf::st_union(tile_cells)) %>% lengths > 0,
  ]
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
places_and_spaces <- function(path, pathOut, bound) {
  bb <- sf::st_as_sf(bound)

  st <- tigris::states(progress_bar = FALSE, year = 2022) |>
    sf::st_transform(4326)
  st <- st[
    sf::st_intersects(st, bb) %>% lengths > 0,
    c('STATEFP', 'NAME', 'STUSPS')
  ]
  places <- lapply(
    st$STATEFP,
    tigris::places,
    progress_bar = FALSE,
    year = 2022
  )

  places <- places |>
    dplyr::bind_rows() |>
    dplyr::filter(stringr::str_detect(NAMELSAD, 'city')) |>
    dplyr::select(STATEFP, NAME)

  sf::st_agr(places) <- 'constant'
  places <- places |>
    sf::st_centroid() |>
    sf::st_transform(4326)

  places <- places |>
    dplyr::rename(CITY = NAME) |>
    dplyr::left_join(
      .,
      st |>
        sf::st_drop_geometry(),
      by = 'STATEFP'
    ) |>
    sf::st_transform(4326)

  places <- places[sf::st_intersects(places, bb) %>% lengths > 0, ]
  places <- sf::st_set_precision(places, precision = 10^3)
  # this will drop location coordinates to 3 decimal places.

  sf::st_write(pathOut, 'places.shp', append = FALSE)
  message(crayon::green(
    "Done with writing `places` data set. ",
    format(Sys.time(), "%X")
  ))
}


#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
process_gmba <- function(path, pathOut, tile_cells) {
  p <- file.path(path, 'GMBA', 'GMBA_Inventory_v2.0_standard_basic.shp')
  mtns <- sf::st_read(p, quiet = T) |>
    sf::st_make_valid()
  sf::st_agr(mtns) = "constant"
  mtns <- mtns |>
    dplyr::select(MapName) |>
    sf::st_crop(sf::st_union(tile_cells)) |>
    dplyr::rename(Mountains = MapName) |>
    dplyr::mutate(Mountains = stringr::str_remove(Mountains, '[(]nn[])]'))

  dir.create(file.path(pathOut, 'mountains'), showWarnings = FALSE)
  sf::st_write(
    mtns,
    dsn = file.path(pathOut, 'mountains', 'mountains.shp'),
    quiet = TRUE,
    append = FALSE
  )

  message(crayon::green(
    "Done with writing `mountains` data set. ",
    format(Sys.time(), "%X")
  ))
}


#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
process_gnis <- function(path, pathOut, bound) {
  bb <- sf::st_as_sf(bound)
  st <- tigris::states(progress_bar = FALSE, year = 2022) |>
    sf::st_transform(4326)
  st <- st[
    sf::st_intersects(st, bb) %>% lengths > 0,
    c('STATEFP', 'NAME', 'STUSPS')
  ]

  ### crop geographic place name database to extent
  p2dat <- file.path(path, 'GNIS', 'Text')
  files <- file.path(p2dat, list.files(p2dat))
  patterns <- paste0('DomesticNames_', st$STUSPS, '.txt', collapse = '|')

  files <- files[grep(patterns, files)]
  cols <- c('feature_name', 'prim_lat_dec', 'prim_long_dec')

  places <- lapply(files, read.csv, sep = "|") %>%
    purrr::map(., ~ .x |> dplyr::select(all_of(cols))) |>
    data.table::rbindlist() |>
    sf::st_as_sf(coords = c('prim_long_dec', 'prim_lat_dec'), crs = 4269) |>
    sf::st_transform(4326)

  sf::st_agr(places) <- 'constant'
  places <- places[sf::st_intersects(places, bb) %>% lengths > 0, ]
  places <- places |>
    dplyr::mutate(ID = seq_len(dplyr::n())) |>
    dplyr::rename(fetr_nm = feature_name)

  places <- places |>
    dplyr::filter(
      !stringr::str_detect(
        fetr_nm,
        'Election Precinct| County|Ditch|Unorganized Territory|Canal|Lateral|Division|River Division|Drain Number|Waste Pond|Commissioner District'
      )
    ) |>
    dplyr::mutate(
      fetr_nm = stringr::str_remove(fetr_nm, ' Census Designated Place'),
      fetr_nm = stringr::str_remove(fetr_nm, 'Township of '),
      fetr_nm = stringr::str_remove(fetr_nm, ' \\(historical\\)'),
      fetr_nm = stringr::str_remove(fetr_nm, 'Village of '),
      fetr_nm = stringr::str_remove(fetr_nm, 'Town of '),
      fetr_nm = stringr::str_remove(fetr_nm, 'City of ')
    ) |>
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
  sf::st_write(
    places,
    dsn = file.path(pathOut, 'places', 'places.shp'),
    quiet = TRUE,
    append = FALSE
  )
}


#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
process_padus <- function(path, pathOut, bound, tile_cells) {
  states <- tigris::states(cb = TRUE, year = 2022, progress_bar = FALSE)
  states <- states[
    unlist(sf::st_intersects(
      sf::st_transform(bound, sf::st_crs(states)),
      states
    )),
    'STUSPS'
  ] |>
    sf::st_drop_geometry() |>
    dplyr::pull(STUSPS)

  p <- file.path(path, 'PADUS4_0Geodatabase', 'PADUS4_0_Geodatabase.gdb')
  padus <- sf::st_read(
    dsn = p,
    quiet = TRUE,
    layer = 'PADUS4_0Fee'
  ) |>
    dplyr::filter(State_Nm %in% states) |>
    dplyr::select(Mang_Name, Unit_Nm) |>
    sf::st_cast('MULTIPOLYGON')

  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(padus))
  padus <- sf::st_make_valid(padus)
  padus <- padus[
    sf::st_intersects(padus, sf::st_union(tile_cells)) %>% lengths > 0,
  ]
  padus <- sf::st_transform(padus, crs = 4326)
  padus <- dplyr::filter(padus, sf::st_is_valid(padus))

  # replace really long state land board names with 'STATE SLB'
  padus <- padus |> # this one is just a wild outlier.
    dplyr::mutate(
      Unit_Nm = stringr::str_replace(
        Unit_Nm,
        'The State of Utah School and Institutional Trust Lands Administration',
        'Utah'
      )
    ) |>
    dplyr::mutate(
      Unit_Nm = stringr::str_replace(Unit_Nm, "National Forest", "NF"),
      Unit_Nm = stringr::str_replace(Unit_Nm, "District Office", "DO"),
      Unit_Nm = stringr::str_replace(Unit_Nm, "Field Office", "FO"),
      Unit_Nm = stringr::str_replace(Unit_Nm, "National Park", "NP"),
      Unit_Nm = stringr::str_replace(Unit_Nm, 'National Grassland', 'NG'),
      Unit_Nm = stringr::str_replace(
        Unit_Nm,
        "National Wildlife Refuge|National Wildlife Range",
        "NWR"
      ),
      Unit_Nm = stringr::str_replace(Unit_Nm, 'National Monument', 'NM'),
      Unit_Nm = stringr::str_replace(
        Unit_Nm,
        "National Recreation Area",
        "NRA"
      ),
      Unit_Nm = stringr::str_replace(
        Unit_Nm,
        "State Resource Management Area",
        "SRMA"
      ),
      Unit_Nm = stringr::str_replace(Unit_Nm, "State Trust Lands", "STL"),
      Unit_Nm = stringr::str_replace(Unit_Nm, "Department", "Dept."),
      Unit_Nm = stringr::str_replace(Unit_Nm, "Recreation Area", "Rec. Area"),
      Unit_Nm = stringr::str_replace(
        Unit_Nm,
        'Wildlife Habitat Management Area',
        "WHMA"
      ),
      Unit_Nm = stringr::str_replace(Unit_Nm, 'Wildlife Management Area', "WMA")
    )

  dir.create(file.path(pathOut, 'pad'), showWarnings = FALSE)
  sf::st_write(
    padus,
    dsn = file.path(pathOut, 'pad', 'pad.shp'),
    quiet = TRUE,
    append = FALSE
  )

  message(crayon::green(
    "Done with writing `PADUS` data set. ",
    format(Sys.time(), "%X")
  ))
}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
geological_map <- function(path, pathOut, tile_cells) {
  geological <- sf::st_read(
    file.path(
      path,
      'SGMC',
      'USGS_SGMC_Geodatabase',
      'USGS_StateGeologicMapCompilation_ver1.1.gdb'
    ),
    layer = 'SGMC_Geology',
    quiet = T
  ) |>
    dplyr::select(GENERALIZED_LITH, UNIT_NAME)

  sf::st_agr(tile_cells) = "constant"
  sf::st_agr(geological) = "constant"
  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(geological))
  geological <- geological[
    sf::st_intersects(geological, sf::st_union(tile_cells)) %>% lengths > 0,
  ]
  geological <- sf::st_crop(geological, sf::st_union(tile_cells))
  geological <- sf::st_transform(geological, 4326)

  dir.create(file.path(pathOut, 'geology'), showWarnings = FALSE)
  sf::st_write(
    geological,
    dsn = file.path(pathOut, 'geology', 'geology.shp'),
    quiet = TRUE,
    append = FALSE
  )

  message(crayon::green(
    "Done with writing `geology` data set. ",
    format(Sys.time(), "%X")
  ))
}


#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
process_grazing_allot <- function(path, pathOut, tile_cells) {
  datasets <- c('BLMAllotments', 'USFSAllotments')

  paths <- vector(length = 2)
  base <- vector(length = 2)
  shp <- vector(mode = 'list', length = 2)

  for (i in seq_along(datasets)) {
    base[i] <- file.path(path, datasets[i])
    paths[i] <- file.path(base[i], list.files(base[i], pattern = 'shp$'))

    shp[[i]] <- st_read(paths[i], quiet = TRUE) |>
      dplyr::select(ALLOT_NAME)
  }

  allotments <- dplyr::bind_rows(shp) |>
    sf::st_make_valid()

  tile_cells <- sf::st_transform(tile_cells, sf::st_crs(allotments))

  sf::st_agr(tile_cells) = "constant"
  sf::st_agr(allotments) = "constant"

  allotments <- allotments[
    sf::st_intersects(allotments, sf::st_union(tile_cells)) %>% lengths > 0,
  ]
  allotments <- sf::st_crop(allotments, sf::st_union(tile_cells))
  allotments <- sf::st_transform(allotments, 4326) |>
    dplyr::mutate(Allotment = stringr::str_to_title(ALLOT_NAME)) |>
    dplyr::select(-ALLOT_NAME)

  dir.create(file.path(pathOut, 'allotments'), showWarnings = FALSE)
  sf::st_write(
    allotments,
    quiet = TRUE,
    append = FALSE,
    dsn = file.path(pathOut, 'allotments', 'allotments.shp')
  )

  message(crayon::green(
    "Done with writing `allotments` data set. ",
    format(Sys.time(), "%X")
  ))
}

#' Set up the downloaded data for a BarnebyLives instance
#'
#' @description used within `data_setup`
#' @keywords internal
process_plss <- function(path, pathOut, tile_cells) {
  p <- file.path(path, "PLSS", "ilmocplss.gdb")

  # --- Township layer ---
  township <- safe_step("read township", {
    sf::st_read(p, layer = "PLSSTownship", quiet = TRUE) |>
      dplyr::select(TWNSHPLAB, PLSSID)
  })
  township_crs <- sf::st_crs(township)

  # --- Adaptive buffer calc ---
  bbox_proj <- tile_cells |>
    sf::st_union() |>
    sf::st_transform(5070) |>
    sf::st_bbox()

  width_miles <- (bbox_proj["xmax"] - bbox_proj["xmin"]) / 1609.34
  n_cells <- dplyr::case_when(
    width_miles < 30 ~ 1,
    width_miles < 60 ~ 2,
    width_miles < 120 ~ 3,
    width_miles < 180 ~ 4,
    TRUE ~ 5
  )

  # buffer in township CRS units
  if (tolower(township_crs$units_gdal) == "degree") {
    buffer <- (n_cells * 6.01) / 69 # degrees
    unit_label <- "°"
  } else {
    buffer <- n_cells * 6.01 * 1609.34 # meters
    unit_label <- "m"
  }

  message(crayon::silver(
    "[process_plss] Domain ~",
    round(width_miles, 1),
    " mi wide → buffer = ",
    n_cells,
    " cells (~",
    round(buffer, 1),
    " ",
    unit_label,
    ")"
  ))

  # --- Township filter by vertex coords ---
  tile_bbox <- tile_cells |>
    sf::st_union() |>
    sf::st_transform(township_crs) |>
    sf::st_bbox()

  coords <- sf::st_geometry(township) |>
    purrr::map(~ sf::st_coordinates(.x)[1, ]) |>
    do.call(what = rbind)
  coords_df <- tibble::tibble(X = coords[, 1], Y = coords[, 2])

  xlim <- tile_bbox[c("xmin", "xmax")] + c(-1, 1) * buffer
  ylim <- tile_bbox[c("ymin", "ymax")] + c(-1, 1) * buffer
  keep <- coords_df$X >= xlim[1] &
    coords_df$X <= xlim[2] &
    coords_df$Y >= ylim[1] &
    coords_df$Y <= ylim[2]

  message(crayon::silver(
    "[process_plss] Kept ",
    sum(keep),
    "/",
    nrow(coords_df),
    " townships"
  ))
  township <- township[keep, ]
  township <- sf::st_drop_geometry(township)

  # --- Sections ---
  section <- safe_step("read PLSSFirstDivision", {
    sf::st_read(p, layer = "PLSSFirstDivision", quiet = TRUE)
  })
  section <- safe_step("join sections to townships", {
    joined <- dplyr::right_join(
      section,
      township,
      by = "PLSSID",
      relationship = "many-to-many"
    )
    message(crayon::silver("[process_plss] Joined rows: ", nrow(joined)))
    joined
  })

  # --- Clean + write ---
  gcol <- attr(section, "sf_column")

  trs <- safe_step("clean/cast/mutate", {
    section |>
      sf::st_zm(drop = TRUE) |>
      sf::st_set_precision(1) |> # snap to 1 m grid
      sf::st_make_valid() |>
      sf::st_cast("POLYGON", warn = TRUE) |>
      dplyr::mutate(TRS = paste(TWNSHPLAB, FRSTDIVLAB)) |>
      dplyr::select(trs = TRS, !!gcol)
  })

  dir.create(file.path(pathOut, "plss"), showWarnings = FALSE)
  safe_step("write shapefile", {
    sf::st_write(
      trs,
      dsn = file.path(pathOut, "plss", "plss.shp"),
      quiet = TRUE,
      append = FALSE
    )
  })

  message(crayon::green(
    "Done with writing `PLSS (trs)` data set. ",
    format(Sys.time(), "%X")
  ))
}


#' Safe untar wrapper
#'
#' @description
#' Internal helper around `untar()` / system tar to smooth over differences
#' between Linux, macOS, and Windows. On macOS, prefers GNU tar (`gtar`)
#' if available; otherwise falls back to system BSD tar and warns that
#' hardlink issues may occur. Suggests `brew install gnu-tar` when relevant.
#'
#' @param archive Path to the `.tar` or `.tar.gz` file.
#' @param exdir   Directory to extract into.
#' @param verbose Logical; print messages about which backend is used.
#'
#' @keywords internal
safe_untar <- function(archive, exdir, verbose = TRUE) {
  os <- Sys.info()[["sysname"]]

  if (os == "Darwin") {
    if (Sys.which("gtar") != "") {
      if (verbose) {
        message("[safe_untar] macOS: using GNU tar (gtar).")
      }
      system2(
        "gtar",
        c("--hard-dereference", "-xf", shQuote(archive), "-C", shQuote(exdir))
      )
    } else {
      if (verbose) {
        message("[safe_untar] macOS: using BSD tar (system tar).")
        message("[safe_untar] Install GNU tar with: brew install gnu-tar")
      }
      system2("tar", c("-xf", shQuote(archive), "-C", shQuote(exdir)))
    }
  } else {
    if (verbose) {
      message("[safe_untar] Using R's untar() on ", os, ".")
    }
    untar(archive, exdir = exdir)
  }
}


#' Check whether expected output files from data_setup() exist
#'
#' @param pathOut Output directory used in data_setup()
#' @return None. prints to console.
#' @export
#' Check and print status of data_setup outputs
#'
#' @param pathOut Output directory used in data_setup()
#' @examples \dontrun{
#' check_data_setup_outputs(path.expand('~/Documents/BL_testing_data/geo'))
#' }
#'
#' @export
check_data_setup_outputs <- function(pathOut) {
  expected <- list(
    political = "political/political.shp",
    mountains = "mountains/mountains.shp",
    places = "places/places.shp", # shared by GNIS + city points
    gnis = "places/places.shp",
    padus = "pad/pad.shp",
    geology = "geology/geology.shp",
    allotments = "allotments/allotments.shp",
    plss = "plss/plss.shp",
    aspect = "aspect",
    dem = "dem",
    geom = "geom",
    slope = "slope"
  )

  full_paths <- file.path(pathOut, unlist(expected))
  names(full_paths) <- names(expected)

  check_result <- sapply(full_paths, function(p) {
    if (grepl("[.]shp$", p)) {
      file.exists(p)
    } else {
      dir.exists(p) &&
        length(list.files(p, pattern = "[.]tif$", full.names = TRUE)) > 0
    }
  })

  present <- names(check_result)[check_result]
  missing <- names(check_result)[!check_result]

  cat(crayon::green("Success:\n"))
  for (p in present) {
    cat(crayon::green(paste0("  - ", p)), "\n")
  }
  cat(crayon::silver("\n====\n\n"))
  cat(crayon::red("Works in progress:\n"))
  for (m in missing) {
    cat(crayon::red(paste0("  - ", m)), "\n")
  }

  invisible(NULL)
}

#' Make a quick county dot map to display the location of the collection
#'
#' @description use sf to create a 20th century style 'dot map' which features the state
#' boundary and county lines.
#'
#' @param x an sf dataframe of coordinates to make maps for, requires collection number and spatial attributes
#' @param path_out a directory to store the map images in before merging
#' @param path a path to the directory holding the BarnebyLivesGeodata
#' @param collection_col column specify the collection number or other UNIQUE id for the collection
#' @param parallel Whether to use parallel to write out the maps in parallel,
#'  defaults to 0 (for false), 1 uses all threads, 0.5 for half, 0.25 for a quarter etc.
#' @examples \dontrun{
#' ce <- collection_examples[ sample(1:nrow(collection_examples), size = 20), ] |>
#'   sf::st_as_sf(coords = c('longitude_dd', 'latitude_dd'), crs = 4326)
#'
#'#' # You need to define 'path' to point to your geodata's root location
#' path <- "/path/to/your/BarnebyLivesGeodata"
#'
#' map_maker(ce, path_out = 'test', path = path, collection_col = 'Collection_number')
#'
#' # single threaded; but gains on parallel unlikely.
#' start_time <- Sys.time()
#' map_maker(ce, path_out = 'test', path = path, collection_col = 'Collection_number')
#' duration <- Sys.time() - start_time
#'
#' # with all cores via parallel::
#' start_time_parallel <- Sys.time()
#' map_maker(ce, path_out = 'test', path = path, collection_col = 'Collection_number', parallel = 1)
#' parallel_duration <- Sys.time() - start_time_parallel
#'
#' # but speed up gains unlikely. if pct is % loading cores took longer than single threading.
#' speedup <- as.numeric(duration) / as.numeric(parallel_duration)
#' if(speedup > 1) {
#'  cat("Parallel was", round(
#'  (1 - as.numeric(parallel_duration)/as.numeric(duration)) * 100, 1), "% faster\n")
#' } else {
#'   cat("Single-threaded was",
#'   round((1 - speedup) * 100, 1), "% faster (parallel overhead exceeded benefits)\n")
#' }
#'
#' rm(start_time, duration, start_time_parallel, parallel_duration, speedup)
#' }
#' @export
map_maker <- function(x, path_out, path, collection_col, parallel = 0) {
  political <- sf::st_read(
    file.path(path, 'political', 'political.shp'),
    quiet = T
  )
  if (sf::st_crs(x) == sf::st_crs(political)) {
    pts <- x
  } else {
    pts <- sf::st_transform(x, sf::st_crs(political))
  }
  dir.create(
    file.path(path_out, 'maps'),
    recursive = TRUE,
    showWarnings = FALSE
  )

  if (!inherits(x, "sf")) {
    stop("x must be an sf object")
  }
  if (!collection_col %in% names(x)) {
    stop(paste("Column", collection_col, "not found in x"))
  }
  if (parallel < 0 || parallel > 1) {
    if (parallel < 0) {
      parellel = 0
    } else {
      parallel <- 1
    }
  }

  # first apply fn to all data points - and group by states.
  # split by states and write them out in batches.

  intersection_indices <- sf::st_intersects(pts, political)
  pts$temp_state <- political$STUSPS[
    sapply(
      intersection_indices,
      function(x) if (length(x) > 0) x[1] else NA
    )
  ]
  pts <- sf::st_as_sf(pts)

  # Add this check:
  missing_states <- is.na(pts$temp_state)
  if (any(missing_states)) {
    warning(paste(
      sum(missing_states),
      "points did not intersect any state and will be skipped"
    ))
    pts <- pts[!missing_states, ] # Remove problematic points
  }

  # Then check if anything is left:
  if (nrow(pts) == 0) {
    stop("No points intersected with the political boundaries")
  }

  # maybe bind state for temp, and then apply rowwise !!!! after filtering tabular.
  core_map_maker <- function(y, path_out, political, collection_col) {
    focal_state <- dplyr::filter(political, STUSPS == y$temp_state[1])

    # if now intersection found return from fun.
    if (nrow(focal_state) == 0) {
      warning(paste("No state found for", y$temp_state[1], "- skipping"))
      return(NULL)
    }

    p <- ggplot2::ggplot() +
      ggplot2::geom_sf(data = focal_state, fill = NA, color = 'grey15') +
      ggplot2::geom_sf(data = y) +
      ggplot2::theme_void()

    col_no <- sf::st_drop_geometry(y)[[collection_col]]

    fname <- file.path(path_out, 'maps', paste0('map_', col_no, '.png'))
    ggplot2::ggsave(
      filename = fname,
      plot = p,
      device = 'png',
      dpi = 300,
      width = 1,
      height = 1,
      units = 'in',
      bg = 'transparent'
    )
  }

  pts_list <- split(pts, seq(nrow(pts)))
  if (parallel > 0) {
    n_cores <- max(1, round(parallel::detectCores() * parallel))
    cl <- parallel::makeCluster(n_cores)
    on.exit(parallel::stopCluster(cl))

    parallel::clusterEvalQ(cl, {
      library(sf)
      library(ggplot2)
      library(dplyr)
    })

    parallel::parLapply(
      cl,
      pts_list,
      core_map_maker,
      path_out = path_out,
      political = political,
      collection_col = collection_col
    )
  } else {
    lapply(
      pts_list,
      core_map_maker,
      path_out = path_out,
      political = political,
      collection_col = collection_col
    )
  }
}

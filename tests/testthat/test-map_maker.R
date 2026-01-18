library(testthat)

test_that("map_maker creates PNG files for each collection", {
  skip_if_not_installed("sf")
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("dplyr")
  
  tmp <- withr::local_tempdir()
  
  # Create mock sf data
  df <- data.frame(
    Collection_number = c(101, 102),
    lon = c(-105, -106),
    lat = c(40, 41)
  )
  pts <- sf::st_as_sf(df, coords = c("lon", "lat"), crs = 4326)
  
  # Create mock political boundaries
  mock_political <- sf::st_sf(
    STUSPS = "CO",
    geometry = sf::st_sfc(sf::st_polygon(list(matrix(
      c(-109, 37, -102, 37, -102, 41, -109, 41, -109, 37),
      ncol = 2, byrow = TRUE
    ))), crs = 4326)
  )
  
  saved_files <- character()
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_political,
    .package = "sf"
  )
  
  testthat::local_mocked_bindings(
    ggsave = function(filename, ...) {
      saved_files <<- c(saved_files, filename)
      invisible(NULL)
    },
    .package = "ggplot2"
  )
  
  map_maker(pts, path_out = tmp, path = tmp, collection_col = "Collection_number")
  
  expect_length(saved_files, 2)
  expect_true(all(grepl("\\.png$", saved_files)))
  expect_true(all(grepl("map_101|map_102", saved_files)))
})

test_that("map_maker creates maps directory", {
  skip_if_not_installed("sf")
  skip_if_not_installed("ggplot2")
  
  tmp <- withr::local_tempdir()
  
  df <- data.frame(
    Collection_number = 101,
    lon = -105,
    lat = 40
  )
  pts <- sf::st_as_sf(df, coords = c("lon", "lat"), crs = 4326)
  
  mock_political <- sf::st_sf(
    STUSPS = "CO",
    geometry = sf::st_sfc(sf::st_polygon(list(matrix(
      c(-109, 37, -102, 37, -102, 41, -109, 41, -109, 37),
      ncol = 2, byrow = TRUE
    ))), crs = 4326)
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_political,
    .package = "sf"
  )
  
  testthat::local_mocked_bindings(
    ggsave = function(...) invisible(NULL),
    .package = "ggplot2"
  )
  
  map_maker(pts, path_out = tmp, path = tmp, collection_col = "Collection_number")
  
  expect_true(dir.exists(file.path(tmp, "maps")))
})

test_that("map_maker stops if x is not sf object", {
  skip_if_not_installed("sf")
  
  tmp <- withr::local_tempdir()
  
  df <- data.frame(
    Collection_number = 101,
    lon = -105,
    lat = 40
  )
  
  # Need to mock st_read even though we expect an early error
  mock_political <- sf::st_sf(
    STUSPS = "CO",
    geometry = sf::st_sfc(sf::st_polygon(list(matrix(
      c(-109, 37, -102, 37, -102, 41, -109, 41, -109, 37),
      ncol = 2, byrow = TRUE
    ))), crs = 4326)
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_political,
    .package = "sf"
  )
  
  expect_error(
    map_maker(df, path_out = tmp, path = tmp, collection_col = "Collection_number"),
    "x must be an sf object"
  )
})

test_that("map_maker stops if collection_col not found", {
  skip_if_not_installed("sf")
  
  tmp <- withr::local_tempdir()
  
  df <- data.frame(
    wrong_col = 101,
    lon = -105,
    lat = 40
  )
  pts <- sf::st_as_sf(df, coords = c("lon", "lat"), crs = 4326)
  
  # Need to mock st_read for this test too
  mock_political <- sf::st_sf(
    STUSPS = "CO",
    geometry = sf::st_sfc(sf::st_polygon(list(matrix(
      c(-109, 37, -102, 37, -102, 41, -109, 41, -109, 37),
      ncol = 2, byrow = TRUE
    ))), crs = 4326)
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_political,
    .package = "sf"
  )
  
  expect_error(
    map_maker(pts, path_out = tmp, path = tmp, collection_col = "Collection_number"),
    "Column Collection_number not found in x"
  )
})

test_that("map_maker warns and skips points outside boundaries", {
  skip_if_not_installed("sf")
  skip_if_not_installed("ggplot2")
  
  tmp <- withr::local_tempdir()
  
  # Create points - one inside, one outside Colorado
  df <- data.frame(
    Collection_number = c(101, 102),
    lon = c(-105, 0),
    lat = c(40, 0)
  )
  pts <- sf::st_as_sf(df, coords = c("lon", "lat"), crs = 4326)
  
  mock_political <- sf::st_sf(
    STUSPS = "CO",
    geometry = sf::st_sfc(sf::st_polygon(list(matrix(
      c(-109, 37, -102, 37, -102, 41, -109, 41, -109, 37),
      ncol = 2, byrow = TRUE
    ))), crs = 4326)
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_political,
    .package = "sf"
  )
  
  testthat::local_mocked_bindings(
    ggsave = function(...) invisible(NULL),
    .package = "ggplot2"
  )
  
  expect_warning(
    map_maker(pts, path_out = tmp, path = tmp, collection_col = "Collection_number"),
    "points did not intersect any state"
  )
})

test_that("map_maker handles parallel parameter bounds", {
  skip_if_not_installed("sf")
  skip_if_not_installed("ggplot2")
  
  tmp <- withr::local_tempdir()
  
  df <- data.frame(
    Collection_number = 101,
    lon = -105,
    lat = 40
  )
  pts <- sf::st_as_sf(df, coords = c("lon", "lat"), crs = 4326)
  
  mock_political <- sf::st_sf(
    STUSPS = "CO",
    geometry = sf::st_sfc(sf::st_polygon(list(matrix(
      c(-109, 37, -102, 37, -102, 41, -109, 41, -109, 37),
      ncol = 2, byrow = TRUE
    ))), crs = 4326)
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_political,
    .package = "sf"
  )
  
  testthat::local_mocked_bindings(
    ggsave = function(...) invisible(NULL),
    .package = "ggplot2"
  )
  
  # Should not error with out-of-bounds parallel values
  expect_no_error(
    map_maker(pts, path_out = tmp, path = tmp, 
              collection_col = "Collection_number", parallel = -0.5)
  )
  
  expect_no_error(
    map_maker(pts, path_out = tmp, path = tmp, 
              collection_col = "Collection_number", parallel = 1.5)
  )
})
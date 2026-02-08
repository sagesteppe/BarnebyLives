library(testthat)

test_that("site_writer calculates distances and azimuths", {
  skip_if_not_installed("sf")
  skip_if_not_installed("dplyr")
  skip_if_not_installed("geosphere")
  skip_if_not_installed("stringr")
  
  tmp <- withr::local_tempdir()
  
  # Create mock site data
  sites <- data.frame(
    id = 1:2,
    lon = c(-105, -106),
    lat = c(40, 41)
  )
  sites <- sf::st_as_sf(sites, coords = c("lon", "lat"), crs = 4326)
  
  # Create mock GNIS places data
  mock_places <- sf::st_sf(
    fetr_nm = c("Denver", "Boulder"),
    geometry = sf::st_sfc(
      sf::st_point(c(-104.9, 39.7)),
      sf::st_point(c(-105.3, 40.0)),
      crs = 4326
    )
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_places,
    .package = "sf"
  )
  
  testthat::local_mocked_bindings(
    format_degree = function(x) paste0(x, "°"),
    .package = "BarnebyLives"
  )
  
  result <- site_writer(sites, path = tmp)
  
  # Should have Site column
  expect_true("Site" %in% names(result))
  
  # Should be sf object
  expect_true(inherits(result, "sf"))
  
  # Should have same number of rows as input
  expect_equal(nrow(result), nrow(sites))
})

test_that("site_writer formats nearby sites correctly", {
  skip_if_not_installed("sf")
  skip_if_not_installed("dplyr")
  skip_if_not_installed("geosphere")
  skip_if_not_installed("stringr")
  
  tmp <- withr::local_tempdir()
  
  # Create site very close to a place (< 0.25 mi)
  sites <- data.frame(
    id = 1,
    lon = -105,
    lat = 40
  )
  sites <- sf::st_as_sf(sites, coords = c("lon", "lat"), crs = 4326)
  
  # Create place very close to the site
  mock_places <- sf::st_sf(
    fetr_nm = "Boulder",
    geometry = sf::st_sfc(
      sf::st_point(c(-105.0001, 40.0001)),
      crs = 4326
    )
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_places,
    .package = "sf"
  )
  
  testthat::local_mocked_bindings(
    format_degree = function(x) paste0(x, "°"),
    .package = "BarnebyLives"
  )
  
  result <- site_writer(sites, path = tmp)
  
  # When distance < 0.25 mi, should just show place name with period
  expect_match(result$Site[1], "^Boulder\\.$")
})

test_that("site_writer formats distant sites with distance and azimuth", {
  skip_if_not_installed("sf")
  skip_if_not_installed("dplyr")
  skip_if_not_installed("geosphere")
  skip_if_not_installed("stringr")
  
  tmp <- withr::local_tempdir()
  
  # Create site far from place
  sites <- data.frame(
    id = 1,
    lon = -105,
    lat = 40
  )
  sites <- sf::st_as_sf(sites, coords = c("lon", "lat"), crs = 4326)
  
  # Create place far from site
  mock_places <- sf::st_sf(
    fetr_nm = "Denver",
    geometry = sf::st_sfc(
      sf::st_point(c(-104, 39)),
      crs = 4326
    )
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_places,
    .package = "sf"
  )
  
  testthat::local_mocked_bindings(
    format_degree = function(x) paste0(x, "°"),
    .package = "BarnebyLives"
  )
  
  result <- site_writer(sites, path = tmp)
  
  # When distance >= 0.25 mi, should show distance, direction, and place
  expect_match(result$Site[1], "mi.*from.*Denver")
})

test_that("site_writer finds nearest feature for each site", {
  skip_if_not_installed("sf")
  skip_if_not_installed("dplyr")
  skip_if_not_installed("geosphere")
  skip_if_not_installed("stringr")
  
  tmp <- withr::local_tempdir()
  
  # Create two sites
  sites <- data.frame(
    id = 1:2,
    lon = c(-105, -104),
    lat = c(40, 39)
  )
  sites <- sf::st_as_sf(sites, coords = c("lon", "lat"), crs = 4326)
  
  # Create two places - each closer to one site
  mock_places <- sf::st_sf(
    fetr_nm = c("Boulder", "Denver"),
    geometry = sf::st_sfc(
      sf::st_point(c(-105.1, 40.1)),
      sf::st_point(c(-104.1, 39.1)),
      crs = 4326
    )
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_places,
    .package = "sf"
  )
  
  testthat::local_mocked_bindings(
    format_degree = function(x) paste0(x, "°"),
    .package = "BarnebyLives"
  )
  
  result <- site_writer(sites, path = tmp)
  
  # Each site should reference its nearest place
  expect_match(result$Site[1], "Boulder")
  expect_match(result$Site[2], "Denver")
})

test_that("site_writer preserves input columns", {
  skip_if_not_installed("sf")
  skip_if_not_installed("dplyr")
  skip_if_not_installed("geosphere")
  skip_if_not_installed("stringr")
  
  tmp <- withr::local_tempdir()
  
  # Create site with extra columns
  sites <- data.frame(
    id = 1,
    collector = "Smith",
    number = 101,
    lon = -105,
    lat = 40
  )
  sites <- sf::st_as_sf(sites, coords = c("lon", "lat"), crs = 4326)
  
  mock_places <- sf::st_sf(
    fetr_nm = "Boulder",
    geometry = sf::st_sfc(
      sf::st_point(c(-105, 40)),
      crs = 4326
    )
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_places,
    .package = "sf"
  )
  
  testthat::local_mocked_bindings(
    format_degree = function(x) paste0(x, "°"),
    .package = "BarnebyLives"
  )
  
  result <- site_writer(sites, path = tmp)
  
  # Should preserve original columns
  expect_true("id" %in% names(result))
  expect_true("collector" %in% names(result))
  expect_true("number" %in% names(result))
  expect_true("Site" %in% names(result))
})

test_that("site_writer removes temporary columns", {
  skip_if_not_installed("sf")
  skip_if_not_installed("dplyr")
  skip_if_not_installed("geosphere")
  skip_if_not_installed("stringr")
  
  tmp <- withr::local_tempdir()
  
  sites <- data.frame(
    id = 1,
    lon = -105,
    lat = 40
  )
  sites <- sf::st_as_sf(sites, coords = c("lon", "lat"), crs = 4326)
  
  mock_places <- sf::st_sf(
    fetr_nm = "Boulder",
    geometry = sf::st_sfc(
      sf::st_point(c(-105, 40)),
      crs = 4326
    )
  )
  
  testthat::local_mocked_bindings(
    st_read = function(...) mock_places,
    .package = "sf"
  )
  
  testthat::local_mocked_bindings(
    format_degree = function(x) paste0(x, "°"),
    .package = "BarnebyLives"
  )
  
  result <- site_writer(sites, path = tmp)
  
  # Should not have temporary columns
  expect_false("Distance" %in% names(result))
  expect_false("Azimuth" %in% names(result))
  expect_false("Place" %in% names(result))
  expect_false("ID" %in% names(result))
})

test_that("site_writer requires path to places shapefile", {
  skip_if_not_installed("sf")
  
  sites <- data.frame(
    id = 1,
    lon = -105,
    lat = 40
  )
  sites <- sf::st_as_sf(sites, coords = c("lon", "lat"), crs = 4326)
  
  # Without mocking st_read, should error on missing file
  expect_error(site_writer(sites, path = "/nonexistent/path"))
})
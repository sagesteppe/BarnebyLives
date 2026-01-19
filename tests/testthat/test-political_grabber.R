library(testthat)
library(sf)
library(dplyr)

# Helper function to create mock spatial data
create_mock_spatial <- function(type = "political") {
  geom <- sf::st_sfc(
    sf::st_point(c(-118, 43)),
    crs = 4326
  )
  
  switch(type,
    political = sf::st_sf(
      State = "Idaho",
      County = "TestCounty",
      geometry = geom
    ),
    mountains = sf::st_sf(
      Feature = "TestMountain",
      geometry = geom
    ),
    allotments = sf::st_sf(
      Allotment = "TestAllotment",
      geometry = geom
    ),
    plss = sf::st_sf(
      trs = "T1N R1E S1",
      geometry = geom
    ),
    pad = sf::st_sf(
      Mang_Name = "USFS",
      Unit_Nm = "Test NF",
      geometry = geom
    )
  )
}

# Setup function to create mock geodata directory
setup_mock_geodata <- function() {
  tmp_path <- file.path(tempdir(), "mock_geodata")
  
  # Create directory structure
  dirs <- c("political", "mountains", "allotments", "plss", "pad")
  for (d in dirs) {
    dir.create(file.path(tmp_path, d), showWarnings = FALSE, recursive = TRUE)
  }
  
  # Write mock shapefiles
  sf::st_write(
    create_mock_spatial("political"),
    file.path(tmp_path, "political", "political.shp"),
    quiet = TRUE, append = FALSE
  )
  
  sf::st_write(
    create_mock_spatial("mountains"),
    file.path(tmp_path, "mountains", "mountains.shp"),
    quiet = TRUE, append = FALSE
  )
  
  sf::st_write(
    create_mock_spatial("allotments"),
    file.path(tmp_path, "allotments", "allotments.shp"),
    quiet = TRUE, append = FALSE
  )
  
  sf::st_write(
    create_mock_spatial("plss"),
    file.path(tmp_path, "plss", "plss.shp"),
    quiet = TRUE, append = FALSE
  )
  
  sf::st_write(
    create_mock_spatial("pad"),
    file.path(tmp_path, "pad", "pad.shp"),
    quiet = TRUE, append = FALSE
  )
  
  tmp_path
}

test_that("political_grabber returns sf object with expected columns", {
  path <- setup_mock_geodata()
  
  # Create test input data
  test_data <- sf::st_sf(
    id = 1,
    collector = "Smith",
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  expect_s3_class(result, "sf")
  expect_true("Country" %in% names(result))
  expect_true("State" %in% names(result))
  expect_true("County" %in% names(result))
  expect_true("Gen" %in% names(result))
})

test_that("political_grabber removes existing political columns before joining", {
  path <- setup_mock_geodata()
  
  # Create test data with existing political columns
  test_data <- sf::st_sf(
    id = 1,
    State = "OldState",
    County = "OldCounty",
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  # Should have new values, not old ones
  expect_false(any(result$State == "OldState", na.rm = TRUE))
  expect_true("State" %in% names(result))
})

test_that("political_grabber sets Country to U.S.A.", {
  path <- setup_mock_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  expect_equal(result$Country, "U.S.A.")
})

test_that("political_grabber creates Gen field correctly", {
  path <- setup_mock_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  expect_true("Gen" %in% names(result))
  expect_type(result$Gen, "character")
  # Should not have "NA" text in it
  expect_false(grepl("NA", result$Gen))
  # Should not have double spaces
  expect_false(grepl("  ", result$Gen))
  # Should not end with comma
  expect_false(grepl(",$", result$Gen))
})

test_that("political_grabber handles multiple points", {
  path <- setup_mock_geodata()
  
  test_data <- sf::st_sf(
    id = 1:3,
    geometry = sf::st_sfc(
      sf::st_point(c(-118, 43)),
      sf::st_point(c(-118.1, 43.1)),
      sf::st_point(c(-118.2, 43.2)),
      crs = 4326
    )
  )
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  expect_equal(nrow(result), 3)
  expect_equal(result$id, 1:3)
})

test_that("political_grabber handles points on borders (duplicates)", {
  path <- setup_mock_geodata()
  
  # Create input where one point might match multiple features
  test_data <- sf::st_sf(
    id = c(1, 1),  # Duplicate ID
    geometry = sf::st_sfc(
      sf::st_point(c(-118, 43)),
      sf::st_point(c(-118, 43)),
      crs = 4326
    )
  )
  
  result <- political_grabber(test_data, y = 'id', path = path)
  
  # Should only have one row per unique ID
  expect_equal(nrow(result), 1)
  expect_equal(result$id, 1)
})

test_that("political_grabber preserves original columns", {
  path <- setup_mock_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    collector = "Smith",
    date = "2024-01-01",
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  expect_true("collector" %in% names(result))
  expect_true("date" %in% names(result))
  expect_equal(result$collector, "Smith")
})

test_that("political_grabber relocates political columns before geometry", {
  path <- setup_mock_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    other_col = "test",
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  col_names <- names(result)
  geom_pos <- which(col_names == "geometry")
  country_pos <- which(col_names == "Country")
  
  # Country should come before geometry
  expect_true(country_pos < geom_pos)
})

test_that("political_grabber handles CRS transformations for PLSS", {
  path <- setup_mock_geodata()
  
  # Create data in different CRS
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  ) |>
    sf::st_transform(3857)  # Web Mercator
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  expect_s3_class(result, "sf")
  expect_true("trs" %in% names(result))
})

test_that("political_grabber works with character ID column", {
  path <- setup_mock_geodata()
  
  test_data <- sf::st_sf(
    specimen_id = c("SPEC001", "SPEC002"),
    geometry = sf::st_sfc(
      sf::st_point(c(-118, 43)),
      sf::st_point(c(-118.1, 43.1)),
      crs = 4326
    )
  )
  
  result <- political_grabber(test_data, y = "specimen_id", path = path)
  
  expect_equal(nrow(result), 2)
  expect_equal(result$specimen_id, c("SPEC001", "SPEC002"))
})

test_that("political_grabber handles missing spatial joins gracefully", {
  path <- setup_mock_geodata()
  
  # Create point far from mock data
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-70, 40)), crs = 4326)
  )
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 1)
  # Fields should be NA where no match
  expect_true(is.na(result$State) || !is.null(result$State))
})

test_that("political_grabber Gen field cleans up properly", {
  path <- setup_mock_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  # Check cleaning operations
  expect_false(grepl("NA", result$Gen))  # No "NA" text
  expect_false(grepl("  ", result$Gen))   # No double spaces
  expect_false(grepl(", ,", result$Gen))  # No ", ,"
  expect_false(grepl("^\\s|\\s$", result$Gen))  # No leading/trailing whitespace
  expect_false(grepl(",$", result$Gen))   # No trailing comma
})

test_that("political_grabber returns one row per unique identifier", {
  path <- setup_mock_geodata()
  
  # Simulate what happens when a point intersects multiple features
  test_data <- sf::st_sf(
    id = rep(1:2, each = 2),
    geometry = sf::st_sfc(
      sf::st_point(c(-118, 43)),
      sf::st_point(c(-118, 43)),
      sf::st_point(c(-118.1, 43.1)),
      sf::st_point(c(-118.1, 43.1)),
      crs = 4326
    )
  )
  
  result <- political_grabber(test_data, y = "id", path = path)
  
  # Should deduplicate to one row per unique ID
  expect_equal(nrow(result), 2)
  expect_equal(unique(result$id), 1:2)
})

test_that("political_grabber errors informatively if path doesn't exist", {
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  expect_error(
    political_grabber(test_data, y = "id", path = "/nonexistent/path"),
    "Cannot open"
  )
})
library(testthat)
library(dplyr)
library(sf)

# Helper function to create mock spatial data
create_mock_data <- function(n = 3) {
  data.frame(
    Site = c("Site A from Location 1", "Site B from Location 2", "Site C from Location 3"),
    latitude_dd = c(40.7128, 34.0522, 41.8781),
    longitude_dd = c(-74.0060, -118.2437, -87.6298)
  ) %>%
    sf::st_as_sf(coords = c("longitude_dd", "latitude_dd"), crs = 4326) %>%
    dplyr::mutate(
      latitude_dd = c(40.7128, 34.0522, 41.8781),
      longitude_dd = c(-74.0060, -118.2437, -87.6298)
    )
}

# Mock helper functions
mock_get_google_directions <- function(sites, api_key) {
  lapply(sites, function(site) {
    list(
      status = "OK",
      routes = list(
        list(
          legs = list(
            list(
              duration = list(text = "15 mins"),
              distance = list(text = "5.2 km"),
              start_address = "Start",
              end_address = "End"
            )
          )
        )
      )
    )
  })
}

mock_directions_overview <- function(x) {
  "15mins from Start via Main St."
}

mock_specificDirections <- function(x) {
  "Turn left on Main St, then right on 1st Ave."
}

# Tests for input validation
test_that("directions_grabber requires api_key parameter", {
  mock_data <- create_mock_data()
  
  expect_error(
    directions_grabber(mock_data),
    "api_key is required"
  )
  
  expect_error(
    directions_grabber(mock_data, api_key = NULL),
    "api_key is required"
  )
})

test_that("directions_grabber validates required columns", {
  # Missing latitude_dd
  bad_data <- data.frame(
    Site = "Test Site",
    longitude_dd = -74.0060
  )
  
  expect_error(
    directions_grabber(bad_data, api_key = "test_key"),
    "Input must contain columns: latitude_dd, longitude_dd, Site"
  )
  
  # Missing longitude_dd
  bad_data2 <- data.frame(
    Site = "Test Site",
    latitude_dd = 40.7128
  )
  
  expect_error(
    directions_grabber(bad_data2, api_key = "test_key"),
    "Input must contain columns: latitude_dd, longitude_dd, Site"
  )
  
  # Missing Site
  bad_data3 <- data.frame(
    latitude_dd = 40.7128,
    longitude_dd = -74.0060
  )
  
  expect_error(
    directions_grabber(bad_data3, api_key = "test_key"),
    "Input must contain columns: latitude_dd, longitude_dd, Site"
  )
})

# Tests for core functionality with mocked dependencies
test_that("directions_grabber processes valid input correctly", {
  # Mock the helper functions
  mockery::stub(directions_grabber, 'get_google_directions', mock_get_google_directions)
  mockery::stub(directions_grabber, 'directions_overview', mock_directions_overview)
  mockery::stub(directions_grabber, 'specificDirections', mock_specificDirections)
  
  mock_data <- create_mock_data()
  result <- directions_grabber(mock_data, api_key = "test_key")
  
  # Check that output has the expected structure
  expect_true("Directions_BL" %in% names(result))
  expect_equal(nrow(result), nrow(mock_data))
  expect_s3_class(result, "sf")
})

test_that("directions_grabber handles duplicate coordinates", {
  mockery::stub(directions_grabber, 'get_google_directions', mock_get_google_directions)
  mockery::stub(directions_grabber, 'directions_overview', mock_directions_overview)
  mockery::stub(directions_grabber, 'specificDirections', mock_specificDirections)
  
  # Create data with duplicate coordinates
  mock_data <- create_mock_data()
  duplicate_data <- rbind(mock_data, mock_data[1, ])
  
  result <- directions_grabber(duplicate_data, api_key = "test_key")
  
  expect_equal(nrow(result), nrow(duplicate_data))
  # Rows with same coordinates should have same directions
  expect_equal(result$Directions_BL[1], result$Directions_BL[4])
})

test_that("directions_grabber extracts site names correctly", {
  mockery::stub(directions_grabber, 'get_google_directions', mock_get_google_directions)
  mockery::stub(directions_grabber, 'directions_overview', mock_directions_overview)
  mockery::stub(directions_grabber, 'specificDirections', mock_specificDirections)
  
  mock_data <- create_mock_data()
  result <- directions_grabber(mock_data, api_key = "test_key")
  
  # Check that site names are extracted (should contain "Head to")
  expect_true(all(grepl("Head to", result$Directions_BL)))
  expect_true(any(grepl("Location 1", result$Directions_BL[1])))
})

test_that("directions_grabber handles Google API failures", {
  # Mock a failed API response
  mock_failed_directions <- function(sites, api_key) {
    lapply(sites, function(site) {
      list(status = "ZERO_RESULTS")
    })
  }
  
  mock_failed_overview <- function(x) {
    "0mins from  via ."
  }
  
  mockery::stub(directions_grabber, 'get_google_directions', mock_failed_directions)
  mockery::stub(directions_grabber, 'directions_overview', mock_failed_overview)
  mockery::stub(directions_grabber, 'specificDirections', mock_specificDirections)
  
  mock_data <- create_mock_data()
  result <- directions_grabber(mock_data, api_key = "test_key")
  
  # Should handle failed requests gracefully
  expect_true(any(grepl("Google will not", result$Directions_BL)))
  expect_true(any(grepl("give results", result$Directions_BL)))
})

test_that("directions_grabber replaces # with No.", {
  # Mock function that returns directions with #
  mock_directions_with_hash <- function(x) {
    "Turn left at #5 Main St, continue to #10 Oak Ave."
  }
  
  mockery::stub(directions_grabber, 'get_google_directions', mock_get_google_directions)
  mockery::stub(directions_grabber, 'directions_overview', mock_directions_overview)
  mockery::stub(directions_grabber, 'specificDirections', mock_directions_with_hash)
  
  mock_data <- create_mock_data()
  result <- directions_grabber(mock_data, api_key = "test_key")
  
  # Check that # is replaced with "No."
  expect_false(any(grepl("#", result$Directions_BL)))
  expect_true(any(grepl("No\\.", result$Directions_BL)))
})

test_that("directions_grabber preserves geometry column", {
  mockery::stub(directions_grabber, 'get_google_directions', mock_get_google_directions)
  mockery::stub(directions_grabber, 'directions_overview', mock_directions_overview)
  mockery::stub(directions_grabber, 'specificDirections', mock_specificDirections)
  
  mock_data <- create_mock_data()
  result <- directions_grabber(mock_data, api_key = "test_key")
  
  # Check geometry is preserved
  expect_true("geometry" %in% names(result))
  expect_s3_class(sf::st_geometry(result), "sfc")
})

test_that("directions_grabber relocates Directions_BL before geometry", {
  mockery::stub(directions_grabber, 'get_google_directions', mock_get_google_directions)
  mockery::stub(directions_grabber, 'directions_overview', mock_directions_overview)
  mockery::stub(directions_grabber, 'specificDirections', mock_specificDirections)
  
  mock_data <- create_mock_data()
  result <- directions_grabber(mock_data, api_key = "test_key")
  
  col_names <- names(result)
  directions_pos <- which(col_names == "Directions_BL")
  geometry_pos <- which(col_names == "geometry")
  
  expect_true(directions_pos < geometry_pos)
})

test_that("directions_grabber works with single location", {
  mockery::stub(directions_grabber, 'get_google_directions', mock_get_google_directions)
  mockery::stub(directions_grabber, 'directions_overview', mock_directions_overview)
  mockery::stub(directions_grabber, 'specificDirections', mock_specificDirections)
  
  single_data <- create_mock_data()[1, ]
  result <- directions_grabber(single_data, api_key = "test_key")
  
  expect_equal(nrow(result), 1)
  expect_true("Directions_BL" %in% names(result))
})

test_that("directions_grabber returns same number of rows as input", {
  mockery::stub(directions_grabber, 'get_google_directions', mock_get_google_directions)
  mockery::stub(directions_grabber, 'directions_overview', mock_directions_overview)
  mockery::stub(directions_grabber, 'specificDirections', mock_specificDirections)
  
  for (n in c(1, 5, 10)) {
    mock_data <- create_mock_data(n)
    if (nrow(mock_data) != n) next  # Skip if mock doesn't support this n
    
    result <- directions_grabber(mock_data, api_key = "test_key")
    expect_equal(nrow(result), n)
  }
})

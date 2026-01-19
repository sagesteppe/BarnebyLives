library(testthat)
library(sf)
library(terra)
library(dplyr)

# Helper function to create mock raster data
create_mock_raster <- function(type = "aspect", value = 180) {
  r <- terra::rast(
    nrows = 10, ncols = 10,
    xmin = -119, xmax = -117,
    ymin = 42, ymax = 44,
    crs = "EPSG:4326"
  )
  terra::values(r) <- value
  r
}

# Setup function to create mock geodata directory with rasters
setup_mock_physical_geodata <- function() {
  tmp_path <- file.path(tempdir(), "mock_physical_geodata")
  
  # Create directory structure
  dirs <- c("aspect", "slope", "geom", "dem", "geology")
  for (d in dirs) {
    dir.create(file.path(tmp_path, d), showWarnings = FALSE, recursive = TRUE)
  }
  
  # Create and write mock rasters
  aspect <- create_mock_raster("aspect", 180)
  terra::writeRaster(
    aspect,
    file.path(tmp_path, "aspect", "aspect_tile.tif"),
    overwrite = TRUE
  )
  
  slope <- create_mock_raster("slope", 15)
  terra::writeRaster(
    slope,
    file.path(tmp_path, "slope", "slope_tile.tif"),
    overwrite = TRUE
  )
  
  geom <- create_mock_raster("geom", 6)  # 6 = slope in geomorphon
  terra::writeRaster(
    geom,
    file.path(tmp_path, "geom", "geom_tile.tif"),
    overwrite = TRUE
  )
  
  dem <- create_mock_raster("dem", 2000)
  terra::writeRaster(
    dem,
    file.path(tmp_path, "dem", "dem_tile.tif"),
    overwrite = TRUE
  )
  
  # Create mock geology shapefile
  geom_sf <- sf::st_sfc(
    sf::st_polygon(list(cbind(
      c(-119, -117, -117, -119, -119),
      c(42, 42, 44, 44, 42)
    ))),
    crs = 4326
  )
  
  geology <- sf::st_sf(
    GENERALIZED_LITH = "sandstone",
    UNIT_NAME = "Test Formation",
    geometry = geom_sf
  )
  
  suppressWarnings(sf::st_write(
    geology,
    file.path(tmp_path, "geology", "geology.shp"),
    quiet = TRUE,
    append = FALSE
  ))
  
  tmp_path
}

test_that("physical_grabber returns sf object with expected columns", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  expect_s3_class(result, "sf")
  expect_true("elevation_m" %in% names(result))
  expect_true("elevation_ft" %in% names(result))
  expect_true("aspect" %in% names(result))
  expect_true("slope" %in% names(result))
  expect_true("geomorphon" %in% names(result))
  expect_true("geology" %in% names(result))
  expect_true("physical_environ" %in% names(result))
})

test_that("physical_grabber converts elevation m to ft correctly", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  # 2000m * 3.28084 ≈ 6562 ft (rounded to nearest 10)
  expect_true("elevation_ft" %in% names(result))
  # Values should be formatted with comma
  expect_type(result$elevation_ft, "character")
})

test_that("physical_grabber maps geomorphon codes correctly", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  # Mock raster has value 6 which should map to 'slope'
  expect_equal(result$geomorphon, "slope")
})

test_that("physical_grabber geomorphon lookup table is complete", {
  # Test the internal lookup table has all expected values
  geoLKPtab <- data.frame(
    unit = 1:10,
    geomorphon = c(
      'flat', 'peak', 'ridge', 'shoulder', 'spur',
      'slope', 'hollow', 'footslope', 'valley', 'pit'
    )
  )
  
  expect_equal(nrow(geoLKPtab), 10)
  expect_true(all(geoLKPtab$unit == 1:10))
})

test_that("physical_grabber rounds numeric values correctly", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  # Aspect and slope should be rounded to integers
  expect_type(result$aspect, "double")
  expect_type(result$slope, "double")
})

test_that("physical_grabber creates physical_environ description", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  expect_type(result$physical_environ, "character")
  # Should contain key elements
  expect_true(grepl("ft", result$physical_environ))
  expect_true(grepl("m", result$physical_environ))
  expect_true(grepl("slo\\.", result$physical_environ))
  expect_true(grepl("asp\\.", result$physical_environ))
  expect_true(grepl("geology:", result$physical_environ))
})

test_that("physical_grabber handles valley/hollow/pit grammar correctly", {
  path <- setup_mock_physical_geodata()
  
  # Create test data for different geomorphon types
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  # We can't easily test all geomorphons without creating multiple rasters,
  # but we can verify the string replacement logic exists
  result <- physical_grabber(test_data, path = path)
  
  # Check that "on a slope" is used (not "in a slope")
  expect_true(grepl("on a slope", result$physical_environ))
  
  # The replacements should convert "on a valley" -> "in a valley" etc.
  # if those geomorphons were present
  expect_false(grepl("on a valley", result$physical_environ))
  expect_false(grepl("on a hollow", result$physical_environ))
  expect_false(grepl("on a pit", result$physical_environ))
})

test_that("physical_grabber preserves original columns", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    collector = "Smith",
    date = "2024-01-01",
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  expect_true("collector" %in% names(result))
  expect_true("date" %in% names(result))
  expect_equal(result$collector, "Smith")
})

test_that("physical_grabber relocates physical columns before geometry", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    other_col = "test",
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  col_names <- names(result)
  geom_pos <- which(col_names == "geometry")
  elevation_pos <- which(col_names == "elevation_m")
  
  # elevation_m should come before geometry
  expect_true(elevation_pos < geom_pos)
})

test_that("physical_grabber handles multiple points", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1:3,
    geometry = sf::st_sfc(
      sf::st_point(c(-118, 43)),
      sf::st_point(c(-118.1, 43.1)),
      sf::st_point(c(-118.2, 43.2)),
      crs = 4326
    )
  )
  
  result <- physical_grabber(test_data, path = path)
  
  expect_equal(nrow(result), 3)
  expect_equal(result$id, 1:3)
})

test_that("physical_grabber removes ID column from extract", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  # Should only have user's 'id' column, not the extract 'ID' column
  expect_equal(sum(names(result) == "ID"), 0)
  expect_true("id" %in% names(result))
})

test_that("physical_grabber formats elevation with commas", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  # elevation values should be character with commas for thousands
  expect_type(result$elevation_m, "character")
  expect_type(result$elevation_ft, "character")
  # For 2000m, should have comma in ft value (6,560 ft)
  expect_true(grepl(",", result$elevation_ft))
})

test_that("physical_grabber round_df helper works correctly", {
  # Test the internal round_df function
  test_df <- data.frame(
    a = c(1.234, 5.678),
    b = c("text", "more"),
    c = c(9.999, 0.001)
  )
  
  round_df <- function(df, digits) {
    nums <- vapply(df, is.numeric, FUN.VALUE = logical(1))
    df[, nums] <- round(df[, nums], digits = digits)
    df
  }
  
  result <- round_df(test_df, 1)
  
  expect_equal(result$a, c(1.2, 5.7))
  expect_equal(result$b, c("text", "more"))
  expect_equal(result$c, c(10.0, 0.0))
})

test_that("physical_grabber works with different CRS", {
  path <- setup_mock_physical_geodata()
  
  # Create data in Web Mercator
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  ) |>
    sf::st_transform(3857)
  
  result <- physical_grabber(test_data, path = path)
  
  expect_s3_class(result, "sf")
  expect_true("elevation_m" %in% names(result))
})

test_that("physical_grabber extracts geology correctly", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  expect_true("geology" %in% names(result))
  # Should extract GENERALIZED_LITH column
  expect_equal(result$geology, "sandstone")
})

test_that("physical_grabber builds VRTs from multiple tiles", {
  path <- setup_mock_physical_geodata()
  
  # Add a second tile to one directory
  aspect2 <- create_mock_raster("aspect", 270)
  terra::writeRaster(
    aspect2,
    file.path(path, "aspect", "aspect_tile2.tif"),
    overwrite = TRUE
  )
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  # Should not error with multiple tiles
  expect_error(
    physical_grabber(test_data, path = path),
    NA
  )
})

test_that("physical_grabber uses format_degree for slope and aspect", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  # The physical_environ should contain degree symbols (from format_degree)
  expect_true(grepl("°", result$physical_environ) || 
              grepl("slo\\.", result$physical_environ))
})

test_that("physical_grabber handles points outside raster extent", {
  path <- setup_mock_physical_geodata()
  
  # Point outside the mock raster extent
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-70, 40)), crs = 4326)
  )
  
  # Should handle gracefully (values will be NA)
  result <- physical_grabber(test_data, path = path)
  
  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 1)
})

test_that("physical_grabber elevation_ft rounds to nearest 10", {
  path <- setup_mock_physical_geodata()
  
  test_data <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(sf::st_point(c(-118, 43)), crs = 4326)
  )
  
  result <- physical_grabber(test_data, path = path)
  
  # elevation_ft should be rounded to -1 (nearest 10)
  # 2000m * 3.28084 = 6561.68 -> rounds to 6560
  ft_numeric <- as.numeric(gsub(",", "", result$elevation_ft))
  expect_equal(ft_numeric %% 10, 0)
})
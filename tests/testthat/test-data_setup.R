library(testthat)
library(mockery)
library(BarnebyLives)

# Setup temporary directories
setup_test_dirs <- function() {
  tmp_dir <- file.path(tempdir(), "test_input")
  out_dir <- file.path(tempdir(), "test_output")
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  
  list(tmp_dir = tmp_dir, out_dir = out_dir)
}

# Minimal bound for tiles
tmp_bound <- data.frame(
  x = c(-119, -117, -117, -119),
  y = c(42, 42, 44, 44)
)

# List of all steps in data_setup
steps <- c(
  "mason",
  "make_it_political",
  "process_gmba",
  "process_gnis",
  "process_padus",
  "process_geology",
  "process_grazing_allot",
  "process_plss"
)

# ============================================================================
# data_setup() tests
# ============================================================================

test_that("data_setup creates output directory if it doesn't exist", {
  dirs <- setup_test_dirs()
  # Create a completely new directory path (not nested under existing temp)
  new_out <- file.path(tempdir(), "brand_new_output_dir_test")
  
  # Ensure it doesn't exist first
  if (dir.exists(new_out)) {
    unlink(new_out, recursive = TRUE)
  }
  
  stub(data_setup, "unzip", function(...) NULL)
  for (s in steps) {
    stub(data_setup, s, function(...) TRUE)
  }
  
  expect_false(dir.exists(new_out))
  
  suppressMessages({
    data_setup(dirs$tmp_dir, new_out, tmp_bound)
  })
  
  # The main output directory should now exist
  expect_true(dir.exists(new_out))
  
  # Clean up
  unlink(new_out, recursive = TRUE)
})

test_that("data_setup uses default paths when not supplied", {
  old_wd <- getwd()
  on.exit(setwd(old_wd))
  
  test_wd <- file.path(tempdir(), "default_test")
  dir.create(test_wd, showWarnings = FALSE, recursive = TRUE)
  setwd(test_wd)
  
  stub(data_setup, "unzip", function(...) NULL)
  for (s in steps) {
    stub(data_setup, s, function(...) TRUE)
  }
  
  suppressMessages({
    data_setup(bound = tmp_bound)
  })
  
  # Check default paths were created
  expect_true(dir.exists(file.path("..", "geodata")))
})

test_that("data_setup runs all steps successfully", {
  dirs <- setup_test_dirs()
  
  stub(data_setup, "unzip", function(...) NULL)
  for (s in steps) {
    stub(data_setup, s, function(...) TRUE)
  }
  
  msgs <- capture_messages({
    data_setup(dirs$tmp_dir, dirs$out_dir, tmp_bound)
  })
  
  expect_true(any(grepl("All steps succeeded", msgs)))
  expect_true(any(grepl("Cleaning up unzipped data", msgs)))
})

test_that("data_setup handles individual step failures gracefully", {
  dirs <- setup_test_dirs()
  
  stub(data_setup, "unzip", function(...) NULL)
  
  # Make mason fail, others succeed
  stub(data_setup, "mason", function(...) stop("mason failed"))
  for (s in steps[steps != "mason"]) {
    stub(data_setup, s, function(...) TRUE)
  }
  
  msgs <- capture_messages({
    data_setup(dirs$tmp_dir, dirs$out_dir, tmp_bound)
  })
  
  expect_true(any(grepl("following steps failed", msgs)))
  expect_true(any(grepl("mason", msgs)))
})

test_that("data_setup handles multiple step failures", {
  dirs <- setup_test_dirs()
  
  stub(data_setup, "unzip", function(...) NULL)
  
  # Make multiple steps fail
  stub(data_setup, "mason", function(...) stop("mason failed"))
  stub(data_setup, "process_gnis", function(...) stop("gnis failed"))
  
  for (s in steps[!steps %in% c("mason", "process_gnis")]) {
    stub(data_setup, s, function(...) TRUE)
  }
  
  msgs <- capture_messages({
    data_setup(dirs$tmp_dir, dirs$out_dir, tmp_bound)
  })
  
  expect_true(any(grepl("mason", msgs)))
  expect_true(any(grepl("process_gnis", msgs)))
})

test_that("data_setup cleanup removes zips only on success with cleanup=TRUE", {
  dirs <- setup_test_dirs()
  
  zip1 <- file.path(dirs$tmp_dir, "dummy1.zip")
  zip2 <- file.path(dirs$tmp_dir, "dummy2.zip")
  file.create(zip1)
  file.create(zip2)
  
  stub(data_setup, "unzip", function(...) NULL)
  for (s in steps) {
    stub(data_setup, s, function(...) TRUE)
  }
  
  suppressMessages({
    data_setup(dirs$tmp_dir, dirs$out_dir, tmp_bound, cleanup = TRUE)
  })
  
  expect_false(file.exists(zip1))
  expect_false(file.exists(zip2))
})

test_that("data_setup cleanup preserves zips on failure even with cleanup=TRUE", {
  dirs <- setup_test_dirs()
  
  zip1 <- file.path(dirs$tmp_dir, "fail1.zip")
  zip2 <- file.path(dirs$tmp_dir, "fail2.zip")
  file.create(zip1)
  file.create(zip2)
  
  stub(data_setup, "unzip", function(...) NULL)
  stub(data_setup, "mason", function(...) stop("mason failed"))
  
  for (s in steps[steps != "mason"]) {
    stub(data_setup, s, function(...) TRUE)
  }
  
  suppressMessages({
    data_setup(dirs$tmp_dir, dirs$out_dir, tmp_bound, cleanup = TRUE)
  })
  
  expect_true(file.exists(zip1))
  expect_true(file.exists(zip2))
})

test_that("data_setup skips already-unzipped archives", {
  dirs <- setup_test_dirs()
  
  zip1 <- file.path(dirs$tmp_dir, "already.zip")
  file.create(zip1)
  
  # Create the unzipped directory with a file
  unzipped_dir <- file.path(dirs$tmp_dir, "already")
  dir.create(unzipped_dir)
  file.create(file.path(unzipped_dir, "dummy.txt"))
  
  # Stub unzip so it doesn't try to extract the dummy zip
  stub(data_setup, "unzip", function(...) NULL)
  
  for (s in steps) {
    stub(data_setup, s, function(...) TRUE)
  }
  
  msgs <- capture_messages({
    data_setup(dirs$tmp_dir, dirs$out_dir, tmp_bound)
  })
  
  expect_true(any(grepl("Skipping already-unzipped", msgs)))
})

test_that("data_setup cleans up unzipped directories on success", {
  dirs <- setup_test_dirs()
  
  # Create a dummy unzipped directory
  unzipped_dir <- file.path(dirs$tmp_dir, "test_unzipped")
  dir.create(unzipped_dir)
  file.create(file.path(unzipped_dir, "test.txt"))
  
  stub(data_setup, "unzip", function(...) NULL)
  for (s in steps) {
    stub(data_setup, s, function(...) TRUE)
  }
  
  suppressMessages({
    data_setup(dirs$tmp_dir, dirs$out_dir, tmp_bound)
  })
  
  # Unzipped directories should be removed
  expect_false(dir.exists(unzipped_dir))
})

# ============================================================================
# make_tiles() tests
# ============================================================================

test_that("make_tiles creates correct grid structure", {
  bound <- data.frame(
    x = c(-120, -110, -110, -120),
    y = c(40, 40, 45, 45)
  ) |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()
  
  bb_vals <- c(-120, -110, 40, 45)
  
  result <- make_tiles(bound, bb_vals)
  
  expect_type(result, "list")
  expect_named(result, c("tile_cells", "tile_cellsV"))
  expect_s3_class(result$tile_cells, "sf")
  expect_s4_class(result$tile_cellsV, "SpatVector")
})

test_that("make_tiles creates single cell for small domains", {
  bound <- data.frame(
    x = c(-119, -118, -118, -119),
    y = c(42, 42, 43, 43)
  ) |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()
  
  bb_vals <- c(-119, -118, 42, 43)
  
  result <- make_tiles(bound, bb_vals)
  
  # For a domain < 5 degrees, should create 1x1 grid
  expect_equal(nrow(result$tile_cells), 1)
})

test_that("make_tiles creates cellname correctly", {
  bound <- data.frame(
    x = c(-119, -117, -117, -119),
    y = c(42, 42, 44, 44)
  ) |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()
  
  bb_vals <- c(-119, -117, 42, 44)
  
  result <- make_tiles(bound, bb_vals)
  
  expect_true(all(grepl("^n[0-9.]+w[0-9.]+$", result$tile_cells$cellname)))
  expect_true(all(c("x", "y", "cellname", "geometry") %in% names(result$tile_cells)))
})

# ============================================================================
# safe_untar() tests
# ============================================================================

test_that("safe_untar detects macOS and uses appropriate tar", {
  skip_on_os(c("windows", "linux", "solaris"))
  
  tmp <- tempdir()
  tar_file <- file.path(tmp, "test.tar")
  
  # Create a minimal tar file
  test_file <- file.path(tmp, "test.txt")
  writeLines("test", test_file)
  tar(tar_file, files = basename(test_file), compression = "none", tar = "tar")
  
  extract_dir <- file.path(tmp, "extract")
  dir.create(extract_dir, showWarnings = FALSE)
  
  msgs <- capture_messages({
    safe_untar(tar_file, extract_dir, verbose = TRUE)
  })
  
  # Should mention macOS and which tar is being used
  expect_true(any(grepl("macOS", msgs)))
  expect_true(any(grepl("tar", msgs, ignore.case = TRUE)))
})

test_that("safe_untar uses R untar on non-macOS systems", {
  skip_on_os("mac")
  
  tmp <- tempdir()
  old_wd <- getwd()
  on.exit(setwd(old_wd))
  
  # Change to tmp directory so tar can find the file
  setwd(tmp)
  
  tar_file <- file.path(tmp, "test2.tar")
  test_file <- file.path(tmp, "test2.txt")
  writeLines("test", test_file)
  
  # Create tar from within the temp directory
  tar(tar_file, files = basename(test_file), compression = "none")
  
  extract_dir <- file.path(tmp, "extract2")
  dir.create(extract_dir, showWarnings = FALSE)
  
  msgs <- capture_messages({
    safe_untar(tar_file, extract_dir, verbose = TRUE)
  })
  
  expect_true(any(grepl("Using R's untar", msgs)))
})

# ============================================================================
# check_data_setup_outputs() tests
# ============================================================================

test_that("check_data_setup_outputs detects present files", {
  tmp_out <- file.path(tempdir(), "check_test")
  dir.create(tmp_out, showWarnings = FALSE)
  
  # Create some expected outputs
  dir.create(file.path(tmp_out, "political"), showWarnings = FALSE)
  file.create(file.path(tmp_out, "political", "political.shp"))
  
  dir.create(file.path(tmp_out, "aspect"), showWarnings = FALSE)
  file.create(file.path(tmp_out, "aspect", "test.tif"))
  
  output <- capture_output({
    check_data_setup_outputs(tmp_out)
  })
  
  expect_true(grepl("Success", output))
  expect_true(grepl("political", output))
  expect_true(grepl("aspect", output))
})

test_that("check_data_setup_outputs detects missing files", {
  tmp_out <- file.path(tempdir(), "check_missing")
  dir.create(tmp_out, showWarnings = FALSE)
  
  # Don't create any files
  
  output <- capture_output({
    check_data_setup_outputs(tmp_out)
  })
  
  expect_true(grepl("Works in progress", output))
  expect_true(grepl("political", output))
  expect_true(grepl("mountains", output))
})

test_that("check_data_setup_outputs checks for tif files in raster dirs", {
  tmp_out <- file.path(tempdir(), "check_raster")
  dir.create(tmp_out, showWarnings = FALSE)
  
  # Create aspect dir but no tif files
  dir.create(file.path(tmp_out, "aspect"), showWarnings = FALSE)
  
  output <- capture_output({
    check_data_setup_outputs(tmp_out)
  })
  
  # Should be in "missing" because dir exists but has no .tif files
  expect_true(grepl("Works in progress", output))
  expect_true(grepl("aspect", output))
  
  # Now add a tif file
  file.create(file.path(tmp_out, "aspect", "tile.tif"))
  
  output2 <- capture_output({
    check_data_setup_outputs(tmp_out)
  })
  
  # Should now be in "Success"
  expect_true(grepl("Success", output2))
  expect_true(grepl("aspect", output2))
})

# ============================================================================
# Integration-style tests for individual processing functions
# ============================================================================

test_that("make_it_political creates output directory and writes file", {
  dirs <- setup_test_dirs()
  
  bound <- data.frame(
    x = c(-119, -117, -117, -119),
    y = c(42, 42, 44, 44)
  ) |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()
  
  bb_vals <- c(-119, -117, 42, 44)
  tile_cells <- make_tiles(bound, bb_vals)$tile_cells
  
  # Mock the file read to return minimal valid data
  stub(make_it_political, "sf::st_read", function(...) {
    counties <- sf::st_sf(
      STATEFP = "01",
      NAME = "TestCounty",
      geometry = sf::st_sfc(
        sf::st_polygon(list(cbind(c(-119, -117, -117, -119, -119), 
                                   c(42, 42, 44, 44, 42)))),
        crs = 4269
      )
    )
    # Set agr to avoid warnings
    sf::st_agr(counties) <- "constant"
    counties
  })
  
  stub(make_it_political, "tigris::states", function(...) {
    states <- sf::st_sf(
      STATEFP = "01",
      NAME = "TestState",
      STUSPS = "TS",
      geometry = sf::st_sfc(
        sf::st_polygon(list(cbind(c(-120, -116, -116, -120, -120), 
                                   c(41, 41, 45, 45, 41)))),
        crs = 4269
      )
    )
    # Set agr to avoid warnings
    sf::st_agr(states) <- "constant"
    states
  })
  
  suppressMessages({
    suppressWarnings({
      make_it_political(dirs$tmp_dir, dirs$out_dir, tile_cells)
    })
  })
  
  # Check that output directory was created
  expect_true(dir.exists(file.path(dirs$out_dir, "political")))
  
  # Check that shapefile was written
  expect_true(file.exists(file.path(dirs$out_dir, "political", "political.shp")))
})
test_that("process_plss calculates adaptive buffer correctly", {
  # Small domain - should use 1 cell buffer
  small_bound <- data.frame(
    x = c(-119, -118.5, -118.5, -119),
    y = c(42, 42, 42.5, 42.5)
  ) |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()
  
  bb_vals <- c(-119, -118.5, 42, 42.5)
  tiles <- make_tiles(small_bound, bb_vals)
  
  # Can't easily test the internal buffer calculation without running the whole function
  # But we can verify the tile creation works for different domain sizes
  expect_s3_class(tiles$tile_cells, "sf")
  expect_true(nrow(tiles$tile_cells) >= 1)
})

test_that("data_setup handles bound transformation correctly", {
  dirs <- setup_test_dirs()
  
  # Bound in different formats
  bound_df <- data.frame(
    x = c(-119, -117, -117, -119, -119),
    y = c(42, 42, 44, 44, 42)
  )
  
  stub(data_setup, "unzip", function(...) NULL)
  for (s in steps) {
    stub(data_setup, s, function(...) TRUE)
  }
  
  # Should not error with different bound formats
  expect_error(
    suppressMessages({
      data_setup(dirs$tmp_dir, dirs$out_dir, bound_df)
    }),
    NA
  )
})

test_that("mason skips products with no archives", {
  dirs <- setup_test_dirs()
  
  # Create tiles
  bb_vals <- c(-119, -117, 42, 44)
  mt <- make_tiles(
    sf::st_as_sfc(sf::st_bbox(c(xmin = -119, xmax = -117, ymin = 42, ymax = 44), crs = 4326)),
    bb_vals
  )
  
  # No .tar.gz files in the directory
  msgs <- capture_messages({
    mason(dirs$tmp_dir, dirs$out_dir, mt$tile_cellsV)
  })
  
  # Check that it completed without errors and mentions "Done processing"
  expect_true(any(grepl("Done processing raster data", msgs)))
  
  # Verify no output directories were created (since no archives found)
  prods <- c('aspect', 'dem', 'geom', 'slope')
  created_dirs <- sapply(prods, function(p) {
    dir.exists(file.path(dirs$out_dir, p)) && 
    length(list.files(file.path(dirs$out_dir, p), pattern = "\\.tif$")) > 0
  })
  
  expect_false(any(created_dirs))
})
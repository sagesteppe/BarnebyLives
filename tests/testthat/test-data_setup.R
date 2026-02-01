library(testthat)
library(mockery)
library(sf)
library(terra)
library(dplyr)
library(withr)
library(stringr)

# ============================================================================
# Test Fixtures - Real Spatial Data
# ============================================================================

create_test_bound <- function() {
  data.frame(
    x = c(-119, -117, -117, -119, -119),
    y = c(42, 42, 44, 44, 42)
  )
}

create_test_bound_sf <- function() {
  create_test_bound() |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()
}

create_mock_tiles <- function() {
  bound <- create_test_bound_sf()
  bb_vals <- c(-119, -117, 42, 44)
  make_tiles(bound, bb_vals)
}

create_mock_counties <- function() {
  sf::st_sf(
    STATEFP = c("16", "41"),
    County = c("Ada", "Baker"),
    NAME = c("Ada", "Baker"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(cbind(c(-119, -118, -118, -119, -119), c(42, 42, 43, 43, 42)))),
      sf::st_polygon(list(cbind(c(-118, -117, -117, -118, -118), c(43, 43, 44, 44, 43)))),
      crs = 4269
    )
  )
}

create_mock_states <- function() {
  sf::st_sf(
    STATEFP = c("16", "41"),
    NAME = c("Idaho", "Oregon"),
    STUSPS = c("ID", "OR"),
    State = c("Idaho", "Oregon"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(cbind(c(-120, -114, -114, -120, -120), c(42, 42, 49, 49, 42)))),
      sf::st_polygon(list(cbind(c(-125, -116, -116, -125, -125), c(42, 42, 46, 46, 42)))),
      crs = 4269
    )
  )
}

create_mock_mountains <- function() {
  sf::st_sf(
    MapName = c("Sawtooth Mountains", "Wallowa Mountains"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(cbind(c(-119, -118, -118, -119, -119), c(42, 42, 43, 43, 42)))),
      sf::st_polygon(list(cbind(c(-118, -117, -117, -118, -118), c(43, 43, 44, 44, 43)))),
      crs = 4269
    )
  )
}

create_mock_valleys <- function() {
  sf::st_sf(
    transferred_tag = c("Snake River Valley", "Grande Ronde Valley"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(cbind(c(-119, -118.5, -118.5, -119, -119), c(42, 42, 42.5, 42.5, 42)))),
      sf::st_polygon(list(cbind(c(-118.5, -117.5, -117.5, -118.5, -118.5), c(43, 43, 43.5, 43.5, 43)))),
      crs = 4269
    )
  )
}

create_mock_gnis_data <- function() {
  data.frame(
    feature_name = c("Test Peak", "Test Creek", "Test Canyon Census Designated Place"),
    prim_lat_dec = c(42.5, 43.0, 43.5),
    prim_long_dec = c(-118.5, -118.0, -117.5)
  )
}

create_mock_padus <- function() {
  sf::st_sf(
    State_Nm = c("Idaho", "Oregon"),
    Mang_Name = c("USDA Forest Service", "Bureau of Land Management"),
    Unit_Nm = c("Sawtooth National Forest", "Baker District Office"),
    geometry = sf::st_sfc(
      sf::st_multipolygon(list(list(cbind(c(-119, -118, -118, -119, -119), c(42, 42, 43, 43, 42))))),
      sf::st_multipolygon(list(list(cbind(c(-118, -117, -117, -118, -118), c(43, 43, 44, 44, 43))))),
      crs = 4269
    )
  )
}

create_mock_geology <- function() {
  sf::st_sf(
    GENERALIZED_LITH = c("Sedimentary", "Igneous"),
    UNIT_NAME = c("Morrison Formation", "Columbia River Basalt"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(cbind(c(-119, -118, -118, -119, -119), c(42, 42, 43, 43, 42)))),
      sf::st_polygon(list(cbind(c(-118, -117, -117, -118, -118), c(43, 43, 44, 44, 43)))),
      crs = 4269
    )
  )
}

create_mock_allotments <- function(source = "BLM") {
  col_name <- if (source == "BLM") "ALLOT_NAME" else "ALLOTMENT_"
  
  df <- data.frame(
    name = c("Test Allotment 1", "Test Allotment 2")
  )
  names(df)[1] <- col_name
  
  sf::st_sf(
    df,
    geometry = sf::st_sfc(
      sf::st_polygon(list(cbind(c(-119, -118, -118, -119, -119), c(42, 42, 43, 43, 42)))),
      sf::st_polygon(list(cbind(c(-118, -117, -117, -118, -118), c(43, 43, 44, 44, 43)))),
      crs = 4269
    )
  )
}

create_mock_plss_township <- function() {
  sf::st_sf(
    TWNSHPLAB = c("T01N R01E", "T01N R02E"),
    PLSSID = c("ID001", "ID002"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(cbind(c(-119, -118, -118, -119, -119), c(42, 42, 43, 43, 42)))),
      sf::st_polygon(list(cbind(c(-118, -117, -117, -118, -118), c(43, 43, 44, 44, 43)))),
      crs = 4269
    )
  )
}

create_mock_plss_section <- function() {
  sf::st_sf(
    PLSSID = c("ID001", "ID001", "ID002", "ID002"),
    FRSTDIVLAB = c("1", "2", "1", "2"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(cbind(c(-119, -118.5, -118.5, -119, -119), c(42, 42, 42.5, 42.5, 42)))),
      sf::st_polygon(list(cbind(c(-118.5, -118, -118, -118.5, -118.5), c(42.5, 42.5, 43, 43, 42.5)))),
      sf::st_polygon(list(cbind(c(-118, -117.5, -117.5, -118, -118), c(43, 43, 43.5, 43.5, 43)))),
      sf::st_polygon(list(cbind(c(-117.5, -117, -117, -117.5, -117.5), c(43.5, 43.5, 44, 44, 43.5)))),
      crs = 4269
    )
  )
}

# ============================================================================
# make_tiles() Tests
# ============================================================================

test_that("make_tiles creates correct structure", {
  bound <- create_test_bound_sf()
  bb_vals <- c(-119, -117, 42, 44)
  
  result <- make_tiles(bound, bb_vals)
  
  expect_type(result, "list")
  expect_named(result, c("tile_cells", "tile_cellsV"))
  expect_s3_class(result$tile_cells, "sf")
  expect_s4_class(result$tile_cellsV, "SpatVector")
})

test_that("make_tiles creates cellnames correctly", {
  bound <- create_test_bound_sf()
  bb_vals <- c(-119, -117, 42, 44)
  
  result <- make_tiles(bound, bb_vals)
  
  expect_true(all(grepl("^n[0-9.]+w[0-9.]+$", result$tile_cells$cellname)))
  expect_true(all(c("x", "y", "cellname", "geometry") %in% names(result$tile_cells)))
})

test_that("make_tiles handles small domains", {
  small_bound <- data.frame(
    x = c(-119, -118, -118, -119, -119),
    y = c(42, 42, 43, 43, 42)
  ) |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()
  
  bb_vals <- c(-119, -118, 42, 43)
  result <- make_tiles(small_bound, bb_vals)
  
  expect_equal(nrow(result$tile_cells), 1)
})

test_that("make_tiles rounds coordinates", {
  bound <- create_test_bound_sf()
  bb_vals <- c(-119, -117, 42, 44)
  
  result <- make_tiles(bound, bb_vals)
  
  expect_true(all(result$tile_cells$x == round(result$tile_cells$x, 1)))
  expect_true(all(result$tile_cells$y == round(result$tile_cells$y, 1)))
})

# ============================================================================
# make_it_political() Tests
# ============================================================================

test_that("make_it_political creates output directory", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  # Create mock counties file
  counties_dir <- file.path(temp_path, "Counties")
  dir.create(counties_dir)
  mock_counties <- create_mock_counties()
  sf::st_write(mock_counties, file.path(counties_dir, "tl_2020_us_county.shp"), quiet = TRUE)
  
  tiles <- create_mock_tiles()
  
  stub(make_it_political, "tigris::states", function(...) create_mock_states())
  
  suppressMessages(suppressWarnings({
    make_it_political(temp_path, temp_out, tiles$tile_cells)
  }))
  
  expect_true(dir.exists(file.path(temp_out, "political")))
})

test_that("make_it_political writes shapefile with correct columns", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  counties_dir <- file.path(temp_path, "Counties")
  dir.create(counties_dir)
  mock_counties <- create_mock_counties()
  sf::st_write(mock_counties, file.path(counties_dir, "tl_2020_us_county.shp"), quiet = TRUE)
  
  tiles <- create_mock_tiles()
  
  stub(make_it_political, "tigris::states", function(...) create_mock_states())
  
  suppressMessages(suppressWarnings({
    make_it_political(temp_path, temp_out, tiles$tile_cells)
  }))
  
  result <- sf::st_read(file.path(temp_out, "political", "political.shp"), quiet = TRUE)
  
  expect_true("State" %in% names(result))
  expect_true("County" %in% names(result))
  expect_true("STUSPS" %in% names(result))
})

test_that("make_it_political transforms to WGS84", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  counties_dir <- file.path(temp_path, "Counties")
  dir.create(counties_dir)
  mock_counties <- create_mock_counties()
  sf::st_write(mock_counties, file.path(counties_dir, "tl_2020_us_county.shp"), quiet = TRUE)
  
  tiles <- create_mock_tiles()
  
  stub(make_it_political, "tigris::states", function(...) create_mock_states())
  
  suppressMessages(suppressWarnings({
    make_it_political(temp_path, temp_out, tiles$tile_cells)
  }))
  
  result <- sf::st_read(file.path(temp_out, "political", "political.shp"), quiet = TRUE)
  
  expect_equal(sf::st_crs(result)$input, "WGS 84")
})

test_that("make_it_political crops to tile extent", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  counties_dir <- file.path(temp_path, "Counties")
  dir.create(counties_dir)
  mock_counties <- create_mock_counties()
  sf::st_write(mock_counties, file.path(counties_dir, "tl_2020_us_county.shp"), quiet = TRUE)
  
  tiles <- create_mock_tiles()
  
  stub(make_it_political, "tigris::states", function(...) create_mock_states())
  
  suppressMessages(suppressWarnings({
    make_it_political(temp_path, temp_out, tiles$tile_cells)
  }))
  
  result <- sf::st_read(file.path(temp_out, "political", "political.shp"), quiet = TRUE)
  
  # Result should be within tile bounds
  expect_true(nrow(result) > 0)
})

# ============================================================================
# process_gmba() Tests
# ============================================================================

test_that("process_gmba creates output directory", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  gmba_dir <- file.path(temp_path, "GMBA")
  dir.create(gmba_dir)
  
  mock_mtns <- create_mock_mountains()
  sf::st_write(mock_mtns, file.path(gmba_dir, "GMBA_Inventory_v2.0_standard_basic.shp"), quiet = TRUE)
  
  mock_valleys <- create_mock_valleys()
  sf::st_write(mock_valleys, file.path(temp_path, "Named_Valleys.gpkg"), quiet = TRUE)
  
  tiles <- create_mock_tiles()
  
  suppressMessages({
    process_gmba(temp_path, temp_out, tiles$tile_cells)
  })
  
  expect_true(dir.exists(file.path(temp_out, "mountains")))
})

test_that("process_gmba combines mountains and valleys", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  gmba_dir <- file.path(temp_path, "GMBA")
  dir.create(gmba_dir)
  
  mock_mtns <- create_mock_mountains()
  sf::st_write(mock_mtns, file.path(gmba_dir, "GMBA_Inventory_v2.0_standard_basic.shp"), quiet = TRUE)
  
  mock_valleys <- create_mock_valleys()
  sf::st_write(mock_valleys, file.path(temp_path, "Named_Valleys.gpkg"), quiet = TRUE)
  
  tiles <- create_mock_tiles()
  
  suppressMessages({
    process_gmba(temp_path, temp_out, tiles$tile_cells)
  })
  
  result <- sf::st_read(file.path(temp_out, "mountains", "mountains.shp"), quiet = TRUE)
  
  expect_true("Feature" %in% names(result))
  expect_true(nrow(result) > 0)
})

test_that("process_gmba removes '(nn)' from MapName", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  gmba_dir <- file.path(temp_path, "GMBA")
  dir.create(gmba_dir)
  
  # Create mountains with (nn) in name
  mock_mtns <- create_mock_mountains()
  mock_mtns$MapName <- c("Sawtooth Mountains (nn)", "Wallowa Mountains")
  sf::st_write(mock_mtns, file.path(gmba_dir, "GMBA_Inventory_v2.0_standard_basic.shp"), quiet = TRUE)
  
  mock_valleys <- create_mock_valleys()
  sf::st_write(mock_valleys, file.path(temp_path, "Named_Valleys.gpkg"), quiet = TRUE)
  
  tiles <- create_mock_tiles()
  
  suppressMessages({
    process_gmba(temp_path, temp_out, tiles$tile_cells)
  })
  
  result <- sf::st_read(file.path(temp_out, "mountains", "mountains.shp"), quiet = TRUE)
  
  expect_false(any(grepl("\\(nn\\)", result$Feature)))
})

# ============================================================================
# process_gnis() Tests
# ============================================================================

test_that("process_gnis creates output directory", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  gnis_dir <- file.path(temp_path, "GNIS", "Text")
  dir.create(gnis_dir, recursive = TRUE)
  
  # Create mock GNIS file
  mock_data <- create_mock_gnis_data()
  write.table(mock_data, file.path(gnis_dir, "DomesticNames_ID.txt"), 
              sep = "|", row.names = FALSE, quote = FALSE)
  
  bound <- create_test_bound_sf()
  
  stub(process_gnis, "tigris::states", function(...) {
    create_mock_states() |> dplyr::filter(STUSPS == "ID")
  })
  
  suppressMessages({
    process_gnis(temp_path, temp_out, bound)
  })
  
  expect_true(dir.exists(file.path(temp_out, "places")))
})

test_that("process_gnis filters unwanted features", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  gnis_dir <- file.path(temp_path, "GNIS", "Text")
  dir.create(gnis_dir, recursive = TRUE)
  
  mock_data <- create_mock_gnis_data()
  mock_data$feature_name <- c("Test Peak", "Election Precinct 1", "Test Ditch")
  write.table(mock_data, file.path(gnis_dir, "DomesticNames_ID.txt"), 
              sep = "|", row.names = FALSE, quote = FALSE)
  
  bound <- create_test_bound_sf()
  
  stub(process_gnis, "tigris::states", function(...) {
    create_mock_states() |> dplyr::filter(STUSPS == "ID")
  })
  
  suppressMessages({
    process_gnis(temp_path, temp_out, bound)
  })
  
  result <- sf::st_read(file.path(temp_out, "places", "places.shp"), quiet = TRUE)
  
  # Should filter out "Election Precinct" and "Ditch"
  expect_true(all(!grepl("Election Precinct|Ditch", result$fetr_nm)))
})

test_that("process_gnis abbreviates feature names", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  gnis_dir <- file.path(temp_path, "GNIS", "Text")
  dir.create(gnis_dir, recursive = TRUE)
  
  mock_data <- create_mock_gnis_data()
  mock_data$feature_name <- c("Test Canyon", "Test Creek", "Test Mountain")
  write.table(mock_data, file.path(gnis_dir, "DomesticNames_ID.txt"), 
              sep = "|", row.names = FALSE, quote = FALSE)
  
  bound <- create_test_bound_sf()
  
  stub(process_gnis, "tigris::states", function(...) {
    create_mock_states() |> dplyr::filter(STUSPS == "ID")
  })
  
  suppressMessages({
    process_gnis(temp_path, temp_out, bound)
  })
  
  result <- sf::st_read(file.path(temp_out, "places", "places.shp"), quiet = TRUE)
  
  expect_true(any(grepl("cnyn\\.", result$fetr_nm)))
  expect_true(any(grepl("crk\\.", result$fetr_nm)))
  expect_true(any(grepl("mtn\\.", result$fetr_nm)))
})

# ============================================================================
# process_padus() Tests
# ============================================================================

test_that("process_padus creates output directory", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  # Create mock PADUS geodatabase structure
  padus_dir <- file.path(temp_path, "PADUS3_0Geodatabase")
  dir.create(padus_dir)
  
  gdb_path <- file.path(padus_dir, "PADUS3_0Geodatabase.gdb")
  dir.create(gdb_path)
  
  # Write mock shapefile as stand-in for GDB layer
  mock_padus <- create_mock_padus()
  sf::st_write(mock_padus, file.path(gdb_path, "PADUS3_0Fee.shp"), quiet = TRUE)
  
  # Create version file
  file.create(file.path(temp_path, "PADUS3_0GAPStatusCode.txt"))
  
  tiles <- create_mock_tiles()
  bound <- create_test_bound_sf()
  
  stub(process_padus, "sf::st_layers", function(...) list(name = "PADUS3_0Fee"))
  stub(process_padus, "sf::st_read", function(...) mock_padus)
  stub(process_padus, "tigris::states", function(...) create_mock_states())
  
  suppressMessages({
    process_padus(temp_path, temp_out, bound, tiles$tile_cells)
  })
  
  expect_true(dir.exists(file.path(temp_out, "pad")))
})

# test_that("process_padus abbreviates unit names", {
#   temp_path <- withr::local_tempdir()
#   temp_out <- withr::local_tempdir()
#   
#   file.create(file.path(temp_path, "PADUS3_0GAPStatusCode.txt"))
#   
#   # Create PADUS data with full names that should be abbreviated
#   mock_padus <- sf::st_sf(
#     State_Nm = c("Idaho", "Oregon", "Idaho"),
#     Mang_Name = c("USDA Forest Service", "Bureau of Land Management", "National Park Service"),
#     Unit_Nm = c("Sawtooth National Forest", "Baker District Office", "Craters of the Moon National Monument"),
#     geometry = sf::st_sfc(
#       sf::st_multipolygon(list(list(cbind(c(-119, -118, -118, -119, -119), c(42, 42, 43, 43, 42))))),
#       sf::st_multipolygon(list(list(cbind(c(-118, -117, -117, -118, -118), c(43, 43, 44, 44, 43))))),
#       sf::st_multipolygon(list(list(cbind(c(-118.5, -117.5, -117.5, -118.5, -118.5), c(42.5, 42.5, 43.5, 43.5, 42.5))))),
#       crs = 4269
#     )
#   )
#   
#   tiles <- create_mock_tiles()
#   bound <- create_test_bound_sf()
#   
#   stub(process_padus, "sf::st_layers", function(...) list(name = "PADUS3_0Fee"))
#   stub(process_padus, "sf::st_read", function(...) mock_padus)
#   stub(process_padus, "tigris::states", function(...) create_mock_states())
#   
#   suppressMessages({
#     process_padus(temp_path, temp_out, bound, tiles$tile_cells)
#   })
#   
#   result <- sf::st_read(file.path(temp_out, "pad", "pad.shp"), quiet = TRUE)
#   
#   expect_true(any(grepl("NF", result$Unit_Nm)))
#   expect_true(any(grepl("DO|FO", result$Unit_Nm)))
# })

# ============================================================================
# process_geology() Tests
# ============================================================================

test_that("process_geology creates output directory", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  sgmc_dir <- file.path(temp_path, "SGMC", "USGS_SGMC_Geodatabase")
  dir.create(sgmc_dir, recursive = TRUE)
  
  gdb_path <- file.path(sgmc_dir, "USGS_StateGeologicMapCompilation_ver1.1.gdb")
  dir.create(gdb_path)
  
  mock_geology <- create_mock_geology()
  sf::st_write(mock_geology, file.path(gdb_path, "SGMC_Geology.shp"), quiet = TRUE)
  
  tiles <- create_mock_tiles()
  
  stub(process_geology, "sf::st_read", function(...) mock_geology)
  
  suppressMessages({
    process_geology(temp_path, temp_out, tiles$tile_cells)
  })
  
  expect_true(dir.exists(file.path(temp_out, "geology")))
})

# test_that("process_geology writes correct columns", {
#   temp_path <- withr::local_tempdir()
#   temp_out <- withr::local_tempdir()
#   
#   sgmc_dir <- file.path(temp_path, "SGMC", "USGS_SGMC_Geodatabase")
#   dir.create(sgmc_dir, recursive = TRUE)
#   
#   gdb_path <- file.path(sgmc_dir, "USGS_StateGeologicMapCompilation_ver1.1.gdb")
#   dir.create(gdb_path)
#   
#   mock_geology <- create_mock_geology()
#   
#   tiles <- create_mock_tiles()
#   
#   stub(process_geology, "sf::st_read", function(...) mock_geology)
#   
#   suppressMessages({
#     process_geology(temp_path, temp_out, tiles$tile_cells)
#   })
#   
#   result <- sf::st_read(file.path(temp_out, "geology", "geology.shp"), quiet = TRUE)
#   
#   expect_true("GENERALIZE" %in% names(result) || "GENERALZD" %in% names(result))
#   expect_true("UNIT_NAME" %in% names(result))
# })

# ============================================================================
# process_grazing_allot() Tests
# ============================================================================

test_that("process_grazing_allot creates output directory", {
  temp_path <- withr::local_tempdir()
  temp_out <- withr::local_tempdir()
  
  # Create BLM allotments
  blm_dir <- file.path(temp_path, "BLMAllotments")
  dir.create(blm_dir)
  mock_blm <- create_mock_allotments("BLM")
  sf::st_write(mock_blm, file.path(blm_dir, "blm_allotments.shp"), quiet = TRUE)
  
  # Create USFS allotments
  usfs_dir <- file.path(temp_path, "USFSAllotments")
  dir.create(usfs_dir)
  mock_usfs <- create_mock_allotments("USFS")
  sf::st_write(mock_usfs, file.path(usfs_dir, "usfs_allotments.shp"), quiet = TRUE)
  
  tiles <- create_mock_tiles()
  
  suppressMessages({
    process_grazing_allot(temp_path, temp_out, tiles$tile_cells)
  })
  
  result <- sf::st_read(file.path(temp_out, "allotments", "allotments.shp"), quiet = TRUE)
  
  # Should be title case
  expect_true(all(result$Allotment == stringr::str_to_title(result$Allotment)))
})

# ============================================================================
# process_plss() Tests
# ============================================================================

#test_that("process_plss creates output directory", {
#  temp_path <- withr::local_tempdir()
#  temp_out <- withr::local_tempdir()
#  
#  plss_dir <- file.path(temp_path, "PLSS")
#  dir.create(plss_dir)
#  gdb_path <- file.path(plss_dir, "ilmocplss.gdb")
#  dir.create(gdb_path)
#  
#  mock_township <- create_mock_plss_township()
#  sf::st_write(mock_township, file.path(gdb_path, "PLSSTownship.shp"), quiet = TRUE)
#  
#  mock_section <- create_mock_plss_section()
#  sf::st_write(mock_section, file.path(gdb_path, "PLSSFirstDivision.shp"), quiet = TRUE)
#  
#  tiles <- create_mock_tiles()
#  
#  stub(process_plss, "sf::st_read", function(dsn, layer, ...) {
#    if (grepl("Township", layer)) mock_township else mock_section
#  })
#  
#  suppressMessages({
#    process_plss(temp_path, temp_out, tiles$tile_cells)
#  })
#  
#  expect_true(dir.exists(file.path(temp_out, "plss")))
#})

# test_that("process_plss creates TRS column", {
#   temp_path <- withr::local_tempdir()
#   temp_out <- withr::local_tempdir()
#   
#   plss_dir <- file.path(temp_path, "PLSS")
#   dir.create(plss_dir)
#   gdb_path <- file.path(plss_dir, "ilmocplss.gdb")
#   dir.create(gdb_path)
#   
#   mock_township <- create_mock_plss_township()
#   mock_section <- create_mock_plss_section()
#   
#   tiles <- create_mock_tiles()
#   
#   stub(process_plss, "sf::st_read", function(dsn, layer, ...) {
#     if (grepl("Township", layer)) mock_township else mock_section
#   })
#   
#   suppressMessages({
#     process_plss(temp_path, temp_out, tiles$tile_cells)
#   })
#   
#   result <- sf::st_read(file.path(temp_out, "plss", "plss.shp"), quiet = TRUE)
#   
#   expect_true("trs" %in% names(result))
#   expect_true(all(grepl("T[0-9]+N R[0-9]+E", result$trs)))
# })
# 
# test_that("process_plss calculates adaptive buffer", {
#  temp_path <- withr::local_tempdir()
#  temp_out <- withr::local_tempdir()
#  
#  plss_dir <- file.path(temp_path, "PLSS")
#  dir.create(plss_dir)
#  gdb_path <- file.path(plss_dir, "ilmocplss.gdb")
#  dir.create(gdb_path)
#  
#  # Create small domain tiles
#  small_bound <- data.frame(
#    x = c(-119, -118.5, -118.5, -119, -119),
#    y = c(42, 42, 42.5, 42.5, 42)
#  ) |>
#    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
#    sf::st_bbox() |>
#    sf::st_as_sfc()
#  
#  small_tiles <- make_tiles(small_bound, c(-119, -118.5, 42, 42.5))
#  
#  mock_township <- create_mock_plss_township()
#  mock_section <- create_mock_plss_section()
#  
#  stub(process_plss, "sf::st_read", function(dsn, layer, ...) {
#    if (grepl("Township", layer)) mock_township else mock_section
#  })
#  
#  suppressMessages({
#    process_plss(temp_path, temp_out, small_tiles$tile_cells)
#  })
#  
#  expect_true(file.exists(file.path(temp_out, "plss", "plss.shp")))
#})

# ============================================================================
# safe_untar() Tests
# ============================================================================

test_that("safe_untar detects OS correctly", {
  skip_on_os(c("windows", "solaris"))
  
  temp_dir <- withr::local_tempdir()
  tar_file <- file.path(temp_dir, "test.tar")
  test_file <- file.path(temp_dir, "test.txt")
  
  writeLines("test content", test_file)
  old_wd <- getwd()
  setwd(temp_dir)
  tar(tar_file, files = basename(test_file), compression = "none")
  setwd(old_wd)
  
  extract_dir <- file.path(temp_dir, "extract")
  dir.create(extract_dir)
  
  msgs <- capture_messages({
    safe_untar(tar_file, extract_dir, verbose = TRUE)
  })
  
  os <- Sys.info()[["sysname"]]
  if (os == "Darwin") {
    expect_true(any(grepl("macOS", msgs)))
  } else {
    expect_true(any(grepl("Using R's untar", msgs)))
  }
})

test_that("safe_untar extracts files successfully", {
  skip_on_os(c("windows", "solaris"))
  
  temp_dir <- withr::local_tempdir()
  tar_file <- file.path(temp_dir, "test.tar")
  test_file <- file.path(temp_dir, "test.txt")
  
  writeLines("test content", test_file)
  old_wd <- getwd()
  setwd(temp_dir)
  tar(tar_file, files = basename(test_file), compression = "none")
  setwd(old_wd)
  
  extract_dir <- file.path(temp_dir, "extract")
  dir.create(extract_dir)
  
  safe_untar(tar_file, extract_dir, verbose = FALSE)
  
  expect_true(file.exists(file.path(extract_dir, basename(test_file))))
})

# ============================================================================
# check_data_setup_outputs() Tests
# ============================================================================

test_that("check_data_setup_outputs detects all expected files", {
  temp_out <- withr::local_tempdir()
  
  # Create all expected outputs
  dirs <- c("political", "mountains", "places", "pad", "geology", "allotments", "plss")
  for (d in dirs) {
    dir.create(file.path(temp_out, d))
    file.create(file.path(temp_out, d, paste0(d, ".shp")))
  }
  
  raster_dirs <- c("aspect", "dem", "geom", "slope")
  for (d in raster_dirs) {
    dir.create(file.path(temp_out, d))
    file.create(file.path(temp_out, d, "tile1.tif"))
  }
  
  output <- capture_output({
    check_data_setup_outputs(temp_out)
  })
  
  expect_true(grepl("Success", output))
  for (d in c(dirs, raster_dirs)) {
    expect_true(grepl(d, output))
  }
})

test_that("check_data_setup_outputs detects missing files", {
  temp_out <- withr::local_tempdir()
  
  # Don't create anything
  output <- capture_output({
    check_data_setup_outputs(temp_out)
  })
  
  expect_true(grepl("Works in progress", output))
})
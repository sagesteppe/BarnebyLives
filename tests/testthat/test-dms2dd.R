library(testthat)
library(BarnebyLives)

test_that("dms2dd converts decimal degree input correctly", {
  df <- data.frame(
    latitude = c(45.123, 46.456),
    longitude = c(-120.456, -121.789)
  )
  
  res <- dms2dd(df, lat = "latitude", long = "longitude")
  
  expect_true(all(c("latitude_dd", "longitude_dd", "latitude_dms", "longitude_dms") %in% colnames(res)))
  expect_equal(round(res$latitude_dd, 3), c(45.123, 46.456))
  expect_equal(round(res$longitude_dd, 3), c(-120.456, -121.789))
  expect_s3_class(res, "data.frame")
})

test_that("dms2dd auto-detects lat/long columns if not supplied", {
  df <- data.frame(
    lat_val = c(45.123),
    long_val = c(-120.456)
  )
  
  expect_message(res <- dms2dd(df))
  expect_equal(round(res$latitude_dd, 3), 45.123)
  expect_equal(round(res$longitude_dd, 3), -120.456)
})

test_that("dms2dd stops if columns not found", {
  df <- data.frame(foo = 1, bar = 2)
  expect_error(dms2dd(df), "Error, argument for `lat` not found")
})

test_that("dms2dd converts DMS strings correctly", {
  df <- data.frame(
    latitude = c("45° 7' 24\""),    # or "45 7 24N" or "45:7:24"
    longitude = c("120° 27' 21\"")  # or "120 27 21W" or "120:27:21"
  )
  res <- dms2dd(df)
  expect_true(all(c("latitude_dd", "longitude_dd") %in% colnames(res)))
  expect_true(all(c("latitude_dms", "longitude_dms") %in% colnames(res)))
  # You could also check the actual values
  expect_equal(res$latitude_dd, 45.123, tolerance = 0.01)
  expect_equal(res$longitude_dd, -120.456, tolerance = 0.01)
})
test_that("dms2dd preserves data.table class", {
  dt <- data.table::data.table(
    latitude = c(45.123),
    longitude = c(-120.456)
  )
  
  res <- dms2dd(dt)
  expect_s3_class(res, "data.table")
})

test_that("dmsbyrow handles mixed DMS/DD input", {
  df <- data.frame(
    lat1 = c(45.123, "45 7 24"),
    long1 = c(-120.456, "120 27 21")
  )
  
  res <- lapply(split(df, 1:nrow(df)), dmsbyrow, long = "long1", lat = "lat1")
  expect_equal(length(res), 2)
  expect_true(all(c("latitude_dd", "longitude_dd") %in% colnames(res[[1]])))
})


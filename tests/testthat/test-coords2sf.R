library(testthat)
library(sf)
library(dplyr)
library(BarnebyLives)

test_that("coords2sf removes rows with NA coordinates", {
  x <- data.frame(
    datum = c("WGS84", "NAD27", "NAD83"),
    longitude_dd = c(NA, -111, -112),
    latitude_dd  = c(45, NA, -112)
  )

  expect_output(
    res <- coords2sf(x),
    "Error with row"
  )
  expect_equal(nrow(res), 1)
})

test_that("coords2sf works with single-row input", {
  x <- data.frame(
    datum = "WGS84",
    longitude_dd = -110,
    latitude_dd = 45
  )

  res <- coords2sf(x)

  expect_s3_class(res, "sf")
  expect_equal(nrow(res), 1)
  expect_identical(res$datum, "WGS84")
  expect_true("geometry" %in% names(res))
})

test_that("coords2sf auto-detects datum column", {
  x <- data.frame(
    Datum = c("nad27", "wgs84"),
    longitude_dd = c(-110, -111),
    latitude_dd  = c(45, 46)
  )

  res <- coords2sf(x)

  expect_s3_class(res, "sf")
  expect_identical(res$datum, rep("WGS84", 2))
})

test_that("coords2sf defaults to WGS84 if datum column missing", {
  x <- data.frame(
    longitude_dd = c(-110, -111),
    latitude_dd  = c(45, 46)
  )

  res <- coords2sf(x)

  expect_s3_class(res, "sf")
  expect_identical(res$datum, rep("WGS84", 2))
})

test_that("coords2sf normalizes unrecognized datum values to WGS84", {
  x <- data.frame(
    datum = c("unknown", "garbage", "NAD83"),
    longitude_dd = c(-110, -111, -112),
    latitude_dd  = c(45, 46, 47)
  )

  res <- coords2sf(x)
  expect_identical(res$datum, rep("WGS84", 3))
})

test_that("coords2sf handles single-datum branch correctly", {
  x <- data.frame(
    datum = rep("NAD83", 3),
    longitude_dd = c(-110, -111, -112),
    latitude_dd  = c(45, 46, 47)
  )

  res <- coords2sf(x)
  expect_s3_class(res, "sf")
  expect_equal(sf::st_crs(res)$epsg, 4326)
  expect_identical(res$datum, rep("WGS84", 3))
})

test_that("coords2sf handles multi-datum branch correctly", {
  x <- data.frame(
    datum = c("NAD27", "NAD83", "WGS84"),
    longitude_dd = c(-110, -111, -112),
    latitude_dd  = c(45, 46, 47)
  )

  res <- coords2sf(x)
  expect_s3_class(res, "sf")
  expect_equal(sf::st_crs(res)$epsg, 4326)
  expect_identical(res$datum, rep("WGS84", 3))
})

test_that("coords2sf preserves original coordinate columns", {
  x <- data.frame(
    datum = c("WGS84", "WGS84"),
    longitude_dd = c(-110, -111),
    latitude_dd  = c(45, 46)
  )

  res <- coords2sf(x)

  expect_true("longitude_dd" %in% names(res))
  expect_true("latitude_dd" %in% names(res))
})

test_that("coords2sf always returns geometry column", {
  x <- data.frame(
    datum = c("WGS84", "WGS84"),
    longitude_dd = c(-110, -111),
    latitude_dd  = c(45, 46)
  )

  res <- coords2sf(x)

  expect_true("geometry" %in% names(res))
  expect_s3_class(res$geometry, "sfc")
})
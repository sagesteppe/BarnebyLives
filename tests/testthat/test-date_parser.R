library(testthat)
library(lubridate)
library(sf)
library(BarnebyLives)

test_that("date_parser handles collection date only", {
  x <- data.frame(
    collection_date = c("6-12-2023", "7-4-2023")
  )

  res <- date_parser(x, coll_date = "collection_date")

  # Check new columns exist
  expect_true(all(c(
    "collection_date",
    "collection_date_day",
    "collection_date_mo",
    "collection_date_yr",
    "collection_date_text"
  ) %in% names(res)))

  # Check text format
  expect_identical(res$collection_date_text, c("12 Jun, 2023", "4 Jul, 2023"))

  # Check numeric columns
  expect_equal(res$collection_date_day, c(12, 4))
  expect_equal(res$collection_date_mo, c(6, 7))
  expect_equal(res$collection_date_yr, c(2023, 2023))
})

test_that("date_parser handles collection and determination dates", {
  x <- data.frame(
    collection_date = c("6-12-2023", "7-4-2023"),
    determination_date = c("6-20-2023", "7-10-2023")
  )

  res <- date_parser(x, coll_date = "collection_date", det_date = "determination_date")

  # Columns for both collection and determination exist
  expect_true(all(c(
    "collection_date",
    "collection_date_day",
    "collection_date_mo",
    "collection_date_yr",
    "collection_date_text",
    "determination_date",
    "determination_date_day",
    "determination_date_mo",
    "determination_date_yr",
    "determination_date_text"
  ) %in% names(res)))

  # Check text format
  expect_identical(res$collection_date_text, c("12 Jun, 2023", "4 Jul, 2023"))
  expect_identical(res$determination_date_text, c("20 Jun, 2023", "10 Jul, 2023"))
})

test_that("date_parser works on single-row data frames", {
  x <- data.frame(collection_date = "6-12-2023")
  res <- date_parser(x, coll_date = "collection_date")

  expect_equal(nrow(res), 1)
  expect_identical(res$collection_date_text, "12 Jun, 2023")
})

test_that("date_parser handles empty data frames", {
  x <- data.frame(collection_date = character(0))
  res <- date_parser(x, coll_date = "collection_date")

  expect_equal(nrow(res), 0)
  expect_true(all(c(
    "collection_date",
    "collection_date_day",
    "collection_date_mo",
    "collection_date_yr",
    "collection_date_text"
  ) %in% names(res)))
})

test_that("date_parser works with sf objects", {
  x <- sf::st_as_sf(data.frame(
    collection_date = c("6-12-2023", "7-4-2023"),
    longitude = c(-110, -111),
    latitude = c(45, 46)
  ), coords = c("longitude", "latitude"), crs = 4326)

  res <- date_parser(x, coll_date = "collection_date")

  expect_s3_class(res, "sf")
  expect_true("geometry" %in% names(res))
  expect_identical(res$collection_date_text, c("12 Jun, 2023", "4 Jul, 2023"))
})


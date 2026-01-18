library(testthat)
library(lubridate)
library(BarnebyLives)

test_that("date2text converts single date correctly", {
  x <- "6-12-2023"
  res <- date2text(x)
  
  expect_type(res, "character")
  expect_length(res, 1)
  expect_identical(res, "12 Jun, 2023")
})

test_that("date2text converts multiple dates correctly", {
  x <- c("6-12-2023", "7-4-2023", "8-15-2023")
  res <- date2text(x)
  
  expect_type(res, "character")
  expect_length(res, 3)
  expect_identical(res, c("12 Jun, 2023", "4 Jul, 2023", "15 Aug, 2023"))
})

test_that("date2text preserves day, month abbreviation, and year", {
  x <- "12-25-2020"
  res <- date2text(x)
  
  expect_match(res, "^25 Dec, 2020$")
})


library(testthat)

test_that("format_degree appends degree symbol", {
  expect_equal(
    format_degree(180),
    "180\u00B0"
  )
})

test_that("format_degree is vectorized", {
  expect_equal(
    format_degree(c(0, 90, 180)),
    c("0\u00B0", "90\u00B0", "180\u00B0")
  )
})

test_that("format_degree returns UTF-8 encoded output", {
  out <- format_degree(45)

  expect_true(
    Encoding(out) %in% c("UTF-8", "unknown")
  )
})

test_that("format_degree respects custom symbol", {
  expect_equal(
    format_degree(10, symbol = "deg"),
    "10deg"
  )
})


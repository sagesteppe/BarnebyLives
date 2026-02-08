test_that("autofill_checker adds autofill flag columns", {
  coords <- data.frame(
    longitude_dd = c(42.3456, 42.3456, 42.3456),
    latitude_dd  = c(-116.7890, -116.7890, -116.7890)
  )

  res <- autofill_checker(coords)

  expect_true("Long_AutoFill_Flag" %in% names(res))
  expect_true("Lat_AutoFill_Flag" %in% names(res))
})

test_that("autofill_checker flags changes in integer (degree) values", {
  coords <- data.frame(
    longitude_dd = c(rep(42.3456, 5), 43.3456),
    latitude_dd  = c(rep(-116.7890, 5), -115.7890)
  )

  res <- autofill_checker(coords)

  expect_identical(
    res$Long_AutoFill_Flag,
    c(NA, NA, NA, NA, NA, "Flagged")
  )

  expect_identical(
    res$Lat_AutoFill_Flag,
    c(NA, NA, NA, NA, NA, "Flagged")
  )
})

test_that("autofill_checker does not flag repeated degree values", {
  coords <- data.frame(
    longitude_dd = c(42.3456, 42.9999, 42.1111),
    latitude_dd  = c(-116.7890, -116.1234, -116.0001)
  )

  res <- autofill_checker(coords)

  expect_true(all(is.na(res$Long_AutoFill_Flag)))
  expect_true(all(is.na(res$Lat_AutoFill_Flag)))
})

test_that("autofill_checker flags independently by longitude and latitude", {
  coords <- data.frame(
    longitude_dd = c(42.1111, 43.1111, 43.1111),
    latitude_dd  = c(-116.2222, -116.2222, -115.2222)
  )

  res <- autofill_checker(coords)

  expect_identical(
    res$Long_AutoFill_Flag,
    c(NA, "Flagged", NA)
  )

  expect_identical(
    res$Lat_AutoFill_Flag,
    c(NA, NA, "Flagged")
  )
})

test_that("autofill_checker preserves original data and appends flags at end", {
  coords <- data.frame(
    longitude_dd = 42.3456,
    latitude_dd  = -116.7890
  )

  res <- autofill_checker(coords)

  expect_identical(
    names(res),
    c(
      "longitude_dd",
      "latitude_dd",
      "Long_AutoFill_Flag",
      "Lat_AutoFill_Flag"
    )
  )
})


library(testthat)

test_that("notFound identifies rows with NOT FOUND", {
  df <- data.frame(
    query = c("Species A", "Species B", "Species C"),
    family = c("Fabaceae", "NOT FOUND", "Rosaceae"),
    genus = c("Acacia", "Unknown", "Rosa"),
    stringsAsFactors = FALSE
  )
  
  expect_message(
    notFound(df),
    "Species B"
  )
  
  expect_message(
    notFound(df),
    "row 2"
  )
})

test_that("notFound handles multiple NOT FOUND entries", {
  df <- data.frame(
    query = c("Species A", "Species B", "Species C"),
    family = c("NOT FOUND", "Poaceae", "NOT FOUND"),
    genus = c("Unknown", "Poa", "Unknown"),
    stringsAsFactors = FALSE
  )
  
  expect_message(
    notFound(df),
    "Species A"
  )
  
  expect_message(
    notFound(df),
    "Species C"
  )
})

test_that("notFound handles NOT FOUND in multiple columns", {
  df <- data.frame(
    query = c("Species A", "Species B"),
    family = c("Fabaceae", "NOT FOUND"),
    genus = c("NOT FOUND", "Acacia"),
    stringsAsFactors = FALSE
  )
  
  # Both rows should be mentioned since each has at least one NOT FOUND
  expect_message(
    notFound(df),
    "Species A"
  )
  
  expect_message(
    notFound(df),
    "Species B"
  )
})

test_that("notFound handles data with no NOT FOUND entries", {
  df <- data.frame(
    query = c("Species A", "Species B"),
    family = c("Fabaceae", "Rosaceae"),
    genus = c("Acacia", "Rosa"),
    stringsAsFactors = FALSE
  )
  
  # When there are no NOT FOUND entries, grep returns integer(0)
  # and the function will still produce a message but with empty content
  expect_message(notFound(df))
})

test_that("notFound works with single row dataframe", {
  df <- data.frame(
    query = "Species A",
    family = "NOT FOUND",
    genus = "Unknown",
    stringsAsFactors = FALSE
  )
  
  expect_message(
    notFound(df),
    "Species A"
  )
  
  expect_message(
    notFound(df),
    "row 1"
  )
})

test_that("notFound handles case sensitivity", {
  df <- data.frame(
    query = c("Species A", "Species B"),
    family = c("not found", "NOT FOUND"),
    genus = c("Acacia", "Unknown"),
    stringsAsFactors = FALSE
  )
  
  # Should only find "NOT FOUND" (uppercase), not "not found"
  expect_message(
    notFound(df),
    "Species B"
  )
  
  # Should not mention Species A
  result <- capture_messages(notFound(df))
  expect_false(any(grepl("Species A", result)))
})
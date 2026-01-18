library(testthat)
library(mockery)
library(BarnebyLives)

# Setup temporary directories
tmp_dir <- tempdir()
out_dir <- file.path(tempdir(), "out")
dir.create(out_dir, showWarnings = FALSE)

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

test_that("data_setup runs all steps successfully", {
  # Stub all steps to return TRUE
  for (s in steps) {
    stub(data_setup, s, function(...) TRUE)
  }

  # Capture all messages
  msgs <- capture_messages({
    data_setup(tmp_dir, out_dir, tmp_bound)
  })

  # The success message should be present
  expect_true(any(grepl("All steps succeeded", msgs)))
})

test_that("data_setup cleanup argument triggers deletion only on success", {
  # Create dummy zip files
  zip1 <- file.path(tmp_dir, "dummy1.zip")
  zip2 <- file.path(tmp_dir, "dummy2.zip")
  file.create(zip1)
  file.create(zip2)

  # Stub all steps to TRUE (success)
  for (s in steps) {
    stub(data_setup, s, function(...) TRUE)
  }

  # Run with cleanup = TRUE
  msgs <- capture_messages({
    data_setup(tmp_dir, out_dir, tmp_bound, cleanup = TRUE)
  })

  # Original zip files should now be deleted
  expect_false(file.exists(zip1))
  expect_false(file.exists(zip2))

  # Messages should mention cleanup
  expect_true(any(grepl("Original data downloads removed", msgs)))

  # Recreate zip files for failure scenario
  file.create(zip1)
  file.create(zip2)

  # Simulate failure in mason
  stub(data_setup, "mason", function(...) stop("mason failed"))

  msgs <- capture_messages({
    data_setup(tmp_dir, out_dir, tmp_bound, cleanup = TRUE)
  })

  # Zip files should still exist (cleanup skipped)
  expect_true(file.exists(zip1))
  expect_true(file.exists(zip2))

})

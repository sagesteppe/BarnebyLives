library(testthat)

test_that("format_database_import returns JEPS schema in correct order", {
  out <- format_database_import(collection_examples, format = "JEPS")

  # Template-derived expectations
  dbt <- database_templates[database_templates$Database == "JEPS", ]

  expect_equal(
    colnames(out),
    dbt$OutputField
  )
})

test_that("format_database_import engineers Vegetation_Associates", {
  x <- collection_examples[1, ]

  out <- format_database_import(x, format = "JEPS")

  expect_equal(
    out$Associated_Taxa,
    paste(x$Vegetation, x$Associates, sep = ", ")
  )
})

test_that("format_database_import fills default Coordinate_Uncertainty when required", {
  x <- collection_examples[1, ]

  out <- format_database_import(x, format = "JEPS")

  expect_true("Coordinate_Uncertainty_In_Meters" %in% colnames(out))
})

test_that("format_database_import fills Elevation_Units when required", {
  x <- collection_examples[1, ]

  out <- format_database_import(x, format = "JEPS")

  expect_equal(out$Elevation_Units, "m")
})

test_that("format_database_import works for Symbiota", {
  out <- format_database_import(collection_examples, format = "Symbiota")

  dbt <- database_templates[database_templates$Database == "Symbiota", ]

  expect_equal(colnames(out), dbt$OutputField)
  expect_equal(nrow(out), nrow(collection_examples))
})

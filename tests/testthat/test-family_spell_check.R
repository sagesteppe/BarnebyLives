library(testthat)
library(dplyr)
library(sf)
library(withr)

# Test file: test-family_spell_check.R

# Helper function to create mock family lookup table
create_mock_families_lookup <- function() {
  data.frame(
    Family = c(
      "Asteraceae",
      "Fabaceae",
      "Onagraceae",
      "Poaceae",
      "Rosaceae",
      "Lamiaceae",
      "Brassicaceae"
    ),
    stringsAsFactors = FALSE
  )
}

# Helper to create test data
create_family_test_data <- function() {
  data.frame(
    Collection_number = 1:5,
    Family = c('Asteraceae', 'Fabaceae', 'Onagraceae', 'Poaceae', 'Rosaceae'),
    stringsAsFactors = FALSE
  )
}

create_family_test_data_sf <- function() {
  df <- data.frame(
    Collection_number = 1:5,
    Family = c('Asteraceae', 'Fabaceae', 'Onagraceae', 'Poaceae', 'Rosaceae'),
    lon = c(-105.5, -106.2, -107.1, -108.0, -109.3),
    lat = c(40.5, 41.2, 42.1, 43.0, 44.3),
    stringsAsFactors = FALSE
  )
  
  sf::st_as_sf(df, coords = c("lon", "lat"), crs = 4326) %>%
    mutate(lon = c(-105.5, -106.2, -107.1, -108.0, -109.3),
           lat = c(40.5, 41.2, 42.1, 43.0, 44.3))
}

# Tests for exact matches
test_that("family_spell_check returns input unchanged when all families are correct", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- create_family_test_data()
  
  result <- family_spell_check(test_data, path = temp_path)
  
  expect_equal(nrow(result), nrow(test_data))
  expect_equal(result$Family, test_data$Family)
})

test_that("family_spell_check corrects single misspelled family", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- data.frame(
    Collection_number = 1,
    Family = "Asteracea"  # Missing 'e'
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  expect_equal(result$Family, "Asteraceae")
})

test_that("family_spell_check corrects multiple misspelled families", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- data.frame(
    Collection_number = 1:3,
    Family = c('Asteracea', 'Flabaceae', 'Onnagraceae')
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  expect_equal(result$Family[1], "Asteraceae")
  expect_equal(result$Family[2], "Fabaceae")
  expect_equal(result$Family[3], "Onagraceae")
})

test_that("family_spell_check handles mix of correct and incorrect families", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- data.frame(
    Collection_number = 1:5,
    Family = c(
      'Asteraceae',    # correct
      'Flabaceae',     # incorrect (Fabaceae)
      'Onagraceae',    # correct
      'Poacea',        # incorrect (Poaceae)
      'Rosaceae'       # correct
    )
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  expect_equal(result$Family[1], "Asteraceae")
  expect_equal(result$Family[2], "Fabaceae")
  expect_equal(result$Family[3], "Onagraceae")
  expect_equal(result$Family[4], "Poaceae")
  expect_equal(result$Family[5], "Rosaceae")
})

# Tests for NA handling
test_that("family_spell_check handles NA values", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- data.frame(
    Collection_number = 1:3,
    Family = c('Asteraceae', NA, 'Fabaceae')
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  expect_equal(nrow(result), 3)
  expect_true(is.na(result$Family[2]))
  expect_equal(result$Family[1], "Asteraceae")
  expect_equal(result$Family[3], "Fabaceae")
})

test_that("family_spell_check handles all NA values", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- data.frame(
    Collection_number = 1:3,
    Family = c(NA, NA, NA)
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  expect_equal(nrow(result), 3)
  expect_true(all(is.na(result$Family)))
})

# Tests for ordering preservation
test_that("family_spell_check preserves Collection_number order", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- data.frame(
    Collection_number = c(5, 3, 1, 4, 2),
    Family = c('Asteracea', 'Fabaceae', 'Onnagraceae', 'Poaceae', 'Rosaceae')
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  # Should be sorted by Collection_number
  expect_equal(result$Collection_number, 1:5)
  expect_equal(result$Family[result$Collection_number == 1], "Onagraceae")
  expect_equal(result$Family[result$Collection_number == 5], "Asteraceae")
})

# Tests for sf object handling
test_that("family_spell_check works with sf objects", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data_sf <- create_family_test_data_sf()
  
  result <- family_spell_check(test_data_sf, path = temp_path)
  
  expect_s3_class(result, "sf")
  expect_true("geometry" %in% names(result))
  expect_equal(nrow(result), nrow(test_data_sf))
})

test_that("family_spell_check preserves geometry with corrections", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  df <- data.frame(
    Collection_number = 1:3,
    Family = c('Asteracea', 'Flabaceae', 'Onnagraceae'),
    lon = c(-105.5, -106.2, -107.1),
    lat = c(40.5, 41.2, 42.1)
  )
  
  test_data_sf <- sf::st_as_sf(df, coords = c("lon", "lat"), crs = 4326) %>%
    mutate(lon = c(-105.5, -106.2, -107.1),
           lat = c(40.5, 41.2, 42.1))
  
  result <- family_spell_check(test_data_sf, path = temp_path)
  
  expect_s3_class(result, "sf")
  expect_equal(result$Family[1], "Asteraceae")
  expect_equal(result$Family[2], "Fabaceae")
  expect_equal(result$Family[3], "Onagraceae")
})

# Tests for data structure preservation
test_that("family_spell_check preserves additional columns", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- data.frame(
    Collection_number = 1:3,
    Family = c('Asteracea', 'Fabaceae', 'Onnagraceae'),
    Genus = c('Helianthus', 'Trifolium', 'Oenothera'),
    Collector = c('Smith', 'Jones', 'Brown')
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  expect_true("Genus" %in% names(result))
  expect_true("Collector" %in% names(result))
  expect_equal(result$Genus, test_data$Genus)
  expect_equal(result$Collector, test_data$Collector)
})

test_that("family_spell_check removes SPELLING column", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- data.frame(
    Collection_number = 1:3,
    Family = c('Asteracea', 'Fabaceae', 'Onagraceae')
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  # Should not have SPELLING column in output
  expect_false("SPELLING" %in% names(result))
})

# Tests for edge cases
test_that("family_spell_check handles single row", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- data.frame(
    Collection_number = 1,
    Family = 'Asteracea'
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  expect_equal(nrow(result), 1)
  expect_equal(result$Family, "Asteraceae")
})

test_that("family_spell_check handles empty data frame", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  test_data <- data.frame(
    Collection_number = integer(0),
    Family = character(0)
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  expect_equal(nrow(result), 0)
})

# Tests for string distance correction
test_that("family_spell_check uses adist for closest match", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  # Very misspelled - should still find closest
  test_data <- data.frame(
    Collection_number = 1:2,
    Family = c('Astrraceae', 'Fbaceae')  # Heavy misspellings
  )
  
  result <- family_spell_check(test_data, path = temp_path)
  
  # Should find closest matches
  expect_true(result$Family[1] %in% create_mock_families_lookup()$Family)
  expect_true(result$Family[2] %in% create_mock_families_lookup()$Family)
})

# Tests for file I/O
test_that("family_spell_check reads CSV from correct path", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  # Verify file exists
  expect_true(file.exists(file.path(temp_path, "families_lookup_table.csv")))
  
  test_data <- data.frame(
    Collection_number = 1,
    Family = "Asteraceae"
  )
  
  # Should not error
  expect_error(family_spell_check(test_data, path = temp_path), NA)
})

test_that("family_spell_check warns with invalid path", {
  test_data <- data.frame(
    Collection_number = 1,
    Family = "Asteraceae"
  )
  
  expect_warning(
    family_spell_check(test_data, path = "/nonexistent/path")
  )
})

# Integration test with documentation example
test_that("family_spell_check works with documentation example", {
  temp_path <- withr::local_tempdir()
  
  write.csv(
    create_mock_families_lookup(),
    file.path(temp_path, "families_lookup_table.csv"),
    row.names = FALSE
  )
  
  names <- data.frame(
    Collection_number = 1:3,
    Family = c('Asteracea', 'Flabaceae', 'Onnagraceae')
  )
  
  spelling <- family_spell_check(names, path = temp_path)
  
  expect_equal(nrow(spelling), 3)
  expect_equal(spelling$Family[1], "Asteraceae")
  expect_equal(spelling$Family[2], "Fabaceae")
  expect_equal(spelling$Family[3], "Onagraceae")
  expect_equal(spelling$Collection_number, 1:3)
})

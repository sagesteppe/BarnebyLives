library(testthat)
library(dplyr)
library(mockery)

# Mock helper functions that powo_searcher depends on
mock_try_again <- function(query_results) {
  # Returns NULL results (simulating a failed retry)
  list(results = NULL)
}

mock_try_again_success <- function(query_results) {
  # Returns successful results on retry
  list(
    results = list(
      list(
        family = "Caprifoliaceae",
        name = "Linnaea borealis var. borealis",
        authors = "L.",
        genus = "Linnaea",
        species = "borealis",
        infraspecies = "borealis",
        rank = "var."
      )
    )
  )
}

mock_result_grabber <- function(results) {
  # Extract taxonomic info from results
  if (length(results$results) == 0) {
    return(data.frame(
      family = "NOT FOUND",
      name_authority = "NOT FOUND",
      full_name = "NOT FOUND",
      binom_authority = "NOT FOUND",
      genus = "NOT FOUND",
      epithet = "NOT FOUND",
      infrarank = "NOT FOUND",
      infraspecies = "NOT FOUND",
      infra_authority = "NOT FOUND"
    ))
  }
  
  result <- results$results[[1]]
  
  data.frame(
    family = result$family %||% NA_character_,
    name_authority = result$authors %||% NA_character_,
    full_name = result$name %||% NA_character_,
    binom_authority = result$authors %||% NA_character_,
    genus = result$genus %||% NA_character_,
    epithet = result$species %||% NA_character_,
    infrarank = result$rank %||% NA_character_,
    infraspecies = result$infraspecies %||% NA_character_,
    infra_authority = result$authors %||% NA_character_
  )
}

# Mock successful POWO API response
mock_powo_success <- function(x) {
  list(
    results = list(
      list(
        family = "Fabaceae",
        name = "Astragalus purshii",
        authors = "Douglas ex Hook.",
        genus = "Astragalus",
        species = "purshii",
        infraspecies = NA,
        rank = NA
      )
    )
  )
}

# Mock failed POWO API response (no results)
mock_powo_no_results <- function(x) {
  list(results = NULL)
}

# Mock POWO response for infraspecies
mock_powo_infraspecies <- function(x) {
  list(
    results = list(
      list(
        family = "Caprifoliaceae",
        name = "Linnaea borealis var. borealis",
        authors = "L.",
        genus = "Linnaea",
        species = "borealis",
        infraspecies = "borealis",
        rank = "var."
      )
    )
  )
}

# Tests for successful queries
test_that("powo_searcher handles successful species query", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  result <- powo_searcher("Astragalus purshii")
  
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 1)
  expect_true("POW_Query" %in% names(result))
  expect_equal(result$POW_Query, "Astragalus purshii")
})

test_that("powo_searcher handles infraspecies query", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_infraspecies)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  result <- powo_searcher("Linnaea borealis var. borealis")
  
  expect_true(is.data.frame(result))
  expect_equal(result$POW_Query, "Linnaea borealis var. borealis")
})

# Tests for whitespace normalization
test_that("powo_searcher normalizes multiple spaces", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  # Input with multiple spaces
  result <- powo_searcher("Astragalus    purshii")
  
  expect_equal(result$POW_Query, "Astragalus purshii")
})

test_that("powo_searcher trims leading and trailing whitespace", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  result <- powo_searcher("  Astragalus purshii  ")
  
  expect_equal(result$POW_Query, "Astragalus purshii")
})

# Tests for failed queries
test_that("powo_searcher handles species not found", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_no_results)
  mockery::stub(powo_searcher, 'try_again', mock_try_again)
  
  result <- powo_searcher("Nonexistent species")
  
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 1)
  expect_true(all(result[1, -1] == "NOT FOUND"))
  expect_equal(result$POW_Query, "Nonexistent species")
})

test_that("powo_searcher retries failed queries", {
  # First call returns NULL, try_again also returns NULL
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_no_results)
  mockery::stub(powo_searcher, 'try_again', mock_try_again)
  
  result <- powo_searcher("Failed query")
  
  # Should return NOT FOUND for all fields
  expect_equal(result$POW_Family, "NOT FOUND")
  expect_equal(result$POW_Name_authority, "NOT FOUND")
})

test_that("powo_searcher succeeds on retry", {
  # First call fails, but try_again succeeds
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_no_results)
  mockery::stub(powo_searcher, 'try_again', mock_try_again_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  result <- powo_searcher("Linnaea borealis var. borealis")
  
  expect_true(is.data.frame(result))
  expect_equal(result$POW_Query, "Linnaea borealis var. borealis")
})

# Tests for column naming
test_that("powo_searcher prefixes columns with POW_", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  result <- powo_searcher("Astragalus purshii")
  
  # All columns should start with POW_
  expect_true(all(grepl("^POW_", names(result))))
})

test_that("powo_searcher uses sentence case for column names", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  result <- powo_searcher("Astragalus purshii")
  
  # Check specific expected columns
  expected_cols <- c(
    "POW_Query",
    "POW_Family",
    "POW_Name_authority",
    "POW_Full_name",
    "POW_Binom_authority",
    "POW_Genus",
    "POW_Epithet",
    "POW_Infrarank",
    "POW_Infraspecies",
    "POW_Infra_authority"
  )
  
  expect_true(all(expected_cols %in% names(result)))
})

# Tests for output structure
test_that("powo_searcher returns data frame with correct structure", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  result <- powo_searcher("Astragalus purshii")
  
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 1)
  expect_true(ncol(result) >= 2)  # At least query + one result column
})

test_that("powo_searcher includes query in output", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  query <- "Astragalus purshii"
  result <- powo_searcher(query)
  
  expect_true("POW_Query" %in% names(result))
  expect_equal(result$POW_Query, query)
})

# Tests for NOT FOUND structure
test_that("powo_searcher returns correct NOT FOUND structure", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_no_results)
  mockery::stub(powo_searcher, 'try_again', mock_try_again)
  
  result <- powo_searcher("Unknown species")
  
  # All taxonomic fields should be NOT FOUND
  expect_equal(result$POW_Family, "NOT FOUND")
  expect_equal(result$POW_Genus, "NOT FOUND")
  expect_equal(result$POW_Epithet, "NOT FOUND")
  
  # Query should be preserved
  expect_equal(result$POW_Query, "Unknown species")
})

# Integration test with multiple species
test_that("powo_searcher works with lapply and bind_rows", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  species_list <- c(
    'Linnaea borealis var. borealis',
    'Astragalus purshii',
    'Pinus ponderosa'
  )
  
  # Simulate the documentation example
  pow_results <- lapply(species_list, powo_searcher) |>
    dplyr::bind_rows()
  
  expect_equal(nrow(pow_results), 3)
  expect_true(all(grepl("^POW_", names(pow_results))))
})

# Tests for edge cases
test_that("powo_searcher handles empty string", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_no_results)
  mockery::stub(powo_searcher, 'try_again', mock_try_again)
  
  result <- powo_searcher("")
  
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 1)
})

test_that("powo_searcher handles very long species names", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  long_name <- "Astragalus purshii var. purshii subsp. purshii forma purshii"
  result <- powo_searcher(long_name)
  
  expect_true(is.data.frame(result))
  expect_equal(result$POW_Query, long_name)
})

test_that("powo_searcher handles special characters in names", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  # Some botanical names have special characters
  result <- powo_searcher("Astragalus ×purshii")
  
  expect_true(is.data.frame(result))
  expect_equal(result$POW_Query, "Astragalus ×purshii")
})

# Test that the function preserves the input query exactly (after normalization)
test_that("powo_searcher preserves normalized query in output", {
  mockery::stub(powo_searcher, 'kewr::search_powo', mock_powo_success)
  mockery::stub(powo_searcher, 'result_grabber', mock_result_grabber)
  
  queries <- c(
    "Astragalus purshii",
    "  Pinus   ponderosa  ",
    "Linnaea borealis"
  )
  
  for (query in queries) {
    result <- powo_searcher(query)
    normalized <- trimws(gsub("\\s+", " ", query))
    expect_equal(result$POW_Query, normalized)
  }
})

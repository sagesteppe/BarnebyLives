library(testthat)

test_that("result_grabber extracts basic species information", {
  skip_if_not_installed("stringr")
  
  # Mock POWO search result for a species without infraspecific rank
  mock_result <- list(
    results = list(
      list(
        accepted = TRUE,
        family = "Fabaceae",
        author = "L.",
        name = "Acacia dealbata"
      )
    )
  )
  
  result <- result_grabber(mock_result)
  
  expect_equal(result$family, "Fabaceae")
  expect_equal(result$genus, "Acacia")
  expect_equal(result$epithet, "dealbata")
  expect_true(is.na(result$infrarank))
  expect_true(is.na(result$infraspecies))
})

test_that("result_grabber handles variety correctly", {
  skip_if_not_installed("stringr")
  
  # Mock POWO search result for a variety
  mock_result <- list(
    results = list(
      list(
        accepted = TRUE,
        family = "Orobanchaceae",
        author = "(S. Watson) Rydb.",
        name = "Castilleja pilosa var. pilosa"
      )
    )
  )
  
  # Mock all_authors function
  testthat::local_mocked_bindings(
    all_authors = function(genus, epithet, infrarank, infraspecies) {
      list(
        "Castilleja pilosa var. pilosa (S. Watson) Rydb.",
        "Castilleja pilosa (S. Watson)",
        "var. pilosa Rydb."
      )
    },
    .package = "BarnebyLives"
  )
  
  result <- result_grabber(mock_result)
  
  expect_equal(result$family, "Orobanchaceae")
  expect_equal(result$genus, "Castilleja")
  expect_equal(result$epithet, "pilosa")
  expect_equal(result$infrarank, "var.")
  expect_equal(result$infraspecies, "pilosa")
  expect_false(is.na(result$infra_authority))
})

test_that("result_grabber handles subspecies correctly", {
  skip_if_not_installed("stringr")
  
  # Mock POWO search result for a subspecies
  mock_result <- list(
    results = list(
      list(
        accepted = TRUE,
        family = "Pinaceae",
        author = "Lemmon & Lemmon",
        name = "Pinus ponderosa subsp. scopulorum"
      )
    )
  )
  
  # Mock all_authors function
  testthat::local_mocked_bindings(
    all_authors = function(genus, epithet, infrarank, infraspecies) {
      list(
        "Pinus ponderosa subsp. scopulorum Lemmon & Lemmon",
        "Pinus ponderosa Laws.",
        "subsp. scopulorum Lemmon & Lemmon"
      )
    },
    .package = "BarnebyLives"
  )
  
  result <- result_grabber(mock_result)
  
  expect_equal(result$genus, "Pinus")
  expect_equal(result$epithet, "ponderosa")
  expect_equal(result$infrarank, "subsp.")
  expect_equal(result$infraspecies, "scopulorum")
})

test_that("result_grabber selects accepted name from multiple results", {
  skip_if_not_installed("stringr")
  
  # Mock POWO search with synonym and accepted name
  mock_result <- list(
    results = list(
      list(
        accepted = FALSE,
        family = "Fabaceae",
        author = "Old Author",
        name = "Old name synonym"
      ),
      list(
        accepted = TRUE,
        family = "Fabaceae",
        author = "L.",
        name = "Acacia dealbata"
      )
    )
  )
  
  result <- result_grabber(mock_result)
  
  # Should use the accepted name, not the synonym
  expect_equal(result$genus, "Acacia")
  expect_equal(result$epithet, "dealbata")
  expect_equal(result$binom_authority, "L.")
})

test_that("result_grabber creates name_authority for species without infrarank", {
  skip_if_not_installed("stringr")
  
  mock_result <- list(
    results = list(
      list(
        accepted = TRUE,
        family = "Asteraceae",
        author = "A. Gray",
        name = "Dimeresia howellii"
      )
    )
  )
  
  result <- result_grabber(mock_result)
  
  # name_authority should be full_name + author
  expect_equal(result$name_authority, "Dimeresia howellii A. Gray")
  expect_true(is.na(result$infra_authority))
})

test_that("result_grabber extracts infrarank correctly", {
  skip_if_not_installed("stringr")
  
  # Test var.
  mock_var <- list(
    results = list(
      list(
        accepted = TRUE,
        family = "Test",
        author = "Auth.",
        name = "Genus species var. infraspecies"
      )
    )
  )
  
  testthat::local_mocked_bindings(
    all_authors = function(...) list("name", "binom", "infra"),
    .package = "BarnebyLives"
  )
  
  result <- result_grabber(mock_var)
  expect_equal(result$infrarank, "var.")
  
  # Test subsp.
  mock_subsp <- list(
    results = list(
      list(
        accepted = TRUE,
        family = "Test",
        author = "Auth.",
        name = "Genus species subsp. infraspecies"
      )
    )
  )
  
  result <- result_grabber(mock_subsp)
  expect_equal(result$infrarank, "subsp.")
})

test_that("result_grabber handles full_name correctly", {
  skip_if_not_installed("stringr")
  
  mock_result <- list(
    results = list(
      list(
        accepted = TRUE,
        family = "Rosaceae",
        author = "L.",
        name = "Rosa canina"
      )
    )
  )
  
  result <- result_grabber(mock_result)
  
  expect_equal(result$full_name, "Rosa canina")
})

test_that("result_grabber returns data frame with correct columns", {
  skip_if_not_installed("stringr")
  
  mock_result <- list(
    results = list(
      list(
        accepted = TRUE,
        family = "Fabaceae",
        author = "L.",
        name = "Acacia dealbata"
      )
    )
  )
  
  result <- result_grabber(mock_result)
  
  expected_cols <- c("family", "name_authority", "full_name", "binom_authority",
                     "genus", "epithet", "infrarank", "infraspecies", "infra_authority")
  
  expect_true(all(expected_cols %in% names(result)))
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
})

test_that("result_grabber handles spp. rank", {
  skip_if_not_installed("stringr")
  
  mock_result <- list(
    results = list(
      list(
        accepted = TRUE,
        family = "Poaceae",
        author = "Auth.",
        name = "Carex spp. multiple"
      )
    )
  )
  
  testthat::local_mocked_bindings(
    all_authors = function(...) list("name", "binom", "infra"),
    .package = "BarnebyLives"
  )
  
  result <- result_grabber(mock_result)
  
  expect_equal(result$infrarank, "spp.")
})

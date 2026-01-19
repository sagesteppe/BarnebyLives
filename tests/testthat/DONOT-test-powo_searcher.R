library(testthat)
library(mockery)

test_that("powo_searcher returns processed results when POWO responds", {

  mock_search <- function(x) {
    list(results = "something")
  }

  mock_grabber <- function(res) {
    data.frame(
      family = "Caprifoliaceae",
      name_authority = "L.",
      full_name = "Linnaea borealis",
      binom_authority = "L.",
      genus = "Linnaea",
      epithet = "borealis",
      infrarank = NA,
      infraspecies = NA,
      infra_authority = NA,
      stringsAsFactors = FALSE
    )
  }

  stub(powo_searcher, "kewr::search_powo", mock_search)
  stub(powo_searcher, "result_grabber", mock_grabber)

  res <- powo_searcher("  Linnaea   borealis ")

  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1)
  expect_true(all(startsWith(colnames(res), "POW_")))
  expect_equal(res$POW_Query, "Linnaea borealis")
  expect_equal(res$POW_Genus, "Linnaea")
})

test_that("powo_searcher retries when initial query fails", {

  mock_search <- function(x) {
    list(results = NULL)
  }

  mock_try_again <- function(res) {
    list(results = "second_success")
  }

  mock_grabber <- function(res) {
    data.frame(
      family = "Pinaceae",
      name_authority = "Douglas ex C.Lawson",
      full_name = "Pinus ponderosa",
      binom_authority = "Douglas ex C.Lawson",
      genus = "Pinus",
      epithet = "ponderosa",
      infrarank = NA,
      infraspecies = NA,
      infra_authority = NA,
      stringsAsFactors = FALSE
    )
  }

  stub(powo_searcher, "kewr::search_powo", mock_search)
  stub(powo_searcher, "try_again", mock_try_again)
  stub(powo_searcher, "result_grabber", mock_grabber)

  res <- powo_searcher("Pinus ponderosa")

  expect_equal(res$POW_Genus, "Pinus")
  expect_equal(res$POW_Family, "Pinaceae")
})

test_that("powo_searcher returns NOT FOUND when POWO fails twice", {

  mock_search <- function(x) {
    list(results = NULL)
  }

  mock_try_again <- function(res) {
    list(results = NULL)
  }

  stub(powo_searcher, "kewr::search_powo", mock_search)
  stub(powo_searcher, "try_again", mock_try_again)

  res <- powo_searcher("Definitely not a plant")

  expect_equal(nrow(res), 1)
  expect_true(all(res[1, -1] == "NOT FOUND"))
})

test_that("spell_check finds exact species match", {

  tmp <- tempdir()
  make_spellcheck_tables(tmp)

  df <- data.frame(
    Full_name = "Helianthus annuus",
    stringsAsFactors = FALSE
  )

  res <- spell_check(df, column = "Full_name", path = tmp)

  expect_equal(res$Match, "exact")
  expect_equal(res$SpellCk.taxon_name, "Helianthus annuus")
})

test_that("spell_check finds fuzzy species match", {

  tmp <- tempdir()
  make_spellcheck_tables(tmp)

  df <- data.frame(
    Full_name = "Astagalus purshii",  # misspelled
    stringsAsFactors = FALSE
  )

  res <- spell_check(df, column = "Full_name", path = tmp)

  expect_equal(res$Match, "fuzzy")
  expect_equal(res$SpellCk.taxon_name, "Astragalus purshii")
})

test_that("spell_check resolves infraspecies exact match", {

  tmp <- tempdir()
  make_spellcheck_tables(tmp)

  df <- data.frame(
    Full_name = "Linnaea borealis ssp. borealis",
    stringsAsFactors = FALSE
  )

  res <- spell_check(df, column = "Full_name", path = tmp)

  expect_equal(res$Match, "exact")
  expect_equal(
    res$SpellCk.taxon_name,
    "Linnaea borealis subsp. borealis"
  )
})

test_that("spell_check preserves sf geometry", {

  tmp <- tempdir()
  make_spellcheck_tables(tmp)

  sf_df <- sf::st_as_sf(
    data.frame(
      Full_name = "Helianthus annuus",
      lon = 0,
      lat = 0
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )

  res <- spell_check(sf_df, column = "Full_name", path = tmp)

  expect_s3_class(res, "sf")
  expect_true("geometry" %in% colnames(res))
})

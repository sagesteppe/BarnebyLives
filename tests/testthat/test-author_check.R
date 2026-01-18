# tests/testthat/test-author_check.R

library(testthat)
library(dplyr)
library(sf)

test_that("author_check flags incorrect abbreviations", {
  
  # create a small mock abbreviation CSV for testing
  temp_dir <- tempdir()
  abbrevs <- data.frame(x = c("L.", "J.M. Coult.", "S.R. Downie", "A. Gray"))
  write.csv(abbrevs, file.path(temp_dir, "ipni_author_abbreviations.csv"), row.names = FALSE)
  
  # example data frame
  df <- data.frame(
    Genus = c('Lomatium', 'Linnaea', 'Angelica'),
    Epithet = c('dissectum', 'borealis', 'capitellata'),
    Binomial_authority = c('(Pursh) J.M. Coult & Rose', 'L.', '(A. Gray) Spalik, Reduron & S.R.Downie'),
    Infrarank = c(NA, 'var.', NA),
    Infraspecies = c(NA, 'americana', NA),
    Infraspecific_authority = c(NA, '(J. Forbes) Rehder', NA)
  )

  res <- author_check(df, path = temp_dir)

  # expect column names
  expect_true(all(c("Binomial_authority_issues", "Infra_auth_issues") %in% colnames(res)))

  # Pursh and Rose are not in abbrevs -> should be flagged
  expect_match(res$Binomial_authority_issues[1], "Pursh")
  expect_match(res$Binomial_authority_issues[1], "Rose")

  # L. is correct -> no issues
  expect_true(is.na(res$Binomial_authority_issues[2]))

  # Check spacing issue flagged
  expect_match(res$Binomial_authority_issues[3], "S.R.Downie")
})

test_that("author_check handles NA correctly", {

  temp_dir <- tempdir()
  write.csv(data.frame(x = c("L.")), file.path(temp_dir, "ipni_author_abbreviations.csv"), row.names = FALSE)

  df <- data.frame(
    Genus = "Mentzelia",
    Epithet = "albicaulis",
    Binomial_authority = NA,
    Infrarank = NA,
    Infraspecies = NA,
    Infraspecific_authority = NA
  )

  res <- author_check(df, path = temp_dir)

  # expect NA issues if authority is NA
  expect_true(is.na(res$Binomial_authority_issues))
  expect_true(is.na(res$Infra_auth_issues))
})

test_that("author_check works with sf objects", {
  temp_dir <- tempdir()
  write.csv(data.frame(x = c("L.")), file.path(temp_dir, "ipni_author_abbreviations.csv"), row.names = FALSE)

  # create simple sf object
  sf_df <- sf::st_as_sf(
    data.frame(
      Genus = "Linnaea",
      Epithet = "borealis",
      Binomial_authority = "L.",
      Infraspecific_authority = NA,  
      geometry = sf::st_sfc(sf::st_point(c(0,0)))
    )
  )

  res <- author_check(sf_df, path = temp_dir)

  # column still exists
  expect_true("Binomial_authority_issues" %in% colnames(res))
  # no issues
  expect_true(is.na(res$Binomial_authority_issues))
})

test_that("author_check returns data frame with same number of rows", {
  temp_dir <- tempdir()
  write.csv(data.frame(x = c("L.")), file.path(temp_dir, "ipni_author_abbreviations.csv"), row.names = FALSE)

  df <- data.frame(
    Genus = c("A", "B"),
    Epithet = c("a", "b"),
    Binomial_authority = c("L.", "X."),
    Infrarank = NA,
    Infraspecies = NA,
    Infraspecific_authority = NA
  )

  res <- author_check(df, path = temp_dir)
  expect_equal(nrow(res), nrow(df))
})


library(testthat)
library(mockery)

test_that("all_authors returns correct values for autonyms and infra-species", {

  # -----------------------
  # 1. Setup fake KEW API responses
  # -----------------------
  # Autonym response
  fake_autonym <- list(
    results = list(
      list(accepted = TRUE, author = "AuthorA"),
      list(accepted = FALSE, author = "Wrong")
    )
  )

  # Infra-species response (binomial)
  fake_binom <- list(
    results = list(
      list(accepted = TRUE, author = "BinomAuthor"),
      list(accepted = FALSE, author = "Wrong")
    )
  )

  # Infra-species response (full infra)
  fake_infra <- list(
    results = list(
      list(accepted = TRUE, author = "InfraAuthor"),
      list(accepted = FALSE, author = "Wrong")
    )
  )

  # -----------------------
  # 2. Create mocks
  # -----------------------
  mock_search <- mock(
    fake_autonym,        # for autonym branch
    fake_binom,          # binomial part of infra-species branch
    fake_infra,          # infra-species part
    cycle = TRUE
  )

  stub(all_authors, "kewr::search_powo", mock_search)

  # -----------------------
  # 3. Test autonym branch
  # -----------------------
  res_auto <- all_authors(
    genus = "Quercus",
    epithet = "robur",
    infrarank = "subsp.",
    infraspecies = "robur" # same as epithet -> autonym
  )

  expect_equal(res_auto[[2]], "AuthorA")          # binomial author
  expect_true(is.na(res_auto[[3]]))              # infra_authority should be NA
  expect_match(res_auto[[1]], "Quercus robur AuthorA subsp. robur")

  # -----------------------
  # 4. Test infra-species branch
  # -----------------------
  res_infra <- all_authors(
    genus = "Quercus",
    epithet = "robur",
    infrarank = "subsp.",
    infraspecies = "pedunculata" # different -> infra-species
  )

  expect_equal(res_infra[[2]], "BinomAuthor")    # binomial author
  expect_equal(res_infra[[3]], "InfraAuthor")    # infra author
  expect_match(
    res_infra[[1]],
    "Quercus robur BinomAuthor subsp. pedunculata InfraAuthor"
  )

  # -----------------------
  # 5. Ensure kewr::search_powo was called correct number of times
  # -----------------------
  expect_called(mock_search, 3)
})


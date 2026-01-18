library(testthat)
library(mockery)
library(dplyr)
library(stringr)

test_that("associates_spell_check handles genus, species, infra and uncertainty", {

  tmp_dir <- tempdir()

  # -----------------------
  # 1. Fake input dataframe with all cases
  # -----------------------
  df <- data.frame(
    Vegetation = c(
      "Cypers sp., Persicara spp., Eupatorium occidentalis, Pinus ponderosa var. scopulorum"
    ),
    stringsAsFactors = FALSE
  )

  # -----------------------
  # 2. Fake species lookup tables
  # -----------------------
  sppLKPtab <- data.frame(
    genus = c("Cypers", "Persicara", "Eupatorium", "Pinus"),
    taxon_name = c("Cypers sp.", "Persicara spp.", "Eupatorium occidentalis", "Pinus ponderosa"),
    gGRP = c("Cy", "Pe", "Eu", "Pi"),
    stringsAsFactors = FALSE
  )

  infra_sppLKPtab <- data.frame(
    genus = "Pinus",
    taxon_name = "Pinus ponderosa var. scopulorum",
    gGRP = "Pi",
    stringsAsFactors = FALSE
  )

  # -----------------------
  # 3. Mock read.csv
  # -----------------------
  mock_read <- mock(sppLKPtab, infra_sppLKPtab, cycle = TRUE)
  stub(associates_spell_check, "read.csv", mock_read)

  # -----------------------
  # 4. Run function
  # -----------------------
  out <- associates_spell_check(df, column = "Vegetation", path = tmp_dir)

  # -----------------------
  # 5. Expectations
  # -----------------------
  expect_true("SpellCk.Vegetation" %in% colnames(out))
  expect_called(mock_read, 2)  # spp + infra tables

  # Check genus-only (Cypers sp.) -> keeps uncertainty
  expect_match(out$SpellCk.Vegetation[1], "Cypers sp\\.")

  # Check genus with spp. -> uncertainty preserved
  expect_match(out$SpellCk.Vegetation[1], "Persicara spp\\.")

  # Check species search (2-word)
  expect_match(out$SpellCk.Vegetation[1], "Eupatorium occidentalis")

  # Check infra species search (4-word)
  expect_match(out$SpellCk.Vegetation[1], "Pinus ponderosa var. scopulorum")
})

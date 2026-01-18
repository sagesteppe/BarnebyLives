library(testthat)

test_that("split_scientificName parses basic binomial with multiple rows", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c("Castilleja miniata", "Penstemon strictus")
  )
  
  result <- split_scientificName(df, sciName_col = "Binomial")
  
  expect_equal(result$Genus[1], "Castilleja")
  expect_equal(result$Epithet[1], "miniata")
  expect_equal(result$Binomial[1], "Castilleja miniata")
  expect_equal(result$Genus[2], "Penstemon")
  expect_equal(result$Epithet[2], "strictus")
})

test_that("split_scientificName parses binomial with authority", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c(
      "Castilleja miniata Douglas ex Hook.",
      "Penstemon strictus Benth."
    )
  )
  
  result <- split_scientificName(df, sciName_col = "Binomial")
  
  expect_equal(result$Genus[1], "Castilleja")
  expect_equal(result$Epithet[1], "miniata")
  expect_match(result$Name_authority[1], "Douglas")
})

test_that("split_scientificName parses variety", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c(
      "Castilleja pilosa var. pilosa",
      "Penstemon strictus"
    )
  )
  
  result <- split_scientificName(df, sciName_col = "Binomial")
  
  expect_equal(result$Genus[1], "Castilleja")
  expect_equal(result$Epithet[1], "pilosa")
  expect_equal(result$Infraspecific_rank[1], "var.")
  expect_equal(result$Infraspecies[1], "pilosa")
})

test_that("split_scientificName parses variety with authority", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c(
      "Castilleja pilosa var. steenburghii (Standl.) N.H. Holmgren",
      "Penstemon strictus"
    )
  )
  
  result <- split_scientificName(df, sciName_col = "Binomial")
  
  expect_equal(result$Genus[1], "Castilleja")
  expect_equal(result$Epithet[1], "pilosa")
  expect_equal(result$Infraspecific_rank[1], "var.")
  expect_equal(result$Infraspecies[1], "steenburghii")
  expect_match(as.character(result$Infraspecific_authority[1]), "Holmgren")
})

test_that("split_scientificName parses subspecies", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c(
      "Pinus ponderosa subsp. scopulorum",
      "Penstemon strictus"
    )
  )
  
  result <- split_scientificName(df, sciName_col = "Binomial")
  
  expect_equal(result$Genus[1], "Pinus")
  expect_equal(result$Epithet[1], "ponderosa")
  expect_equal(result$Infraspecific_rank[1], "subsp.")
  expect_equal(result$Infraspecies[1], "scopulorum")
})

test_that("split_scientificName handles ssp. abbreviation", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c(
      "Pinus ponderosa ssp. scopulorum",
      "Penstemon strictus"
    )
  )
  
  result <- split_scientificName(df, sciName_col = "Binomial")
  
  expect_equal(result$Infraspecific_rank[1], "ssp.")
  expect_equal(result$Infraspecies[1], "scopulorum")
})

test_that("split_scientificName auto-detects binomial column", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c("Castilleja miniata", "Penstemon strictus")
  )
  
  expect_output(
    result <- split_scientificName(df),
    "using: Binomial"
  )
  
  expect_equal(result$Genus[1], "Castilleja")
})

test_that("split_scientificName handles multiple binomial columns", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c("Castilleja miniata", "Penstemon strictus"),
    Binomial_authority = c("Douglas ex Hook.", "Benth.")
  )
  
  # Should find Binomial, not Binomial_authority
  expect_output(
    result <- split_scientificName(df),
    "using: Binomial"
  )
})

test_that("split_scientificName errors when no binomial column found", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    ScientificName = c("Castilleja miniata", "Penstemon strictus")
  )
  
  expect_error(
    split_scientificName(df),
    "unable to find name column"
  )
})

test_that("split_scientificName cleans up double spaces", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c("Castilleja  miniata", "Penstemon  strictus")
  )
  
  result <- split_scientificName(df, sciName_col = "Binomial")
  
  expect_equal(result$Binomial[1], "Castilleja miniata")
  expect_false(grepl("  ", result$Binomial[1]))
})

test_that("split_scientificName trims whitespace", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c("  Castilleja miniata  ", "  Penstemon strictus  ")
  )
  
  result <- split_scientificName(df, sciName_col = "Binomial")
  
  expect_equal(result$Binomial[1], "Castilleja miniata")
})

test_that("split_scientificName handles multiple rows with mixed content", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:3,
    Binomial = c(
      "Castilleja miniata",
      "Penstemon strictus",
      "Eriogonum ovalifolium var. purpureum"
    )
  )
  
  result <- split_scientificName(df, sciName_col = "Binomial")
  
  expect_equal(nrow(result), 3)
  expect_equal(result$Genus[1], "Castilleja")
  expect_equal(result$Genus[2], "Penstemon")
  expect_equal(result$Genus[3], "Eriogonum")
})

test_that("split_scientificName overwrite parameter works", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c("Castilleja miniata", "Penstemon strictus"),
    Genus = c("OldGenus1", "OldGenus2")
  )
  
  # With overwrite = TRUE (default), should replace Genus
  result_overwrite <- split_scientificName(df, sciName_col = "Binomial", overwrite = TRUE)
  expect_equal(result_overwrite$Genus[1], "Castilleja")
  expect_false("OldGenus1" %in% result_overwrite$Genus)
  
  # With overwrite = FALSE, should keep original column name
  result_no_overwrite <- split_scientificName(df, sciName_col = "Binomial", overwrite = FALSE)
  expect_true("Binomial" %in% names(result_no_overwrite))
})

test_that("split_scientificName extracts binomial authority correctly", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    Binomial = c(
      "Castilleja pilosa (S. Watson) Rydb. var. steenburghii (Standl.) N.H. Holmgren",
      "Penstemon strictus Benth."
    )
  )
  
  result <- split_scientificName(df, sciName_col = "Binomial")
  
  # Binomial_authority should be everything before var./subsp./ssp.
  expect_match(as.character(result$Binomial_authority[1]), "Rydb")
  expect_false(grepl("Holmgren", as.character(result$Binomial_authority[1])))
})

test_that("split_scientificName handles case variations", {
  skip_if_not_installed("stringr")
  skip_if_not_installed("data.table")
  skip_if_not_installed("dplyr")
  
  df <- data.frame(
    Collection_number = 1:2,
    binomial = c("Castilleja miniata", "Penstemon strictus")  # lowercase
  )
  
  expect_output(
    result <- split_scientificName(df),
    "using: binomial"
  )
  
  expect_equal(result$Genus[1], "Castilleja")
})
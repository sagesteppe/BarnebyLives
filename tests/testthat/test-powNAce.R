library(testthat)
library(dplyr)
library(sf)

# Helper function to create test data
create_pownace_test_data <- function() {
  data.frame(
    UNIQUEID = 1:5,
    Collection_number = 101:105,
    Collector = c("Smith", "Jones", "Brown", "Davis", "Wilson"),
    Date = c("2023-01-01", "2023-02-01", "2023-03-01", "2023-04-01", "2023-05-01"),
    Genus = c('Castilleja', 'Linnaea', 'Dimeresia', 'Astragalus', 'Pinus'),
    POW_Genus = c('Castilleja', 'Linnaea', 'Dimeresia', 'Astragalus', 'Pinus'),
    Epithet = c('pilosa', 'borealis', 'howellii', 'purshii', 'ponderosa'),
    POW_Epithet = c('pilosa', 'borealis', 'howellii', 'purshii', 'ponderosa'),
    Infrarank = c('var.', 'var.', NA, NA, 'var.'),
    POW_Infrarank = c('var.', 'var.', NA, NA, 'var.'),
    Infraspecies = c('pilosa', 'americana', NA, NA, 'scopulorum'),
    POW_Infraspecies = c('pilosa', 'americana', NA, NA, 'scopulorum'),
    Binomial_authority = c('(S. Watson) Rydb.', 'L.', 'A. Gray', 'Douglas', 'Lawson'),
    POW_Authority = c('(S. Watson) Rydb.', '(J. Forbes) Rehder', 'A. Gray', 'Douglas', 'Lawson & C. Lawson'),
    Family = c('Orobanchaceae', 'Caprifoliaceae', 'Asteraceae', 'Fabaceae', 'Pinaceae'),
    POW_Family = c('Orobanchaceae', 'Caprifoliaceae', 'Asteraceae', 'Fabaceae', 'Pinaceae'),
    stringsAsFactors = FALSE
  )
}

create_pownace_test_data_sf <- function() {
  df <- create_pownace_test_data()
  df$lon <- c(-105.5, -106.2, -107.1, -108.0, -109.3)
  df$lat <- c(40.5, 41.2, 42.1, 43.0, 44.3)
  
  sf::st_as_sf(df, coords = c("lon", "lat"), crs = 4326) |>
    mutate(
      lon = c(-105.5, -106.2, -107.1, -108.0, -109.3),
      lat = c(40.5, 41.2, 42.1, 43.0, 44.3)
    )
}

# Tests for matching field replacement with NA
test_that("powNAce replaces matching Genus with NA", {
  test_data <- data.frame(
    UNIQUEID = 1:2,
    Genus = c('Castilleja', 'Linnaea'),
    POW_Genus = c('Castilleja', 'Different'),
    Epithet = c('pilosa', 'borealis'),
    POW_Epithet = c('pilosa', 'borealis'),
    POW_Infrarank = c(NA, NA),
    POW_Infraspecies = c(NA, NA),
    POW_Authority = c('Auth1', 'Auth2')
  )
  
  result <- powNAce(test_data)
  
  # First genus matches, should be NA
  expect_true(is.na(result$POW_Genus[1]))
  # Second doesn't match, should remain
  expect_equal(result$POW_Genus[2], 'Different')
})

test_that("powNAce replaces matching Epithet with NA", {
  test_data <- data.frame(
    UNIQUEID = 1:2,
    Genus = c('Castilleja', 'Linnaea'),
    POW_Genus = c('Castilleja', 'Linnaea'),
    Epithet = c('pilosa', 'borealis'),
    POW_Epithet = c('pilosa', 'different'),
    POW_Infrarank = c(NA, NA),
    POW_Infraspecies = c(NA, NA),
    POW_Authority = c('Auth1', 'Auth2')
  )
  
  result <- powNAce(test_data)
  
  # First epithet matches, should be NA
  expect_true(is.na(result$POW_Epithet[1]))
  # Second doesn't match, should remain
  expect_equal(result$POW_Epithet[2], 'different')
})

test_that("powNAce replaces matching Family with NA", {
  test_data <- data.frame(
    UNIQUEID = 1:2,
    Family = c('Asteraceae', 'Fabaceae'),
    POW_Family = c('Asteraceae', 'Different'),
    Genus = c('Genus1', 'Genus2'),
    POW_Genus = c('Genus1', 'Genus2'),
    Epithet = c('sp1', 'sp2'),
    POW_Epithet = c('sp1', 'sp2'),
    POW_Infrarank = c(NA, NA),
    POW_Infraspecies = c(NA, NA),
    POW_Authority = c('Auth1', 'Auth2')
  )
  
  result <- powNAce(test_data)
  
  expect_true(is.na(result$POW_Family[1]))
  expect_equal(result$POW_Family[2], 'Different')
})

# Tests for infraspecific handling
test_that("powNAce replaces matching Infrarank with NA", {
  test_data <- data.frame(
    UNIQUEID = 1:2,
    Genus = c('Pinus', 'Quercus'),
    POW_Genus = c('Pinus', 'Quercus'),
    Epithet = c('ponderosa', 'robur'),
    POW_Epithet = c('ponderosa', 'robur'),
    Infrarank = c('var.', 'subsp.'),
    POW_Infrarank = c('var.', 'forma'),
    Infraspecies = c('scopulorum', 'robur'),
    POW_Infraspecies = c('scopulorum', 'robur'),
    POW_Authority = c('Auth1', 'Auth2')
  )
  
  result <- powNAce(test_data)
  
  # First infrarank matches, should be NA
  expect_true(is.na(result$POW_Infrarank[1]))
  # Second doesn't match, should remain
  expect_equal(result$POW_Infrarank[2], 'forma')
})

test_that("powNAce replaces matching Infraspecies with NA", {
  test_data <- data.frame(
    UNIQUEID = 1:2,
    Genus = c('Pinus', 'Quercus'),
    POW_Genus = c('Pinus', 'Quercus'),
    Epithet = c('ponderosa', 'robur'),
    POW_Epithet = c('ponderosa', 'robur'),
    Infrarank = c('var.', 'var.'),
    POW_Infrarank = c('var.', 'var.'),
    Infraspecies = c('scopulorum', 'different'),
    POW_Infraspecies = c('scopulorum', 'robur'),
    POW_Authority = c('Auth1', 'Auth2')
  )
  
  result <- powNAce(test_data)
  
  # First matches
  expect_true(is.na(result$POW_Infraspecies[1]))
  # Second doesn't match
  expect_equal(result$POW_Infraspecies[2], 'robur')
})


test_that("powNAce assigns authority to binomial when infraspecies equals epithet", {
  test_data <- data.frame(
    UNIQUEID = 1,
    Genus = 'Castilleja',
    POW_Genus = 'Castilleja',
    Epithet = 'pilosa',
    POW_Epithet = 'pilosa',
    Infrarank = 'var.',
    POW_Infrarank = 'var.',
    Infraspecies = 'pilosa',
    POW_Infraspecies = 'pilosa',
    POW_Authority = '(S. Watson) Rydb.'
  )
  
  result <- powNAce(test_data)
  
  # When infraspecies == epithet, authority goes to binomial
  expect_false(is.na(result$POW_Binomial_authority[1]))
  expect_true(is.na(result$POW_Infraspecific_authority[1]))
})

test_that("powNAce assigns authority to infraspecific when infraspecies differs from epithet", {
  test_data <- data.frame(
    UNIQUEID = 1,
    Genus = 'Linnaea',
    POW_Genus = 'Linnaea',
    Epithet = 'borealis',
    POW_Epithet = 'borealis',
    Infrarank = 'var.',
    POW_Infrarank = 'var.',
    Infraspecies = 'americana',
    POW_Infraspecies = 'americana',
    POW_Authority = '(J. Forbes) Rehder'
  )
  
  result <- powNAce(test_data)
  
  # When infraspecies != epithet, authority goes to infraspecific
  expect_true(is.na(result$POW_Binomial_authority[1]))
  expect_equal(result$POW_Infraspecific_authority[1], '(J. Forbes) Rehder')
})


# Tests for author_spacer function
test_that("powNAce adds spaces after abbreviated middle names", {
  test_data <- data.frame(
    UNIQUEID = 1,
    Genus = 'Pinus',
    POW_Genus = 'Pinus',
    Epithet = 'ponderosa',
    POW_Epithet = 'ponderosa',
    Infrarank = NA,
    POW_Infrarank = NA,
    Infraspecies = NA,
    POW_Infraspecies = NA,
    POW_Authority = 'Lawson & C.Lawson'  # Missing space after C.
  )
  
  result <- powNAce(test_data)
  
  # Should add space after C.
  expect_true(grepl('C\\. Lawson', result$POW_Binomial_authority[1]))
})

test_that("powNAce preserves trailing periods in authorities", {
  test_data <- data.frame(
    UNIQUEID = 1,
    Genus = 'Linnaea',
    POW_Genus = 'Linnaea',
    Epithet = 'borealis',
    POW_Epithet = 'borealis',
    Infrarank = NA,
    POW_Infrarank = NA,
    Infraspecies = NA,
    POW_Infraspecies = NA,
    POW_Authority = 'L.'
  )
  
  result <- powNAce(test_data)
  
  # Should preserve the trailing period
  expect_equal(result$POW_Binomial_authority[1], 'L.')
})

test_that("powNAce handles parentheses in authorities correctly", {
  test_data <- data.frame(
    UNIQUEID = 1,
    Genus = 'Castilleja',
    POW_Genus = 'Castilleja',
    Epithet = 'pilosa',
    POW_Epithet = 'pilosa',
    Infrarank = NA,
    POW_Infrarank = NA,
    Infraspecies = NA,
    POW_Infraspecies = NA,
    POW_Authority = '(S.Watson) Rydb.'
  )
  
  result <- powNAce(test_data)
  
  # Should add space after S. but not have space before )
  expect_true(grepl('S\\. Watson', result$POW_Binomial_authority[1]))
  expect_false(grepl(' \\)', result$POW_Binomial_authority[1]))
})

# Tests for compareNA function
test_that("powNAce handles NA comparisons correctly", {
  test_data <- data.frame(
    UNIQUEID = 1:3,
    Genus = c('Gen1', NA, 'Gen3'),
    POW_Genus = c('Gen1', NA, 'Different'),
    Epithet = c('sp1', 'sp2', 'sp3'),
    POW_Epithet = c('sp1', 'sp2', 'sp3'),
    POW_Infrarank = c(NA, NA, NA),
    POW_Infraspecies = c(NA, NA, NA),
    POW_Authority = c('Auth1', 'Auth2', 'Auth3')
  )
  
  result <- powNAce(test_data)
  
  # Both Gen1 match -> NA
  expect_true(is.na(result$POW_Genus[1]))
  # Both NA -> should be NA (NAs match)
  expect_true(is.na(result$POW_Genus[2]))
  # Different values -> keep POW value
  expect_equal(result$POW_Genus[3], 'Different')
})

# Tests for sf object handling
test_that("powNAce works with sf objects", {
  test_data_sf <- create_pownace_test_data_sf()
  
  result <- powNAce(test_data_sf)
  
  expect_s3_class(result, "sf")
  expect_true("geometry" %in% names(result))
})

test_that("powNAce preserves geometry column", {
  test_data_sf <- create_pownace_test_data_sf()
  
  result <- powNAce(test_data_sf)
  
  expect_equal(nrow(result), nrow(test_data_sf))
  expect_s3_class(sf::st_geometry(result), "sfc")
})

# Tests for column removal and preservation
test_that("powNAce removes POW_Authority column", {
  test_data <- create_pownace_test_data()
  
  result <- powNAce(test_data)
  
  expect_false("POW_Authority" %in% names(result))
})

test_that("powNAce removes POW_Name_authority and POW_Full_name columns", {
  test_data <- create_pownace_test_data()
  test_data$POW_Name_authority <- "Some authority"
  test_data$POW_Full_name <- "Some full name"
  
  result <- powNAce(test_data)
  
  expect_false("POW_Name_authority" %in% names(result))
  expect_false("POW_Full_name" %in% names(result))
})

test_that("powNAce preserves non-taxonomic columns", {
  test_data <- create_pownace_test_data()
  
  result <- powNAce(test_data)
  
  expect_true("Collection_number" %in% names(result))
  expect_true("Collector" %in% names(result))
  expect_true("Date" %in% names(result))
  expect_equal(result$Collector, test_data$Collector)
})

# Tests for column ordering
test_that("powNAce relocates taxonomic columns after position 4", {
  test_data <- create_pownace_test_data()
  
  result <- powNAce(test_data)
  
  # Check that taxonomic columns come after the first 4 columns
  col_names <- names(result)
  genus_pos <- which(col_names == "Genus")
  
  expect_true(genus_pos > 4)
})

# Tests for authority comparison
test_that("powNAce replaces matching binomial authority with NA", {
  test_data <- data.frame(
    UNIQUEID = 1:2,
    Genus = c('Astragalus', 'Pinus'),
    POW_Genus = c('Astragalus', 'Pinus'),
    Epithet = c('purshii', 'ponderosa'),
    POW_Epithet = c('purshii', 'ponderosa'),
    Infrarank = c(NA, NA),
    POW_Infrarank = c(NA, NA),
    Infraspecies = c(NA, NA),
    POW_Infraspecies = c(NA, NA),
    Binomial_authority = c('Douglas', 'Lawson'),
    POW_Authority = c('Douglas', 'Different')
  )
  
  result <- powNAce(test_data)
  
  # First matches
  expect_true(is.na(result$POW_Binomial_authority[1]))
  # Second doesn't match
  expect_equal(result$POW_Binomial_authority[2], 'Different')
})

test_that("powNAce replaces matching infraspecific authority with NA", {
  test_data <- data.frame(
    UNIQUEID = 1:2,
    Genus = c('Linnaea', 'Pinus'),
    POW_Genus = c('Linnaea', 'Pinus'),
    Epithet = c('borealis', 'ponderosa'),
    POW_Epithet = c('borealis', 'ponderosa'),
    Infrarank = c('var.', 'var.'),
    POW_Infrarank = c('var.', 'var.'),
    Infraspecies = c('americana', 'scopulorum'),
    POW_Infraspecies = c('americana', 'scopulorum'),
    Infraspecific_authority = c('(J. Forbes) Rehder', 'Auth'),
    POW_Authority = c('(J. Forbes) Rehder', 'Different')
  )
  
  result <- powNAce(test_data)
  
  # First matches (after author_spacer formatting)
  expect_true(is.na(result$POW_Infraspecific_authority[1]))
  # Second doesn't match
  expect_equal(result$POW_Infraspecific_authority[2], 'Different')
})

# Tests for UNIQUEID requirement
test_that("powNAce requires UNIQUEID column", {
  test_data <- data.frame(
    Genus = 'Castilleja',
    POW_Genus = 'Castilleja',
    Epithet = 'pilosa',
    POW_Epithet = 'pilosa',
    POW_Infrarank = NA,
    POW_Infraspecies = NA,
    POW_Authority = 'Auth'
  )
  
  # Should error or fail without UNIQUEID
  expect_error(powNAce(test_data))
})

# Integration test with documentation example
test_that("powNAce works with documentation example", {
  df <- data.frame(
    UNIQUEID = 1:3,
    Genus = c('Castilleja', 'Linnaea', 'Dimeresia'),
    POW_Genus = c('Castilleja', 'Linnaea', 'Dimeresia'),
    Epithet = c('pilosa', 'borealis', 'howellii'),
    POW_Epithet = c('pilosa', 'borealis', 'howellii'),
    Infrarank = c('var.', 'var.', NA),
    POW_Infrarank = c('var.', 'var.', NA),
    Infraspecies = c('pilosa', 'americana', NA),
    POW_Infraspecies = c('pilosa', 'americana', NA),
    POW_Authority = c('(S. Watson) Rydb.', '(J. Forbes) Rehder', 'A. Gray')
  )
  
  result <- powNAce(df)
  
  # All genera match -> should be NA
  expect_true(all(is.na(result$POW_Genus)))
  # All epithets match -> should be NA
  expect_true(all(is.na(result$POW_Epithet)))
  # All infraranks match (including both NA) -> should be NA
  expect_true(all(is.na(result$POW_Infrarank)))
  # All infraspecies match (including both NA) -> should be NA
  expect_true(all(is.na(result$POW_Infraspecies)))
})

# Tests for edge cases
test_that("powNAce handles single row", {
  test_data <- data.frame(
    UNIQUEID = 1,
    Genus = 'Castilleja',
    POW_Genus = 'Castilleja',
    Epithet = 'pilosa',
    POW_Epithet = 'pilosa',
    POW_Infrarank = NA,
    POW_Infraspecies = NA,
    POW_Authority = 'Auth'
  )
  
  result <- powNAce(test_data)
  
  expect_equal(nrow(result), 1)
  expect_true(is.na(result$POW_Genus))
})

test_that("powNAce handles all different values", {
  test_data <- data.frame(
    UNIQUEID = 1,
    Genus = 'Genus1',
    POW_Genus = 'DifferentGenus',
    Epithet = 'species1',
    POW_Epithet = 'differentSpecies',
    Family = 'Family1',
    POW_Family = 'DifferentFamily',
    POW_Infrarank = NA,
    POW_Infraspecies = NA,
    POW_Authority = 'Auth'
  )
  
  result <- powNAce(test_data)
  
  # None should be NA since nothing matches
  expect_equal(result$POW_Genus, 'DifferentGenus')
  expect_equal(result$POW_Epithet, 'differentSpecies')
  expect_equal(result$POW_Family, 'DifferentFamily')
})
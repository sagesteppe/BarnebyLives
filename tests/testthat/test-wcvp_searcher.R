library(testthat)
library(dplyr)
library(sf)
library(stringr)
library(data.table)
library(withr)

create_id_lookup <- function() {
  data.frame(
    taxonid = c(1, 2, 3, 4, 5, 6),
    family = c(
      'Fabaceae', 'Caprifoliaceae', 'Fabaceae',
      'Caprifoliaceae', 'Caprifoliaceae', 'Fagaceae'
    ),
    genus = c(
      'Astragalus', 'Linnaea', 'Astragalus',
      'Linnaea', 'Linnaea', 'Quercus'
    ),
    specificepithet = c(
      'purshii', 'borealis', 'oldname',
      'borealis', 'borealis', 'mystery'
    ),
    infraspecificepithet = c('', '', '', 'borealis', 'oldvar', ''),
    taxonrank = c(
      'Species', 'Species', 'Species',
      'Subspecies', 'Variety', 'Species'
    ),
    scientfiicname = c(
      'Astragalus purshii', 'Linnaea borealis', 'Astragalus oldname',
      'Linnaea borealis subsp. borealis', 'Linnaea borealis var. oldvar',
      'Quercus mystery'
    ),
    scientfiicnameauthorship = c(
      'Douglas ex Hook.', 'L.', 'Someauthor',
      '(L.) auct.', 'Oldauth', 'Unknown'
    ),
    taxonomicstatus = c(
      'Accepted', 'Accepted', 'Synonym',
      'Accepted', 'Synonym', 'Unplaced'
    ),
    acceptednameusageid = c(1, 2, 1, 4, 4, 6),
    parentnameusageid = c(NA, NA, NA, 2, NA, NA),
    stringsAsFactors = FALSE
  )
}

write_lookup_tables <- function(path) {
  write.csv(
    create_id_lookup(),
    file.path(path, 'id_lookup_table.csv'),
    row.names = FALSE
  )
}

test_that("wcvp_searcher resolves an already-accepted species", {
  temp_path <- withr::local_tempdir()
  write_lookup_tables(temp_path)

  data <- data.frame(Full_name = 'Astragalus purshii', stringsAsFactors = FALSE)
  result <- wcvp_searcher(data, column = 'Full_name', path = temp_path)

  expect_equal(result$POW_Family, 'Fabaceae')
  expect_equal(result$POW_Genus, 'Astragalus')
  expect_equal(result$POW_Epithet, 'purshii')
  expect_true(is.na(result$POW_Infrarank))
  expect_true(is.na(result$POW_Infraspecies))
  expect_equal(result$POW_Authority, 'Douglas ex Hook.')
  expect_equal(result$POW_Status, 'Accepted')
})

test_that("wcvp_searcher resolves a synonym to its accepted name", {
  temp_path <- withr::local_tempdir()
  write_lookup_tables(temp_path)

  data <- data.frame(Full_name = 'Astragalus oldname', stringsAsFactors = FALSE)
  result <- wcvp_searcher(data, column = 'Full_name', path = temp_path)

  # taxonomic fields reflect the ACCEPTED record...
  expect_equal(result$POW_Genus, 'Astragalus')
  expect_equal(result$POW_Epithet, 'purshii')
  expect_equal(result$POW_Authority, 'Douglas ex Hook.')
  # ...but Status flags what was actually submitted, for review.
  expect_equal(result$POW_Status, 'Synonym')
})

test_that("wcvp_searcher resolves an accepted infraspecies and maps rank abbreviations", {
  temp_path <- withr::local_tempdir()
  write_lookup_tables(temp_path)

  data <- data.frame(
    Full_name = 'Linnaea borealis subsp. borealis',
    stringsAsFactors = FALSE
  )
  result <- wcvp_searcher(data, column = 'Full_name', path = temp_path)

  expect_equal(result$POW_Infrarank, 'subsp.')
  expect_equal(result$POW_Infraspecies, 'borealis')
  expect_equal(result$POW_Authority, '(L.) auct.')
  expect_equal(result$POW_Status, 'Accepted')
})

test_that("wcvp_searcher resolves an infraspecific synonym through acceptednameusageid", {
  temp_path <- withr::local_tempdir()
  write_lookup_tables(temp_path)

  data <- data.frame(
    Full_name = 'Linnaea borealis var. oldvar',
    stringsAsFactors = FALSE
  )
  result <- wcvp_searcher(data, column = 'Full_name', path = temp_path)

  # resolved to the accepted subspecies record, not the submitted variety
  expect_equal(result$POW_Infrarank, 'subsp.')
  expect_equal(result$POW_Infraspecies, 'borealis')
  expect_equal(result$POW_Authority, '(L.) auct.')
  expect_equal(result$POW_Status, 'Synonym')
})

test_that("wcvp_searcher passes through a self-referencing non-accepted status", {
  temp_path <- withr::local_tempdir()
  write_lookup_tables(temp_path)

  data <- data.frame(Full_name = 'Quercus mystery', stringsAsFactors = FALSE)
  result <- wcvp_searcher(data, column = 'Full_name', path = temp_path)

  expect_equal(result$POW_Genus, 'Quercus')
  expect_equal(result$POW_Status, 'Unplaced')
})

test_that("wcvp_searcher flags unmatched names as not-found", {
  temp_path <- withr::local_tempdir()
  write_lookup_tables(temp_path)

  data <- data.frame(Full_name = 'Pinus ponderosa', stringsAsFactors = FALSE)
  result <- wcvp_searcher(data, column = 'Full_name', path = temp_path)

  expect_equal(result$POW_Status, 'not-found')
  expect_true(is.na(result$POW_Family))
  expect_equal(result$POW_Query, 'Pinus ponderosa')
})

test_that("wcvp_searcher handles multiple rows and preserves original columns", {
  temp_path <- withr::local_tempdir()
  write_lookup_tables(temp_path)

  data <- data.frame(
    UNIQUEID = 1:3,
    Full_name = c(
      'Astragalus purshii', 'Astragalus oldname', 'Pinus ponderosa'
    ),
    stringsAsFactors = FALSE
  )
  result <- wcvp_searcher(data, column = 'Full_name', path = temp_path)

  expect_equal(nrow(result), 3)
  expect_equal(result$UNIQUEID, 1:3)
  expect_equal(result$POW_Status, c('Accepted', 'Synonym', 'not-found'))
})

test_that("wcvp_searcher works with sf input and preserves geometry", {
  temp_path <- withr::local_tempdir()
  write_lookup_tables(temp_path)

  data <- data.frame(
    Full_name = c('Astragalus purshii', 'Linnaea borealis'),
    lon = c(-105.5, -106.2),
    lat = c(40.5, 41.2),
    stringsAsFactors = FALSE
  ) |>
    sf::st_as_sf(coords = c('lon', 'lat'), crs = 4326)

  result <- wcvp_searcher(data, column = 'Full_name', path = temp_path)

  expect_true(any(class(result) == 'sf'))
  expect_equal(nrow(result), 2)
  expect_equal(result$POW_Status, c('Accepted', 'Accepted'))
})

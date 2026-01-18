library(testthat)
library(mockery)
library(sf)

test_that("TaxUnpack runs with mocks", {

  tmp_dir <- tempdir()

  # -----------------------
  # 1. Fake bound geometry
  # -----------------------
  bound <- sf::st_sf(
    x = c(0,1),
    y = c(0,1),
    geometry = sf::st_sfc(
      sf::st_point(c(0,0)),
      sf::st_point(c(1,1))
    ),
    crs = 4326
  )

  # -----------------------
  # 2. Mock side-effect functions
  # -----------------------
  mock_WCVP_dl <- mock(NULL)
  mock_write <- mock(NULL, cycle = TRUE)
  mock_GET <- mock(NULL)

  # -----------------------
  # 3. Mock tigris::states() to return 3 fake states with geometry
  # -----------------------
  mock_states <- mock(
    sf::st_sf(
      NAME = c("A","B","C"),
      geometry = sf::st_sfc(
        sf::st_point(c(0,0)),
        sf::st_point(c(1,1)),
        sf::st_point(c(2,2))
      ),
      crs = 4326
    )
  )

  # -----------------------
  # 4. Fake data for read.table()
  # -----------------------
  distributions_df <- data.frame(
    coreid = 1:3,
    locality = c("A","B","C")
  )

  taxon_df <- data.frame(
    taxonid = 1:3,
    taxonrank = c("Species","Subspecies","Variety"),
    family = c("Fam1","Fam2","Fam3"),
    genus = c("Genus1","Genus2","Genus3"),
    specificepithet = c("s1","s2","s3"),
    infraspecificepithet = c("i1","i2","i3"),
    scientfiicname = c("Name1","Name2","Name3"),
    acceptednameusageid = 1:3,
    parentnameusageid = 1:3,
    taxonomicstatus = c("accepted","accepted","accepted")
  )

  # -----------------------
  # 5. Stub all side effects
  # -----------------------
  stub(TaxUnpack, "WCVP_dl", mock_WCVP_dl)
  stub(TaxUnpack, "write.csv", mock_write)
  stub(TaxUnpack, "httr::GET", mock_GET)
  stub(TaxUnpack, "tigris::states", mock_states)

  # Stub read.table() to handle distribution and taxon files separately
  # Stub unz() so read.table sees the filename directly
  stub(TaxUnpack, "unz", function(zipfile, filename) filename)

  # Stub read.table() to return correct data frames based on the filename
  stub(TaxUnpack, "read.table", function(file, ...) {
    if (grepl("distribution", file)) {
      distributions_df
    } else if (grepl("taxon", file)) {
      taxon_df
    } else {
      stop("Unexpected file in read.table")
    }
  })


  # -----------------------
  # 6. Run the function
  # -----------------------
  TaxUnpack(path = tmp_dir, bound = bound)

  # -----------------------
  # 7. Expectations
  # -----------------------
  expect_called(mock_WCVP_dl, 1)        # WCVP_dl called once
  expect_called(mock_write, 3)          # families + species + infra_species
  expect_called(mock_GET, 1)            # author abbreviations downloaded
  expect_called(mock_states, 1)         # tigris::states called
})

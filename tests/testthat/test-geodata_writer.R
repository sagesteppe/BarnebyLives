library(testthat)

sf_fixture <- function() {
  sf::st_as_sf(
    data.frame(
      Primary_Collector = "Smith",
      Collection_number = "123",
      longitude_dd = -120,
      latitude_dd = 38
    ),
    coords = c("longitude_dd", "latitude_dd"),
    crs = 4326
  )
}


test_that("geodata_writer writes a file with correct name and type", {
  tmp <- withr::local_tempdir()

  x <- sf_fixture()

  geodata_writer(
    x,
    path = tmp,
    filename = "testfile",
    filetype = "kml"
  )

  files <- list.files(tmp, full.names = TRUE)

  expect_true(any(grepl("testfile.*\\.kml$", files)))
})

test_that("geodata_writer uses defaults when arguments missing", {
  tmp <- withr::local_tempdir()

  withr::with_dir(tmp, {
    geodata_writer(sf_fixture())
  })

  files <- list.files(tmp, pattern = "\\.kml$", full.names = TRUE)

  expect_length(files, 1)
  expect_match(basename(files), "HerbariumCollections-")
})


test_that("geodata_writer creates Name and Description fields", {
  tmp <- withr::local_tempdir()

  x <- sf_fixture()

  geodata_writer(
    x,
    path = tmp,
    filename = "cols",
    filetype = "kml"
  )

  f <- list.files(tmp, full.names = TRUE)
  out <- sf::st_read(f, quiet = TRUE)

  nm <- tolower(names(out))

  expect_true("name" %in% nm)
  expect_true("description" %in% nm)
})


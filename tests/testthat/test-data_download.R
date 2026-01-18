library(testthat)
library(mockery)
library(sf)
library(terra)

test_that("data_download nominal case calls all steps", {
  tmp_dir <- tempdir()

  # Mocks for all download functions
  mock_counties <- mock(TRUE)
  mock_GMBA <- mock(TRUE)
  mock_Valleys <- mock(TRUE)
  mock_allotments <- mock(TRUE)
  mock_GNIS <- mock(TRUE)
  mock_PLSS <- mock(TRUE)
  mock_SGMC <- mock(TRUE)

  stub(data_download, "counties_dl", mock_counties)
  stub(data_download, "GMBA_dl", mock_GMBA)
  stub(data_download, "Valleys_dl", mock_Valleys)
  stub(data_download, "allotments_dl", mock_allotments)
  stub(data_download, "GNIS_dl", mock_GNIS)
  stub(data_download, "PLSS_dl", mock_PLSS)
  stub(data_download, "SGMC_dl", mock_SGMC)

  data_download(tmp_dir)

  expect_called(mock_counties, 1)
  expect_called(mock_GMBA, 1)
  expect_called(mock_Valleys, 1)
  expect_called(mock_allotments, 1)
  expect_called(mock_GNIS, 1)
  expect_called(mock_PLSS, 1)
  expect_called(mock_SGMC, 1)
})

test_that("data_download prints error message and stops next steps if a step fails", {
  tmp_dir <- tempdir()

  mock_counties <- mock(TRUE)
  mock_GMBA <- function(...) stop("Download error")
  mock_Valleys <- mock(TRUE)

  stub(data_download, "counties_dl", mock_counties)
  stub(data_download, "GMBA_dl", mock_GMBA)
  stub(data_download, "Valleys_dl", mock_Valleys)

  # match partial string because of crayon colors
  expect_message(
    data_download(tmp_dir),
    "Download error"
  )

  # Only first step should be called
  expect_called(mock_counties, 1)
  # Valleys_dl should never be called
  expect_called(mock_Valleys, 0)
})



test_that("download functions skip if file exists", {
  tmp_dir <- tempdir()

  # Fake file.exists to always return TRUE
  stub(counties_dl, "file.exists", function(fp) TRUE)
  stub(GMBA_dl, "file.exists", function(fp) TRUE)

  expect_message(counties_dl(tmp_dir), "already downloaded")
  expect_message(GMBA_dl(tmp_dir), "already downloaded")
})

test_that("download_sgmc triggers stop branch when tools missing", {
  tmp_fp <- file.path(tempdir(), "SGMC_test.zip")

  # Force Sys.which to return empty → simulate no wget/curl
  stub(download_sgmc, "Sys.which", function(tool) "")
  stub(download_sgmc, "Sys.info", function() list(sysname = "Linux"))
  stub(download_sgmc, "system", function(cmd) 1) # simulate failure

  expect_error(
    download_sgmc(tmp_fp, url = "http://fake.url/file.zip"),
    "Download must be completed by hand"
  )
})

test_that("tileSelector returns correct filenames and length", {
  bound <- data.frame(
    x = c(-126, -82, -82, -126, -126),
    y = c(30.1, 30.1, 49.5, 49.5, 30.1)
  )

  fnames <- tileSelector(bound)
  expect_type(fnames, "character")
  expect_true(all(grepl("_90M_", fnames)))
  expect_true(all(grepl("\\.tar\\.gz$", fnames)))
  expect_true(length(fnames) > 0)
})

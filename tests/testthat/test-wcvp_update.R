library(testthat)
library(mockery)

test_that("wcvp_update downloads when local file is outdated or missing", {
  
  # Temporary directory
  tmp_dir <- tempdir()
  
  # Mock list.files to simulate local wcvp.zip present
  mock_list <- mock(c("wcvp.zip"))
  stub(wcvp_update, "list.files", mock_list)
  
  # Mock read_xlsx to return a fake date (6 days ago)
  fake_read <- data.frame(matrix(NA, nrow = 7, ncol = 1))
  fake_read[7, 1] <- format(Sys.Date() - 30, "%d/%m/%Y")
  mock_read <- mock(fake_read)
  stub(wcvp_update, "readxl::read_xlsx", mock_read)
  
  # Mock file.remove to do nothing
  mock_remove <- mock(NULL)
  stub(wcvp_update, "file.remove", mock_remove)
  
  # Mock rvest chain: read_html -> html_element -> html_element -> html_text2
  fake_html <- paste0("<pre>wcvp.zip ", format(Sys.Date(), "%Y-%m-%d"), " wcvp_dwca.zip</pre>")
  stub(wcvp_update, "rvest::read_html", function(url) list())
  stub(wcvp_update, "rvest::html_element", function(x, ...) list())
  stub(wcvp_update, "rvest::html_text2", function(x) fake_html)
  
  # Mock download.file to capture the call
  mock_download <- mock(NULL)
  stub(wcvp_update, "download.file", mock_download)
  
  # Run function
  mock_unzip <- mock(NULL)
  stub(wcvp_update, "unzip", mock_unzip)

  wcvp_update(tmp_dir)
  
  # Expectations
  expect_called(mock_list, 1)
  expect_called(mock_read, 1)
  expect_called(mock_remove, 1)
  expect_called(mock_download, 1)
  
  # Check that download.file was called with correct destination
  expect_equal(mockery::mock_args(mock_download)[[1]]$destfile,
               file.path(tmp_dir, "wcvp.zip"))
})


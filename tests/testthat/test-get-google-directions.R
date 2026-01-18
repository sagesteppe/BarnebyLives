library(testthat)

test_that("label_writer renders one PDF per row", {
  tmp <- withr::local_tempdir()
  df <- data.frame(
    Primary_Collector = c("Smith", "Jones"),
    Collection_number = c(101, 102)
  )
  csv <- file.path(tmp, "labels.csv")
  write.csv(df, csv, row.names = FALSE)
  
  rendered <- character()
  testthat::local_mocked_bindings(
    render = function(input, output_format, output_file, output_dir, ...) {
      rendered <<- c(rendered, file.path(output_dir, output_file))
      invisible(NULL)
    },
    .package = "rmarkdown"
  )
  
  label_writer(csv, outdir = tmp)
  
  expect_length(rendered, 2)
  expect_true(all(grepl("\\.pdf$", rendered)))
  expect_true(all(grepl("Smith101|Jones102", rendered)))
})

test_that("label_writer creates default Labels directory", {
  tmp <- withr::local_tempdir()
  df <- data.frame(
    Primary_Collector = "Smith",
    Collection_number = 1
  )
  csv <- file.path(tmp, "labels.csv")
  write.csv(df, csv, row.names = FALSE)
  
  testthat::local_mocked_bindings(
    render = function(...) invisible(NULL),
    .package = "rmarkdown"
  )
  
  withr::with_dir(tmp, {
    label_writer(csv)
  })
  
  expect_true(dir.exists(file.path(tmp, "Labels")))
})
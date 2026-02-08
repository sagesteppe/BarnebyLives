test_that("collection_writer writes primary collector, number, and date by default", {
  x <- data.frame(
    Primary_Collector = "Smith",
    Collection_number = "1234",
    Associated_Collectors = NA_character_,
    Date_digital_text = "12 June 1998",
    stringsAsFactors = FALSE
  )

  res <- collection_writer(x)

  expect_identical(
    res,
    "Smith 1234; 12 June 1998"
  )
})

test_that("collection_writer suppresses date when date = FALSE", {
  x <- data.frame(
    Primary_Collector = "Smith",
    Collection_number = "1234",
    Associated_Collectors = NA_character_,
    Date_digital_text = "12 June 1998",
    stringsAsFactors = FALSE
  )

  res <- collection_writer(x, date = FALSE)

  expect_identical(
    res,
    "Smith 1234"
  )
})

test_that("collection_writer includes associated collectors when present", {
  x <- data.frame(
    Primary_Collector = "Smith",
    Collection_number = "1234",
    Associated_Collectors = "Jones & Patel",
    Date_digital_text = "12 June 1998",
    stringsAsFactors = FALSE
  )

  res <- collection_writer(x)

  expect_identical(
    res,
    "Smith 1234, Jones & Patel; 12 June 1998"
  )
})

test_that("collection_writer drops empty associated collectors", {
  x <- data.frame(
    Primary_Collector = "Smith",
    Collection_number = "1234",
    Associated_Collectors = "",
    Date_digital_text = "12 June 1998",
    stringsAsFactors = FALSE
  )

  res <- collection_writer(x)

  expect_identical(
    res,
    "Smith 1234; 12 June 1998"
  )
})

test_that("collection_writer handles absence of associated collectors and date", {
  x <- data.frame(
    Primary_Collector = "Smith",
    Collection_number = "1234",
    Associated_Collectors = "",
    Date_digital_text = "12 June 1998",
    stringsAsFactors = FALSE
  )

  res <- collection_writer(x, date = FALSE)

  expect_identical(
    res,
    "Smith 1234"
  )
})

test_that("collection_writer always returns a scalar character", {
  x <- data.frame(
    Primary_Collector = "Smith",
    Collection_number = "1234",
    Associated_Collectors = NA_character_,
    Date_digital_text = "12 June 1998",
    stringsAsFactors = FALSE
  )

  res <- collection_writer(x)

  expect_type(res, "character")
  expect_length(res, 1)
})


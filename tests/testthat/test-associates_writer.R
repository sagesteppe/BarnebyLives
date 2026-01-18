test_that("associates_writer returns empty string for NA or empty input", {
  expect_identical(associates_writer(NA_character_), "")
  expect_identical(associates_writer(""), "")
  expect_identical(associates_writer(" "), "")
})

test_that("associates_writer writes abbreviated label by default", {
  res <- associates_writer("Carex aquatilis, Juncus balticus")

  expect_identical(
    res,
    "Ass.: \\textit{Carex aquatilis, Juncus balticus}."
  )
})

test_that("associates_writer writes full label when full = TRUE", {
  res <- associates_writer(
    "Carex aquatilis, Juncus balticus",
    full = TRUE
  )

  expect_identical(
    res,
    "Associates: \\textit{Carex aquatilis, Juncus balticus}."
  )
})

test_that("associates_writer always returns a scalar character", {
  res <- associates_writer("A, B, C")

  expect_type(res, "character")
  expect_length(res, 1)
})

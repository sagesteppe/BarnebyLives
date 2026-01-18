test_that("writer collapses empty strings and handles NA", {
  expect_identical(writer(""), "")
  expect_identical(writer(NA_character_), "")
})

test_that("writer returns plain text when italics = FALSE or missing", {
  expect_identical(writer("abc"), "abc")
  expect_identical(writer("abc", italics = FALSE), "abc")
})

test_that("writer italicizes text when italics = TRUE", {
  expect_identical(writer("abc", italics = TRUE), "\\textit{abc}")
})


test_that("writer2 collapses empty strings and handles NA", {
  expect_identical(writer2(""), "")
  expect_identical(writer2(NA_character_), "")
})

test_that("writer2 handles italics argument correctly", {
  expect_identical(writer2("abc"), "abc")
  expect_identical(writer2("abc", italics = FALSE), "abc")
  expect_identical(writer2("abc", italics = TRUE), "\\textit{abc}")
})

test_that("writer2 appends a period only when requested", {
  expect_identical(writer2("abc", period = FALSE), "abc")
  expect_identical(writer2("abc", period = TRUE), "abc.")
})

test_that("writer2 avoids double periods", {
  expect_identical(writer2("abc.", period = TRUE), "abc.")
})


test_that("writer_fide returns empty string when Fide is NA or empty", {
  x1 <- data.frame(
    Fide = "",
    Determined_by = "Someone",
    Determined_date_text = "Some time"
  )
  x2 <- data.frame(
    Fide = NA_character_,
    Determined_by = "Someone",
    Determined_date_text = "Some time"
  )

  expect_identical(writer_fide(x1), "")
  expect_identical(writer_fide(x2), "")
})

test_that("writer_fide formats simple fide strings without parentheses", {
  x <- data.frame(
    Fide = "Michigan Flora Book",
    Determined_by = "Marabeth",
    Determined_date_text = "a day in time"
  )

  expect_identical(
    writer_fide(x),
    "Fide: \\textit{Michigan Fl. Book}, det.: Marabeth, a day in time."
  )
})

test_that("writer_fide handles parentheses with no trailing text", {
  x <- data.frame(
    Fide = "Michigan Flora Book (emphatic)",
    Determined_by = "Marabeth",
    Determined_date_text = "a day in time"
  )

  expect_identical(
    writer_fide(x),
    "Fide: \\textit{Michigan Fl. Book }(emphatic), det.: Marabeth, a day in time."
  )
})

test_that("writer_fide handles parentheses with trailing text", {
  x <- data.frame(
    Fide = "Michigan Flora Book (emphatic) verbose",
    Determined_by = "Marabeth",
    Determined_date_text = "a day in time"
  )

  expect_identical(
    writer_fide(x),
    paste0(
      "Fide: \\textit{Michigan Fl. Book }(emphatic)",
      " \\textit{ verbose}, det.: Marabeth, a day in time."
    )
  )
})


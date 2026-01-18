library(testthat)

test_that("escape_latex correctly escapes LaTeX special characters", {
  input <- c("\\", "&", "%", "$", "#", "^", "_", "{", "}", "~")
  expected <- c(
    "\\textbackslash\\{\\}", "\\&", "\\%", "\\$", "\\#", "\\textasciicircum\\{\\}",
    "\\_", "\\{", "\\}", "\\textasciitilde{}"
  )
  expect_identical(escape_latex(input), expected)
})

test_that("escape_latex works with mixed strings", {
  input <- "Price is $100 & tax #1 ~ estimate \\^_{}"
  expected <- "Price is \\$100 \\& tax \\#1 \\textasciitilde{} estimate \\textbackslash\\{\\}\\textasciicircum\\{\\}\\_\\{\\}"
  expect_identical(escape_latex(input), expected)
})

test_that("escape_latex handles vectors with NA and normal text", {
  input <- c("A & B", NA, "C $ D", "\\", "")
  expected <- c("A \\& B", "", "C \\$ D", "\\textbackslash\\{\\}", "")
  expect_identical(escape_latex(input), expected)
})

test_that("escape_latex handles NULL input", {
  expect_identical(escape_latex(NULL), "")
})

test_that("escape_latex preserves non-special characters", {
  input <- c("Hello World", "R is fun!")
  expect_identical(escape_latex(input), input)
})

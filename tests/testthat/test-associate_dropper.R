test_that("associate_dropper removes the focal species from associates", {
  ce <- data.frame(
    Full_name = c(
      "Microseris gracilis",
      "Alyssum desertorum",
      "Ceratocephala testiculata"
    ),
    Associates = rep(
      paste(
        "Microseris gracilis, Lupinus lepidus,",
        "Alyssum desertorum, Ceratocephala testiculata"
      ),
      times = 3
    ),
    stringsAsFactors = FALSE
  )

  res <- associate_dropper(ce, col = "Associates")

  expect_equal(
    res$Associates,
    c(
      "Lupinus lepidus, Alyssum desertorum, Ceratocephala testiculata",
      "Microseris gracilis, Lupinus lepidus, Ceratocephala testiculata",
      "Microseris gracilis, Lupinus lepidus, Alyssum desertorum"
    )
  )
})

test_that("associate_dropper respects explicit Binomial argument", {
  ce <- data.frame(
    species = c("A", "B"),
    Associates = c("A, B, C", "A, B, C"),
    stringsAsFactors = FALSE
  )

  res <- associate_dropper(
    ce,
    Binomial = "species",
    col = "Associates"
  )

  expect_equal(
    res$Associates,
    c("B, C", "A, C")
  )
})

test_that("associate_dropper emits a message when Binomial is missing", {
  ce <- data.frame(
    Full_name = "A",
    Associates = "A, B, C",
    stringsAsFactors = FALSE
  )

  expect_message(
    associate_dropper(ce, col = "Associates"),
    "defaulting to `Full_name`"
  )
})

test_that("associate_dropper trims whitespace and dangling commas", {
  ce <- data.frame(
    Full_name = "A",
    Associates = "A,  B ,C ,",
    stringsAsFactors = FALSE
  )

  res <- associate_dropper(ce, col = "Associates")

  expect_identical(res$Associates, "B , C")
})

test_that("associate_dropper handles rows independently", {
  ce <- data.frame(
    Full_name = c("A", "C"),
    Associates = c("A, B, C", "A, B, C"),
    stringsAsFactors = FALSE
  )

  res <- associate_dropper(ce, col = "Associates")

  expect_equal(
    res$Associates,
    c("B, C", "A, B")
  )
})

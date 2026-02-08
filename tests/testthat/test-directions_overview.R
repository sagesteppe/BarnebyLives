library(testthat)
library(BarnebyLives)

# Helper: fake google_directions-like object
make_fake_direction <- function(hours = 0, minutes = 30) {
  total_sec <- hours * 3600 + minutes * 60
  list(
    routes = list(
      summary = "Main St",
      legs = list(
        list(
          start_address = "123 Main St 12345, City, USA",
          steps = list(
            list(duration = list(value = total_sec))
          )
        )
      )
    )
  )
}

test_that("directions_overview works for multiple hours, zero minutes", {
  x <- make_fake_direction(hours = 2, minutes = 0)
  res <- directions_overview(x)
  expect_match(res, "2 hrs from 123 Main St via Main St\\.")
})

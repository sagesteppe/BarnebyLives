library(testthat)
library(sf)
library(mockery)

test_that("get_google_directions returns a list with correct structure", {

  x_list <- list(
    sf::st_as_sf(
      data.frame(
        Site_name = "SampleSite",
        latitude_dd = 34.1,
        longitude_dd = -118.3,
        Infraspecific_authority = NA
      ),
      coords = c("longitude_dd", "latitude_dd"),
      crs = 4326,
      remove = FALSE
    )
  )

  mock_directions <- function(origin, destination, key, mode, simplify) {
    list(origin = origin, destination = destination)
  }

  stub(
    BarnebyLives::get_google_directions,
    "googleway::google_directions",
    mock_directions
  )

  res <- BarnebyLives::get_google_directions(x_list, api_key = "fake_key")

  expect_type(res, "list")
  expect_length(res, 1)

  # origin: invariant properties
  expect_true(is.character(res[[1]]$origin))
  expect_true(grepl(", ", res[[1]]$origin))

  # destination: invariant formatting
  expect_equal(res[[1]]$destination, "34.1, -118.3")
})

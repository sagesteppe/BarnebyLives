library(testthat)
library(mockery)

test_that("try_again extracts only genus and calls kewr::search_powo", {
  
  input <- list(query = "Quercus robur subsp. robur")
  
  fake_result <- data.frame(
    name = "Quercus",
    family = "Fagaceae",
    status = "accepted"
  )
  
  # Mock kewr::search_powo
  stub <- mockery::mock(fake_result)
  mockery::stub(try_again, "kewr::search_powo", stub)
  
  out <- try_again(input)
  
  # Output matches mock
  expect_equal(out, fake_result)
  
  # Mock was called once
  expect_called(stub, 1)
  
  # Check that the argument passed to the mock was "Quercus"
  expect_equal(mockery::mock_args(stub)[[1]][[1]], "Quercus")
})

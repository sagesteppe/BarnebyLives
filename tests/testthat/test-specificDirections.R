library(testthat)

test_that("specificDirections processes basic Google directions", {
  skip_if_not_installed("rvest")
  
  # Create mock Google directions response with proper structure
  mock_response <- list(
    routes = list(
      legs = list(
        list(
          steps = list(
            list(
              distance = data.frame(
                value = c(1000, 2000, 500),
                text = c("1.0 km", "2.0 km", "0.5 km")
              ),
              html_instructions = c(
                "<div>Turn left onto Main St</div>",
                "<div>Continue onto Highway 50</div>",
                "<div>Turn right onto Oak Ave</div>"
              )
            )
          )
        )
      )
    )
  )
  
  result <- specificDirections(mock_response)
  
  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})

test_that("specificDirections strips HTML tags", {
  skip_if_not_installed("rvest")
  
  mock_response <- list(
    routes = list(
      legs = list(
        list(
          steps = list(
            list(
              distance = data.frame(
                value = 1000,
                text = "1.0 km"
              ),
              html_instructions = c(
                "<div><b>Turn</b> left onto Main St</div>"
              )
            )
          )
        )
      )
    )
  )
  
  result <- specificDirections(mock_response)
  
  # Should not contain HTML tags
  expect_false(grepl("<div>|<b>|</div>|</b>", result))
  expect_match(result, "Turn")
})

test_that("specificDirections converts distances to miles", {
  skip_if_not_installed("rvest")
  
  mock_response <- list(
    routes = list(
      legs = list(
        list(
          steps = list(
            list(
              distance = data.frame(
                value = 1609,  # Approximately 1 mile
                text = "1.6 km"
              ),
              html_instructions = c(
                "<div>Turn left</div>"
              )
            )
          )
        )
      )
    )
  )
  
  result <- specificDirections(mock_response)
  
  # Should show distance in miles
  expect_match(result, "Turn left 1 mi\\.")
})

test_that("specificDirections abbreviates left and right", {
  skip_if_not_installed("rvest")
  
  mock_response <- list(
    routes = list(
      legs = list(
        list(
          steps = list(
            list(
              distance = data.frame(
                value = c(1000, 2000),
                text = c("1.0 km", "2.0 km")
              ),
              html_instructions = c(
                "<div>Turn left onto Main St</div>",
                "<div>Turn right onto Oak Ave</div>"
              )
            )
          )
        )
      )
    )
  )
  
  result <- specificDirections(mock_response)
  
  # Should abbreviate left to L and right to R
  expect_match(result, " L ")
  expect_match(result, " R ")
  expect_false(grepl(" left ", result))
  expect_false(grepl(" right ", result))
})

test_that("specificDirections abbreviates Continue", {
  skip_if_not_installed("rvest")
  
  mock_response <- list(
    routes = list(
      legs = list(
        list(
          steps = list(
            list(
              distance = data.frame(
                value = 1000,
                text = "1.0 km"
              ),
              html_instructions = c(
                "<div>Continue onto Highway 50</div>"
              )
            )
          )
        )
      )
    )
  )
  
  result <- specificDirections(mock_response)
  
  # Should abbreviate Continue to Con't
  expect_match(result, "Con't")
  expect_false(grepl("Continue", result))
})

test_that("specificDirections removes commercial landmarks", {
  skip_if_not_installed("rvest")
  
  mock_response <- list(
    routes = list(
      legs = list(
        list(
          steps = list(
            list(
              distance = data.frame(
                value = 1000,
                text = "1.0 km"
              ),
              html_instructions = c(
                "<div>Turn left Pass by Burger King on the right</div>"
              )
            )
          )
        )
      )
    )
  )
  
  result <- specificDirections(mock_response)
  
  # Should remove "Pass by Burger King" text
  expect_false(grepl("Burger King", result))
  expect_false(grepl("Pass by", result))
})

test_that("specificDirections removes destination phrases", {
  skip_if_not_installed("rvest")
  
  mock_response <- list(
    routes = list(
      legs = list(
        list(
          steps = list(
            list(
              distance = data.frame(
                value = 1000,
                text = "1.0 km"
              ),
              html_instructions = c(
                "<div>Turn left Destination will be on the right</div>"
              )
            )
          )
        )
      )
    )
  )
  
  result <- specificDirections(mock_response)
  
  # Should remove "Destination will be on" text
  expect_false(grepl("Destination will be", result))
})

test_that("specificDirections filters out very short distances", {
  skip_if_not_installed("rvest")
  
  mock_response <- list(
    routes = list(
      legs = list(
        list(
          steps = list(
            list(
              distance = data.frame(
                value = c(0.5, 1000, 2000, 3000, 4000, 5000, 6000),
                text = rep("1.0 km", 7)
              ),
              html_instructions = c(
                "<div>Step 1</div>",
                "<div>Step 2</div>",
                "<div>Step 3</div>",
                "<div>Step 4</div>",
                "<div>Step 5</div>",
                "<div>Step 6</div>",
                "<div>Step 7</div>"
              )
            )
          )
        )
      )
    )
  )
  
  result <- specificDirections(mock_response)
  
  # Should not include the very short distance step
  expect_false(grepl("Step 1", result))
})

test_that("specificDirections keeps all steps if 5 or fewer", {
  skip_if_not_installed("rvest")
  
  mock_response <- list(
    routes = list(
      legs = list(
        list(
          steps = list(
            list(
              distance = data.frame(
                value = c(0.5, 1000),
                text = c("0.5 m", "1.0 km")
              ),
              html_instructions = c(
                "<div>Step 1</div>",
                "<div>Step 2</div>"
              )
            )
          )
        )
      )
    )
  )
  
  result <- specificDirections(mock_response)
  
  # Should include all steps when 5 or fewer
  expect_match(result, "Step 1")
  expect_match(result, "Step 2")
})

test_that("specificDirections returns a single string", {
  skip_if_not_installed("rvest")
  
  mock_response <- list(
    routes = list(
      legs = list(
        list(
          steps = list(
            list(
              distance = data.frame(
                value = c(1000, 2000),
                text = c("1.0 km", "2.0 km")
              ),
              html_instructions = c(
                "<div>Step 1</div>",
                "<div>Step 2</div>"
              )
            )
          )
        )
      )
    )
  )
  
  result <- specificDirections(mock_response)
  
  # Should return a single concatenated string
  expect_length(result, 1)
  expect_type(result, "character")
})
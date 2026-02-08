library(testthat)

test_that("species_font italicizes basic species names", {
  input <- "Eriogonum ovalifolium"
  result <- species_font(input)
  
  expect_equal(result, "\\textit{Eriogonum ovalifolium}.")
})

test_that("species_font handles sp. in middle of string", {
  input <- "Castilleja sp., Penstemon sp."
  result <- species_font(input)
  
  expect_match(result, "} sp\\., ")
  expect_false(grepl("\\\\textit\\{sp\\.", result))
})

test_that("species_font handles sp. at end of string", {
  input <- "Castilleja sp."
  result <- species_font(input)
  
  expect_equal(result, "\\textit{Castilleja} sp.")
})

test_that("species_font handles spp. in middle of string", {
  input <- "Carex spp., Juncus spp."
  result <- species_font(input)
  
  expect_match(result, "} spp\\., ")
  expect_false(grepl("\\\\textit\\{spp\\.", result))
})

test_that("species_font handles spp. at end of string", {
  input <- "Carex spp."
  result <- species_font(input)
  
  expect_equal(result, "\\textit{Carex} spp.")
})

test_that("species_font handles var. correctly", {
  input <- "Eriogonum ovalifolium var. purpureum"
  result <- species_font(input)
  
  expect_match(result, "} var\\. \\\\textit\\{")
  expect_false(grepl("\\\\textit\\{var\\.", result))
})

test_that("species_font converts subsp. to ssp.", {
  input <- "Pinus ponderosa subsp. scopulorum"
  result <- species_font(input)
  
  expect_match(result, "} ssp\\. \\\\textit\\{")
  expect_false(grepl("subsp", result))
})

test_that("species_font handles ssp. in middle", {
  input <- "Pinus ponderosa ssp. scopulorum"
  result <- species_font(input)
  
  expect_match(result, "} ssp\\. \\\\textit\\{")
  expect_false(grepl("\\\\textit\\{ssp\\.", result))
})

test_that("species_font handles ssp. at end", {
  input <- "Pinus ponderosa ssp."
  result <- species_font(input)
  
  expect_equal(result, "\\textit{Pinus ponderosa} ssp.")
})

test_that("species_font handles complex mixed string", {
  input <- "Eriogonum ovalifolium var. purpureum, Castilleja sp., Crepis spp."
  result <- species_font(input)
  
  # Should have var. not italicized
  expect_match(result, "} var\\. \\\\textit\\{")
  # Should have sp. not italicized
  expect_match(result, "} sp\\., ")
  # Should have spp. not italicized at end
  expect_match(result, "} spp\\.$")
})

test_that("species_font adds period if missing", {
  input <- "Eriogonum ovalifolium"
  result <- species_font(input)
  
  expect_match(result, "\\.$")
})

test_that("species_font does not add double periods", {
  input <- "Castilleja sp."
  result <- species_font(input)
  
  expect_false(grepl("\\.\\.", result))
  expect_match(result, "\\.$")
})

test_that("species_font cleans up double spaces", {
  input <- "Eriogonum  ovalifolium"
  result <- species_font(input)
  
  expect_false(grepl("  ", result))
})

test_that("species_font handles multiple varieties in one string", {
  input <- "Penstemon strictus var. strictus, Penstemon strictus var. angustifolius"
  result <- species_font(input)
  
  # Both var. should be unitalicized
  expect_equal(length(gregexpr("} var\\. \\\\textit\\{", result)[[1]]), 2)
})

test_that("species_font handles string with no abbreviations", {
  input <- "Eriogonum ovalifolium purpureum"
  result <- species_font(input)
  
  expect_equal(result, "\\textit{Eriogonum ovalifolium purpureum}.")
})

test_that("species_font LaTeX output is valid", {
  input <- "Castilleja miniata subsp. miniata, Penstemon sp."
  result <- species_font(input)
  
  # Count opening and closing textit commands
  opening <- length(gregexpr("\\\\textit\\{", result)[[1]])
  closing <- length(gregexpr("}", result)[[1]])
  
  expect_equal(opening, closing)
})

test_that("species_font handles empty or edge cases", {
  # Single word
  expect_equal(species_font("Castilleja"), "\\textit{Castilleja}.")
  
  # Already has period - should not add another
  expect_equal(species_font("Castilleja miniata."), "\\textit{Castilleja miniata}.")
})

test_that("species_font maintains proper LaTeX escaping", {
  input <- "Eriogonum ovalifolium var. purpureum"
  result <- species_font(input)
  
  # Should have proper backslash escaping for LaTeX
  expect_match(result, "\\\\textit")
  expect_false(grepl("\\textit[^\\{]", result))
})
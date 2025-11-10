#' 10 random plant names from taxize
#'
#' A vector from taxize::names_list(rank = 'species', size = 10)
#'
#'
#' @docType data
#' @keywords datasets
#' @name randomNames
#' @usage data(names_vec)
#' @format A character vector
"names_vec"


#' Collection examples for a shipping manifest
#'
#' This is a small data frame of species information for use with the shipping/transferal notes
#' as well as with the label makers.
#'
#'
#' @docType data
#' @keywords datasets
#' @name collection_examples
#' @usage data(collection_examples)
#' @format data frame
"collection_examples"

#' Collection examples for a shipping manifest
#'
#' This is a small data frame of species information for use with with the vignette
#'
#'
#' @docType data
#' @keywords datasets
#' @name collection_examples
#' @usage data(collection_examples)
#' @format data frame
"uncleaned_collection_examples"

#' This is a reproduced and slightly curated list of populated places.
#'
#' this sf/tibble/data.frame data set is derived from the U.S. Census Bureaus tigris::places() data set. It has only the centroid of each place rounded to
#' three decimal places to reduce size.
#'
#'
#' @docType data
#' @keywords datasets
#' @name google_towns
#' @usage data(google_towns)
#' @format Each is a tibble with two variables and three observations
"google_towns"

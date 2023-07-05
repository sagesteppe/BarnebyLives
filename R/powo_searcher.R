#' query plants of the world online for taxonomic information
#'
#'  a wrapper for kewr::search_powo
#' @param x a vector of species names to submit, these should have clean spelling
#' notes: results are observed to fail for valid infraspecies on Kew's end, and they seem not
#' to mention valid infraspecies.
#' @examples
#' library(dplyr)
#' pow_results <- lapply(
#'       c('Linnaea borealis', 'Astragalus purshii', 'Pinus ponderosa'),
#'       powo_searcher) |>
#'    dplyr::bind_rows()
#' head(pow_results)
#' @export
powo_searcher <- function(x){

  q <- paste(x[,'Genus'], x[,'Epithet'], x[,'Infraspecies'])
  return(q)
#  query_results <- kewr::search_powo(q)

#  if (is.null(query_results[["results"]])) {
#    second_try <- try_again(query_results)

#    if (is.null(second_try[["results"]])) {
##      taxonomic_info <- data.frame(
#        family = as.character(),
#        name_authority = as.character(),
#        full_name = as.character(),
#        genus = as.character(),
#        epithet = as.character(),
#        infrarank = as.character(),
#        infraspecies = as.character(),
#        authority = as.character()
#      )
#      taxonomic_info[1,] <- 'NOT FOUND'

#    } else {
#      results_to_process <- second_try
#    }

#  } else {
#    results_to_process <- query_results
#  }

  # this is the end of the process, return empty results without error, or real results
#  if (exists('taxonomic_info')) {
#    return(cbind(query = q, taxonomic_info))
#  } else {
#    taxonomic_info <- result_grabber(results_to_process)
#    return(cbind(query = q, taxonomic_info))
#  }
}


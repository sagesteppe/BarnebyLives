#' query plants of the world online for taxonomic information
#'
#' @description a wrapper for kewr::search_powo
#' @param x a vector of species names to submit, these should have clean spelling
#' notes: results are observed to fail for valid infraspecies on Kew's end, and they seem not
#' to mention valid infraspecies.
#' @examples
#' library(dplyr)
#' pow_results <- lapply(
#'       c('Linnaea borealis var. borealis', 'Linnaea borealis var. americana',
#'       'Astragalus purshii', 'Pinus ponderosa'),
#'       powo_searcher) |>
#'    dplyr::bind_rows()
#' head(pow_results)
#' @export
powo_searcher <- function(x) {
  x <- trimws(gsub("\\s+", " ", x))
  query_results <- kewr::search_powo(x)

  if (is.null(query_results[["results"]])) {
    second_try <- try_again(query_results)

    if (is.null(second_try[["results"]])) {
      taxonomic_info <- data.frame(
        family = as.character(),
        name_authority = as.character(),
        full_name = as.character(),
        binom_authority = as.character(),
        genus = as.character(),
        epithet = as.character(),
        infrarank = as.character(),
        infraspecies = as.character(),
        infra_authority = as.character()
      )
      taxonomic_info[1, ] <- 'NOT FOUND'
    } else {
      results_to_process <- second_try
    }
  } else {
    results_to_process <- query_results
  }

  # this is the end of the process, return empty results without error, or real results
  if (exists('taxonomic_info')) {
    out_ob <- data.frame(cbind(query = x, taxonomic_info))
  } else {
    taxonomic_info <- result_grabber(results_to_process)
    out_ob <- data.frame(cbind(query = x, taxonomic_info))
  }

  new_names <- paste0('POW', '_', stringr::str_to_sentence(colnames(out_ob)))
  colnames(out_ob) <- new_names

  out_ob
}

#' try to download from Kew again, with just the binomial
#'
#' @description several infra species fail from POWO, retry the query with just the base name. This not accessed directly by the user but used inside 'powo_searcher'
#' @param x output from the first step of 'powo_searcher'
#' @keywords internal
#' @export
try_again <- function(x){
  q <- x[['query']]
  only_binomial <- unlist(stringr::str_split(q, pattern = " "))
  only_binomial <- paste(only_binomial[1], only_binomial[2])

  results <- kewr::search_powo(only_binomial)
  return(results)
}

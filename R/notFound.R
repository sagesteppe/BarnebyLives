#' notify user if an entry had any results not found in POWO
#'
#' @description simple function to run on 'powo_searcher' results to show species not found which
#' @param x output of 'powo_searcher' after binding rows
#' @param returns messages to consoles indicating search terms, and there status if failed to be found. This desirable because 'powo_searcher' squashes these errors.
#' @example  names_vec <- taxize::names_list(rank = 'species', size = 10) # 10 random species from taxize, usually 1 or 2 species are not found in Plants of the world online
#' pow_results <- lapply(names_vec, powo_searcher) |>
#'   dplyr::bind_rows()
#' pow_results[,1:5] # if there is not a family which is 'NOT FOUND', reshuffle the random species from taxize.
#' notFound(pow_results) # little message.
#' @export
notFound <- function(x){

  library(crayon)
  row_no <- unlist( apply(FUN = grep, X = x, MARGIN = 2, pattern = 'NOT FOUND') )
  rows <- unique(row_no) # these rows had complications...
  not_found <- x[rows, 'query'] # these records were not found.

  recs <- cat(
    'The record: ' %+%
      blue$underline$bold(not_found) %+%
      blue$bold(' (row ') %+% blue$underline$bold(rows) %+% ') did not have all data retrieved.\n')

  message(recs)

}

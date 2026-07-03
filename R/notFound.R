#' notify user if an entry had any results not found in POWO
#'
#' @description \strong{[Deprecated]} simple function to run on 'powo_searcher' results to show species not found which.
#' This only has a purpose alongside \code{\link{powo_searcher}}, which is itself deprecated
#' because Kew's POWO search API now blocks this style of request. Use
#' \code{\link{wcvp_searcher}} instead (after setting up a local taxonomy backbone with
#' \code{\link{wcvp_update}} and \code{\link{TaxUnpack}}) and filter its output for
#' \code{POW_Status == 'not-found'}.
#' @param x output of 'powo_searcher' after binding rows
#' @returns messages to consoles indicating search terms, and there status if failed to be found. This desirable because 'powo_searcher' squashes these errors.
#' @examples
#' library(dplyr)
#' library(crayon)
#' \dontrun{
#' names_vec <- data(names_vec)
#' # 10 random species from taxize, usually 1 or 2 species are not found in Plants of the world online
#' pow_results <- lapply(names_vec, powo_searcher) |>
#'   dplyr::bind_rows()
#' # pow_results[,1:5]
#' # if there is not a family which is 'NOT FOUND', reshuffle the random species from taxize.
#' notFound(pow_results) # little message.
#' }
#' @export
notFound <- function(x) {
  .Deprecated(
    new = "wcvp_searcher",
    package = "BarnebyLives",
    msg = "notFound() is deprecated: it only has a purpose alongside powo_searcher(), which can no longer reach Kew's POWO API (HTTP 403 from any client/origin). Use wcvp_searcher() instead and filter its output for POW_Status == 'not-found'."
  )
  row_no <- unlist(apply(FUN = grep, X = x, MARGIN = 2, pattern = 'NOT FOUND'))
  rows <- unique(row_no) # these rows had complications...
  not_found <- x[rows, 'query'] # these records were not found.

  message(
    'The record: ',
    not_found,
    ' (row ',
    rows,
    ') did not have all data retrieved.\n'
  )
}

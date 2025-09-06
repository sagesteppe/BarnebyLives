#' take mdy format date and make it written herbarium label format
#'
#' @description take the 'month day year' date format, popular in North America, and place it into a
#' museum compliant text format
#'
#' @param x a data frame with dates
#' @examples
#' first50dates <- paste0(sample(3:9, size = 10, replace = TRUE), '-',
#'    sample(1:29, size = 10, replace = TRUE), '-',
#'    rep(2023, times = 10)
#'  )
#' head(first50dates)
#' first50dates <- date2text(first50dates)
#' head(first50dates)
#' @export
date2text <- function(x) {
  x1 <- lubridate::mdy(x)

  text <- paste0(
    lubridate::day(x1), # just grab day of month here
    ' ',
    lubridate::month(x1, abbr = T, label = T), # grab the abbreviation for the month here
    ', ',
    lubridate::year(x1)
  ) # grab the year here
}

#' ASCII compliant degree symbol
#'
#' This function is required to pass R CMD CHECKS via generating an appropriately
#' encoded degree symbol in line.
#' @param x a value to add the symbol onto.
#' @param symbol, fixed here as the degree symbol
#' @examples format_degree(180)
format_degree <- function(x, symbol="\u00B0"){
  paste0(x, symbol) # @ dirk
}

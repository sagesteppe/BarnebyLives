#' write values and collapse NAs
#' 
#' This function will determine whether to print or hide a variable onto labels
#' @param x the input character of length 1
#' @param italics italicize or not? Boolean, defualts to FALSE
writer <- function(x, italics){
  if(missing(italics)){italics <- FALSE}
  if (is.na(x)){""} else if(italics == FALSE){x} else (paste0('*', x, '*'))
  }

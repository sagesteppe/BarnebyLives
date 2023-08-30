#' write values and collapse NAs
#'
#' This function will determine whether to print or hide a variable onto labels
#' @param x the input character of length 1
#' @param italics italicize or not? Boolean, defualts to FALSE
#' @examples
#' writer(collection_examples[9,'Binomial_authority'] )
#' writer(collection_examples[9, 'Infraspecies'], italics = TRUE )
#' @export
writer <- function(x, italics){
  x[x==""] <- NA
  if(missing(italics)){italics <- FALSE}
  if (is.na(x)){""} else if(italics == FALSE){x} else (paste0('*', x, '*'))
  }

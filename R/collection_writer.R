#' format collector info and codes
#'
#' Format these data to have commas or periods as appropriate
#' @param x dataframe holding the values
#' @example
#' data('collection_examples')
#' ce <- collection_examples[14,]
#' collection_writer(ce)
#' @export
collection_writer <- function(x){

  x$Associated_Collectors[x$Associated_Collectors==""] <- NA

  if (is.na(x$Associated_Collectors)){
    paste0(x$Primary_Collector, " ", x$Collection_number, '; ', x$Date_digital_text)
  } else {
    paste0(x$Primary_Collector, " ",  x$Collection_number, ', ',
                  x$Associated_Collectors, '; ', x$Date_digital_text)
           }
}


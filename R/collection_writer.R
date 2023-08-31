#' format collector info and codes
#'
#' Format these data to have commas or periods as appropriate
#' @param x dataframe holding the values
#' @export
collection_write <- function(x){

  x$Associated_Collectors[x$Associated_Collectors==""] <- NA

  if (is.na(x$Associated_Collectors)){
    paste0(data$Primary_Collector, data$Collection_number, ',', data$Date_digital_text, '.')
  } else {
    paste0(paste0(data$Primary_Collector, data$Collection_number ','
                  data$Associated_Collectors, ',', data$Date_digital_text, '.')}
}

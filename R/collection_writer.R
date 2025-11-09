#' format collector info and codes
#'
#' Format these data to have commas or periods as appropriate
#' @param x dataframe holding the values
#' @param date Boolean, default TRUE. Whether to write the collection date.
#' @examples
#' data('collection_examples')
#' ce <- collection_examples[12,]
#' collection_writer(ce)
#' collection_writer(ce, date = FALSE)
#' collection_writer(collection_examples[106,])
#' @export
collection_writer <- function(x, date = TRUE) {

  x[["Associated_Collectors"]] <- replace(
    x[["Associated_Collectors"]],
    x[["Associated_Collectors"]] == "",
    NA
    )

  primary_info <-
    paste0(
      x[['Primary_Collector']],
      " ",
      x[['Collection_number']]
    )

  collectors_info <- if (anyNA(x[["Associated_Collectors"]])) {
    ""
  } else {
    paste0(", ", x[["Associated_Collectors"]])
  }

  date_info <- if (date) {
    paste0("; ", x[["Date_digital_text"]])
  } else {
    ""
  }

  paste0(primary_info, collectors_info, date_info)

}

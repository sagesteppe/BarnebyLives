#' remove collection from associated species
#'
#' this function removes the collected species from the list of associated
#' species
#' @param x a dataframe containing collection info
#' @example
#'
#' out <- associate_dropper(collection_examples) |>
#'  dplyr::select(Full_name, Associates)
#' @export
associate_dropper <- function(x){

  x <- x |>
    dplyr::rowwise() |>
    dplyr::mutate(
      Associates = gsub(paste0(Full_name), "", Associates),
      Associates = trimws(gsub("\\s+", " ", Associates)),
      Associates = gsub(",$", "", Associates),
      Associates = gsub("^, ", "", Associates),
      Associates = gsub(", ,", ",", Associates),
      Associates = gsub(", ,", ",", Associates)
    )

  return(x)
}

#' remove collection from associated species
#'
#' this function removes the collected species from the list of associated
#' species
#' @param x a data frame containing collection info
#' @param Binomial a column containing the name of the collection, without authorship.
#' @examples
#' out <- associate_dropper(collection_examples, Binomial = 'Full_name') |>
#'  dplyr::select(Full_name, Associates)
#' @export
associate_dropper <- function(x, Binomial){

  if(missing(Binomial)){Binomial <- 'Full_name' ;
    message(crayon::yellow('Argument to `Binomial` not supplied, defaulting to `Full_name`'))}

  x <- x |>
    dplyr::rowwise() |>
    dplyr::mutate(
      Associates = gsub(paste0(Binomial), "", Associates),
      Associates = trimws(gsub("\\s+", " ", Associates)),
      Associates = gsub(",$", "", Associates),
      Associates = gsub("^, ", "", Associates),
      Associates = gsub(", ,", ",", Associates),
      Associates = gsub(",([A-Za-z])", ", \\1", Associates)
    ) |>
    dplyr::mutate(
      Vegetation = gsub(paste0(Binomial), "", Vegetation),
      Vegetation = trimws(gsub("\\s+", " ", Vegetation)),
      Vegetation = gsub(",$", "", Vegetation),
      Vegetation = gsub("^, ", "", Vegetation),
      Vegetation = gsub(", ,", ",", Vegetation),
      Vegetation = gsub(",([A-Za-z])", ", \\1", Vegetation)
    )


  return(x)
}

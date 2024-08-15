#' remove collection from associated species
#'
#' this function removes the collected species from the list of associated
#' species
#' @param x a data frame containing collection info
#' @param Binomial a column containing the name of the collection, without authorship.
#' @param col
#' @examples
#' out <- associate_dropper(collection_examples, Binomial = 'Full_name') |>
#'  dplyr::select(Full_name, Associates)
#' @export
associate_dropper <- function(x, Binomial, col){

  if(missing(Binomial)){Binomial <- 'Full_name' ;
    message(crayon::yellow('Argument to `Binomial` not supplied, defaulting to `Full_name`'))}

  x[,col] <- gsub(paste0(x[,Binomial]), "", x[,col])
  x[,col] <- trimws(gsub("\\s+", " ", x[,col]))
  x[,col] <- gsub(",$", "", x[,col])
  x[,col] <- gsub("^, ", "", x[,col])
  x[,col] <- gsub(", ,", ",", x[,col])
  x[,col] <- gsub(",([A-Za-z])", ", \\1", x[,col])

  return(x)
}

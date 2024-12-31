#' remove collection from associated species
#'
#' @description Removes the collected species from the list of associated species
#' @param x data frame containing collection info
#' @param Binomial Character. a column containing the name of the collection, without authorship.
#' Defaults to 'Full_name'.
#' @param col Character. the column with the species to be checked
#' @examples
#' ce <- data.frame(
#' Full_name = c(
#'   'Microseris gracilis', 'Alyssum desertorum', 'Ceratocephala testiculata'),
#' Associates = rep(
#'    'Microseris gracilis, Lupinus lepidus, Alyssum desertorum, Ceratocephala testiculata',
#'  times = 3)
#' )
#'
#' associate_dropper(ce, col = 'Associates')
#' @export
associate_dropper <- function(x, Binomial, col){

  if(missing(Binomial)){Binomial <- 'Full_name' ;
    message(crayon::yellow('Argument to `Binomial` not supplied, defaulting to `Full_name`'))}

  remove <- function(x, Binomial, col){

    x[col] <- gsub(x[Binomial], "", x[col])
    x[col] <- trimws(gsub("\\s+", " ", x[col]))
    x[col] <- gsub(",$", "", x[col])
    x[col] <- gsub("^, ", "", x[col])
    x[col] <- gsub(", ,", ",", x[col])
    x[col] <- gsub(",([A-Za-z])", ", \\1", x[col])
  }
  res <- apply(X = x, FUN = remove, MARGIN = 1, Binomial, col)
  x[,col] <- res
  x
}

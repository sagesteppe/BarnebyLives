#' do or don't write the associated plant species
#'
#' This functions determines whether to write information on associated plant
#' species. It used as a final step when formatting labels.
#' @param x data frame holding the values
#' @param full Boolean. If TRUE, write "Associates" if FALSE (the default), write
#' "Ass.:".
#' @examples
#' library(BarnebyLives)
#' hilaria <- collection_examples[73,]
#' associates_writer(hilaria$Vegetation)
#' agoseris <- collection_examples[82,]
#' associates_writer(agoseris$Associates)
#' @export
associates_writer <- function(x, full = FALSE){

  x[x==""] <- NA ; x[x==" "] <- NA

  if (is.na(x)){""} else {

    if(full==FALSE){
      gsub("..", ".", paste0('Ass.: ', species_font(x)), fixed = TRUE)
    } else {
      gsub("..", ".", paste0('Associates: ', species_font(x)), fixed = TRUE)
      }
    }
}

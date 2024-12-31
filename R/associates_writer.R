#' do or don't write the associated plant species
#'
#' This functions determines whether to write information on associated plant
#' species. It used as a final step when formatting labels.
#' @param x data frame holding the values
#' @examples
#' library(BarnebyLives)
#' hilaria <- collection_examples[73,]
#' associates_writer(hilaria$Vegetation)
#' agoseris <- collection_examples[82,]
#' associates_writer(agoseris$Associates)
#' @export
associates_writer <- function(x){

  x[x==""] <- NA

  if (is.na(x)){""} else {
    gsub("..", ".", paste0('Ass.: ', species_font(x)), fixed = TRUE)}

}

#' ensure proper italicization of a associated species
#'
#' This function works at the time of label creation to ensure that abbreviations
#' such as 'species' 'variety' and such are not italicizded, per convention.
#' @param x a value being feed into the label during the merge
#' @examples
#' associates <- c('Eriogonum ovalifolium var. purpureum, Castilleja sp., Crepis spp.')
#' species_font(associates)
#' @export
species_font <- function(x){

  x <- paste0('*', x, '*')

  if(any(grep(' sp..| s.p[.]| var. | subsp. ', x)) == TRUE){
    x <- gsub(' sp[.], ', '* sp., *', x)
    x <- gsub(' sp[.]\\*$', '* sp.', x)
    x <- gsub(' spp[.]\\*$', '* spp.', x)
    x <- gsub(' spp[.], ', '* spp., *', x)

    # infraspecies will always have a space before and after - WORKING
    x <- gsub(' ssp[.] ', '* ssp. *', x)
    x <- gsub(' ssp[.]\\*$', '* ssp.', x)
    x <- gsub(' var[.] ', '* var. *', x)
    x <- gsub(' subsp[.] ', '* spp. *', x)

    x <- gsub('  ', ' ', x)
    x <- paste0(x, '.')
    x <- gsub("..", ".", x, fixed = TRUE)
    return(x)
  }

  x <- gsub('  ', ' ', x)
  x <- paste0(x, '.')
  x <- gsub("..", ".", x, fixed = TRUE)
  return(x)
}

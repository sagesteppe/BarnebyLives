#' ensure proper italicization of a associated species
#'
#' This function works at the time of label creation to ensure that abbreviations
#' such as 'species' 'variety' and such are not italicized, per convention.
#' @param x a value being feed into the label during the merge
#' @examples
#' associates <- c('Eriogonum ovalifolium var. purpureum, Castilleja sp., Crepis spp.')
#' species_font(associates)
#' @export
species_font <- function(x){
  # Start by italicizing everything
  x <- paste0('\\textit{', x, '}')

  # Check if any abbreviations are present
  if(any(grepl(' sp\\.| spp\\.| var\\. | subsp\\. | ssp\\.', x))){
    # Handle sp. in middle of string (followed by comma and space)
    x <- gsub(' sp\\., ', '} sp., \\\\textit{', x)
    # Handle sp. at end of string (remove the trailing })
    x <- gsub(' sp\\.}$', '} sp.', x)

    # Handle spp. in middle of string (followed by comma and space)
    x <- gsub(' spp\\., ', '} spp., \\\\textit{', x)
    # Handle spp. at end of string (remove the trailing })
    x <- gsub(' spp\\.}$', '} spp.', x)

    # Handle subspecies abbreviations (always have space before and after, or at end)
    x <- gsub(' ssp\\. ', '} ssp. \\\\textit{', x)
    x <- gsub(' ssp\\.}$', '} ssp.', x)

    # Handle variety (always has space before and after)
    x <- gsub(' var\\. ', '} var. \\\\textit{', x)

    # Handle subspecies (convert to ssp. and remove trailing })
    x <- gsub(' subsp\\. ', '} ssp. \\\\textit{', x)
    x <- gsub(' subsp\\.}$', '} ssp.', x)
  }

  # Clean up any double spaces
  x <- gsub('  +', ' ', x)

  # Add final period if not present
  if(!grepl('\\.$', x)){
    x <- paste0(x, '.')
  }

  # Clean up any double periods
  x <- gsub('\\.+', '.', x)

  return(x)
}

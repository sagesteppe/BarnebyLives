#' Format associated species, and spell check them internally
#'
#' Apply proper capitalization to the species, and spell check all components.
#' @param x a data frame containing collection info
#' @param column a column containing the family information
#' @param path a path to a folder containing the taxonomic data.
#' @examples
#' \dontrun{
#'df <- data.frame(
#'  Family = c('Apiacace', 'Apiaceae', 'Ongraceae', 'Syperaceae', 'Poacaceae')
#' )
#' p2tax <- '/media/steppe/hdd/Barneby_Lives-dev/taxonomic_data'
#' associates_spell_check.R(x = df, column = 'Family', p2tax)
#' }
#' @export
associates_spell_check <- function(x, column, path){

  if(missing(column)){column <- 'Associates' ;
    message(crayon::yellow('Argument to `column` not supplied, defaulting to `Associates`'))}

  # remove notation of '.sp' and simply search that the genus is spelled correctly.
  # we'll simply add 'sp.' to any single piece returned by the fn.
  associates <- dplyr::pull(x, column)

  associates <- trimws(associates)

  # import look up table
  sppLKPtab <- read.csv(file.path(path, 'species_lookup_table.csv'))
  infra_sppLKPtab <- read.csv(file.path(path, 'infra_species_lookup_table.csv')) |>
    dplyr::mutate(gGRP = substr(genus, 1, 2))
  genLKPtab <- dplyr::distinct(sppLKPtab, genus, .keep_all = TRUE)

  # now perform a simple spell check on each item.

  for (y in seq_along(associates)){

    # separate each name into an element of a vector
    names2search <- unlist(stringr::str_split(associates[[y]], pattern = ","))
    names2search <- trimws(names2search)

    for (i in seq_along(names2search)){

      L = lengths(strsplit(names2search[i], " "))

      if(L == 1){ # genus search

        if(is.na(names2search[[i]])){names2search[[i]] <- names2search} else {

          genLKPsub <- genLKPtab[
            grepl(substr(names2search[[i]], 1, 2), genLKPtab$gGRP, ignore.case = TRUE),]
          names2search[[i]] <- paste(genLKPsub[
            which.min(
              stringdist::stringdist(names2search[[i]], genLKPsub$genus, method = 'jw')), 'genus'], 'sp.')
        }

      } else if(L == 2){ # species search

        sppLKPsub <- sppLKPtab[
          grepl(substr(names2search[[i]], 1, 2), sppLKPtab$gGRP, ignore.case = TRUE),]
       names2search[[i]] <- sppLKPsub[
          which.min(
           stringdist::stringdist(names2search[[i]], sppLKPsub$taxon_name, method = 'jw')), 'taxon_name']

        } else if(L == 4) { # infra species search

          infra_sppLKPsub <- dplyr::filter(infra_sppLKPtab, gGRP == substr(names2search[[i]], 1, 2))
          names2search[[i]] <- infra_sppLKPsub[
            which.min(
              stringdist::stringdist(names2search[[i]], infra_sppLKPsub$taxon_name, method = 'jw')), 'taxon_name']

          }
    }
    associates[[y]] <- paste(names2search, collapse = ', ')
  }

  spellck <- setNames(data.frame(associates), paste0('SpellCk.', column))
  out <- dplyr::bind_cols(x, spellck)
  return(out)
}

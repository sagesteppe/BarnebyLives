#' check that genera and specific epithets are spelled (almost) correctly
#'
#' @description this function attempts to verify the spelling of a user submitted taxonomic name. If necessary it will proceed step-wise by name pieces attempting to place them.
#' @param x a vector of species names
#' @param path a path to a folder containing the taxonomic data.
#' @examples
#' \dontrun{
#' names_vec <- c('Astagalus purshii', 'Linnaeus borealius', 'Heliumorus multifora')
#' spelling <- spell_check(names_vec, path = '../taxonomic_data')
#' spelling
#' }
#' @export
spell_check <- function(x, path){

  sppLKPtab <- read.csv(file.path(path, 'species_lookup_table.csv'))
  epiLKPtab <- read.csv(file.path(path, 'epithet_lookup_table.csv'))
  genLKPtab <- read.csv(file.path(path, 'genus_lookup_table.csv'))

  pieces <- unlist(stringr::str_split(x, pattern = " "))
  genus <- pieces[1] ; species <- pieces[2]
  binom <- paste(genus, species)

  # infra species should be found without much hassle due to their length
  if(length(pieces) == 4){
    infras <- na.omit(epiLKPtab)
    full_name <- paste(genus, species,
                       stringr::str_replace(pieces[3], 'ssp\\.|ssp', 'subsp.'), pieces[4])

    if (any(grep( x = infras$scientificName, pattern = full_name, fixed = T))) {
      return(data.frame(Query = x, Result = full_name, Match = 'exact'))
    } else {

      infras <- na.omit(epiLKPtab)
      full_name <- paste(genus, species,
                         stringr::str_replace(pieces[3], 'ssp\\.|ssp', 'subsp.'), pieces[4])
      infraspecies_name <-
        infras[which.min(adist(full_name, infras$scientificName)), 'scientificName'] |> as.character()
      return(data.frame(Query = x, Result = infraspecies_name, Match = 'fuzzy'))
    }

  # species can become difficult due to their short  names, e.g. 'Poa annua'
  } else {

    if (any(grep( x = sppLKPtab$scientificName, pattern = binom, fixed = T))) {
      return(data.frame(Query = x, Result = x, Match = 'exact'))
    } else{
      # try and determine which piece is incorrect.

      # subset datasets to query each name component separately
      genus2char <- stringr::str_extract(genus, '[A-Z][a-z]{1}')
      species3char <- stringr::str_extract(species, '[a-z]{3}')
      gen_strings <-
        dplyr::filter(genLKPtab, .data$Grp == genus2char) |> dplyr::pull(strings)
      spe_strings <-
        dplyr::filter(sppLKPtab, .data$Grp == species3char) |> dplyr::pull(strings)

      # check to see if both genus and species are clean
      if (any(grep(x = gen_strings, pattern = paste0('^', genus, '$')))) {
        clean_genus_Tag <- genus
      } else {
        possible_genus_Tag <-
          gen_strings[which.min(adist(genus, gen_strings))]
      }

      # is species clean
      if (any(grep(x = spe_strings, pattern = paste0('^', species, '$')))) {
        clean_species_Tag <- species
      } else {
        possible_species_Tag <-
          spe_strings[which.min(adist(species, spe_strings))]
      }

      # if both the genus and species name are present, we could be missing it from the DB
      if (exists('clean_genus_Tag') & exists ('clean_species_Tag'))
      {
        return(data.frame(
          Query = x, Result = binom, Match = 'Suspected missing from ref DB'))
      } else { # if one is not clean search them with the 'cleaned' up versions
        combos <- ls()[grep(ls(), pattern = 'Tag')]
        search_q <-
          combos[c(grep(combos, pattern = 'genus'),
                   grep(combos, pattern = 'species'))]
        search_nom <- paste(unlist(mget(search_q)), collapse = " ")

        if (any(grep(x = epiLKPtab$scientificName, pattern = search_nom, fixed = T))) {

          return(data.frame(Query = x, Result = search_nom, Match = 'fuzzy'))

        } else{
          possible_binomial <-
            epiLKPtab[which.min(adist(search_nom, epiLKPtab$scientificName)), 'scientificName'] |>
              as.character()
          return(data.frame(Query = x, Binomial = possible_binomial, Match = 'fuzzy'))
        }
      }
    }
  }
}

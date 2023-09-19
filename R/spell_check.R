#' check that genera and specific epithets are spelled (almost) correctly
#'
#' @description this function attempts to verify the spelling of a user submitted taxonomic name. If necessary it will proceed step-wise by name pieces attempting to place them.
#' @param x data frame/ tibble /sf object containing names to spell check
#' @param full_name a column containing the full name, genus, species, and infraspecific rank information as relevant.
#' @param path a path to a folder containing the taxonomic data.
#' @examples
#' \dontrun{
#' names <- data.frame(
#'  Full_name = c('Astagalus purshii', 'Linnaeus borealius ssp. borealis', 'Heliumorus multifora', NA, 'Helianthus annuus'),
#'  Genus = c('Astagalus', 'Linnaeus', 'Heliumorus', NA, 'Helianthus'),
#'  Epithet = c('purshii', 'borealius', 'multifora', NA, 'annuus'))
#' names_l <- split(names, f = 1:nrow(names))
#' r <- lapply(names_l, spell_check, column = 'Full_name', path = p2tax)
#' }
#' @export
spell_check <- function(x, column, path) {

  sppLKPtab <- read.csv(file.path(path, 'species_lookup_table.csv'))
  infra_sppLKPtab <- read.csv(file.path(path, 'infra_species_lookup_table.csv'))
  genLKPtab <- read.csv(file.path(path, 'genus_lookup_table.csv'))
  epiLKPtab <- read.csv(file.path(path, 'epithet_lookup_table.csv'))

  sc <- function(x, column){

    pieces <- unlist(stringr::str_split(x[,column], pattern = " "))
    genus <- pieces[1] ; species <- pieces[2]
    binom <- paste(genus, species)
    rownames(x) <- FALSE

    # infra species should be found without much hassle due to their length
    if(length(pieces) == 4){
      full_name <- paste(genus, species,
                         stringr::str_replace(pieces[3], 'ssp\\.|ssp', 'subsp.'), pieces[4])

      pos <- grep( x = infra_sppLKPtab$scientificName, pattern = full_name, fixed = T)
      if(length(pos)==1) {
        infraspecies_name <- infra_sppLKPtab[pos,]
        infraspecies_name <- infraspecies_name[1,]
        return(data.frame(x, SpellCk = infraspecies_name, Match = 'exact'))
      } else {
        infraspecies_name <-
          infra_sppLKPtab[which.min(adist(full_name, infra_sppLKPtab$scientificName)),]
        infraspecies_name <- infraspecies_name[1,]
        return(data.frame(x, SpellCk = infraspecies_name, Match = 'fuzzy'))
      }

      # species can become difficult due to their short  names, e.g. 'Poa annua'
    } else {

      pos <- grep( x = sppLKPtab$scientificName, pattern = binom, fixed = T)
      if (length(pos) == 4) {
        species_name <- sppLKPtab[pos,]
        species_name <- species_name[1,]
        return(data.frame(x, SpellCk = species_name, Match = 'exact'))
      } else {
        # try and determine which piece is incorrect.

        # subset data sets to query each name component separately
        genus2char <- stringr::str_extract(genus, '[A-Z][a-z]{1}')
        species3char <- stringr::str_extract(species, '[a-z]{3}')
        gen_strings <-
          dplyr::filter(genLKPtab, Grp == genus2char) |> dplyr::pull(strings)
        spe_strings <-
          dplyr::filter(epiLKPtab, Grp == species3char) |> dplyr::pull(strings)

        # check to see if both genus and species are clean
        if (any(grep(x = gen_strings, pattern = paste0('^', genus, '$')))) {
          clean_genus_Tag <- genus
        } else {
          possible_genus_Tag <-
            gen_strings[which.min(adist(genus, gen_strings))]
        }

        # is species clean ?
        if (any(grep(x = spe_strings, pattern = paste0('^', species, '$')))) {
          clean_species_Tag <- species
        } else {
          possible_species_Tag <-
            spe_strings[which.min(adist(species, spe_strings))]
        }

        # if both the genus and species name are present, we could be missing it from the DB
        if (exists('clean_genus_Tag') & exists ('clean_species_Tag'))
        {
          return(data.frame(x, Match = 'Suspected missing from ref DB'))
        } else { # if one name is not clean search them with the 'cleaned' up versions
          combos <- ls()[grep(ls(), pattern = 'Tag')]
          search_q <-
            combos[c(grep(combos, pattern = 'genus'),
                     grep(combos, pattern = 'species'))]
          search_nom <- paste(unlist(mget(search_q)), collapse = " ")

          pos <- grep(x = sppLKPtab$scientificName, pattern = search_nom, fixed = T)
          if (length(pos) == 1) {
            species_name <- sppLKPtab[pos,]
            species_name <- species_name[1,]
            return(data.frame(x, SpellCk = species_name, Match = 'fuzzy'))

          } else {
            possible_binomial <-
              sppLKPtab[which.min(adist(search_nom, sppLKPtab$scientificName)),]
            return(data.frame(x, SpellCk = possible_binomial, Match = 'fuzzy'))
          }
        }
      }
    }
  }
  data_l <- split(x, f = 1:nrow(x))
  sc_res <- lapply(data_l, sc, column = column)
  sc_res <- data.table::rbindlist(sc_res, fill = TRUE) |>
    dplyr::select(-any_of('SpellCk.Grp')) |>
    dplyr::rename(SpellCk_Infraspecific_rank = SpellCk.verbatimTaxonRank)
  return(sc_res)
}

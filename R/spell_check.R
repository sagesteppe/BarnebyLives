#' check that genera and specific epithets are spelled (almost) correctly
#'
#' @description this function attempts to verify the spelling of a user submitted taxonomic name. If necessary it will proceed step-wise by name pieces attempting to place them.
#' @param data data frame/ tibble /sf object containing names to spell check
#' @param column a column containing the full name, genus, species, and infraspecific rank information as relevant.
#' @param path a path to a folder containing the taxonomic data.
#' @examples
#' \dontrun{
#' names <- data.frame(
#'  Full_name = c('Astagalus purshii', 'Linnaeus borealius ssp. borealis',
#'   'Heliumorus multifora', NA, 'Helianthus annuus'),
#'  Genus = c('Astagalus', 'Linnaeus', 'Heliumorus', NA, 'Helianthus'),
#'  Epithet = c('purshii', 'borealius', 'multifora', NA, 'annuus'))
#' names_l <- split(names, f = 1:nrow(names))
#' r <- lapply(names_l, spell_check, column = 'Full_name', path = p2tax)
#' }
#' @export
spell_check <- function(data, column, path) {
  sppLKPtab <- read.csv(file.path(path, 'species_lookup_table.csv'))
  infra_sppLKPtab <- read.csv(file.path(path, 'infra_species_lookup_table.csv'))

  sc <- function(x, column) {
    pieces <- unlist(stringr::str_split(x[, column], pattern = " "))
    genus <- pieces[1]
    species <- pieces[2]
    binom <- paste(genus, species)
    rownames(x) <- FALSE

    # infra species should be found without much hassle due to their length
    if (length(pieces) == 4) {
      full_name <- paste(
        genus,
        species,
        stringr::str_replace(pieces[3], 'ssp\\.|ssp', 'subsp.'),
        pieces[4]
      )

      pos <- grep(
        x = infra_sppLKPtab$taxon_name,
        pattern = full_name,
        fixed = T
      )
      if (length(pos) == 1) {
        infraspecies_name <- infra_sppLKPtab[pos, ]
        infraspecies_name <- infraspecies_name[1, ]
        data.frame(x, SpellCk = infraspecies_name, Match = 'exact')
      } else {
        # run a search if an exact match is not found.
        infraspecies_name <-
          infra_sppLKPtab[
            which.min(
              stringdist::stringdist(
                full_name,
                infra_sppLKPtab$taxon_name,
                method = 'jw'
              )
            ),
          ]
        infraspecies_name <- infraspecies_name[1, ]

        data.frame(x, SpellCk = infraspecies_name, Match = 'fuzzy')
      }
    } else {
      # search for the species epithet down here.

      # try for the exact match of the species name.
      pos <- grep(x = sppLKPtab$taxon_name, pattern = binom, fixed = T)
      if (length(pos) == 1) {
        species_name <- sppLKPtab[pos, ]
        species_name <- species_name[1, ]
        data.frame(x, SpellCk = species_name, Match = 'exact')
      } else {
        # if we were not able to to get an exact match, we will now try jw distance
        # but only testing against a subset of species which have a genus starting
        # with the same first two letters as the search query.

        sppLKP_l <- sppLKPtab[
          sppLKPtab$gGRP == stringr::str_extract(genus, '[A-Z]{1}[a-z]{1}'),
        ]

        if (nrow(sppLKP_l) == 0) {
          data.frame(x, SpellCk = binom, Match = 'not-performed')
        } else {
          species_name <-
            sppLKP_l[
              which.min(
                stringdist::stringdist(
                  binom,
                  sppLKP_l$taxon_name,
                  method = 'jw'
                )
              ),
            ]
          data.frame(x, SpellCk = species_name, Match = 'fuzzy')
        }
      }
    }
  }

  if (any(class(data) == 'sf')) {
    # drop geometry column to pull vectors out
    geometry_col <- dplyr::select(data, geometry)
    x <- sf::st_drop_geometry(data) |>
      data.frame()
  } else {
    x <- data
  }

  data_l <- split(x, f = seq_len(nrow(x)))
  sc_res <- lapply(data_l, sc, column = column)

  rn <- c(SpellCk_Infraspecific_rank = 'SpellCk.verbatimTaxonRank')
  sc_res <- data.table::rbindlist(sc_res, fill = TRUE) |>
    dplyr::select(-dplyr::any_of(c('SpellCk.gGrp', 'SpellCk.Taxon.Rank'))) |>
    dplyr::rename(dplyr::any_of(rn))

  if (any(class(data) == 'sf')) {
    sc_res <- dplyr::bind_cols(sc_res, geometry_col) |>
      sf::st_as_sf()
  }
}
#' check that family is spelledcorrectly.
#'
#' @description this function attempts to verify the spelling of a user submitted taxonomic name.
#' @param x data frame/ tibble /sf object containing names to spell check
#' @param path a path to a folder containing the taxonomic data.
#' @examples
#' \dontrun{
#' names <- data.frame(
#'  Collection_number = 1:3,
#'  Family = c('Asteracea', 'Flabaceae', 'Onnagraceae')
#' )
#' spelling <- family_spell_check(names, path = '../taxonomic_data')
#'}
#' @export
family_spell_check <- function(x, path) {
  closest_name <- function(x) {
    if (is.na(x)) {
      out <- data.frame(Family = NA)
    } else {
      out <- famLKPtab[which.min(adist(x, famLKPtab$Family)), 'Family']
    }
    out
  }

  famLKPtab <- read.csv(file.path(path, 'families_lookup_table.csv')) |>
    dplyr::mutate(SPELLING = TRUE)
  families <- dplyr::left_join(x, famLKPtab, by = 'Family')

  correct_families <- families[!is.na(families$SPELLING), ]
  incorrect_families <- families[is.na(families$SPELLING), ]

  searchF <- sf::st_drop_geometry(incorrect_families) |>
    dplyr::pull(Family)

  if (nrow(incorrect_families) > 0) {
    incorrect_families$Family = unlist(sapply(searchF, closest_name))
    out <-
      dplyr::bind_rows(incorrect_families, correct_families) |>
      dplyr::select(-SPELLING) |>
      dplyr::arrange(Collection_number)
    out
  } else {
    x
  }
}

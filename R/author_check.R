#' Check spelling of botanical author abbreviations
#'
#' Determine whether the spelling of a botanical author abbreviation matches
#' one in the IPNI index. This function will not seek a correct spelling, but rather
#' only flag spellings which are not present in the abbreviations section
#' of the IPNI database
#' @param x an sf/dataframe/tibble of species identities including an Authority column
#' @param path a path to the directory containing the abbrevation data
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   Genus = c('Lomatium', 'Linnaea', 'Angelica', 'Mentzelia', 'Castilleja'),
#'   Epithet = c('dissectum', 'borealis', 'capitellata', 'albicaulis', 'pilosa'),
#'   Binomial_authority = c('(Pursh) J.M. Coult & Rose', 'L.',
#'                          '(A. Gray) Spalik, Reduron & S.R.Downie',
#'                          '(Douglas ex Hook.) Douglas ex Torr. & A. Gray', NA),
#'   Infrarank = c(NA, 'var.', NA, NA, 'var.'),
#'   Infraspecies	=c(NA, 'americana', NA, NA, 'pilosa'),
#'   Infraspecific_authority = c(NA, '(J. Forbes) Rehder', NA, NA, '(S. Watson) Rydb.')
#'   )
#' head(df)
#' author_check(df, path = '/hdd/Barneby_Lives-dev/taxonomic_data')
#' # we know that the proper abbreviation is 'J.M. Coult.' short for 'Coulter'
#' # and 'S.R. Downie' is more human readable than 'S.R.Downie' (no space)
#' }
#' @export
author_check <- function(x, path) {
  auth_check <- function(x) {
    # identify pieces which are not in the look up list.
    L <- length(x)
    matched <- vector(mode = 'logical', length = L)
    if (all(is.na(x))) {
      Issues = NA
    } else {
      for (i in 1:L) {
        if (any(abbrevs == x[i])) {
          matched[i] <- TRUE
        } else {
          matched[i] <- FALSE
        }
      }

      # create column 'Issues'; to flag specific names
      if (any(matched == FALSE)) {
        Issues <- paste(x[which(matched == FALSE)], '-? ', collapse = '')
      } else {
        Issues <- NA
      }
    }
    return(Issues)
  }

  # load abbreviations
  abbrevs <- read.csv(file.path(path, 'ipni_author_abbreviations.csv'))$x

  # identify columns containing authority information
  binom_auth <- colnames(x)[grep('binom.*author', colnames(x), ignore.case = T)]
  infra_auth <- colnames(x)[grep(
    'infraspecific.*author',
    colnames(x),
    ignore.case = T
  )]

  if (any(grepl('geometry', colnames(x)))) {
    no_spat <- sf::st_drop_geometry(x)
  } else {
    no_spat <- x
  }

  # there should always be at least two columns.
  auth <- dplyr::pull(no_spat, binom_auth)
  auth <- sub('\\(', "", auth)
  pieces <- strsplit(auth, split = '\\) | & |, | ex ')
  binom_results <- lapply(pieces, auth_check)

  auth <- dplyr::pull(no_spat, !!infra_auth)
  # infra species tends to be arranged down stream
  auth <- sub('\\(', "", auth)
  pieces <- strsplit(auth, split = '\\) | & |, | ex ')
  infra_results <- lapply(pieces, auth_check)

  Issues <- data.frame(
    Binomial_authority_issues = do.call(rbind, binom_results),
    Infra_auth_issues = do.call(rbind, infra_results)
  )

  Issues <- dplyr::bind_cols(x, Issues)

  Issues <- Issues |>
    dplyr::relocate(
      dplyr::any_of(c('Binomial_authority_issues')),
      .after = binom_auth
    ) |>
    dplyr::relocate(dplyr::any_of(c('Infra_auth_issues')), .after = infra_auth)

  return(Issues)
}

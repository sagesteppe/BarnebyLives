
#' Check spelling of botanical author abbreviations
#'
#' Determine whether the spelling of a botanical author abbreviation matches
#' one in the IPNI index. This function will not seek a correct spelling, but rather
#' only flag spellings which are not present in the abbreviations section
#' of the IPNI database
#' @param x an sf/dataframe/tibble of species identities including an Authoiry column
#' @examples
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
#' author_check(df) # we know that the proper abbreviation is 'J.M. Coult.' short for 'Coulter'
#' # and 'S.R. Downie' is human readable format
#' @export
#'
author_check <- function(x){

  auth_check <- function(x){
    # identify pieces which are not in the look up list.
    L <- length(x)
    matched <- vector(mode = 'logical', length = L)
    if(all(is.na(x))){Issues = 'None'} else {
      for(i in 1:L){
        if(any(abbrevs == x[i])) {
          matched[i] <- TRUE
        } else {
          matched[i] <- FALSE
        }
      }

      # create column 'Issues'; to flag specific names
      if(any(matched == FALSE)) {
        Issues <- paste(x[which(matched == FALSE)], '-? ', collapse = '')
      } else {
        Issues <- 'None'
      }
    }
    return(Issues)
  }

  # load abbreviations
  abbrevs <- read.csv('../data/abbrevs.csv')

  # identify columns containing authority information
  cols <- colnames(df)[grep('author', colnames(df), ignore.case = T)]

  # there should always be at least two columns.

  auth <- df[,cols[1]] # binomial should be first.
  auth <- sub('\\(', "", auth)
  pieces <- strsplit(auth, split = '\\) | & |, | ex ')
  binom_results <- lapply(pieces, auth_check)

  auth <- df[,cols[2]] # infra species tends to be arranged down stream
  auth <- sub('\\(', "", auth)
  pieces <- strsplit(auth, split = '\\) | & |, | ex ')
  infra_results <- lapply(pieces, auth_check)

  Issues <- data.frame(
    x,
    'Binomial_authority_issues' = do.call(rbind, binom_results),
    'Infra_auth_issues'= do.call(rbind, infra_results)
  )

  return(Issues)
}

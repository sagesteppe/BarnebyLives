#' Easily compare POW column to input columns
#'
#' pronounced 'pounce'.
#' After querying the POW database via 'powo_searcher' this function will mark
#' POW cells which are identical to the input (verified cleaned) as NA
#' ideally making it easier for person to process there results and prepare
#' there data for sharing via labels and digitally.
#' @param x an sf/data frame/tibble which has both the input and POW ran data on it
#' @examples
#' \dontrun{
#' df <- data.frame(
#'  POW_Genus = c('Castilleja', 'Linnaea', 'Dimeresia'),
#'  POW_Epithet = c('pilosa', 'borealis', 'howellii'),
#'  POW_Infrarank = c('var.', 'var.', NA),
#'  POW_Infraspecies =  c('pilosa', 'americana', NA),
#'  POW_Authority =  c('(S. Watson) Rydb.', '(J. Forbes) Rehder', 'A. Gray')
#' )
#' powNAce(df)
#' }
#' @export
powNAce <- function(x) {
  # four conditions are compared to determine which taxonomic level the authority
  # applies to
  infra_base <- function(x) {
    x$POW_Infraspecific_authority <- NA
    x$POW_Binomial_authority <- NA

    y <- x

    if (is.na(y$POW_Infrarank)) {
      y$POW_Binomial_authority <- y$POW_Authority
    } else if (y$POW_Infraspecies == y$POW_Epithet) {
      y$POW_Binomial_authority <- y$POW_Authority
    } else {
      y$POW_Infraspecific_authority <- y$POW_Authority
    }

    #  x$POW_Infraspecific_authority <- as.character(x$POW_Infraspecific_authority)
    #  x$POW_Binomial_authority <- as.character(x$POW_Binomial_authority)

    return(y)
  }

  # we need NA's to be explicitly treated
  compareNA <- function(v1, v2) {
    same <- (v1 == v2) | (is.na(v1) & is.na(v2))
    same[is.na(same)] <- FALSE
    return(same)
  } # @ BEN STACK O 16822426

  author_spacer <- function(x) {
    trailed <- vector(mode = 'character', length = length(x))
    trailed[grep('\\.$', x)] <- '.'

    abbrevs_spaced <- sub('\\.$', '', x) # remove the trailing periods
    abbrevs_notrail <- sub('\\.(?!.*\\.)', ". ", abbrevs_spaced, perl = T)
    # identify the last period in the name, and add a space after it

    abbrevs <- paste0(abbrevs_notrail, trailed)
    abbrevs <- gsub("  ", " ", abbrevs)
    abbrevs <- gsub(" \\)", ")", abbrevs)
    return(abbrevs)
  }

  mycs <- c(
    'Genus',
    'POW_Genus',
    'Epithet',
    'POW_Epithet',
    'Binomial_authority',
    'POW_Binomial_authority',
    'Infrarank',
    'POW_Infrarank',
    'Infraspecies',
    'POW_Infraspecies',
    'Infraspecific_authority',
    'POW_Infraspecific_authority',
    'Family',
    'POW_Family'
  )

  # identify whether the author is for the species or infra species

  x_pow <- sf::st_drop_geometry(x) |>
    dplyr::select(dplyr::any_of(c(mycs, 'POW_Authority', 'UNIQUEID'))) |>
    data.frame()

  splits <- split(x_pow, f = rownames(x_pow))
  x_pow <- lapply(X = splits, FUN = infra_base)
  x_pow <- do.call(rbind, x_pow)

  #ensure we have implemented a human readable spacing to our authors
  x_pow$POW_Binomial_authority <- author_spacer(x_pow$POW_Binomial_authority)
  x_pow$POW_Infraspecific_authority <- author_spacer(
    x_pow$POW_Infraspecific_authority
  )

  x_pow[
    compareNA(x_pow$POW_Name_authority, x_pow$Name_authority),
    'POW_Name_authority'
  ] <- NA
  x_pow[compareNA(x_pow$POW_Full_name, x_pow$Full_name), 'POW_Full_name'] <- NA
  x_pow[compareNA(x_pow$POW_Genus, x_pow$Genus), 'POW_Genus'] <- NA
  x_pow[compareNA(x_pow$POW_Epithet, x_pow$Epithet), 'POW_Epithet'] <- NA
  x_pow[compareNA(x_pow$POW_Infrarank, x_pow$Infrarank), 'POW_Infrarank'] <- NA
  x_pow[
    compareNA(x_pow$POW_Infraspecies, x_pow$Infraspecies),
    'POW_Infraspecies'
  ] <- NA
  x_pow[compareNA(x_pow$POW_Family, x_pow$Family), 'POW_Family'] <- NA
  x_pow[
    compareNA(x_pow$POW_Binomial_authority, x_pow$Binomial_authority),
    'POW_Binomial_authority'
  ] <- NA
  x_pow[
    compareNA(x_pow$POW_Infraspecific_authority, x_pow$Infraspecific_authority),
    'POW_Infraspecific_authority'
  ] <- NA

  x <- dplyr::select(
    x,
    -dplyr::any_of(c(mycs, 'POW_Authority', 'POW_Name_authority', 'POW_Full_name'))
  )
  x <- dplyr::left_join(x, x_pow, by = 'UNIQUEID')

  x <- dplyr::relocate(x, dplyr::any_of(c(mycs, 'POW_Query')), .after = 4) %>%
    dplyr::select(
      -dplyr::any_of(c('POW_Authority', 'POW_Name_authority', 'POW_Full_name'))
    )

  return(x)
}

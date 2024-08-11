#' split out a scientific input column to pieces
#'
#' This function attempts to split a scientific name into it's component pieces.
#' Given an input scientific, or scientific with scientific authorities and infraspecies
#' this function will parse them into the columns used in the BarnebyLives pipeline.
#' @param x a dataframe with collection information
#' @param sciName_col column containing the data to parse
#' @example
#' library(BarnebyLives)
#' ce <- collection_examples
#' ce <- data.frame(
#'   Collection_number = ce$Collection_number[sample(1:nrow(ce), size = 100, replace = F)],
#'   Binomial = c(ce$Full_name, ce$Name_authority)[sample(1:nrow(ce)*2, size = 100, replace = F)],
#'   Binomial_authority = ce$Binomial_authority[sample(1:nrow(ce), size = 100, replace = F)]
#' ) # extra columns to challenge name search - values are meaningless
#'
#' split_scientificName(ce)|> head()
#' split_scientificName(ce, sciName_col = 'Binomial') |> head()
#' @export
split_scientificName <- function(x, sciName_col, overwrite){

  if(missing(sciName_col)){  # search for non supplied column name
    indices <- grep('binomial', colnames(x), ignore.case=TRUE)

    if(length(indices) > 1){ # if more columns are found, try and find it an # authority column is the culprit
      indices <- indices[ grep('auth', colnames(x)[indices], invert = TRUE)]}
    if(length(indices) == 0){
      stop('unable to find name column, please supply argument to `sciName_col`')}
    if(length(indices) == 1){
      sciName_col <- colnames(x)[indices]
      cat('`sciName_col` argument not supplied, using:', colnames(x)[indices])
    }
  }
  if(missing(overwrite)){overwrite <- TRUE}

  # double spaces will mess with some of our sensitive regrexes below
  x[,sciName_col] <- unlist(lapply(x[,sciName_col], gsub, pattern = "\\s+", replacement =  " "))
  x[,sciName_col] <- unlist(lapply(x[,sciName_col], trimws))
  # we will proceed row wise, treating each record independently from the last
  # in case that there are missing values.

  to_split <- split(x[,sciName_col], f = 1:nrow(x))

  binomial <- function(x){ # recovery of the binomial, only the first two pieces of the name.
    pieces <- unlist(stringr::str_split(x, pattern = " "))
    Genus <- pieces[1]; Epithet <- pieces[2]
    Binomial = paste(Genus, Epithet)

    vars <- data.frame(cbind(Binomial, Genus, Epithet))

    return(vars)
  }

    binomials <- lapply(to_split, binomial) |>
    data.table::rbindlist()

  # We'll use these strings as the basis for all future work - it includes everything past the binomial
  remaining_info <- lapply(x[,sciName_col], sub, pattern = '\\w+\\s\\w+\\s', replacement =  "")

  # extract the binomial name and the authorities
  Binomial_authority <- lapply(x[,sciName_col], sub, pattern = "ssp[.].*|subsp[.].*|var[.].*", replacement =  "")
  Binomial_authority <- lapply(Binomial_authority, str_trim)[[1]]

  # extract the authority for the binomial name.
  Authority <- unlist(lapply(Binomial_authority, sub,
                             pattern = '\\w+\\s\\w+\\s', replacement =  ""))

  # extract the infra specific rank if it exists.
  Infraspecific_rank <- lapply(remaining_info, stringr::str_extract, "var.|subsp.|ssp.")[[1]]

  # Now extract the infra species name
  infra_info <- lapply(remaining_info, stringr::str_extract, "subsp[.] .*$|var[.] .*$|ssp[.] .*$")
  infra_pieces <- lapply(infra_info, stringr::str_split, pattern = " ")
  Infraspecies <- lapply(infra_pieces[[1]], '[', 2)

  # here extract the infra specific authors
  infra_authors <- lapply(infra_pieces[[1]], '[', 3:20)
  authors_part <- lapply(infra_authors, FUN = \(x) paste(x[!is.na(x)], collapse = " "))
  infra_auth_not_need <- lapply(infra_authors, \(x) all(is.na(x)))
  authors_part[infra_auth_not_need==TRUE] <- NA

  # return these data.
  output <- data.frame(
    x[,sciName_col],
    binomials,
    'Binomial_authority' = Binomial_authority,
    'Name_authority' = Authority,
    'Infraspecific_rank' = Infraspecific_rank,
    'Infraspecies' = unlist(Infraspecies),
    'Infraspecific_authority' = unlist(authors_part)
  )

  output <- data.frame (apply(output, MARGIN = 2, FUN = trimws))

  if(overwrite == TRUE){
    output <- output[ , !names(output) %in% sciName_col]
    cols2overwrite <- c('Binomial', 'Genus', 'Epithet', 'Binomial_authority', 'Name_authority',
                        'Infraspecific_rank', 'Infraspecies', 'Infraspecific_authority')
    in_out <- dplyr::select(x, -any_of(cols2overwrite))
    output <- dplyr::bind_cols(in_out, output)

    return(output)
  } else {return(output)}

}


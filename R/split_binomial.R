#' split out a binomial input column to pieces
#'
#' This function attempts to split a scientific name into it's component pieces.
#' Given an input binomial, or binomial with scientific authorities and infraspecies
#' this function will parse them into the columns used in the BarnebyLives pipeline.
#' @param x a dataframe with collection information
#' @param binomial_col column containing the data to parse
#' @examples
#' library(BarnebyLives)
#' ce <- collection_examples
#' ce <- data.frame(
#'   Collection_number = ce$Collection_number[sample(1:nrow(ce), size = 100, replace = F)],
#'   Binomial = c(ce$Full_name, ce$Name_authority)[sample(1:nrow(ce)*2, size = 100, replace = F)],
#'   Binomial_authority = ce$Binomial_authority[sample(1:nrow(ce), size = 100, replace = F)]
#' ) # extra columns to challenge name search - values are meaningless
#'
#' split_binomial(ce)|> head()
#' split_binomial(ce, binomial_col = 'Binomial') |> head()
#' @export
split_binomial <- function(x, binomial_col){

  if(missing(binomial_col)){  # search for non supplied column name
    indices <- grep('binomial', colnames(x), ignore.case=TRUE)

    if(length(indices) > 1){ # if more columns are found, try and find it an # authority column is the culprit
          indices <- indices[ grep('auth', colnames(x)[indices], invert = TRUE)]}
    if(length(indices) == 0){
          stop('unable to find name column, please supply argument to `binomial_col`')}
    if(length(indices) == 1){
          binomial_col <- colnames(x)[indices]
          cat('`binomial_col` argument not supplied, using:', colnames(x)[indices])
          }
  }

  # double spaces will mess with some of our sensitive regrexes below
  x[,binomial_col] <- trimws(gsub("\\s+", " ", x[,binomial_col]))

  # we will proceed row wise, treating each record independently from the last
  # in case that there are missing values.

  to_split <- split(x[,binomial_col], f = 1:nrow(x))
  binomial <- function(x){ # recovery of the binomial, only the first two pieces of the name.
    pieces <- unlist(stringr::str_split(x, pattern = " "))
    Genus <- pieces[1]; Epithet <- pieces[2]
    Binomial = paste(Genus, Epithet)

    vars <- data.frame(cbind(Binomial, Genus, Epithet))

   return(vars)
  }

  binomials <- lapply(to_split, binomial) |>
    data.table::rbindlist()

  # detection of infra-species, the complication for authorship retrieval

  remaining_info <- sub('\\w+\\s\\w+\\s', '', x[,binomial_col])
  remaining_info <- mapply(
    \(x, patt) gsub(patt, "", x, ignore.case = T), patt = binomials$Binomial, x = remaining_info)

  # if there is text before the infra rank grab it, this should be the authority
  # for the binomial

  # Binomial authority
  Binomial_authority <- sub("ssp[.].*|subsp[.].*|var[.].*", "", remaining_info)

  # Infra specific_rank
  Infraspecific_rank <- stringr::str_extract(remaining_info, "var.|subsp.|ssp.")

  # the word following infra species is always the name

  infra_info <- gsub(".*subsp[.] |.*var[.] |.*ssp[.] ", "", remaining_info)
  infra_pieces <- stringr::str_split(infra_info, pattern = " ")
  Infraspecies <- unlist(lapply(infra_pieces, '[[', 1))

  mask  <- grep("subsp[.] |var[.] |ssp[.] ", x[,binomial_col], invert = TRUE)
  Infraspecies <- replace(Infraspecies, mask, values = NA )

  # all remaining words are potential authors
  Infraspecific_authority <- mapply(
    \(x, patt) gsub(patt, "", x, ignore.case = T), patt = Infraspecies, x = infra_info)


  # combine results to BL format
  output <- cbind(binomials, Binomial_authority,
              Infraspecific_rank, Infraspecies, Infraspecific_authority)

  output[output == ""] <- NA
  output <- data.frame ( apply(output, MARGIN = 2, FUN = trimws) )
  output <- tidyr::unite(data = output, col = 'Full_name', Genus:Infraspecific_authority, na.rm=TRUE, sep = " ", remove = FALSE)

  cols2overwrite <- c('Binomial', 'Genus', 'Epithet', 'Binomial_authority',
                'Infraspecific_rank', 'Infrarank', 'Infraspecies', 'Infraspecific_authority')
  in_out <- dplyr::select(x, -any_of(cols2overwrite))
  output <- dplyr::bind_cols(in_out, output)

  return(output)
}


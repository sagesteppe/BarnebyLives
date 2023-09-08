#' split out a binomial input column to pieces
#'
#' This function attempts to split a scientific name into it's component pieces.
#' Given an input binomial, or binomial with scientific authorities and infraspecies
#' this function will parse them into the columns used in the BarnebyLives pipeline.
#' @param x a dataframe with collection information
#' @param binomial_col column containing the data to parse
#' @example
#'
#' @export
split_binomial <- function(x, binomial_col){

  if(missing(binomial_col)){  # search for non supplied column name
    indices <- grep('binomial', colnames(x), ignore.case=TRUE)}
  if(length(indices > 1)){ # if more columns are found, try and find it an
    # authority column is the culprit
      indices <- indices[ grep('auth', colnames(x)[indices], invert = TRUE)]}
  if(length(indices) == 0){ stop( # if no named columns are found stop the function
   cat('unable to find name column, please supply argument to "binomial_col"') )}
  if(length(indices == 1)){
    binomial_col <- colnames(x)[indices]
    cat('`binomial_col` argument not supplied, using:', colnames(x)[indices])
  }

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
  Infraspecies <- replace(Infraspecies, mask, values = NA )

 # return(Infraspecies)
  # all remaining words are potential authors

  # combine results to BL format
  ou <- cbind(input = x[,binomial_col], binomials, Binomial_authority, Infraspecific_rank
              ,Infraspecies)

  return(ou)
}

ob <- split_binomial(ce)


Infraspecies[]

mask  <- grep("subsp[.] |var[.] |ssp[.] ", ce$Binomial, invert = TRUE)
na_na

ce <- collection_examples
ce <- data.frame(
  Primary_Collector = ce$Primary_Collector[sample(1:nrow(ce), size = 75, replace = F)],
  Binomial = c(ce$Full_name, ce$Name_authority)[sample(1:nrow(ce)*2, size = 75, replace = F)],
  Binomial_authority = ce$Binomial_authority[sample(1:nrow(ce), size = 75, replace = F)]
) # second column to challenge name search - values are meaningless

with(ce, replace(Binomial, mask, values = NA ))

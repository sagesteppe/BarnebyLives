#' collect the results of a successful powo search
#'
#' @description this function is used within 'powo_searcher' to retrieve the results from a successful POWO query.
#' @param x a successful powo search query
#' @export
result_grabber <- function(x){
  # subset the appropriate data frame, there is one if clean data were entered,
  # and two if a synonym was entered.
  results <- x[['results']]

  clean <- which(unlist(lapply(results, `[`, 'accepted')) == T)
  resultT <- data.frame(results[clean])

  # the main variables which all results should have.
  family <- resultT$family
  binom_authority <- resultT$author
  full_name <- resultT$name
  split_name <- unlist(stringr::str_split(full_name, pattern = " "))
  genus <- split_name[1]
  epithet <- split_name[2]

  # the infra species information if relevant.
  if (length(split_name) > 2) {
    infraspecies <- split_name[length(split_name)]
  } else {
    infraspecies <- NA
  }

  if (length(split_name) > 2) {
    infrarank <-
      stringr::str_extract(full_name, ' var\\. | spp\\. | subsp\\. ') |>
      stringr::str_trim(side = 'both')
  } else {
    infrarank <- NA
  }

 if(!is.na(infrarank)){
    res <- all_authors(genus, epithet,
                       infrarank, infraspecies)
    name_authority <- as.character(res[[1]])
    binom_authority <- as.character(res[[2]])
    infra_authority <- as.character(res[[3]])
    message('module ran...')

 } else {
    name_authority = paste(full_name, binom_authority)
    infra_authority <- NA
 }

  taxonomic_info <- data.frame(
    family,
    'name_authority' = name_authority,
    full_name,
    binom_authority,
    genus,
    epithet,
    infrarank,
    infraspecies,
    infra_authority
  )

  return(taxonomic_info)
}


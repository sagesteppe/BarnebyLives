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
  authority <- resultT$author
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


  # experimental, let's grab all name components.
  if (length(split_name) > 2) {

    if(epithet == infraspecies) dispatch autonym
    res <- autonym(genus, epithet, infrarank, infraspecies)
    res <- autonym(genus, epithet, infrarank, infraspecies)
    name_authority <- as.character(res[[1]])
    authority <- as.character(res[[2]])


  }
  ### end experimental.

 if (is.null(authority)){
    res <- autonym(genus, epithet, infrarank, infraspecies)
    name_authority <- as.character(res[[1]])
    authority <- as.character(res[[2]])

  } else{name_authority = paste(full_name, authority)}

  taxonomic_info <- data.frame(
    family,
    'name_authority' = name_authority,
    full_name,
    genus,
    epithet,
    infrarank,
    infraspecies,
    binom_authority
  )

  return(taxonomic_info)
}


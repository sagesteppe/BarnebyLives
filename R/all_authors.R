#' retrieve author results for autonyms
#'
#' this function is internal to result_grabber, it ensures that an author is collected from the KEW API for infra-species which have autonyms.
#' @param  genus derived from result_grabber
#' @param  epithet derived from result_grabber
#' @param  infrarank derived from result_grabber
#' @param  infraspecies derived from result_grabber
#' @keywords internal
all_authors <- function(genus, epithet, infrarank, infraspecies){

  if(epithet == infraspecies){
    authority_hunt <- kewr::search_powo(paste(genus, epithet))

    results <- authority_hunt[['results']]
    clean <- which(unlist(lapply(results, `[`, 'accepted')) == T)
    auth_hunt <- data.frame(results[clean])
    binom_auth <- auth_hunt$author
    infra_authority <- NA

    name_authority <- paste(genus, epithet, binom_auth, infrarank, infraspecies)

    list(name_authority, binom_auth, infra_authority) # this returned

  } else {

    binom_authority_hunt <- kewr::search_powo(paste(genus, epithet))
    results <- binom_authority_hunt[['results']]
    clean <- which(unlist(lapply(results, `[`, 'accepted')) == T)
    auth_hunt <- data.frame(results[clean])
    binom_auth <- auth_hunt$author

    authority_hunt <- kewr::search_powo(paste(genus, epithet, infrarank, infraspecies))
    results <- authority_hunt[['results']]
    clean <- which(unlist(lapply(results, `[`, 'accepted')) == T)
    auth_hunt <- data.frame(results[clean])
    infra_authority <- auth_hunt$author

    name_authority <- paste(genus, epithet, binom_auth, infrarank, infraspecies, infra_authority)

    list(name_authority, binom_auth, infra_authority) # this returned
  }
}

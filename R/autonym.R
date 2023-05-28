#' retrieve author results for autonyms
#' 
#' this function is internal to result_grabber, it ensures that an author is collected from the KEW API for infra-species which have autonyms. 
#' @param  genus derived from result_grabber
#' @param  epithet derived from result_grabber
#' @param  infrarank derived from result_grabber
#' @param  infraspecies derived from result_grabber
#' @param export 
autonym <- function(genus, epithet, infrarank, infraspecies){
  
  authority_hunt <- search_powo(paste(genus, epithet))
  
  results <- authority_hunt[['results']]
  clean <- which(unlist(lapply(results, `[`, 'accepted')) == T)
  auth_hunt <- data.frame(results[clean])
  authority <- auth_hunt$author
  
  name_authority <- paste(genus, epithet, authority, infrarank, infraspecies)
  return(list(name_authority, authority))
  
}

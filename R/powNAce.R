
#' Easily compare POW column to input columns
#'
#' pronounced 'pounce'. 
#' After querying the POW database via 'powo_searcher' this function will mark
#' POW cells which are identical to the input (verified cleaned) as NA
#' ideally making it easier for person to process there results and prepare
#' there data for sharing via labels and digitally. 
#' @param x an sf/data frame/tibble which has both the input and POW ran data on it
#' @examples 
#' df <- data.frame(
#'   Genus = c('Castilleja', 'Linnaea', 'Dimeresia'),
#'   Epithet = c('pilosa', 'borealis', 'howellii'), 
#'   Infrarank = c('var.', 'var.', NA),
#'   Infraspecies =  c('pilosa', 'americana', NA), 
#'   Authority =  c('(S. Watson) Rydb.', '(J. Forbes) Rehder', 'A. Gray')
#' )
#' 
#' @export
powNAce <- function(x){
  
   compareNA <- function(v1,v2) {
    same <- (v1 == v2)  |  (is.na(v1) & is.na(v2))
    same[is.na(same)] <- FALSE
    return(same)
   } # @ BEN STACK O 16822426
   
   # work on identifying whether the author is for the species or infra species
   x$POW_Infraspecies_authority <- x$POW_authority
   x$POW_Binomial_authority <- x$POW_authority
   
   infra_maker <- function(x){
     if_else(!is.na(.$POW_Infrarank)) {  
       .$POW_Binomial_authority = .$POW_authority} if_else (x$POW_Epithet == x$POW_Infraspecies){  
         .$POW_Binomial_authority = .$POW_authority} 
   
     if_else(is.na(.$POW_Infrarank) & .$POW_Infrarank != x.$POW_Epithet){
       .$POW_Infraspecies_authority = .$POW_Epithet
    } 
   }

#  x[compareNA(x$POW_Name_authority, x$Name_authority ), 'POW_Name_authority'] <- NA
#  x[compareNA(x$POW_Full_name, x$Full_name ), 'POW_Full_name'] <- NA
#  x[compareNA(x$POW_Genus, x$Genus ), 'POW_Genus'] <- NA
#  x[compareNA(x$POW_Epithet, x$Epithet ), 'POW_Epithet'] <- NA
#  x[compareNA(x$POW_Infrarank, x$Infrarank ), 'POW_Infrarank'] <- NA
#  x[compareNA(x$POW_Infraspecies, x$Infraspecies ), 'POW_Infraspecies'] <- NA
#  x[compareNA(x$POW_Family, x$Family ), 'POW_Family'] <- NA
#   return(x)
}


df <- data.frame(
   POW_Genus = c('Castilleja', 'Linnaea', 'Dimeresia'),
   POW_Epithet = c('pilosa', 'borealis', 'howellii'), 
   POW_Infrarank = c('var.', 'var.', NA),
   POW_Infraspecies =  c('pilosa', 'americana', NA), 
   POW_Authority =  c('(S. Watson) Rydb.', '(J. Forbes) Rehder', 'A. Gray')
 )

powNAce(df)

sdf <- split(df, f = df$POW_Epithet)
lapply(X = sdf, FUN = infra_maker)


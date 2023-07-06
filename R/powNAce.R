
#' Easily compare POW column to input columns
#'
#' pronounced 'pounce'. 
#' After querying the POW database via 'powo_searcher' this function will mark
#' POW cells which are identical to the input (verified cleaned) as NA
#' ideally making it easier for person to process there results and prepare
#' there data for sharing via labels and digitally. 
#' @param x an sf/data frame/tibble which has both the input and POW ran data on it
powNAce <- function(x){
  
   compareNA <- function(v1,v2) {
    same <- (v1 == v2)  |  (is.na(v1) & is.na(v2))
    same[is.na(same)] <- FALSE
    return(same)
   } # @ BEN STACK O 16822426
   
   # work on identifying whether the author is for the species or infra species
   
   # ... check if infraspecies exists in first place ? it not default species
   # check if autonym is present, then default to species
   # if infraspecies present which != species, than author is presumed infra
   
   # then check if we have it right on the input data set...
   
  x[compareNA(x$POW_Name_authority, x$Name_authority ), 'POW_Name_authority'] <- NA
  x[compareNA(x$POW_Full_name, x$Full_name ), 'POW_Full_name'] <- NA
  x[compareNA(x$POW_Genus, x$Genus ), 'POW_Genus'] <- NA
  x[compareNA(x$POW_Epithet, x$Epithet ), 'POW_Epithet'] <- NA
  x[compareNA(x$POW_Infrarank, x$Infrarank ), 'POW_Infrarank'] <- NA
  x[compareNA(x$POW_Infraspecies, x$Infraspecies ), 'POW_Infraspecies'] <- NA
  x[compareNA(x$POW_Family, x$Family ), 'POW_Family'] <- NA
   return(x)
}

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
#'  POW_Genus = c('Castilleja', 'Linnaea', 'Dimeresia'),
#'  POW_Epithet = c('pilosa', 'borealis', 'howellii'), 
#'  POW_Infrarank = c('var.', 'var.', NA),
#'  POW_Infraspecies =  c('pilosa', 'americana', NA), 
#'  POW_Authority =  c('(S. Watson) Rydb.', '(J. Forbes) Rehder', 'A. Gray')
#' )
#' powNAce(df)
#' @export
#' 
powNAce <- function(x){
  
   # four conditions are compared to determine which taxonomic level the authority 
   # applies to
   infra_base <- function(x){
    
    x$POW_Infraspecies_authority <- NA
    x$POW_Binomial_authority <- NA
    
    if(is.na(x$POW_Infrarank)){
      x$POW_Binomial_authority = x$POW_Authority
    } else if ( x$POW_Infraspecies == x$POW_Epithet){
      x$POW_Binomial_authority = x$POW_Authority} else {
        x$POW_Infraspecies_authority = x$POW_Authority
      }
    return(x)
  }
  
   # we need NA's to be explicitly treated
   compareNA <- function(v1, v2){
    same <- (v1 == v2)  |  (is.na(v1) & is.na(v2))
    same[is.na(same)] <- FALSE
    return(same)
   } # @ BEN STACK O 16822426
   
   mycs <- c('Genus', 'POW_Genus', 'Epithet', 'POW_Epithet', 'Binomial_Authority',
             'POW_Binomial_authority', 'Infrarank', 'POW_Infrarank', 
             'Infraspecies', 'POW_Infraspecies', 'POW_Family')

   # identify whether the author is for the species or infra species
   rownames(x) <- 1:nrow(x)
   splits <- split(x, f = rownames(x))
   x <- lapply(X = splits, FUN = infra_base) 
   x <- do.call(rbind, x)
   
   x[compareNA(x$POW_Name_authority, x$Name_authority ), 'POW_Name_authority'] <- NA
   x[compareNA(x$POW_Full_name, x$Full_name ), 'POW_Full_name'] <- NA
   x[compareNA(x$POW_Genus, x$Genus ), 'POW_Genus'] <- NA
   x[compareNA(x$POW_Epithet, x$Epithet ), 'POW_Epithet'] <- NA
   x[compareNA(x$POW_Infrarank, x$Infrarank ), 'POW_Infrarank'] <- NA
   x[compareNA(x$POW_Infraspecies, x$Infraspecies ), 'POW_Infraspecies'] <- NA
   x[compareNA(x$POW_Family, x$Family ), 'POW_Family'] <- NA
   x[compareNA(x$POW_Binomial_authority, x$Binomial_authority ), 'POW_Binomial_authority'] <- NA
   x[compareNA(x$POW_Infraspecies_authority, x$Infraspecies_authority ), 'POW_Infraspecies_authority'] <- NA
   
   pos <- which( colnames(x) == 'POW_Epithet' ) - 1 
   x <- dplyr::relocate(x, any_of(mycs), 
                   .after = pos) |>
     dplyr::select(-any_of(c('POW_Name_authority', 'POW_Full_name', 'POW_Authority')))
  
   return(x)
  
}


df <- data.frame(
  POW_Genus = c('Castilleja', 'Linnaea', 'Dimeresia'),
  POW_Epithet = c('pilosa', 'borealis', 'howellii'), 
  POW_Infrarank = c('var.', 'var.', NA),
  POW_Infraspecies =  c('pilosa', 'americana', NA), 
  POW_Authority =  c('(S. Watson) Rydb.', '(J. Forbes) Rehder', 'A. Gray')
)

 powNAce(df)
#' do or don't write determination information
#' 
#' This functions determines whether to write information on whom determined the specimen
#' when, and via which texts. It used as a final step when formatting labels. 
#' @param x
#' @examples
#' writer_fide( collection_examples[31,'Fide'] )
#' @export
writer_fide <- function(x){if (is.na(x)){""} else {
  paste0('Fide: *', 
         sub(' Flora ', ' Fl. ', x),
         '*, by: ', data$Determined_by, ' on ', data$Determined_date)}
  }

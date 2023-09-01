#' do or don't write determination information
#'
#' This functions determines whether to write information on whom determined the specimen
#' when, and via which texts. It used as a final step when formatting labels.
#' @param x dataframe holding the values
#' @examples
#' phacelia <- collection_examples[31,]
#' writer_fide(phacelia)
#' @export
writer_fide <- function(x){

  x$Fide[x$Fide==""] <- NA

  if (is.na(x$Fide)){""} else {
    paste0('Fide: *',
           sub(' Flora ', ' Fl. ', x$Fide),
           '*, det.: ', x$Determined_by, ', ', x$Determined_date_text, '.')}
}




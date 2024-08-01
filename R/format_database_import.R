#' Export a spreadsheet for mass upload to an herbariums database
#'
#' Only a few schemas are currently supported, but we always seek to add more.
#' @param x data frame holding the final output from BarnebyLives
#' @param format a character vector indicating which database to create output for.
#' Currently supported options include: Symbiota, JEPS, CHIC...
#' @examples
#' @export
format_database_import <- function(x, format){

  dbt <- data('database_templates')
  dbt <- dbt[dbt$Database == 'Symbiota', c('BarnebyLives', 'OutputField')]

  lkp <- setNames( # create a look up vector to map our columns to theirs.
    dbt[!is.na(dbt$BarnebyLives), 'BarnebyLives'],
    dbt[!is.na(dbt$BarnebyLives), 'OutputField']
  )

  empty_cols <- setNames( # determine which columns we do not have an analogue
    data.frame( # for, these will be added on as empty columns after we map
      matrix( # our names to theirs.
        ncol = sum(is.na(dbt$BarnebyLives)),
        nrow = x)),
    dbt[is.na(dbt$BarnebyLives), 'OutputField'])


  x <- x |>
    dplyr::unite(., col = "Vegetation_Associates",  Vegetation, Associates, na.rm=TRUE, sep = ", ") %>%
    dplyr::mutate(AUTHORS_TRUNC = if_else(
      is.na(Infraspecific_authority), Binomial_authority, Infraspecific_authority),
      elevation_m_copy = elevation_m) %>%
    dplyr::rename(., any_of(lkp)) %>%
    dplyr::select(all_of(names(lkp))) %>%
    dplyr::bind_cols(., empty_cols) %>%
    dplyr::relocate(cname_lkp$OutputField)

  return(x)
}

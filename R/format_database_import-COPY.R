#' Export a spreadsheet for mass upload to an herbariums database
#'
#' Only a few schemas are currently supported, but we always seek to add more.
#' @param x data frame holding the final output from BarnebyLives
#' @param format a character vector indicating which database to create output for.
#' @examples
#' library(BarnebyLives)
#' dat4import <- format_database_import(collection_examples, format = 'JEPS')
#'
# we also know a bit about our material and can populate it here by hand #
#' dat4import |>
#'   dplyr::mutate(
#'    Label_Footer = 'Collected under the auspices of the Bureau of Land Management',
#'    Coordinate_Uncertainty_In_Meters = 5,
#    Coordinate_Source = 'iPad')
#' @export
format_database_import <- function(x, format){

  dbt <- database_templates[database_templates$Database == format,]

  col2select <- dbt$BarnebyLives[!is.na(dbt$BarnebyLives)]
  names4cols <- dbt$OutputField[!is.na(dbt$BarnebyLives)]

}


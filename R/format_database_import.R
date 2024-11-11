#' Export a spreadsheet for mass upload to an herbariums database
#'
#' Only a few schemas are currently supported, but we always seek to add more.
#' @param x data frame holding the final output from BarnebyLives
#' @param format a character vector indicating which database to create output for.
#' @examples
#' library(BarnebyLives)
#' dat4import <- format_database_import(collection_examples, format = 'JEPS')
#'
#' # we also know a bit about our material and can populate it here by hand #
#' dat4import |>
#'   dplyr::mutate(
#'    Label_Footer = 'Collected under the auspices of the Bureau of Land Management',
#'    Coordinate_Uncertainty_In_Meters = 5,
#'     Coordinate_Source = 'iPad')
#'
#' @export
format_database_import <- function(x, format){

  dbt <- database_templates[database_templates$Database == format,]

  col2select <- dbt$BarnebyLives[!is.na(dbt$BarnebyLives)]
  names4cols <- dbt$OutputField[!is.na(dbt$BarnebyLives)]

  # create any necessary columns by engineering the input data.
  if(any(col2select=='Vegetation_Associates')){
    x <- tidyr::unite(x, col = Vegetation_Associates,
                      Vegetation, Associates, na.rm=TRUE, sep = ", ")}

  if(any(col2select=='Coordinate_Uncertainty')){
    x <- dplyr::mutate(x, Coordinate_Uncertainty = 'Not Recorded')}

  if(any(col2select=='Elevation_Units')){
    x <- dplyr::mutate(x, Elevation_Units = 'm')}

  if(any(col2select=='Date_digital_vd')){
    x <- dplyr::mutate(x, Date_digital_vd = Date_digital)}

  if(any(col2select=='elevation_m_cp')){
    x <- dplyr::mutate(x, elevation_m_cp = elevation_m)}

  # select the relevant columns & rename them
  x_sub <- dplyr::select(x, dplyr::all_of(col2select)) |>
    purrr::set_names(names4cols)

  # pad output data with empty columns
  empty_cols <- dbt$OutputField[is.na(dbt$BarnebyLives)]
  empty_cols <- setNames(
    data.frame(
      matrix(nrow = nrow(x), ncol = length(empty_cols))),
    empty_cols)

  out <- dplyr::bind_cols(x_sub, empty_cols) |>
    dplyr::select(dplyr::all_of(dbt$OutputField))

  return(out)

}s


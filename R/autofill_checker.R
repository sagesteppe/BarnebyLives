#' Search for accidental auto-increments from spreadsheet autofills
#'
#' Spreadsheets like to automatically increment everything all the time.
#' Here we try to detect these where they may have effected the coordinates.
#' This function operates under the observation, that the incrementation only occurs
#' to the 'integers' or degrees
#' @param x a data frame which has undergone 'dms2dd' from BarnebyLives
#' @examples
#' coords <- data.frame(
#'   longitude_dd = c(rep(42.3456, times = 5), 43.3456),
#'   latitude_dd = c(rep(-116.7890, times = 5), -115.7890)
#' )
#' autofill_checker(coords) # note that all values in the column will
#' # flagged after the occurrence (see 'Lat_AutoFill_Flag')
#' @export
autofill_checker <- function(x) {
  flags <- x |>
    dplyr::mutate(
      long_degrees = gsub('.*\\.', '', longitude_dd),
      lat_degrees = gsub('.*\\.', '', latitude_dd),
      long_decimel = gsub('[.].*$', '', longitude_dd),
      lat_decimel = gsub('[.].*$', '', latitude_dd),
    ) |>
    dplyr::group_by(long_degrees, lat_degrees) |>
    dplyr::mutate(
      long_dec_last = dplyr::lag(long_decimel),
      lat_dec_last = dplyr::lag(lat_decimel),
      Long_AutoFill_Flag = dplyr::if_else(
        long_decimel == long_dec_last,
        NA,
        'Flagged'
      ),
      Lat_AutoFill_Flag = dplyr::if_else(
        lat_decimel == lat_dec_last,
        NA,
        'Flagged'
      ),
    ) |>
    dplyr::ungroup() |>
    dplyr::select(Long_AutoFill_Flag, Lat_AutoFill_Flag)

  output <- dplyr::bind_cols(x, flags) |>
    dplyr::relocate(
      Long_AutoFill_Flag,
      Lat_AutoFill_Flag,
      .after = dplyr::last_col()
    )

  return(output)
}

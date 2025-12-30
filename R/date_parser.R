#' create herbarium format dates for specimens
#'
#' @description this function will return up to two additional columns with x. 'coll_date_text' a text format for the date of collection and 'det_date_text" a shorter text format date for identification
#' @param x an (sf/tibble/) data frame with both the collection date
#' and determination date
#' @param coll_date date of collection, expected to be of the format 'MM/DD/YYYY', minor checks for compliance to the format will be carried out before returning an error.
#' @param det_date date of determination, same format and processes as above.
#' @returns original data frame plus: x_dmy, x_day, x_month, x_year, x_text, det_date_text, columns for both parameters which are supplied as inputs
#' @examples
#' first50dates <- data.frame(
#'    collection_date = paste0(
#'    sample(3:9, size = 10, replace = TRUE), '-',
#'    sample(1:29, size = 10, replace  = TRUE), '-',
#'    rep(2023, times = 10 )))
#' dates <- date_parser(first50dates, coll_date = 'collection_date')
#' head(dates)
#' @export
date_parser <- function(x, coll_date, det_date = NULL) {
  # column name vectors for later relocation
  names_v <- c('_ymd', '_day', '_mo', '_yr', '_text')
  if (is.null(det_date)) {
    column_names <- c(coll_date, paste0(coll_date, names_v))
  } else {
    column_names <- c(
      coll_date,
      paste0(coll_date, names_v),
      det_date,
      paste0(det_date, names_v)
    )
  }

  # convert collection and determination dates to lubridate
  x_dmy <- x |>
    dplyr::mutate(
      dplyr::across(
        .cols = dplyr::all_of(c(coll_date, det_date)),
        ~ lubridate::mdy(.x),
        .names = "{.col}_ymd"
      )
    ) |>
    dplyr::mutate(
      dplyr::across(
        .cols = dplyr::ends_with('_ymd'),
        ~ lubridate::month(.),
        .names = "{.col}_mo"
      ),
      dplyr::across(
        .cols = dplyr::ends_with('_ymd'),
        ~ lubridate::day(.),
        .names = "{.col}_day"
      ),
      dplyr::across(
        .cols = dplyr::ends_with('_ymd'),
        ~ lubridate::year(.),
        .names = "{.col}_yr"
      )
    ) |>
    dplyr::mutate(
      dplyr::across(
        .cols = dplyr::all_of(c(coll_date, det_date)),
        date2text,
        .names = '{.col}_text'
      )
    )

  # handle sf objects separately
  if ("sf" %in% class(x_dmy)) {
    x_dmy_geo <- x_dmy |>
      dplyr::select(geometry)

    x_dmy_no_geo <- x_dmy |>
      sf::st_drop_geometry() |>
      dplyr::rename_with(
        ~ stringr::str_remove(., '_ymd'),
        dplyr::matches('_ymd_.*$')
      ) |>
      dplyr::relocate(dplyr::all_of(column_names), .before = dplyr::last_col())

    x_dmy <- dplyr::bind_cols(x_dmy_no_geo, x_dmy_geo) |>
      sf::st_as_sf(crs = sf::st_crs(x_dmy_geo))
  } else {
    x_dmy <- x_dmy |>
      dplyr::rename_with(
        ~ stringr::str_remove(., '_ymd'),
        dplyr::matches('_ymd_.*$')
      ) |>
      dplyr::relocate(dplyr::all_of(column_names), .before = dplyr::last_col())
  }

  return(x_dmy)
}

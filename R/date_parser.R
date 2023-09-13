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
#'    sample(3:9, size = 50, replace = TRUE), '-',
#'    sample(1:29, size = 50, replace  = TRUE), '-',
#'    rep(2023, times = 50 )))
#' dates <- date_parser(first50dates, coll_date = 'collection_date')
#' head(dates)
#' @export
date_parser <- function(x, coll_date, det_date){

  coll_date_q <- rlang::enquo(coll_date)
  det_date_q <- rlang::enquo(det_date)

  names_v <- c('_dmy', '_day', '_mo',  '_yr', '_text')
  if(missing(det_date)){
    column_names <- c(coll_date, paste0(coll_date, names_v))
  } else {
    column_names <- c(coll_date,
                      paste0(coll_date, names_v),
                        det_date,
                        paste0(det_date, names_v))
  }

  rename_with.sf = function(.data, .fn, .cols, ...) {
    if (!requireNamespace("rlang", quietly = TRUE))
      stop("rlang required: install that first") # nocov
    .fn = rlang::as_function(.fn)

    sf_column = attr(.data, "sf_column")
    sf_column_loc = match(sf_column, names(.data))

    if (length(sf_column_loc) != 1 || is.na(sf_column_loc))
      stop("internal error: can't find sf column") # nocov

    agr = sf::st_agr(.data)

    .data = as.data.frame(.data)
    ret = if (missing(.cols)) {
      if (!requireNamespace("tidyselect", quietly = TRUE)) {
        stop("tidyselect required: install that first") # nocov
      }
      dplyr::rename_with(
        .data = .data,
        .fn = .fn,
        .cols = tidyselect::everything(),
        ...
      )
    } else {
      dplyr::rename_with(
        .data = .data,
        .fn = .fn,
        .cols = {{ .cols }},
        ...
      )
    }
    ret = sf::st_as_sf(ret, sf_column_name = names(ret)[sf_column_loc])

    names(agr) = .fn(names(agr))
    sf::st_agr(ret) = agr
    ret
  }


  x_dmy <- x |>
    dplyr::mutate(across(.cols = c(!!coll_date_q, !!det_date_q), lubridate::mdy, .names = "{.col}_dmy")) |>
    dplyr::mutate(across(ends_with('_dmy'), ~ lubridate::month(.), .names = "{.col}_mo"),
           across(ends_with('_dmy'), ~ lubridate::day(.), .names = "{.col}_day"),
           across(ends_with('_dmy'), ~ lubridate::year(.), .names = "{.col}_yr")) |>
    dplyr::mutate(across(.cols = c(!!coll_date_q, !!det_date_q), date2text, .names = '{.col}_text')) |>
    rename_with.sf( ~ stringr::str_remove(., '_dmy'), matches("_dmy_.*$")) |>
    dplyr::relocate(any_of(column_names), .before = last_col())

  return(x_dmy)
}


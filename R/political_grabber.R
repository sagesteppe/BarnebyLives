#' gather political site information
#'
#' @description this function grabs information on the state, county, and township of collections
#' @param x an sf data frame of collection points
#' @param y a variable which uniquely identifies each observation
#' @param path a path to the directory holding the BarnebyLivesGeodata
#' @examples # see the package vignette
#' @export
political_grabber <- function(x, y, path) {

  x <- dplyr::select(
    x,
    -dplyr::any_of(c(
      'Country',
      'State',
      'County',
      'Mang_Name',
      'Unit_Nm',
      'trs',
      'Allotment'
    ))
  )

  political <- sf::st_read(
    file.path(path, 'political', 'political.shp'),
    quiet = T
  )
  feature <- sf::st_read(
    file.path(p2geo, 'mountains', 'mountains.shp'),
    quiet = T
  )

  allotment <- sf::st_read(
    file.path(path, 'allotments', 'allotments.shp'),
    quiet = T
  )
  plss <- sf::st_read(file.path(path, 'plss', 'plss.shp'), quiet = T)
  ownership <- sf::st_read(file.path(path, 'pad', 'pad.shp'), quiet = T)

  # write attributes to data set

  x <- sf::st_join(x, political)
  x <- sf::st_join(x, allotment)
  x <- sf::st_join(x, ownership)
  x <- sf::st_join(x, feature)

  x_plss <- sf::st_transform(x, sf::st_crs(plss))
  x_plss <- sf::st_join(x_plss, plss) |>
    sf::st_drop_geometry() |>
    dplyr::select(dplyr::any_of(c(y, 'trs')))

  x_vars <- dplyr::left_join(x, x_plss, by = y) |>
    dplyr::mutate(Country = 'U.S.A.') |>
    dplyr::relocate(
      dplyr::any_of(
        c(
          'Country',
          'State',
          'County',
          'Feature',
          'Mang_Name',
          'Unit_Nm',
          'trs',
          'Allotment'
        )
      ),
      .before = geometry
    ) |>
    dplyr::distinct(.keep_all = T) |>
    # with large enough sample size some points fall on an exact border
    dplyr::group_by(.data[[y]]) |>
    dplyr::slice_head(n = 1) |>
    dplyr::ungroup()

  x_vars <- x_vars |>
    dplyr::mutate(
      Gen = paste0(
        Country,
        ', ',
        State,
        ', ',
        County,
        ' Co., ',
        Feature,
        ', ',
        Mang_Name,
        " ",
        Unit_Nm,
        " ",
        trs
      ),
      Gen = stringr::str_replace_all(Gen, "NA", ""),
      Gen = stringr::str_replace_all(Gen, "  ", ""),
      Gen = stringr::str_replace_all(Gen, ", ,", ","),
      Gen = stringr::str_trim(Gen),
      Gen = stringr::str_remove(Gen, ",$"),
      .before = geometry
    )

  return(x_vars)

  rm(political, allotment, plss, ownership)
}

#' gather physical characteristics of the site
#'
#' @description this function grabs information on the elevation, azimuth, geomorphon, and geology of the site
#' @param x an sf data frame of collection points
#' @examples see the package vignette
#' @export
physical_grabber <- function(x) {

  round_df <- function(df, digits) {
    nums <- vapply(df, is.numeric, FUN.VALUE = logical(1))
    df[,nums] <- round(df[,nums], digits = digits)
    return(df)
  }

  x_spat <- terra::vect(x)
  geology <- terra::vect('../geodata/geology/geology.shp')
  x_geo <- terra::extract(geology, x_spat)

  asp <- '../geodata/aspect/'; slo <-  '../geodata/slope'
  geo <-  '../geodata/geomorphons'; elev <-  '../geodata/elevation'

  paths2rast <- file.path(asp, list.files(path = paste0(asp, '/'), recursive = T))
  aspect <- terra::vrt(paths2rast)

  paths2rast <- file.path(slo, list.files(path = paste0(slo, '/'), recursive = T))
  slope <- terra::vrt(paths2rast)

  paths2rast <- file.path(geo, list.files(path = paste0(geo, '/'), recursive = T))
  geomorphon <- terra::vrt(paths2rast)

  paths2rast <- file.path(elev, list.files(path = paste0(elev, '/'), recursive = T))
  elevation <- terra::vrt(paths2rast)

  asp_val <- terra::extract(aspect, x_spat)
  names(asp_val) <- c('ID', 'aspect')
  slo_val <- terra::extract(slope, x_spat)

  geoLKPtab <- data.frame(unit = 1:10, geomorphon = c(
    'flat', 'peak', 'ridge', 'shoulder', 'spur',
    'slope', 'hollow', 'footslope', 'valley', 'pit'
  ))

  geo_val <- terra::extract(geomorphon, x_spat)
  names(geo_val) <- c('ID', 'unit')
  geo_val <- dplyr::left_join(geo_val, geoLKPtab, by = 'unit') |>
    dplyr::select(-unit)

  ele_val <- terra::extract(elevation, x_spat)

  values <- data.frame(cbind(
    asp_val, 'slope' = slo_val[,2],  'elevation_m' = ele_val[,2]),
    'geomorphon' = geo_val[,2], 'geology' = x_geo[,2])

  values$elevation_ft <- round(values$elevation_m * 3.28084, -1)
  values <- round_df(values, 0)

  el_cols <- c('elevation_m', 'elevation_ft')
  values[el_cols] <- lapply(values[el_cols], scales::comma)

  cols <- c('elevation_m', 'elevation_ft', 'aspect', 'slope',
            'geomorphon', 'geology')

  object <- dplyr::bind_cols(x, values) |>
    dplyr::select(-ID) |>
    dplyr::relocate(tidyselect::all_of(cols), .before = geometry) |>
    dplyr::mutate(
      physical_environ =
        paste0('At ', elevation_ft, ' ft, on a ', geomorphon, ', ', format_degree(slope),
               ' slo. and ', format_degree(aspect), ' asp.; geology: ', geology, '.'
                                ), .before = geometry)

  return(object)
}


#' write out digital data for mass upload in an database
#'
#' This function will write out the data from BarnebyLives into many formats commonly used
#' by herbaria to database their records. Currently supports: Symbiota, CPNWH, Darwin Core ... Adding additional
#' support is easy, and the developers are happy to ensure that your museums format is supported, reach out
#' to coordinate this effort with us.
#' @param x a data frame generated from the full steps of BarnebyLives pipeline
#' @param type a string of a supported output format, one of: 'darwincore', 'symbiota', 'cpnwh'
#' @param BL boolean, whether to also write out a copy of data in BarnebyLives format, which can be used to generate labels
#' defaults to the name 'BarnebyLives' with the current data appended.
#' @param basename optional string specifying a filename prefix, e.g. a collector if need be.
#' @param filename a string specifying the filename, and type, best supported are CSV.
#' Defaults to the type of data being written out, with the current date.
#' @param directory a string specifying the path to the directory to write the data to.
#' Defualts to the current working directory
#' @example path.R
#' @export
#'
sheet_writer <- function(x, type, filename, directory){

  if(missing(type)){type <- 'symbiota'}
  if(missing(BL)){BL <- TRUE}
  if(missing(basename)){basename <- ""}
  if(missing(directory)){directory <- '.'}

  if(missing(filename)){ if(grepl("", basename){ # if filename not provided create defaults
    filename <- paste0(type, '_', Sys.Date(), '.csv')
  }) else {
    filename <- paste0(basename, '_', type, '_', Sys.Date(), '.csv')}
  } else{ # if filename provided create the default or user specified input
    if(grepl("", basename){
      filename <- paste0(filename, '_', Sys.Date(), '.csv')
    }) else {
      filename <- paste0(basename, '_', filename)
      }
  }

  x_sub <- dplyr::select(x, -tidyselect::starts_with('POW'), -tidyselect::ends_with('issues')) |>
    sf::st_drop_geometry()

  # import relevant columns, and create empty fields in output data as required by format

  cname_lkp <- data(type)

  cname_lkp_no_na <- drop_na(cname_lkp)
  lkp <- cname_lkp_no_na$BarnebyLives
  names(lkp) <- cname_lkp_no_na$Symbiota

  col_names <- cname_lkp$Symbiota[is.na(cname_lkp$BarnebyLives)]
  empty_cols <- setNames(
    data.frame(
      matrix(
        ncol = length(col_names),
        nrow = nrow(InHouse)
        )
      ), col_names
    )


  # set up the data to be written out to the format

  if(type == 'symbiota'){

    crosswalk <- x_sub |>
      tidyr::unite(., col = "Vegetation_Associates",  Vegetation, Associates, na.rm = TRUE, sep = ", ") |>
      dplyr::rename(., any_of(lkp)) |>
      dplyr::select(all_of(names(lkp))) |>
      dplyr::bind_cols(., empty_cols) |>
      dplyr::relocate(cname_lkp$Symbiota) |>
      dplyr::mutate(across(everything(), ~ replace_na(.x, "")))

  } else if(type == 'darwinCore'){

      crosswalk <- x_sub |>
        tidyr::unite(., col = "Vegetation_Associates",  Vegetation, Associates, na.rm = TRUE, sep = ", ") |>
        dplyr::rename(., any_of(lkp)) |>
        dplyr::select(all_of(names(lkp))) |>
        dplyr::bind_cols(., empty_cols) |>
        dplyr::relocate(cname_lkp$DarwinCore) |>
        dplyr::mutate(across(everything(), ~ replace_na(.x, "")))

  } else if(type == 'cpnwh'){

    # do

  } else {

    #prep data for the the other formats.

  }

 ## if(BL == TRUE){write.csv(x_sub, file.path(directory, 'BarnebyLives', Sys.Date())) }

  write_me <- file.path(directory, filename)

}

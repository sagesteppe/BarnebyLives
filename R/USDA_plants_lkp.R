#' Retrieve binomials from a list of USDA Plants codes
#'
#' Spell out abbreviated fields
#' @param x a data frame containing the values
#' @param y the first column containing the codes, the function works row by row allowing
#' for mixed columns, i.e. those with both spelled out and abbreviated species
#' @param path path to the folder containing taxonomic data
#' @example # buck <- USDA_plants_lkp(data, 'Vegetation', p2tax)
#' @export
USDA_plants_lkp <- function(x, y, path ){

  lkp_tab <- read.csv(file.path(path, 'USDA_PLANTS.csv'))
  dat_sub <- x[,y] |> sf::st_drop_geometry()

  ch <- function(x){if(grepl('[A-Z]{4,5}', x)){
    spl <- data.frame(stringr::str_split(x, pattern = ","))
    colnames(spl) <- 'Symbol'
    full_names <- dplyr::left_join(spl, lkp_tab, by = 'Symbol') |>
      dplyr::pull(Scientific.Name)
    full_names <- paste0(full_names, collapse = ", ")
    return(full_names)
  }
    else (return(x))
  }
  out <- data.frame(do.call(rbind, lapply(FUN = ch, X = dat_sub)))
  colnames(out) <- y
  out <- dplyr::bind_cols(dplyr::select(x, -all_of(y)), out) |>
    dplyr::relocate(y, .before = which(colnames(x) == y) -1)
  return(out)
}

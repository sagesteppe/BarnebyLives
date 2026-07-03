#' resolve a taxonomic name against the local WCVP checklist
#'
#' @description this function replaces 'powo_searcher' now that Kew's POWO search API
#' blocks programmatic requests (HTTP 403 from any client/origin). For each submitted
#' name it looks up an exact match in the global 'id_lookup_table.csv' built by
#' \code{\link{TaxUnpack}}, then follows 'acceptednameusageid' to resolve synonyms to
#' their currently accepted family/genus/epithet/authority. The match is deliberately
#' global rather than restricted to the local, geographically filtered lookup tables -
#' WCVP distribution records are only kept against accepted names, so a submitted
#' synonym would never be found there. This function is not a spell checker - names
#' should already be run through \code{\link{spell_check}} first, since only exact
#' matches are resolved here.
#' @param data data frame/tibble/sf object containing names to resolve
#' @param column a column containing the full name, genus, species, and infraspecific rank information as relevant.
#' @param path a path to a folder containing the taxonomic data set up by \code{\link{TaxUnpack}}.
#' @returns \code{data} with taxonomic columns appended: POW_Query, POW_Family, POW_Genus,
#' POW_Epithet, POW_Infrarank, POW_Infraspecies, POW_Authority, and POW_Status (the
#' taxonomic status of the originally matched name, e.g. 'Accepted' or 'Synonym', so
#' rows where a substitution occurred can be reviewed).
#' @examples
#' \dontrun{
#' names <- data.frame(
#'  Full_name = c('Astragalus purshii', 'Linnaea borealis subsp. borealis'))
#' names_l <- split(names, f = 1:nrow(names))
#' r <- lapply(names_l, wcvp_searcher, column = 'Full_name', path = p2tax)
#' }
#' @export
wcvp_searcher <- function(data, column, path) {
  idLKPtab <- read.csv(file.path(path, 'id_lookup_table.csv'))

  rank_abbrev <- c(Variety = 'var.', Subspecies = 'subsp.')

  # follow 'acceptednameusageid' to the currently accepted record, unless the
  # matched record already is one (it self-references its own taxonid).
  resolve_row <- function(row) {
    if (row$acceptednameusageid != row$taxonid) {
      accepted <- idLKPtab[idLKPtab$taxonid == row$acceptednameusageid, ]
      resolved <- if (nrow(accepted) >= 1) accepted[1, ] else row
    } else {
      resolved <- row
    }
    list(matched_status = row$taxonomicstatus, resolved = resolved)
  }

  not_found <- function(x, query) {
    data.frame(
      x,
      POW_Query = query,
      POW_Family = NA_character_,
      POW_Genus = NA_character_,
      POW_Epithet = NA_character_,
      POW_Infrarank = NA_character_,
      POW_Infraspecies = NA_character_,
      POW_Authority = NA_character_,
      POW_Status = 'not-found'
    )
  }

  ws <- function(x, column) {
    query <- trimws(gsub("\\s+", " ", x[, column]))
    pieces <- unlist(stringr::str_split(query, pattern = " "))
    genus <- pieces[1]
    species <- pieces[2]

    if (length(pieces) == 4) {
      full_name <- paste(
        genus,
        species,
        stringr::str_replace(pieces[3], 'ssp\\.|ssp', 'subsp.'),
        pieces[4]
      )
    } else {
      full_name <- paste(genus, species)
    }

    pos <- which(idLKPtab$scientfiicname == full_name)
    if (length(pos) == 0) {
      return(not_found(x, query))
    }

    res <- resolve_row(idLKPtab[pos[1], ])
    resolved <- res$resolved

    data.frame(
      x,
      POW_Query = query,
      POW_Family = resolved$family,
      POW_Genus = resolved$genus,
      POW_Epithet = resolved$specificepithet,
      POW_Infrarank = unname(rank_abbrev[resolved$taxonrank]),
      POW_Infraspecies = ifelse(
        resolved$infraspecificepithet == '',
        NA_character_,
        resolved$infraspecificepithet
      ),
      POW_Authority = resolved$scientfiicnameauthorship,
      POW_Status = res$matched_status
    )
  }

  if (any(class(data) == 'sf')) {
    geometry_col <- dplyr::select(data, geometry)
    x <- sf::st_drop_geometry(data) |>
      data.frame()
  } else {
    x <- data
  }

  data_l <- split(x, f = seq_len(nrow(x)))
  ws_res <- lapply(data_l, ws, column = column)
  ws_res <- data.table::rbindlist(ws_res, fill = TRUE) |>
    data.frame()

  if (any(class(data) == 'sf')) {
    ws_res <- dplyr::bind_cols(ws_res, geometry_col) |>
      sf::st_as_sf()
  }

  ws_res
}

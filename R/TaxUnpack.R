#' a function to subset the WCVP data set to an area of focus
#'
#' This function is run on the WCVP compressed archive downloaded by 'wcvp_update',
#' and requires some input from the user which specifies a geographic area to establish a
#' taxonomic look up table for.
#' @param path Character vector.  Location to where taxonomic data should be saved,
#' we recommend asubdirectory in the same folder, and at the same level, as the geographic data.
#' @param bound Dataframe of x and y coordinates, same argument as to `data_setup`.
#' Coordinates assumed in WG84, NAD83, or googles absurd projection. Coordinate
#' specifications are very precise later in the process, but at this level any of these
#' three are effectively equivalent.
#' @examples \dontrun{
#'
#' bound <- bound |>
#'   sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
#'   sf::st_bbox() |>
#'   sf::st_as_sfc()
#'
#' oupu <- TaxUnpack(path = '/media/steppe/hdd/BL_sandbox', bound = bound)
#' }
#' @export
TaxUnpack <- function(path, bound ){

  bound <- bound |>
    sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
    sf::st_bbox() |>
    sf::st_as_sfc()

  # identify which states we want to download the plants for.
  sts <- tigris::states(cb = TRUE, progress_bar = FALSE, year = 2022) |>
    dplyr::select(NAME)
  sts <- sts[unlist(
    sf::st_intersects(
      sf::st_transform(bound, sf::st_crs(sts)), sts)
  ),] |>
    dplyr::pull(NAME)

  # download the current data version
  WCVP_dl(path = path)

  distributions <- read.table(
    unz(file.path(path, 'WCVP.zip'), 'wcvp_distribution.csv'),
    sep = "|", header = TRUE, quote = "", fill = TRUE, encoding = "UTF-8")

  # extract all plant codes associated with these states.
  distributions <- distributions[distributions$locality %in% sts, 'coreid']

  cat(
    crayon::green(
      length(distributions),
      'names (mostly synonyms...) found in this spatial domain.\n
      Sit tight while we process all of the synonyms associated with them.')
    )

  names <- read.table(unz(file.path(path, 'WCVP.zip'), 'wcvp_taxon.csv'),
                     sep = "|", header = TRUE, quote = "", fill = TRUE, encoding = "UTF-8")
  names <- names[names$taxonid %in% distributions,
        c('taxonid', 'taxon_rank', 'family', 'genus', 'specificepithet', 'infraspecific_rank',
          'infraspecificepithet', 'scientific_name', 'accepted_plant_name_id', 'parent_plant_name_id',
          'taxononmicstatus', 'scientificnameauthorship')]

  return(names)

  names <- names[names$taxon_rank %in% c('Species', 'Subspecies', 'Variety'),]
  names <- dplyr::arrange(names, family, genus, species)

  sppLKPtab <- names[, c('taxon_name', 'genus', 'species', 'infraspecific_rank',
                         'infraspecies', 'taxon_rank')]

  sppLKPtab <- dplyr::filter(sppLKPtab, taxon_rank == "Species") |>
    dplyr::mutate(gGRP = stringr::str_extract(genus, '[A-Z]{1}[a-z]{1}')) |>
    dplyr::arrange(taxon_name)

  infra_sppLKPtab <- dplyr::filter(names, taxon_rank %in% c("Variety", "Subspecies")) |>
    dplyr::mutate(Grp = stringr::str_extract(infraspecies, '[a-z]{2}')) |>
    dplyr::select('taxon_name', 'genus', 'species', 'infraspecific_rank',
           'infraspecies', 'taxon_rank') |>
    dplyr::arrange(taxon_name)

  families <- sort(unique(names$family))
  families <- c(families, 'Hydrophyllaceae', 'Namaceae') #add on a few
  families <- data.frame(Family = families)

  write.csv(families, file.path(path, 'families_lookup_table.csv'), row.names = F)
  write.csv(sppLKPtab, file.path(path, 'species_lookup_table.csv'), row.names = F)
  write.csv(infra_sppLKPtab, file.path(path, 'infra_species_lookup_table.csv'), row.names = F)

  cat(crayon::green(
    'New taxonomy backbone set up.'))

}


#' download data
#' @description dl data.
#'
#' @keywords internal
WCVP_dl <- function(path){  #  WORKS

  fp <- file.path(path, 'WCVP.zip')
  if(file.exists(fp)){
    message('Product `WCVP` already downloaded. Skipping.')} else{
      URL <- 'https://sftp.kew.org/pub/data-repositories/WCVP/wcvp_dwca.zip'
      httr::GET(URL, httr::progress(), httr::write_disk(path = fp, overwrite = TRUE))
    }
}

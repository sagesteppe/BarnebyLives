#' a function to subset the WCVP data set to an area of focus
#'
#' This function is run on the WCVP compressed archive downloaded by 'wcvp_update',
#' and requires some input from the user which specifies a geographic area to establish a
#' taxonomic look up table for.
#' @param path to where WCVP is stored
#' @param continents one of: 'NORTHERN AMERICA', 'AFRICA', 'ANTARCTICA', 'ASIA-TROPICAL',
#'  'ASIA-TEMPERATE', 'AUSTRALASIA', 'EUROPE', 'OCEANIA', 'SOUTHERN AMERICA', 'PACIFIC',
#' @examples \dontrun{
#' oupu <- TaxUnpack(path = '~/Downloads',
#'                  continent = 'NORTHERN AMERICA')
#'
#' }
#' @export
TaxUnpack <- function(path, continents){

  distributions <- read.table(unz(file.path(path, 'wcvp.zip'), 'wcvp_distribution.csv'),
    sep = "|", header = TRUE, quote = "", fill = TRUE, encoding = "UTF-8")

  distributions <- unique(distributions[distributions$continent %in% continents, c('plant_name_id')])

  cat(crayon::green(length(distributions),
                    'accepted names found in this spatial domain.\nSit tight while we process all of the synonyms associated with them.\n'))

  names <- read.table(unz(file.path(path, 'wcvp.zip'), 'wcvp_names.csv'),
                     sep = "|", header = TRUE, quote = "", fill = TRUE, encoding = "UTF-8")
  names <- names[names$accepted_plant_name_id %in% distributions,
        c('plant_name_id', 'taxon_rank', 'family', 'genus', 'species', 'infraspecific_rank',
          'infraspecies', 'taxon_name', 'accepted_plant_name_id', 'parent_plant_name_id',
          'taxon_status', 'taxon_authors')]
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

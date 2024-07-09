#' a function to subset the WCVP data set to an area of focus
#'
#' This function is run on the WCVP compressed archive downloaded by 'wcvp_update',
#' and requires some input from the user which specifies a geographic area to establish a
#' taxonomic look up table for.
#' @param path to where wczp is stored
#' @param continents one of: 'NORTHERN AMERICA', 'AFRICA', 'ANTARCTICA', 'ASIA-TROPICAL', 'ASIA-TEMPERATE', 'AUSTRALASIA', 'EUROPE', 'OCEANIA', 'SOUTHERN AMERICA', 'PACIFIC',
#' @param examples \dontrun{
#'reggs <- c('Northwestern U.S.A.', 'Southwestern U.S.A.',
#' North-Central U.S.A.', 'South-Central U.S.A.')
#'
#' oupu <- TaxUnpack(path = '~/Downloads',
#'                  continent = 'NORTHERN AMERICA')
#'
#' ## create names with authorities ##
#'
#' acc <- filter(oupu, taxon_status == 'Accepted')
#'
#' species <- filter(acc, taxon_rank == 'Species') %>%
#'  rename(specific_author = taxon_authors)
#'
#'infra <- filter(acc, taxon_rank %in% c('Variety', 'Subspecies')) %>%
#'  rename(infraspecific_author = taxon_authors)
#'
#' bases <- filter(species, plant_name_id %in% infra$parent_plant_name_id) %>%
#'  select(plant_name_id, specific_author)
#'
#' species <- left_join(infra, bases, by = c('parent_plant_name_id' = 'plant_name_id')) %>%
#'  relocate('specific_author', .after = species) %>%
#' relocate('infraspecific_author', .after = infraspecies) %>%
#' bind_rows(., species) |>
#'  arrange(family, genus, species) %>%
#' unite('taxon_name_author', genus:infraspecific_author, remove = FALSE, na.rm = TRUE, sep = ' ') |>
#' mutate(taxon_name_author = str_trim(taxon_name_author, side = 'both'),
#'        across(.cols  = infraspecific_rank:infraspecific_author, ~ na_if(.x, ' ')))
#'
#' rm(infra, acc, bases)
#' }
#'@param export
TaxUnpack <- function(path, continents, regions){

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


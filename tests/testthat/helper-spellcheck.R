make_spellcheck_tables <- function(path) {

  spp <- data.frame(
    taxon_name = c(
      "Astragalus purshii",
      "Helianthus annuus"
    ),
    gGRP = c("As", "He"),
    stringsAsFactors = FALSE
  )

  infra <- data.frame(
    taxon_name = c(
      "Linnaea borealis subsp. borealis"
    ),
    stringsAsFactors = FALSE
  )

  write.csv(
    spp,
    file.path(path, "species_lookup_table.csv"),
    row.names = FALSE
  )

  write.csv(
    infra,
    file.path(path, "infra_species_lookup_table.csv"),
    row.names = FALSE
  )
}

# check that genera and specific epithets are spelled (almost) correctly

this function attempts to verify the spelling of a user submitted
taxonomic name. If necessary it will proceed step-wise by name pieces
attempting to place them.

## Usage

``` r
spell_check(data, column, path)
```

## Arguments

- data:

  data frame/ tibble /sf object containing names to spell check

- column:

  a column containing the full name, genus, species, and infraspecific
  rank information as relevant.

- path:

  a path to a folder containing the taxonomic data.

## Examples

``` r
if (FALSE) { # \dontrun{
names <- data.frame(
 Full_name = c('Astagalus purshii', 'Linnaeus borealius ssp. borealis',
  'Heliumorus multifora', NA, 'Helianthus annuus'),
 Genus = c('Astagalus', 'Linnaeus', 'Heliumorus', NA, 'Helianthus'),
 Epithet = c('purshii', 'borealius', 'multifora', NA, 'annuus'))
names_l <- split(names, f = 1:nrow(names))
r <- lapply(names_l, spell_check, column = 'Full_name', path = p2tax)
} # }
```

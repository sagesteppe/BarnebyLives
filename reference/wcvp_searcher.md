# resolve a taxonomic name against the local WCVP checklist

this function replaces 'powo_searcher' now that Kew's POWO search API
blocks programmatic requests (HTTP 403 from any client/origin). For each
submitted name it looks up an exact match in the global
'id_lookup_table.csv' built by
[`TaxUnpack`](https://sagesteppe.github.io/BarnebyLives/reference/TaxUnpack.md),
then follows 'acceptednameusageid' to resolve synonyms to their
currently accepted family/genus/epithet/authority. The match is
deliberately global rather than restricted to the local, geographically
filtered lookup tables - WCVP distribution records are only kept against
accepted names, so a submitted synonym would never be found there. This
function is not a spell checker - names should already be run through
[`spell_check`](https://sagesteppe.github.io/BarnebyLives/reference/spell_check.md)
first, since only exact matches are resolved here.

## Usage

``` r
wcvp_searcher(data, column, path)
```

## Arguments

- data:

  data frame/tibble/sf object containing names to resolve

- column:

  a column containing the full name, genus, species, and infraspecific
  rank information as relevant.

- path:

  a path to a folder containing the taxonomic data set up by
  [`TaxUnpack`](https://sagesteppe.github.io/BarnebyLives/reference/TaxUnpack.md).

## Value

`data` with taxonomic columns appended: POW_Query, POW_Family,
POW_Genus, POW_Epithet, POW_Infrarank, POW_Infraspecies, POW_Authority,
and POW_Status (the taxonomic status of the originally matched name,
e.g. 'Accepted' or 'Synonym', so rows where a substitution occurred can
be reviewed).

## Examples

``` r
if (FALSE) { # \dontrun{
names <- data.frame(
 Full_name = c('Astragalus purshii', 'Linnaea borealis subsp. borealis'))
names_l <- split(names, f = 1:nrow(names))
r <- lapply(names_l, wcvp_searcher, column = 'Full_name', path = p2tax)
} # }
```

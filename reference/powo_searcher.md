# query plants of the world online for taxonomic information

a wrapper for kewr::search_powo

## Usage

``` r
powo_searcher(x)
```

## Arguments

- x:

  a vector of species names to submit, these should have clean spelling
  notes: results are observed to fail for valid infraspecies on Kew's
  end, and they seem not to mention valid infraspecies.

## Examples

``` r
library(dplyr)
pow_results <- lapply(
      c('Linnaea borealis var. borealis', 'Linnaea borealis var. americana',
      'Astragalus purshii', 'Pinus ponderosa'),
      powo_searcher) |>
   dplyr::bind_rows()
head(pow_results)
#>                         POW_Query     POW_Family
#> 1  Linnaea borealis var. borealis Caprifoliaceae
#> 2 Linnaea borealis var. americana Caprifoliaceae
#> 3              Astragalus purshii       Fabaceae
#> 4                 Pinus ponderosa       Pinaceae
#>                                     POW_Name_authority
#> 1                    Linnaea borealis L. var. borealis
#> 2 Linnaea borealis L. var. americana (J.Forbes) Rehder
#> 3                  Astragalus purshii Douglas ex G.Don
#> 4                  Pinus ponderosa Douglas ex C.Lawson
#>                     POW_Full_name POW_Binom_authority  POW_Genus POW_Epithet
#> 1  Linnaea borealis var. borealis                  L.    Linnaea    borealis
#> 2 Linnaea borealis var. americana                  L.    Linnaea    borealis
#> 3              Astragalus purshii    Douglas ex G.Don Astragalus     purshii
#> 4                 Pinus ponderosa Douglas ex C.Lawson      Pinus   ponderosa
#>   POW_Infrarank POW_Infraspecies POW_Infra_authority
#> 1          var.         borealis                <NA>
#> 2          var.        americana   (J.Forbes) Rehder
#> 3          <NA>             <NA>                <NA>
#> 4          <NA>             <NA>                <NA>
```

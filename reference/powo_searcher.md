# query plants of the world online for taxonomic information

**[Deprecated](https://rdrr.io/r/base/Deprecated.html)** a wrapper for
kewr::search_powo. Kew's POWO search API now blocks this style of
programmatic request (returns HTTP 403 regardless of client or origin),
so this function can no longer reach its data source. Use
[`wcvp_searcher`](https://sagesteppe.github.io/BarnebyLives/reference/wcvp_searcher.md)
instead, after setting up a local taxonomy backbone with
[`wcvp_update`](https://sagesteppe.github.io/BarnebyLives/reference/wcvp_update.md)
and
[`TaxUnpack`](https://sagesteppe.github.io/BarnebyLives/reference/TaxUnpack.md).

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
if (FALSE) { # \dontrun{
library(dplyr)
pow_results <- lapply(
      c('Linnaea borealis var. borealis', 'Linnaea borealis var. americana',
      'Astragalus purshii', 'Pinus ponderosa'),
      powo_searcher) |>
   dplyr::bind_rows()
head(pow_results)
} # }
```

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
#> Error: Request to 'http://www.plantsoftheworldonline.org/api/2/search' failed with code 500: Server error: (500) Internal Server Error
head(pow_results)
#> Error: object 'pow_results' not found
```

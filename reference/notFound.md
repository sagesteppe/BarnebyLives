# notify user if an entry had any results not found in POWO

simple function to run on 'powo_searcher' results to show species not
found which

## Usage

``` r
notFound(x)
```

## Arguments

- x:

  output of 'powo_searcher' after binding rows

## Value

messages to consoles indicating search terms, and there status if failed
to be found. This desirable because 'powo_searcher' squashes these
errors.

## Examples

``` r
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
library(crayon)
if (FALSE) { # \dontrun{
names_vec <- data(names_vec)
# 10 random species from taxize, usually 1 or 2 species are not found in Plants of the world online
pow_results <- lapply(names_vec, powo_searcher) |>
  dplyr::bind_rows()
# pow_results[,1:5]
# if there is not a family which is 'NOT FOUND', reshuffle the random species from taxize.
notFound(pow_results) # little message.
} # }
```

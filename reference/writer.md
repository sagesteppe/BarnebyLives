# write values and collapse NAs

This function will determine whether to print a variable onto labels or
hide it

## Usage

``` r
writer(x, italics)
```

## Arguments

- x:

  the input character of length 1

- italics:

  italicize or not? Boolean, defaults to FALSE

## Examples

``` r
writer(collection_examples[9,'Binomial_authority'] )
#> # A tibble: 1 × 1
#>   Binomial_authority
#>   <chr>             
#> 1 Greene            
writer(collection_examples[9, 'Infraspecies'], italics = TRUE )
#> [1] ""
```

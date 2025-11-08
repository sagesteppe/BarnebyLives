# ASCII compliant degree symbol

This function is required to pass R CMD CHECKS via generating an
appropriately encoded degree symbol in line.

## Usage

``` r
format_degree(x, symbol = "°")
```

## Arguments

- x:

  a value to add the symbol onto.

- symbol:

  fixed here as the degree symbol

## Examples

``` r
format_degree(180)
#> [1] "180°"
```

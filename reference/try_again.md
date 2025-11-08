# try to download from Kew again, with just the binomial

several infra species fail from POWO, retry the query with just the base
name. This not accessed directly by the user but used inside
'powo_searcher'

## Usage

``` r
try_again(x)
```

## Arguments

- x:

  output from the first step of 'powo_searcher'

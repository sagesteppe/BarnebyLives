# take mdy format date and make it written herbarium label format

take the 'month day year' date format, popular in North America, and
place it into a museum compliant text format

## Usage

``` r
date2text(x)
```

## Arguments

- x:

  a data frame with dates

## Examples

``` r
first50dates <- paste0(sample(3:9, size = 10, replace = TRUE), '-',
   sample(1:29, size = 10, replace = TRUE), '-',
   rep(2023, times = 10)
 )
head(first50dates)
#> [1] "9-5-2023"  "3-8-2023"  "8-1-2023"  "4-12-2023" "5-19-2023" "8-28-2023"
first50dates <- date2text(first50dates)
head(first50dates)
#> [1] "5 Sep, 2023"  "8 Mar, 2023"  "1 Aug, 2023"  "12 Apr, 2023" "19 May, 2023"
#> [6] "28 Aug, 2023"
```

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
#> [1] "9-6-2023"  "9-9-2023"  "6-22-2023" "4-10-2023" "5-21-2023" "3-2-2023" 
first50dates <- date2text(first50dates)
head(first50dates)
#> [1] "6 Sep, 2023"  "9 Sep, 2023"  "22 Jun, 2023" "10 Apr, 2023" "21 May, 2023"
#> [6] "2 Mar, 2023" 
```

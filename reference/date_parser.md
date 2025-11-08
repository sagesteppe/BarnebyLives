# create herbarium format dates for specimens

this function will return up to two additional columns with x.
'coll_date_text' a text format for the date of collection and
'det_date_text" a shorter text format date for identification

## Usage

``` r
date_parser(x, coll_date, det_date)
```

## Arguments

- x:

  an (sf/tibble/) data frame with both the collection date and
  determination date

- coll_date:

  date of collection, expected to be of the format 'MM/DD/YYYY', minor
  checks for compliance to the format will be carried out before
  returning an error.

- det_date:

  date of determination, same format and processes as above.

## Value

original data frame plus: x_dmy, x_day, x_month, x_year, x_text,
det_date_text, columns for both parameters which are supplied as inputs

## Examples

``` r
first50dates <- data.frame(
   collection_date = paste0(
   sample(3:9, size = 10, replace = TRUE), '-',
   sample(1:29, size = 10, replace  = TRUE), '-',
   rep(2023, times = 10 )))
dates <- date_parser(first50dates, coll_date = 'collection_date')
head(dates)
#>   collection_date collection_date_ymd collection_date_day collection_date_mo
#> 1        8-8-2023          2023-08-08                   8                  8
#> 2        6-1-2023          2023-06-01                   1                  6
#> 3       4-28-2023          2023-04-28                  28                  4
#> 4        3-1-2023          2023-03-01                   1                  3
#> 5        9-7-2023          2023-09-07                   7                  9
#> 6       8-12-2023          2023-08-12                  12                  8
#>   collection_date_yr collection_date_text
#> 1               2023          8 Aug, 2023
#> 2               2023          1 Jun, 2023
#> 3               2023         28 Apr, 2023
#> 4               2023          1 Mar, 2023
#> 5               2023          7 Sep, 2023
#> 6               2023         12 Aug, 2023
```

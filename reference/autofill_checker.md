# Search for accidental auto-increments from spreadsheet autofills

Spreadsheets like to automatically increment everything all the time.
Here we try to detect these where they may have effected the
coordinates. This function operates under the observation, that the
incrementation only occurs to the 'integers' or degrees

## Usage

``` r
autofill_checker(x)
```

## Arguments

- x:

  a data frame which has undergone 'dms2dd' from BarnebyLives

## Examples

``` r
coords <- data.frame(
  longitude_dd = c(rep(42.3456, times = 5), 43.3456),
  latitude_dd = c(rep(-116.7890, times = 5), -115.7890)
)
autofill_checker(coords) # note that all values in the column will
#>   longitude_dd latitude_dd Long_AutoFill_Flag Lat_AutoFill_Flag
#> 1      42.3456    -116.789               <NA>              <NA>
#> 2      42.3456    -116.789               <NA>              <NA>
#> 3      42.3456    -116.789               <NA>              <NA>
#> 4      42.3456    -116.789               <NA>              <NA>
#> 5      42.3456    -116.789               <NA>              <NA>
#> 6      43.3456    -115.789            Flagged           Flagged
# flagged after the occurrence (see 'Lat_AutoFill_Flag')
```

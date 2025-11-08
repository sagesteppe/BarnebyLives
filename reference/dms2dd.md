# this function parses coordinates from DMS to decimal degrees

this function parses coordinates from DMS to decimal degrees

## Usage

``` r
dms2dd(x, lat, long, dms)
```

## Arguments

- x:

  an input data frame to apply operations too

- lat:

  a name of the column holding the latitude values

- long:

  a name of the colymn holding the longitude values

- dms:

  are coordinates in degrees minutes seconds? TRUE for yes, FALSE for
  decimal degrees

## Value

data frame(/tibble) with coordinates unambiguously labeled as being in
both degrees, minutes, seconds (\_dms) and decimal degrees (\_dd).

## Examples

``` r
 coords <- data.frame(
  input_longitude = runif(15, min = -120, max = -100),
  input_latitude = runif(15, min = 35, max = 48)
)
coords_formatted <- dms2dd( coords )
#> argument to `lat` not found. detected and using:  input_latitude
#> argument to `long` not found. detected and using:  input_longitude
head(coords_formatted)
#>    longitude_dd latitude_dd latitude_dms longitude_dms
#>           <num>       <num>       <char>        <char>
#> 1:   -106.79281    38.28896   N 38°17'20   W 106°47'34
#> 2:   -109.76417    46.94444   N 46°56'40   W 109°45'51
#> 3:   -103.28895    46.27555   N 46°16'32   W 103°17'20
#> 4:   -105.82438    38.23100   N 38°13'52   W 105°49'28
#> 5:   -102.51588    40.23746   N 40°14'15   W 102°30'57
#> 6:   -119.77041    45.00519    N 45°0'19   W 119°46'13
colnames(coords_formatted)
#> [1] "longitude_dd"  "latitude_dd"   "latitude_dms"  "longitude_dms"

rm(coords, coords_formatted)

# example with tibble input
data(uncleaned_collection_examples)

dms2dd(uncleaned_collection_examples) |>
  dplyr::select(latitude_dd, longitude_dd, latitude_dms, longitude_dms)
#> argument to `lat` not found. detected and using:  Latitude
#> argument to `long` not found. detected and using:  Longitude
#> # A tibble: 117 × 4
#>    latitude_dd longitude_dd latitude_dms longitude_dms
#>          <dbl>        <dbl> <chr>        <chr>        
#>  1        39.3        -120. N 39°17'5    W 119°43'56  
#>  2        39.3        -120. N 39°17'2    W 119°43'54  
#>  3        39.3        -120. N 39°17'2    W 119°43'54  
#>  4        39.3        -120. N 39°17'3    W 119°44'1   
#>  5        39.3        -120. N 39°19'36   W 119°47'7   
#>  6        39.3        -120. N 39°19'36   W 119°47'7   
#>  7        39.3        -120. N 39°19'36   W 119°47'7   
#>  8        39.3        -120. N 39°19'36   W 119°47'7   
#>  9        39.3        -120. N 39°19'36   W 119°47'7   
#> 10        39.3        -120. N 39°19'36   W 119°47'7   
#> # ℹ 107 more rows
```

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
  longitude_dd = runif(15, min = -120, max = -100),
  latitude_dd = runif(15, min = 35, max = 48)
)
coords_formatted <- dms2dd( coords )
head(coords_formatted)
#>    longitude_dd latitude_dd latitude_dms longitude_dms
#>           <num>       <num>       <char>        <char>
#> 1:   -111.63277    43.24169   N 43°14'30   W 111°37'58
#> 2:   -106.62259    46.16266    N 46°9'46   W 106°37'21
#> 3:   -109.84699    42.36963   N 42°22'11   W 109°50'49
#> 4:   -106.79281    38.28896   N 38°17'20   W 106°47'34
#> 5:   -109.76417    46.94444   N 46°56'40   W 109°45'51
#> 6:   -103.28895    46.27555   N 46°16'32   W 103°17'20
colnames(coords_formatted)
#> [1] "longitude_dd"  "latitude_dd"   "latitude_dms"  "longitude_dms"
```

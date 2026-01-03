# create an sf object row by row to reflect different datum

This function creates an sf/tibble/dataframe for supporting the spatial
operations which BarnebyLives implements

## Usage

``` r
coords2sf(x, datum)
```

## Arguments

- x:

  a data frame which has undergone dms2dd function

- datum:

  a column, holding the datum values for each observation, works for
  WGS84, NAD83, NAD27

## Value

an sf/tibble/data frame of points in the same WGS84 coordinate reference
system

## Examples

``` r
mixed_datum <- data.frame(
 datum = (rep(c('nad27', 'NAD83', 'wGs84'), each = 5)),
 longitude_dd = runif(15, min = -120, max = -100),
 latitude_dd = runif(15, min = 35, max = 48)
 )

wgs84_dat <- coords2sf( mixed_datum )
str(wgs84_dat)
#> Classes ‘sf’ and 'data.frame':   15 obs. of  4 variables:
#>  $ datum       : chr  "WGS84" "WGS84" "WGS84" "WGS84" ...
#>  $ longitude_dd: num  -112 -119 -112 -100 -114 ...
#>  $ latitude_dd : num  37.9 38.9 43.3 41.2 40.6 ...
#>  $ geometry    :sfc_POINT of length 15; first list element:  'XY' num  -111.9 37.9
#>  - attr(*, "sf_column")= chr "geometry"
#>  - attr(*, "agr")= Factor w/ 3 levels "constant","aggregate",..: NA NA NA
#>   ..- attr(*, "names")= chr [1:3] "datum" "longitude_dd" "latitude_dd"
sf::st_crs(wgs84_dat)
#> Coordinate Reference System:
#>   User input: EPSG:4326 
#>   wkt:
#> GEOGCRS["WGS 84",
#>     ENSEMBLE["World Geodetic System 1984 ensemble",
#>         MEMBER["World Geodetic System 1984 (Transit)"],
#>         MEMBER["World Geodetic System 1984 (G730)"],
#>         MEMBER["World Geodetic System 1984 (G873)"],
#>         MEMBER["World Geodetic System 1984 (G1150)"],
#>         MEMBER["World Geodetic System 1984 (G1674)"],
#>         MEMBER["World Geodetic System 1984 (G1762)"],
#>         MEMBER["World Geodetic System 1984 (G2139)"],
#>         ELLIPSOID["WGS 84",6378137,298.257223563,
#>             LENGTHUNIT["metre",1]],
#>         ENSEMBLEACCURACY[2.0]],
#>     PRIMEM["Greenwich",0,
#>         ANGLEUNIT["degree",0.0174532925199433]],
#>     CS[ellipsoidal,2],
#>         AXIS["geodetic latitude (Lat)",north,
#>             ORDER[1],
#>             ANGLEUNIT["degree",0.0174532925199433]],
#>         AXIS["geodetic longitude (Lon)",east,
#>             ORDER[2],
#>             ANGLEUNIT["degree",0.0174532925199433]],
#>     USAGE[
#>         SCOPE["Horizontal component of 3D system."],
#>         AREA["World."],
#>         BBOX[-90,-180,90,180]],
#>     ID["EPSG",4326]]
```

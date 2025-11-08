# gather distance and azimuth from site to center of town

Help provide some simple context between the building and the

## Usage

``` r
site_writer(x, path)
```

## Arguments

- x:

  an sf/tibble/dataframe of locations with associated nearest locality
  data

- path:

  path to gnis_places

## Examples

``` r
if (FALSE) { # \dontrun{
library(sf)
sites <- data.frame(
 longitude_dd = runif(15, min = -120, max = -100),
 latitude_dd = runif(15, min = 35, max = 48)
 ) |>
 sf::st_as_sf(coords = c('longitude_dd', 'latitude_dd'), crs = 4326)

head(sites)
distaze_results <- site_writer(sites) # takes some time
head(distaze_results)
} # }
```

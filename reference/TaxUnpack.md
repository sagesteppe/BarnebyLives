# a function to subset the WCVP data set to an area of focus

This function is run on the WCVP compressed archive downloaded by
'wcvp_update', and requires some input from the user which specifies a
geographic area to establish a taxonomic look up table for.

## Usage

``` r
TaxUnpack(path, bound)
```

## Arguments

- path:

  Character vector. Location to where taxonomic data should be saved, we
  recommend a subdirectory in the same folder, and at the same level, as
  the geographic data.

- bound:

  Dataframe of x and y coordinates, same argument as to `data_setup`.
  Coordinates assumed in WG84, NAD83, or googles absurd projection.
  Coordinate specifications are very precise later in the process, but
  at this level any of these three are effectively equivalent.

## Examples

``` r
if (FALSE) { # \dontrun{

bound <- bound |>
  sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |>
  sf::st_bbox() |>
  sf::st_as_sfc()

oupu <- TaxUnpack(path = '/media/steppe/hdd/BL_sandbox/taxdata-MI', bound = bound)
} # }
```

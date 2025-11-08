# Determine which raster tiles to download for topographic variables

Given a bounding box, defining the spatial extent of the study area,
return a list of tiles names which need to be downloaded to cover this
area.

## Usage

``` r
tileSelector(bound)
```

## Arguments

- bound:

  Data frame. 'x' and 'y' coordinates of the extent for which the BL
  instance will cover.

## Examples

``` r
if (FALSE) { # \dontrun{
bound <- data.frame(
  y = c(30.1, 30.1, 49.5, 49.5, 30.1),
  x = c(-126, -82, -82, -126, -126)
)

bound <- data.frame(
  y = c(15, 50, 75, 44, 15),
  x = c(-63, -64, -180, -180, -180)
)

tileSelector(bound)
} # }
```

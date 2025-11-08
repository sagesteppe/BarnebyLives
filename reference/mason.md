# a wrapper around terra::makeTiles for setting the domain of a project

for projects with large spatial domains or using relatively high
resolution data, this will help

you make virtual tiles which do not need to be held in memory for the
project.

## Usage

``` r
mason(path, pathOut, tile_cellsV)
```

## Arguments

- path:

  the input directory with all geographic data.

- pathOut:

  the output directory for the final data product to go. Fn will
  automatically create folders for each product type.

- tile_cellsV:

  output of `make_tiles`

# Set up the downloaded data for a BarnebyLives instance

Once all data are downloaded for BarnebyLives use this function to set
them up to be used by the pipeline.

## Usage

``` r
data_setup(path, pathOut, bound, cleanup)
```

## Arguments

- path:

  Character. path to the folder where output from `data_download` was
  downloaded. Defaults to a subfolder within the working directory
  ('./geodata_raw').

- pathOut:

  Character. Path to the folder where final spatial data should be
  placed. Defaults to ('.'), and will create a 'geodata' directory
  within it to store results.

- bound:

  Data frame. 'x' and 'y' coordinates of the extent for which the BL
  instance will cover.

- cleanup:

  Boolean. Whether to remove the original zip files which were
  downloaded. Defaults to FALSE. Either mode of running the function
  will delete the uncompressed zip files generated during the process.
  If FALSE, this will also bundle the downloaded topographic variables
  into their own directories, e.g. all directories of 'aspect' rasters
  will go into a single 'aspect' directory.

## Examples

``` r
if (FALSE) { # \dontrun{
bound <- data.frame(
  y = c(42, 42, 44, 44, 42),
  x = c(-117, -119, -119, -117, -117)
)

setwd('/media/steppe/hdd/BL_sandbox/geodata_raw')
data_setup(path = '.', pathOut = '../geodata', bound = bound, cleanup = FALSE)
} # }
```

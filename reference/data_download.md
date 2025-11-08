# Download the data required to establish a BL instance

this function will download the data which are required to set up an
instance of BarnebyLives. These data must then be processed by the
`data_process` function to set up the directory structures
appropriately. Note that the function will test if the data already
exist in the location, if they do they will not be downloaded again.

Elevation data are available at
http://hydro.iis.u-tokyo.ac.jp/~yamadai/MERIT_DEM/ and require a free
and automatically approved account to download. Download from the second
set of data, under the 'GeoTiff format' header

## Usage

``` r
data_download(path)
```

## Arguments

- path:

  The root directory to save all the data in. Please specify a location,
  we suggest you make a directory for this. If not specified will
  default to your working directory.

- PADUS:

  Boolean. Defaults to FALSE. Honestly, downloading this single object
  takes much more hassle than it is worth. You should just download from
  : https://www.sciencebase.gov/catalog/item/652ef930d34edd15305a9b03
  you'll have to do a captcha, but just download the 'Geodatabase.zip'
  and place it in same directory as other files. Rename it as
  'PADUS.zip' and we are good to go.

## Examples

``` r
if (FALSE) { # \dontrun{
# setwd('/media/steppe/hdd/BL_sandbox/geodata_raw')
# download_data(path = '/media/steppe/hdd/BL_sandbox')
} # }
```

# identify a populated place near a collection and get directions from there

This function identifies the closest populated place, and makes a google
API call via the 'googleway' package to get directions from it to the
collection site. This function operates entirely within
'directions_grabber'

## Usage

``` r
get_google_directions(x, api_key)
```

## Arguments

- x:

  an sf/tibble/dataframe of locations

- api_key:

  a google developer api key for use with googleway

## Examples

``` r
# see 'directions_grabber'
```

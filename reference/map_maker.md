# make a quick county dot map to display the location of the collection

use sf to create a 20th centtury style 'dot map' which features the
state boundary and county lines.

## Usage

``` r
map_maker(x, states, path, collection_col)
```

## Arguments

- x:

  an sf dataframe of coordinates to make maps for, requires collection
  number and spatial attributes

- states:

  an sf object of the united states ala tigris::states()

- path:

  a directory to store the map images in before merging

- collection_col:

  column specify the collection number or other UNIQUE id for the
  collection

## Examples

``` r
# see the package vignette
```

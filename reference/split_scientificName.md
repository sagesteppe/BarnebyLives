# split out a scientific input column to pieces

This function attempts to split a scientific name into it's component
pieces. Given an input scientific, or scientific with scientific
authorities and infraspecies this function will parse them into the
columns used in the BarnebyLives pipeline.

## Usage

``` r
split_scientificName(x, sciName_col, overwrite)
```

## Arguments

- x:

  Dataframe with collection information.

- sciName_col:

  Character. Column containing the data to parse

- overwrite:

  Boolean. Whether to overwrite the original input columns, or simply
  append the spell checked columns.

## Examples

``` r
library(BarnebyLives)
ce <- collection_examples
ce <- collection_examples[
 sample(1:nrow(collection_examples), 25), 
 Sci_name = c('Collection_number', 'Name_authority')
]

split_scientificName(ce, sciName_col = 'Sci_name')|> head()
#> Error in x[, sciName_col]: Can't subset columns that don't exist.
#> ✖ Column `Sci_name` doesn't exist.
```

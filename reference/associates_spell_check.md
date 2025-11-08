# Format associated species, and spell check them internally

Apply proper capitalization to the species, and spell check all
components.

## Usage

``` r
associates_spell_check(x, column, path)
```

## Arguments

- x:

  a data frame containing collection info

- column:

  a column containing the family information

- path:

  a path to a folder containing the taxonomic data.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- data.frame('Vegetation' = 'Cypers sp., Persicara spp.,
  Eupatorium occidentalis, Eryngium articuatum, Menta canadense')
p2tax <- '/media/steppe/hdd/Barneby_Lives-dev/taxonomic_data'
associates_spell_check(df, column = 'Vegetation', path = p2tax)
} # }
```

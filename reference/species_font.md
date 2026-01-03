# ensure proper italicization of a associated species

This function works at the time of label creation to ensure that
abbreviations such as 'species' 'variety' and such are not italicized,
per convention.

## Usage

``` r
species_font(x)
```

## Arguments

- x:

  a value being feed into the label during the merge

## Examples

``` r
associates <- c('Eriogonum ovalifolium var. purpureum, Castilleja sp., Crepis spp.')
species_font(associates)
#> [1] "*Eriogonum ovalifolium* var. *purpureum, Castilleja* sp., *Crepis* spp."
```

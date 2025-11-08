# check that family is spelledcorrectly.

this function attempts to verify the spelling of a user submitted
taxonomic name.

## Usage

``` r
family_spell_check(x, path)
```

## Arguments

- x:

  data frame/ tibble /sf object containing names to spell check

- path:

  a path to a folder containing the taxonomic data.

## Examples

``` r
if (FALSE) { # \dontrun{
names <- data.frame(
 Collection_number = 1:3,
 Family = c('Asteracea', 'Flabaceae', 'Onnagraceae')
)
spelling <- family_spell_check(names, path = '../taxonomic_data')
} # }
```

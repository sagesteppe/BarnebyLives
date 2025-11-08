# Check spelling of botanical author abbreviations

Determine whether the spelling of a botanical author abbreviation
matches one in the IPNI index. This function will not seek a correct
spelling, but rather only flag spellings which are not present in the
abbreviations section of the IPNI database

## Usage

``` r
author_check(x, path)
```

## Arguments

- x:

  an sf/dataframe/tibble of species identities including an Authority
  column

- path:

  a path to the directory containing the abbrevation data

## Examples

``` r
if (FALSE) { # \dontrun{
df <- data.frame(
  Genus = c('Lomatium', 'Linnaea', 'Angelica', 'Mentzelia', 'Castilleja'),
  Epithet = c('dissectum', 'borealis', 'capitellata', 'albicaulis', 'pilosa'),
  Binomial_authority = c('(Pursh) J.M. Coult & Rose', 'L.',
                         '(A. Gray) Spalik, Reduron & S.R.Downie',
                         '(Douglas ex Hook.) Douglas ex Torr. & A. Gray', NA),
  Infrarank = c(NA, 'var.', NA, NA, 'var.'),
  Infraspecies  =c(NA, 'americana', NA, NA, 'pilosa'),
  Infraspecific_authority = c(NA, '(J. Forbes) Rehder', NA, NA, '(S. Watson) Rydb.')
  )
head(df)
author_check(df, path = '/hdd/Barneby_Lives-dev/taxonomic_data')
# we know that the proper abbreviation is 'J.M. Coult.' short for 'Coulter'
# and 'S.R. Downie' is more human readable than 'S.R.Downie' (no space)
} # }
```

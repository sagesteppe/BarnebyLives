# Easily compare POW column to input columns

pronounced 'pounce'. After querying the POW database via 'powo_searcher'
this function will mark POW cells which are identical to the input
(verified cleaned) as NA ideally making it easier for person to process
there results and prepare there data for sharing via labels and
digitally.

## Usage

``` r
powNAce(x)
```

## Arguments

- x:

  an sf/data frame/tibble which has both the input and POW ran data on
  it

## Examples

``` r
if (FALSE) { # \dontrun{
df <- data.frame(
 POW_Genus = c('Castilleja', 'Linnaea', 'Dimeresia'),
 POW_Epithet = c('pilosa', 'borealis', 'howellii'),
 POW_Infrarank = c('var.', 'var.', NA),
 POW_Infraspecies =  c('pilosa', 'americana', NA),
 POW_Authority =  c('(S. Watson) Rydb.', '(J. Forbes) Rehder', 'A. Gray')
)
powNAce(df)
} # }
```

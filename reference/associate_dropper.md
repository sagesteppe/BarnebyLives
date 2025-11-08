# remove collection from associated species

Removes the collected species from the list of associated species

## Usage

``` r
associate_dropper(x, Binomial, col)
```

## Arguments

- x:

  data frame containing collection info

- Binomial:

  Character. a column containing the name of the collection, without
  authorship. Defaults to 'Full_name'.

- col:

  Character. the column with the species to be checked

## Examples

``` r
ce <- data.frame(
Full_name = c(
  'Microseris gracilis', 'Alyssum desertorum', 'Ceratocephala testiculata'),
Associates = rep(
   'Microseris gracilis, Lupinus lepidus, Alyssum desertorum, Ceratocephala testiculata',
 times = 3)
)

associate_dropper(ce, col = 'Associates')
#> Argument to `Binomial` not supplied, defaulting to `Full_name`
#>                   Full_name
#> 1       Microseris gracilis
#> 2        Alyssum desertorum
#> 3 Ceratocephala testiculata
#>                                                        Associates
#> 1  Lupinus lepidus, Alyssum desertorum, Ceratocephala testiculata
#> 2 Microseris gracilis, Lupinus lepidus, Ceratocephala testiculata
#> 3        Microseris gracilis, Lupinus lepidus, Alyssum desertorum
```

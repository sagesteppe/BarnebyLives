# do or don't write the associated plant species

This functions determines whether to write information on associated
plant species. It used as a final step when formatting labels.

## Usage

``` r
associates_writer(x)
```

## Arguments

- x:

  data frame holding the values

## Examples

``` r
library(BarnebyLives)
hilaria <- collection_examples[73,]
associates_writer(hilaria$Vegetation)
#> [1] "Ass.: *Artemisia nova, Kochia* sp., *Pleuraphis rigida, Elymus multisetus*."
agoseris <- collection_examples[82,]
associates_writer(agoseris$Associates)
#> [1] "Ass.: *Lupinus* sp., *Perideridia* sp., *Phlox hoodii*."
```

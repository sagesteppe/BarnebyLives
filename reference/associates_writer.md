# do or don't write the associated plant species

This functions determines whether to write information on associated
plant species. It used as a final step when formatting labels.

## Usage

``` r
associates_writer(x, full = FALSE)
```

## Arguments

- x:

  data frame holding the values

- full:

  Boolean. If TRUE, write "Associates" if FALSE (the default), write
  "Ass.:".

## Examples

``` r
library(BarnebyLives)
hilaria <- collection_examples[73,]
associates_writer(hilaria$Vegetation)
#> [1] "Ass.: \\textit{Sarcobatus vermiculatus}."
agoseris <- collection_examples[82,]
associates_writer(agoseris$Associates)
#> [1] "Ass.: \\textit{Lupinus} sp., \\textit{Perideridia} sp., \\textit{Phlox hoodii}."
```

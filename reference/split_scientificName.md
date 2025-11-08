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
ce <- data.frame(
  Collection_number = ce$Collection_number[sample(1:nrow(ce), size = 100, replace = FALSE)],
  Binomial = c(ce$Full_name, ce$Name_authority)[sample(1:nrow(ce)*2, size = 100, replace = FALSE)],
  Binomial_authority = ce$Binomial_authority[sample(1:nrow(ce), size = 100, replace = FALSE)]
) # extra columns to challenge name search - values are meaningless

split_scientificName(ce)|> head()
#> `sciName_col` argument not supplied, using: Binomial
#>   Collection_number
#> 1              2859
#> 2              2933
#> 3              2927
#> 4              2834
#> 5              2901
#> 6              2863
#>                                                           x...sciName_col.
#> 1                                                Crepis occidentalis Nutt.
#> 2                                                     Ipomopsis polycladon
#> 3                                                            Allium parvum
#> 4                                                         Allium nevadense
#> 5 Bromus sitchensis Trin. var. marginatus (Piper) Otting and R.E. Brainerd
#> 6                                                      Lupinus brevicaulis
#>       Genus      Epithet        Binomial_authority       Name_authority
#> 1    Crepis occidentalis Crepis occidentalis Nutt.                Nutt.
#> 2 Ipomopsis   polycladon      Ipomopsis polycladon Ipomopsis polycladon
#> 3    Allium       parvum             Allium parvum        Allium parvum
#> 4    Allium    nevadense          Allium nevadense     Allium nevadense
#> 5    Bromus   sitchensis   Bromus sitchensis Trin.                Trin.
#> 6   Lupinus  brevicaulis       Lupinus brevicaulis  Lupinus brevicaulis
#>   Infraspecific_rank Infraspecies Infraspecific_authority
#> 1               <NA>         <NA>                    <NA>
#> 2               <NA>         <NA>                    <NA>
#> 3               <NA>         <NA>                    <NA>
#> 4               <NA>         <NA>                    <NA>
#> 5               <NA>         <NA>                    <NA>
#> 6               <NA>         <NA>                    <NA>
split_scientificName(ce, sciName_col = 'Binomial') |> head()
#>   Collection_number
#> 1              2859
#> 2              2933
#> 3              2927
#> 4              2834
#> 5              2901
#> 6              2863
#>                                                           x...sciName_col.
#> 1                                                Crepis occidentalis Nutt.
#> 2                                                     Ipomopsis polycladon
#> 3                                                            Allium parvum
#> 4                                                         Allium nevadense
#> 5 Bromus sitchensis Trin. var. marginatus (Piper) Otting and R.E. Brainerd
#> 6                                                      Lupinus brevicaulis
#>       Genus      Epithet        Binomial_authority       Name_authority
#> 1    Crepis occidentalis Crepis occidentalis Nutt.                Nutt.
#> 2 Ipomopsis   polycladon      Ipomopsis polycladon Ipomopsis polycladon
#> 3    Allium       parvum             Allium parvum        Allium parvum
#> 4    Allium    nevadense          Allium nevadense     Allium nevadense
#> 5    Bromus   sitchensis   Bromus sitchensis Trin.                Trin.
#> 6   Lupinus  brevicaulis       Lupinus brevicaulis  Lupinus brevicaulis
#>   Infraspecific_rank Infraspecies Infraspecific_authority
#> 1               <NA>         <NA>                    <NA>
#> 2               <NA>         <NA>                    <NA>
#> 3               <NA>         <NA>                    <NA>
#> 4               <NA>         <NA>                    <NA>
#> 5               <NA>         <NA>                    <NA>
#> 6               <NA>         <NA>                    <NA>
```

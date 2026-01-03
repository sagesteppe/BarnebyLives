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
#>   Collection_number                  x...sciName_col.        Genus    Epithet
#> 1              2858              Cordylanthus ramosus Cordylanthus    ramosus
#> 2              2829          Scutellaria nana A. Gray  Scutellaria       nana
#> 3              2861                Astragalus filipes   Astragalus    filipes
#> 4              2859              Sphaeralcea munroana  Sphaeralcea   munroana
#> 5              2928                    Diplacus nanus     Diplacus      nanus
#> 6              2834 Bromus sitchensis var. marginatus       Bromus sitchensis
#>         Binomial_authority       Name_authority Infraspecific_rank Infraspecies
#> 1     Cordylanthus ramosus Cordylanthus ramosus               <NA>         <NA>
#> 2 Scutellaria nana A. Gray              A. Gray               <NA>         <NA>
#> 3       Astragalus filipes   Astragalus filipes               <NA>         <NA>
#> 4     Sphaeralcea munroana Sphaeralcea munroana               <NA>         <NA>
#> 5           Diplacus nanus       Diplacus nanus               <NA>         <NA>
#> 6        Bromus sitchensis    Bromus sitchensis               <NA>         <NA>
#>   Infraspecific_authority
#> 1                    <NA>
#> 2                    <NA>
#> 3                    <NA>
#> 4                    <NA>
#> 5                    <NA>
#> 6                    <NA>
split_scientificName(ce, sciName_col = 'Binomial') |> head()
#>   Collection_number                  x...sciName_col.        Genus    Epithet
#> 1              2858              Cordylanthus ramosus Cordylanthus    ramosus
#> 2              2829          Scutellaria nana A. Gray  Scutellaria       nana
#> 3              2861                Astragalus filipes   Astragalus    filipes
#> 4              2859              Sphaeralcea munroana  Sphaeralcea   munroana
#> 5              2928                    Diplacus nanus     Diplacus      nanus
#> 6              2834 Bromus sitchensis var. marginatus       Bromus sitchensis
#>         Binomial_authority       Name_authority Infraspecific_rank Infraspecies
#> 1     Cordylanthus ramosus Cordylanthus ramosus               <NA>         <NA>
#> 2 Scutellaria nana A. Gray              A. Gray               <NA>         <NA>
#> 3       Astragalus filipes   Astragalus filipes               <NA>         <NA>
#> 4     Sphaeralcea munroana Sphaeralcea munroana               <NA>         <NA>
#> 5           Diplacus nanus       Diplacus nanus               <NA>         <NA>
#> 6        Bromus sitchensis    Bromus sitchensis               <NA>         <NA>
#>   Infraspecific_authority
#> 1                    <NA>
#> 2                    <NA>
#> 3                    <NA>
#> 4                    <NA>
#> 5                    <NA>
#> 6                    <NA>
```

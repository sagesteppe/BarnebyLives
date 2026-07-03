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
ce <- collection_examples[
 sample(1:nrow(collection_examples), 25),
]

split_scientificName(ce, sciName_col = 'Full_name') |> head()
#> # A tibble: 6 × 73
#>   Collection_number Primary_Collector Associated_Collectors Project_Accession_No
#>               <dbl> <chr>             <chr>                 <chr>               
#> 1              2879 Reed Clark Benke… NA                    NA                  
#> 2              2833 Reed Clark Benke… Linda Martin, Payton… NA                  
#> 3              2823 Reed Clark Benke… NA                    NA                  
#> 4              2922 Reed Clark Benke… NA                    NA                  
#> 5              2895 Reed Clark Benke… Payton Lott           NA                  
#> 6              2920 Reed Clark Benke… NA                    NA                  
#> # ℹ 69 more variables: Full_name <chr>, Binomial_authority_issues <chr>,
#> #   Infrarank <chr>, Infra_auth_issues <chr>, Family <chr>, Project_name <chr>,
#> #   Site_name <chr>, latitude_dd <dbl>, longitude_dd <dbl>, Datum <chr>,
#> #   Coordinate_Uncertainty <chr>, Directions <chr>, Vegetation <chr>,
#> #   Associates <chr>, Habitat <chr>, Fide <chr>, Determined_by <chr>,
#> #   Aspect <chr>, Slope <dbl>, Notes <chr>, Tissue_collections <dbl>,
#> #   Date_digital <chr>, Date_digital_dmy <dttm>, Date_digital_day <dbl>, …
```

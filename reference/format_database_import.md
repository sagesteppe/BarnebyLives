# Export a spreadsheet for mass upload to an herbariums database

Only a few schemas are currently supported, but we always seek to add
more.

## Usage

``` r
format_database_import(x, format)
```

## Arguments

- x:

  data frame holding the final output from BarnebyLives

- format:

  a character vector indicating which database to create output for.

## Examples

``` r
library(BarnebyLives)
dat4import <- format_database_import(collection_examples, format = 'JEPS')

# we also know a bit about our material and can populate it here by hand #
dat4import |>
  dplyr::mutate(
   Label_Footer = 'Collected under the auspices of the Bureau of Land Management',
   Coordinate_Uncertainty_In_Meters = 5,
    Coordinate_Source = 'iPad')
#> # A tibble: 115 × 28
#>    Locality    Coll_Num Coll_Date Main_Collector Other_Collectors ScientificName
#>    <chr>          <dbl> <chr>     <chr>          <chr>            <chr>         
#>  1 1.4mi at 2…     2819 6 May, 2… Reed Clark Be… NA               Poa secunda J…
#>  2 1.3mi at 2…     2820 6 May, 2… Reed Clark Be… NA               Prunus anders…
#>  3 1.3mi at 2…     2821 6 May, 2… Reed Clark Be… NA               Layia glandul…
#>  4 1.4mi at 2…     2822 6 May, 2… Reed Clark Be… NA               Phlox longifo…
#>  5 0.5mi at 1…     2823 6 May, 2… Reed Clark Be… NA               Lomatium neva…
#>  6 0.5mi at 1…     2824 6 May, 2… Reed Clark Be… NA               Camissonia co…
#>  7 0.5mi at 1…     2825 15 May, … Reed Clark Be… NA               Lomatium neva…
#>  8 0.5mi at 1…     2826 15 May, … Reed Clark Be… NA               Viola purpure…
#>  9 0.5mi at 1…     2827 15 May, … Reed Clark Be… NA               Agoseris retr…
#> 10 0.5mi at 1…     2828 15 May, … Reed Clark Be… NA               Purshia tride…
#> # ℹ 105 more rows
#> # ℹ 22 more variables: DeterminedBy <chr>, Det_Date_Display <chr>,
#> #   Label_Header <chr>, Label_Footer <chr>, Plant_Description <chr>,
#> #   Comments <lgl>, Habitat <chr>, Associated_Taxa <chr>, Country <chr>,
#> #   State_Province <chr>, County <chr>, Latitude <dbl>, Longitude <dbl>,
#> #   Datum <chr>, Coordinate_Uncertainty_In_Meters <dbl>,
#> #   Coordinate_Source <chr>, Elevation <chr>, Elevation_Units <chr>, …
```

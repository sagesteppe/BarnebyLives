# format collector info and codes

Format these data to have commas or periods as appropriate

## Usage

``` r
collection_writer(x)
```

## Arguments

- x:

  dataframe holding the values

## Examples

``` r
data('collection_examples')
ce <- collection_examples[14,]
collection_writer(ce)
#> [1] "Reed Clark Benkendorf 2833, Linda Martin, Payton Lott; 8 Jun, 2023"
```

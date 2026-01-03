# format collector info and codes

Format these data to have commas or periods as appropriate

## Usage

``` r
collection_writer(x, date = TRUE)
```

## Arguments

- x:

  dataframe holding the values

- date:

  Boolean, default TRUE. Whether to write the collection date.

## Examples

``` r
data('collection_examples')
ce <- collection_examples[12,]
collection_writer(ce)
#> [1] "Reed Clark Benkendorf 2830; 15 May, 2023"
collection_writer(ce, date = FALSE)
#> [1] "Reed Clark Benkendorf 2830"
collection_writer(collection_examples[106,])
#> [1] "Reed Clark Benkendorf 2925, H. Sermersheim, G. Rytting; 1 Aug, 2023"
```

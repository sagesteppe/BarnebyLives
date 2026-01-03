# do or don't write determination information

This functions determines whether to write information on whom
determined the specimen when, and via which texts. It used as a final
step when formatting labels.

## Usage

``` r
writer_fide(x)
```

## Arguments

- x:

  data frame holding the values

## Examples

``` r
text <- data.frame(
Fide = c('Michigan Flora Book (emphatic)',
        'Michigan Flora Book (emphatic) verbose',
        'Michigan Flora Book'),
Determined_by = rep('Marabeth', 3),
Determined_date_text = rep('a day in time', 3)
) |>
 split(f = 1:3)

lapply(text, writer_fide)
#> $`1`
#> [1] "Fide: \\textit{Michigan Fl. Book }(emphatic), det.: Marabeth, a day in time."
#> 
#> $`2`
#> [1] "Fide: \\textit{Michigan Fl. Book }(emphatic) \\textit{ verbose}, det.: Marabeth, a day in time."
#> 
#> $`3`
#> [1] "Fide: \\textit{Michigan Fl. Book}, det.: Marabeth, a day in time."
#> 
```

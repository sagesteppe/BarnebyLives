# write herbarium labels to pdf

This function uses the BarnebyLives custom template to write labels ala
a mail merge. Each label will be written as a separate file with the
dimensions of 4x4 inches.

## Usage

``` r
label_writer(x, outdir)
```

## Arguments

- x:

  a path to a csv of labels which have been cleaned with BL, and which
  the analyst has evaluated for conflicts.

- outdir:

  an output directory to hold the files.

## Examples

``` r
if (FALSE) { # \dontrun{
label_writer(collection_examples, BL_label_example)
} # }
```

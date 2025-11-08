# install or update World Vascular Plants Checklist

This function checks to see whether the version of WCVP is the most
current, if not, it will re-download WCVP and set up the BL taxonomy
structure.

## Usage

``` r
wcvp_update(tax_dat_p)
```

## Arguments

- tax_dat_p:

  the path to the taxonomic data, the raw wcvp.zip should be there.

## Examples

``` r
if (FALSE) { # \dontrun{
wcvp_update('/home/sagesteppe/Downloads')
} # }
```

# Safe untar wrapper

Internal helper around [`untar()`](https://rdrr.io/r/utils/untar.html) /
system tar to smooth over differences between Linux, macOS, and Windows.
On macOS, prefers GNU tar (`gtar`) if available; otherwise falls back to
system BSD tar and warns that hardlink issues may occur. Suggests
`brew install gnu-tar` when relevant.

## Usage

``` r
safe_untar(archive, exdir, verbose = TRUE)
```

## Arguments

- archive:

  Path to the `.tar` or `.tar.gz` file.

- exdir:

  Directory to extract into.

- verbose:

  Logical; print messages about which backend is used.

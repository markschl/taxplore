# Generate a HTML chart in R

This does not rely on the external KronaTools software (see
[kt_import_xml](https://markschl.github.io/taxplore/reference/kt_import_xml.md)).

## Usage

``` r
generate_krona_html_internal(
  xml,
  outfile = NULL,
  kronatools_dir = NULL,
  resources_url = NULL,
  minify = FALSE,
  snapshot = FALSE,
  ...
)
```

## Arguments

- xml:

  Krona XML string

- outfile:

  Write the string to file instead of returning the HTML character
  string.

- resources_url, interactive, minify, snapshot:

  See
  [ChartOpts](https://markschl.github.io/taxplore/reference/ChartOpts.md)

- ...:

  Additional arguments are currently ignored

## Value

The generated HTML, or NULL if `outfile` was specified

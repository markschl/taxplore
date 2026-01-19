# Generate a HTML chart using the official Krona tools

The `ktImportXML` script from the Krona tools
(<https://github.com/marbl/Krona>) must be available in *\$PATH*.
Alternatively, the path to the extracted *KronaTools* directory can be
specified with `kronatools_dir`.

## Usage

``` r
kt_import_xml(
  xml,
  outfile = NULL,
  kronatools_dir = NULL,
  resources_url = NULL,
  ...
)
```

## Arguments

- xml:

  Krona XML string

- outfile:

  Write the string to file instead of returning the HTML character
  string.

- kronatools_dir, resources_url:

  see
  [ChartOpts](https://markschl.github.io/taxplore/reference/ChartOpts.md)

- ...:

  Additional arguments are ignored

## Value

The generated HTML, or NULL if `outfile` was specified

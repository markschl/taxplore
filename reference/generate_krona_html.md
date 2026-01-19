# Generates a HTML chart from a character string containing the Krona XML.

With `method = 'internal'` (the default), R implementation in this
package is used, which by default embeds the unmodified Krona JavaScript
source code delivered with this package, or a minified version of it
with `minify = TRUE`. (see
[`generate_krona_html_internal()`](https://markschl.github.io/taxplore/reference/generate_krona_html_internal.md)).

## Usage

``` r
generate_krona_html(xml, method = c("internal", "kronatools"), ...)
```

## Details

Alternatively, `method = 'kronatools'` uses the official Krona software
(see
[`kt_import_xml()`](https://markschl.github.io/taxplore/reference/kt_import_xml.md)).
The resulting HTML should be the same, although the 'internal' method
provides additional options that are useful when embedding charts in
documents. Therefore, this is the default method.

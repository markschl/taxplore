# General chart options

General chart options

## Usage

``` r
ChartOpts(
  max_digits = getOption("taxplore.max_digits", 7),
  hue_range = getOption("taxplore.hue_range", c(0, 120)),
  unknown_label = getOption("taxplore.unknown_label"),
  root_label = getOption("taxplore.root_label", "Root"),
  total_label = getOption("taxplore.total_label", "Total"),
  method = getOption("taxplore.method"),
  resources_url = getOption("taxplore.resources_url"),
  interactive = getOption("taxplore.interactive"),
  minify = getOption("taxplore.minify"),
  kronatools_dir = getOption("taxplore.kronatools_dir")
)
```

## Arguments

- max_digits:

  Maximum number of significant digits to print for decimal numbers.
  Reducing to \<7 digits (the default) may help in obtaining smaller
  HTML files.

- total_label:

  Label for the total abundance displayed on the top right of the chart.

- method:

  HTML generation method ('internal' or 'kronatools'), ' passed to
  [generate_krona_html](https://markschl.github.io/taxplore/reference/generate_krona_html.md)

- minify:

  If `TRUE`, a minified version of the Krona JavaScript is included
  Automatically activated in
  [plot_krona](https://markschl.github.io/taxplore/reference/plot_krona.md)
  when embedded This option is ignored if `method = 'kronatools'` and
  has no effect if `resources_url` is provided.

- hue_range::

  Hue at the start and end points of the fill gradient if coloring by a
  user-specified gradient (see `color` and `color_value_range` arguments
  in `make_krona`).

- unknown_label::

  Label to set instead of `NA`s in the classification/taxonomy (if any
  present). By default, `NA`s are left in place, resulting in fewer
  child nodes. Krona charts handle this situation well (see e.g.
  https://krona.sourceforge.net/examples/xml.krona.html).

- root_label::

  Label to use for the root of the taxonomic tree. It is only displayed
  if the uppermost level in the hierarchy has more than one category, or
  `collapse` is disabled (see
  [ChartDisplayOpts](https://markschl.github.io/taxplore/reference/ChartDisplayOpts.md)).

- resources_url::

  Optional URL pointing to remote Javascript and image resources, which
  will then be linked to instead of embedded into the chart. The
  resulting charts are not be standalone and require an internet
  connection for displaying, but the HTML file size is smaller. Example:
  `resources_url = 'http://marbl.github.io/Krona/'` The given URL
  address should serve the contents of the 'src' and 'img' directories
  from KronaTools
  (https://github.com/marbl/Krona/tree/master/KronaTools) (see
  [copy_krona_resources](https://markschl.github.io/taxplore/reference/copy_krona_resources.md)).

- kronatools_dir::

  Optional path pointing to a 'KronaTools' directory extracted from the
  Krona source code archive, downloaded from
  [here](https://github.com/marbl/Krona/releases/latest). This option is
  ignored if `method = 'internal'`.

- snapshot:

  If `TRUE`, the Krona chart is immediately turned into a
  non-interactive snapshot. In contrast to the `interactive` parameter
  of `plot_krona`, this option permanently modifies the chart HTML code,
  so files exported with `outfile = ...` will also be non-interactive.

## Details

There are different ways to apply these options:

- Supply options directly to
  [make_krona](https://markschl.github.io/taxplore/reference/make_krona.md)
  or
  [plot_krona](https://markschl.github.io/taxplore/reference/plot_krona.md):
  `plot_krona(..., root_label = 'Records')`

- Supply as `opts` to
  [make_krona](https://markschl.github.io/taxplore/reference/make_krona.md)
  or
  [plot_krona](https://markschl.github.io/taxplore/reference/plot_krona.md):
  `make_krona(..., opts = ChartOpts(...))`

- Set global defaults before the call(s) to
  [`make_krona()`](https://markschl.github.io/taxplore/reference/make_krona.md):
  `set_chart_opts(...)`

- Set with [options](https://rdrr.io/r/base/options.html) as follows:
  `options(taxplore.optionname, value)`

## See also

[make_krona](https://markschl.github.io/taxplore/reference/make_krona.md)

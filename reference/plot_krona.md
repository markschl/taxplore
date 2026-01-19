# Display a Krona chart as HTML widget

Pre-generated HTML charts can be displayed given a character string or
supplied with `file = ...`, or the chart can be directly generated with
[`make_krona()`](https://markschl.github.io/taxplore/reference/make_krona.md)
and directly displayed.

## Usage

``` r
plot_krona(
  x,
  ...,
  file = NULL,
  outfile = NULL,
  opts = NULL,
  display = NULL,
  interactive = NULL,
  width = NULL,
  height = NULL,
  elementId = NULL
)
```

## Arguments

- x:

  Character string with a pre-generated HTML chart, or a matrix, data
  frame, list or phyloseq object that serves as input for generating the
  chart with
  [`make_krona()`](https://markschl.github.io/taxplore/reference/make_krona.md).

- ...:

  Additional arguments passed to
  [make_krona](https://markschl.github.io/taxplore/reference/make_krona.md)

- file:

  File path, URL or file connection pointing to an already generated
  chart (passed instead of `x`)

- outfile:

  Write the embedded chart to file

- display:

  A
  [`ChartDisplayOpts()`](https://markschl.github.io/taxplore/reference/ChartDisplayOpts.md)
  instance configuring the (initial) appearance of embedded charts or
  snapshots.

- interactive:

  If `FALSE`, a non-interactive HTML chart is shown, which does not have
  any buttons and does not allow selecting and zooming. This is
  primarily useful for taking snapshots of embedded widgets, and is
  automatically activated in plot_krona when rendering in static
  documents. If set to `TRUE`, charts embedded in static documents such
  as PDF and Word are unmodified snapshots with buttons and other
  controls. Note that `outfile = ...` still exports a "normal"
  interactive Krona chart (see `snapshot` option in
  [ChartOpts](https://markschl.github.io/taxplore/reference/ChartOpts.md)
  for making the exported chart non-interactive).

- width, height:

  Width/height of the widget. Must be a valid CSS unit (like `'100%'`,
  `'400px'`, `'auto'`) or a number, which will be coerced to a string
  and have `'px'` appended.

## Value

A [HTML widget](https://www.htmlwidgets.org) embedable in
[R-Markdown](https://rmarkdown.rstudio.com) /
[Quarto](https://quarto.org) documents. Optionally, `outfile` can be
specified to also save the chart to a HTML file.

## Details

When generating the widget, some settings are adjusted depending on the
environment. In static (non-HTML) documents such as PDF or Word, a
snapshot is taken, which hides the buttons, search box and other things
(can be changed with `interactive = TRUE`). Still, some additional
configuration might be required to ensure that the charts look nice in
every context (see
[`taxplore_configure_snapshot()`](https://markschl.github.io/taxplore/reference/taxplore_configure_snapshot.md)).

## See also

[`make_krona()`](https://markschl.github.io/taxplore/reference/make_krona.md),
[`ChartOpts()`](https://markschl.github.io/taxplore/reference/ChartOpts.md),
[`ChartDisplayOpts()`](https://markschl.github.io/taxplore/reference/ChartDisplayOpts.md)

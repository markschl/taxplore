# Configure the initial chart appearance

Configure the initial chart appearance

## Usage

``` r
ChartDisplayOpts(
  collapse = getOption("taxplore.display.collapse", TRUE),
  showMagnitude = getOption("taxplore.display.showMagnitude", FALSE),
  color = getOption("taxplore.display.color"),
  depth = getOption("taxplore.display.depth"),
  font = getOption("taxplore.display.font", 11),
  key = getOption("taxplore.display.key", TRUE),
  dataset = getOption("taxplore.display.dataset"),
  node = getOption("taxplore.display.node")
)
```

## Arguments

- collapse:

  (logical or 'true'/'false') Should the chart be simplified, collapsing
  'redundant' wedges? (on by default)

- showMagnitude:

  (logical or 'true'/'false') Should magnitudes be displayed in
  \[brackets\]?

- color:

  (logical or 'true'/'false') Color by a custom scheme along a a
  gradient of an attribute variable (see `color`). Automatically
  activated `TRUE` if `color` is set in
  [make_krona](https://markschl.github.io/taxplore/reference/make_krona.md)
  or
  [plot_krona](https://markschl.github.io/taxplore/reference/plot_krona.md),
  unless explicitly set to `FALSE` here.

- depth:

  (number) Maximum number of ranks/levels that should be displayed
  (unlimited by default)

- font:

  (number) Font size (px/pt) (default: 11)

- key:

  (logical or 'true'/'false') Should a list of small wedges ('key') be
  displayed on the bottom right of the chart? (displayed by default)

- dataset:

  (number) Dataset number (see `group`/`group_col`)

- node:

  (number) Node number to highlight...

## Details

The `ChartDisplayOpts` configure the initial (default) appearance of
embedded Krona charts. Some of the settings correspond to checkboxes on
the left. The same parameters can also be passed as key-value (GET) URL
parameters to Krona HTML charts, see Krona wiki:

- https://github.com/marbl/Krona/wiki/Customizing-the-view

- https://github.com/marbl/Krona/wiki/Changing-chart-viewing-defaults

There are different ways to apply these options:

- Directly supply them to
  [make_krona](https://markschl.github.io/taxplore/reference/make_krona.md)
  as follows: `make_krona(..., display = ChartDisplayOpts(...))`

- Set global defaults before the call(s) to
  [`make_krona()`](https://markschl.github.io/taxplore/reference/make_krona.md):
  `set_chart_display_opts(...)`

- Set with [options](https://rdrr.io/r/base/options.html) as follows:
  `options(taxplore.display.optionname = 'value')`

## See also

[make_krona](https://markschl.github.io/taxplore/reference/make_krona.md)

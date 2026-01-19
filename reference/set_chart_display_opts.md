# Set global chart display options to override the default [ChartDisplayOpts](https://markschl.github.io/taxplore/reference/ChartDisplayOpts.md).

The options are added to [options](https://rdrr.io/r/base/options.html)
using `options(taxplore.display.optionname = value)`. The settings are
used to set the initial appearance of all all subsequent charts shown
with
[plot_krona](https://markschl.github.io/taxplore/reference/plot_krona.md).

## Usage

``` r
set_chart_display_opts(...)
```

## Arguments

- ...:

  Named arguments

## Examples

``` r
set_chart_opts(hue_range = c(40, 140))
```

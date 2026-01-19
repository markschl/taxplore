# Set global chart options to override the default [ChartOpts](https://markschl.github.io/taxplore/reference/ChartOpts.md).

The options are added to [options](https://rdrr.io/r/base/options.html)
using `options(taxplore.key = value)`. The settings are used for all
subsequent charts generated with
[plot_krona](https://markschl.github.io/taxplore/reference/plot_krona.md)
and
[make_krona](https://markschl.github.io/taxplore/reference/make_krona.md).

## Usage

``` r
set_chart_opts(...)
```

## Arguments

- ...:

  Named arguments

## Examples

``` r
set_chart_opts(hue_range = c(40, 140))
```

# Set sensible Knitr defaults for chart snapshots

Sets default chunk options that work well both with HTML documents and
other formats such as PDF. **Caution**: The default image format and
resolution are set for *all chunks*, not just those containing Krona
charts.

## Usage

``` r
taxplore_configure_snapshot(dpi = 300, dev = "png", screenshot.delay = 0.05)
```

## Arguments

- screenshot.delay:

  Time (in s) to wait before taking a screenshot of a HTML widget (such
  as the Krona charts from this package, but not exclusively). The
  default of 0.05s differs from the default 0.2s used by Knitr. To be
  precise, the Krona charts need no delay at all. In case of problems
  with other widgets, a longer delay may be set.

- document.dpi:

  Resolution of images in static non-HTML (e.g. PDF) documents

- document.dev:

  Snapshot format for non-HTML documents. The default is to generate PNG
  images, as embedding them as vector graphics may currently not result
  in the correct dimensions due to a [problem with in
  Webshot2](https://github.com/quarto-dev/quarto-cli/issues/7682).

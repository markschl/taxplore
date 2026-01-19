#' Display a Krona chart as HTML widget
#'
#' Pre-generated HTML charts can be displayed given a character string or
#' supplied with `file = ...`, or the chart can be directly generated with
#' [make_krona()] and directly displayed.
#'
#' @param x Character string with a pre-generated HTML chart, or a
#'  matrix, data frame, list or phyloseq object that serves as input for
#'  generating the chart with [make_krona()].
#' @param ... Additional arguments passed to [make_krona]
#' @param file File path, URL or file connection pointing to an already generated
#'   chart (passed instead of `x`)
#' @param display A [ChartDisplayOpts()] instance configuring the (initial)
#'   appearance of embedded charts or snapshots.
#' @param outfile Write the embedded chart to file
#' @param interactive If `FALSE`, a non-interactive HTML chart is shown,
#'   which does not have any buttons and does not allow selecting and zooming.
#'   This is primarily useful for taking snapshots of embedded widgets,
#'   and is automatically activated in [plot_krona] when rendering in static documents.
#'   If set to `TRUE`, charts embedded in static documents such as PDF and Word
#'   are unmodified snapshots with buttons and other controls.
#'   Note that `outfile = ...` still exports a "normal" interactive Krona chart
#'   (see `snapshot` option in [ChartOpts] for making the exported chart non-interactive).
#' @param width,height Width/height of the widget.
#'   Must be a valid CSS unit (like `'100%'`, `'400px'`, `'auto'`) or a number,
#'   which will be coerced to a string and have `'px'` appended.
#'
#' @import htmlwidgets
#'
#' @returns A [HTML widget](https://www.htmlwidgets.org) embedable in
#' [R-Markdown](https://rmarkdown.rstudio.com) / [Quarto](https://quarto.org)
#' documents.
#' Optionally,  `outfile` can be specified to also save the chart to a HTML file.
#'
#' @details
#'
#' When generating the widget, some settings are adjusted depending on the environment.
#' In static (non-HTML) documents such as PDF or Word, a snapshot is taken,
#' which hides the buttons, search box and other things (can be changed with
#' `interactive = TRUE`). Still, some additional configuration might be required
#' to ensure that the charts look nice in every context (see [taxplore_configure_snapshot()]).
#'
#' @seealso [make_krona()], [ChartOpts()], [ChartDisplayOpts()]
#'
#' @export
plot_krona <- function(x,
                       ...,
                       file = NULL,
                       outfile = NULL,
                       opts = NULL,
                       display = NULL,
                       interactive = NULL,
                       width = NULL,
                       height = NULL,
                       elementId = NULL) {
  display <- get_krona_display_opts(display)
  try_run = function(...) suppressWarnings(try(..., silent = TRUE))
  do_snapshot <- isFALSE(interactive) ||
    isTRUE(try_run(knitr::opts_current$get('screenshot.force')))
  if (!missing(x) && is(x, 'character')) {
    # HTML string provided
    if (!is.null(file)) {
      warning("Ignoring the 'file' argument since a classification was provided")
    }
    html <- x
  } else if (!is.null(file)) {
    html <- readChar(file, 1e9, useBytes = TRUE)
  } else {
    fmt <- try_run(knitr::pandoc_to())
    is_html <- isTRUE(try_run(knitr::is_html_output(fmt))) || is.null(fmt)
    # generate chart
    if (!is_html) {
      # Embedding in non-HTML documents:
      # automatically make non-interactive if not explicitly interactive
      if (is.null(interactive)) {
        do_snapshot <- TRUE
      }
      # adjust font size in screenshot according to 'dpi' setting
      # TODO: correct?
      font_size <- display[['font']] %||% 11
      dpi <- try_run(knitr::opts_current$get('dpi')) %||% 96
      display$font <- round(font_size * dpi / 96, 1)
    }
    html <- make_krona(x, ..., opts = opts, outfile = outfile)
    if (!is.null(outfile)) {
      f <- file(outfile)
      html <- readChar(f, file.size(outfile))
      close(f)
    }
  }

  display <- filter_display_opts(display)
  htmlwidgets::createWidget(
    name = 'taxplore_chart',
    list(
      html = html,
      opts = list(snapshotScript = if (do_snapshot) snapshot_script,
                  display = display)
    ),
    width = width,
    height = height,
    package = 'taxplore',
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      viewer.padding = 0,
      browser.padding = 0,
      defaultWidth  = '100%',
      defaultHeight = '100%',
      padding       = 0,
      browser.fill  = TRUE
    )
  )
}

#' Shiny bindings for plot_krona
#'
#' Output and render functions for using Krona charts within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like `'100\%'`,
#'   `'400px'`, `'auto'` or a number, which will be coerced to a
#'   string and have `'px'` appended.
#' @param expr An expression that generates a Krona chart
#' @param env The environment in which to evaluate `expr`.
#' @param quoted Is `expr` a quoted expression (with `quote()`)? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name krona_chart-shiny
#'
#' @export
KronaChartOutput <- function(outputId,
                         width = '100%',
                         height = '500px') {
  htmlwidgets::shinyWidgetOutput(outputId, 'taxplore_chart', width, height,
                                 package = 'taxplore')
}

#' @rdname krona_chart-shiny
#' @export
renderKronaChart <- function(expr,
                         env = parent.frame(),
                         quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  }
  htmlwidgets::shinyRenderWidget(expr, KronaChartOutput, env, quoted = TRUE)
}

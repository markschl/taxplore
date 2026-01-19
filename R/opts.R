#' General chart options
#'
#' @param max_digits Maximum number of significant digits to print for decimal numbers.
#'    Reducing to <7 digits (the default) may help in obtaining smaller HTML files.
#' @param hue_range: Hue at the start and end points of the fill gradient if coloring
#'   by a user-specified gradient (see `color` and `color_value_range` arguments
#'   in `make_krona`).
#' @param unknown_label: Label to set instead of `NA`s in the classification/taxonomy
#'   (if any present).
#'   By default, `NA`s are left in place, resulting in fewer child nodes. Krona
#'   charts handle this situation well (see e.g. https://krona.sourceforge.net/examples/xml.krona.html).
#' @param root_label: Label to use for the root of the taxonomic tree. It is
#'   only displayed if the uppermost level in the hierarchy has more than one
#'   category, or `collapse` is disabled (see [ChartDisplayOpts]).
#' @param total_label Label for the total abundance displayed on the top right
#'   of the chart.
#' @param resources_url: Optional URL pointing to remote Javascript and image resources,
#'   which will then be linked to instead of embedded into the chart.
#'   The resulting charts are not be standalone and require an internet connection
#'   for displaying, but the HTML file size is smaller.
#'   Example: `resources_url = 'http://marbl.github.io/Krona/'`
#'   The given URL address should serve the contents of the 'src'
#'   and 'img' directories from KronaTools (https://github.com/marbl/Krona/tree/master/KronaTools)
#'   (see [copy_krona_resources]).
#' @param minify If `TRUE`, a minified version of the Krona JavaScript is included
#'   Automatically activated in [plot_krona] when embedded
#'   This option is ignored if `method = 'kronatools'` and has no effect
#'   if `resources_url` is provided.
#' @param kronatools_dir: Optional path pointing to a 'KronaTools' directory
#'   extracted from the Krona source code archive, downloaded from
#'   [here](https://github.com/marbl/Krona/releases/latest).
#'   This option is ignored if `method = 'internal'`.
#' @param snapshot If `TRUE`, the Krona chart is immediately turned into a non-interactive
#'   snapshot. In contrast to the `interactive` parameter of `plot_krona`,
#'   this option permanently modifies the chart HTML code, so files exported with
#'   `outfile = ...` will also be non-interactive.
#' @param method HTML generation method ('internal' or 'kronatools'),
#''  passed to [generate_krona_html]
#'
#' @details There are different ways to apply these options:
#'
#' - Supply options directly to [make_krona] or [plot_krona]:
#'   `plot_krona(..., root_label = 'Records')`
#' - Supply as `opts` to [make_krona] or [plot_krona]:
#'   `make_krona(..., opts = ChartOpts(...))`
#' - Set global defaults before the call(s) to `make_krona()`:
#'   `set_chart_opts(...)`
#' - Set with [options] as follows: `options(taxplore.optionname, value)`
#'
#' @seealso [make_krona]
#' @export
ChartOpts <- function(max_digits = getOption('taxplore.max_digits', 7),
                      hue_range = getOption('taxplore.hue_range', c(0, 120)),
                      unknown_label = getOption('taxplore.unknown_label'),
                      root_label = getOption('taxplore.root_label', 'Root'),
                      total_label = getOption('taxplore.total_label', 'Total'),
                      method = getOption('taxplore.method'),
                      resources_url = getOption('taxplore.resources_url'),
                      interactive = getOption('taxplore.interactive'),
                      minify = getOption('taxplore.minify'),
                      kronatools_dir = getOption('taxplore.kronatools_dir')) {
  list(
    max_digits = max_digits,
    hue_range = hue_range,
    unknown_label = unknown_label,
    root_label = root_label,
    total_label = total_label,
    method = method,
    resources_url = resources_url,
    interactive = interactive,
    minify = minify,
    kronatools_dir = kronatools_dir
  )
}

#' Set global chart options to override the default [ChartOpts].
#'
#' The options are added to [options] using `options(taxplore.key = value)`.
#' The settings are used for all subsequent charts generated with [plot_krona] and [make_krona].
#'
#' @param ... Named arguments
#' @examples
#' set_chart_opts(hue_range = c(40, 140))
#'
#' @export
set_chart_opts <- function(...) {
  o <- list(...)
  if (length(o) == 0)
    return()
  names(o) <- paste0('taxplore.', names(o))
  do.call(options, o)
  invisible(NULL)
}

get_krona_opts <- function(x = NULL) {
  x <- modifyList(ChartOpts(), x %||% list())
  if (length(x) > 0 && (is.null(names(x))) || !is.list(x)) {
    stop('opts must be a named list (see ?ChartOpts)')
  }
  stopifnot(
    is.null(x$unknown_label) || length(x$unknown_label) == 1 &&
      (is.na(x$unknown_label) ||
         is.character(x$unknown_label))
  )
  stopifnot(is.numeric(x$max_digits) && length(x$max_digits) == 1)
  stopifnot(is.numeric(x$hue_range) && length(x$hue_range) == 2)
  stopifnot(is.character(x$root_label) && length(x$root_label) == 1)
  stopifnot(is.character(x$total_label) &&
              length(x$total_label) == 1)
  x
}


#' Configure the initial chart appearance
#'
#' @param collapse (logical or 'true'/'false') Should the chart be simplified,
#'    collapsing 'redundant' wedges? (on by default)
#' @param showMagnitude (logical or 'true'/'false') Should magnitudes be displayed
#'    in \[brackets\]?
#' @param color (logical or 'true'/'false') Color by a custom scheme along a
#'    a gradient of an attribute variable (see `color`). Automatically activated
#'    `TRUE` if `color` is set in [make_krona] or [plot_krona], unless explicitly
#'    set to `FALSE` here.
#' @param depth (number) Maximum number of ranks/levels that should be displayed
#'    (unlimited by default)
#' @param font (number) Font size (px/pt) (default: 11)
#' @param key (logical or 'true'/'false') Should a list of small wedges
#'    ('key') be displayed on the bottom right of the chart?
#'    (displayed by default)
#' @param dataset (number) Dataset number (see `group`/`group_col`)
#' @param node (number) Node number to highlight...
#'
#' @details
#' The `ChartDisplayOpts` configure the initial (default) appearance of embedded Krona
#' charts. Some of the settings correspond to checkboxes on the left.
#' The same parameters can also be passed as key-value (GET) URL parameters
#' to Krona HTML charts, see Krona wiki:
#'
#' - https://github.com/marbl/Krona/wiki/Customizing-the-view
#' - https://github.com/marbl/Krona/wiki/Changing-chart-viewing-defaults
#'
#' There are different ways to apply these options:
#'
#' - Directly supply them to [make_krona] as follows:
#'   `make_krona(..., display = ChartDisplayOpts(...))`
#' - Set global defaults before the call(s) to `make_krona()`:
#'   `set_chart_display_opts(...)`
#' - Set with [options] as follows: `options(taxplore.display.optionname = 'value')`
#'
#' @seealso [make_krona]
#' @export
ChartDisplayOpts <- function(collapse = getOption('taxplore.display.collapse', TRUE),
                             showMagnitude = getOption('taxplore.display.showMagnitude', FALSE),
                             color = getOption('taxplore.display.color'),
                             depth = getOption('taxplore.display.depth'),
                             font = getOption('taxplore.display.font', 11),
                             key = getOption('taxplore.display.key', TRUE),
                             dataset = getOption('taxplore.display.dataset'),
                             node = getOption('taxplore.display.node')) {
  list(
    collapse = collapse,
    showMagnitude = showMagnitude,
    color = color,
    depth = depth,
    font = font,
    key = key,
    dataset = dataset,
    node = node
  )
}

#' Set global chart display options to override the default [ChartDisplayOpts].
#'
#' The options are added to [options] using `options(taxplore.display.optionname = value)`.
#' The settings are used to set the initial appearance of all all subsequent
#' charts shown with [plot_krona].
#'
#' @param ... Named arguments
#' @examples
#' set_chart_opts(hue_range = c(40, 140))
#'
#' @export
set_chart_display_opts <- function(...) {
  o <- list(...)
  if (length(o) == 0)
    return()
  names(o) <- paste0('taxplore.display.', names(o))
  do.call(options, o)
  invisible(NULL)
}

get_krona_display_opts <- function(x = NULL) {
  x <- modifyList(ChartDisplayOpts(), x %||% list())
  if (length(x) > 0 && (is.null(names(x))) || !is.list(x)) {
    stop('display must be a named list (see ?ChartDisplayOpts)')
  }
  for (o in c('collapse', 'showMagnitude', 'key', 'color')) {
    v = x[[o]]
    if (!(is.null(v) ||
          (is.logical(v) || is.character(v)) && length(v) == 1))
      stop(paste(
        o,
        'must be a boolean (logical) or character (true/false) of length 1'
      ))
  }
  for (o in c('depth', 'font', 'node')) {
    v = x[[o]]
    if (!(is.null(v) ||
          (is.numeric(v) || is.character(v)) && length(v) == 1)) {
      stop(paste(o, 'must be a number of length 1'))
    }
  }
  x
}

# remove non-defaults
filter_display_opts <- function(x) {
  default_opts <- ChartDisplayOpts()
  x[sapply(names(x), function(n)
    ! identical(x[[n]], default_opts[[n]]))]

}


#' Set sensible Knitr defaults for chart snapshots
#'
#' Sets default chunk options that work well both with HTML documents and other
#' formats such as PDF.
#' **Caution**: The default image format and resolution are set for *all chunks*,
#' not just those containing Krona charts.
#'
#' @param document.dpi Resolution of images in static non-HTML (e.g. PDF) documents
#' @param document.dev Snapshot format for non-HTML documents.
#'   The default is to generate PNG images, as embedding them as vector graphics
#'   may currently not result in the correct dimensions due to a
#'   [problem with Webshot2](https://github.com/quarto-dev/quarto-cli/issues/7682).
#' @param screenshot.delay Time (in s) to wait before taking a screenshot of a
#'   HTML widget (such as the Krona charts from this package, but not exclusively).
#'   The default of 0.05s differs from the default 0.2s used by Knitr. To be precise,
#'   the Krona charts need no delay at all.
#'   In case of problems with other widgets, a longer delay may be set.
#'
#' @details
#'
#' In static documents, this function simply does calls:
#'
#' `knitr::opts_chunk$set(dpi = document.dpi, dev = document.dev, screenshot.opts = list(delay = screenshot.delay))`
#'
#' @export
taxplore_configure_snapshot = function(dpi = 300,
                                       dev = 'png',
                                       screenshot.delay = 0.05) {
  if (!knitr::is_html_output()) {
    knitr::opts_chunk$set(
      dpi = dpi,
      dev = dev,
      screenshot.opts = list(delay = screenshot.delay)
    )
  }
}

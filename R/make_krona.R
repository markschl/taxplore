#' Generate a chart
#'
#' This method generates the HTML code for a chart, which it returns or writes to a file.
#'
#' @param x A classification matrix/data frame containing a hierarchical classification
#'   (e.g. taxonomic lineages), a phyloseq object or a tree data structure
#'   made of nested lists (see *details* below)
#' @param magnitude Specifies the magnitudes (abundances) of the different groups
#'   in the classification. If missing, equal magnitudes are assumed for all entries.
#'   Either a vector or matrix/data frame (see *details*)
#' @param outfile Optional output file. If not provided, the HTML output is returned
#'   as character string.
#' @param dataset_group Optional character vector specifying the grouping of
#'   magnitude columns or phyloseq samples into distinct datasets.
#'   By default, data in different columns of matrix-like abundance objects are
#'   summed up by row and globally displayed as one dataset.
#'   The `dataset_group` vector must be of length `ncol(magnitude)`.
#'   The special value *"separate"* assumes that all all columns/phyloseq samples
#'   are separate data sets.
#'   Adjust the by-row summary function with `dataset_summary_fn`.
#' @param group_vars,group_sep,shorten_group Character vector with phyloseq sample
#'   variables that define the grouping into different datasets (see `dataset_group`.
#'   Multiple variables are joined together using `group_sep` to form the `dataset_group`
#'   vector.
#'   Overly long strings are further shortened using the `shorten_group` function.
#' @param dataset_summary_fn Function used to summarize the magnitudes from several
#'   samples (see `dataset_group`). `sum` is the default, but `mean` is also
#'   a good choice.
#' @param datasets If `x` is a tree data structure with magnitudes for >1 dataset
#'   (stored in 'n' attribute by default), then the names of these data sets
#'   need to be provided with `datasets` (character vector).
#' @param tax_ranks Character vector with phyloseq taxonomy ranks names that
#'   should be chosen from the taxonomy table (default: all ranks)
#' @param attributes Optional list of [ChartAttribute] providing more information
#'   about nodes of in chart (when clicked), or for the coloring.
#' @param color: Indicate data to be used for custom coloring of the chart.
#'   Should be one of:
#'
#'   - Name of a [ChartAttribute] provided in the `attributes` list, which
#'     has *numeric* data to color by.
#'   - *Numeric vector/matrix* that directly provides the necessary data.
#'     See [ChartAttribute] for information about the data format and how values
#'     are aggregated within higher classification ranks.
#'     `color_label` also needs to be specified.
#'
#' @param color_col Name of a column in the *phyloseq* taxonomy table, which
#'   contains numeric values used for coloring (see `color`).
#'   *Note* that it is rather unusual to store extra (numeric) data in the
#'   taxonomy table, but it is still possible.
#' @param color_label Label of the color scale (bottom left).
#'   Must be supplied if `color` is a data vector/matrix.
#'   Otherwise, the `name` or `displayName` of the [ChartAttribute] is used.
#' @param color_value_range Lower and upper value limits that map to the color
#'   range (see `hue_range` in [ChartOpts]). By default, the full `range()`
#'   is used.
#' @param display Optional [ChartDisplayOpts] configuring the initial
#'   appearance of the charts when embedded in RStudio or rendered documents.
#'   See [set_chart_display_opts] to apply these settings globally for multiple
#'   charts.
#' @param opts Optional [ChartOpts] affecting how HTML charts are generated
#'   See also [set_chart_opts] to apply these settings globally for multiple charts.
#' @param ... Passed on to `make_krona.matrix`, and remaining arguments are ultimately
#'   passed as [ChartOpts] as an alternative to `opts` for configuring HTML generation.
#'
#' @returns Krona chart HTML code as character vector
#'
#' @details
#'
#' # Matrix-like classification
#'
#' The classification (`x`) must be one of:
#'
#' - A *matrix* or *data frame* where each row defines a lineage of the
#'   hierarchy from left (higher ranks = inner circles in chart) to right
#'   (lower ranks = outer circles).
#'   Usually, an associated `magnitudes` vector or matrix/data frame is supplied
#'   along, indicating the size (weight) of the nodes in the chart.
#'   If not provided, equal weights are given to all nodes.
#' - A *Phyloseq object* with at least a `tax_table` and `otu_table` component,
#'   or a simple `taxonomyTable` with or without additional `magnitudes`.
#'   Grouping into datasets can be done with `group_vars` (requires `sample_data`
#'   to be present).
#'
#' `magnitudes` modify the width of the outermost nodes in the hierarchy
#' (and the inner nodes along with them).
#' It should be a vector of `nrow(x)` or a matrix/data frame matching the rows of `x`.
#' By default, magnitude values from the different columns are summed up by row
#' (configurable with `dataset_summary_fn`).
#' Optionally samples can be grouped into datasets (see `dataset_group`).
#' Any vector names/row names (if present) must match with nammes of `x`.
#'
#' ## Phyloseq objects
#'
#' If `x` is a *Phyloseq object*, no separate `magnitude` is required as abundances
#' are taken from the `otu_table()` slot (but `magnitude = ...` can override it).
#' Set `magnitude = FALSE` to give equal weight to all taxa.
#'
#' # Tree data structure
#'
#' `x` can be a pre-assembled *tree* made of nested lists, which is written to
#' the Krona XML unmodified.
#' Each node requires at least a `name` attribute.
#' The optional magnitude attribute (default name: `magnitude = 'n'`) specifies
#' the node weights for one or multiple datasets (specified with `datasets`).
#' Additional data can be provided (see `attributes`).
#'
#' @seealso [plot_krona], [ChartOpts], [ChartDisplayOpts]
#'
#' @export
make_krona <- function(x, ...) {
  UseMethod('make_krona')
}

#' @export
#' @rdname make_krona
make_krona.taxonomyTable <- function (x, tax_ranks = NULL, ...)
{
  taxonomy <- as(x, 'matrix')

  if (is.null(tax_ranks))
    tax_ranks <- colnames(taxonomy)
  stopifnot(is.character(tax_ranks))

  taxonomy <- taxonomy[, tax_ranks, drop = F]

  make_krona.matrix(taxonomy, ...)
}

#' @exportS3Method taxplore::make_krona
#' @rdname make_krona
make_krona.phyloseq <- function (x,
                                 magnitude = NULL,
                                 outfile = NULL,
                                 tax_ranks = NULL,
                                 dataset_group = NULL,
                                 group_vars = NULL,
                                 color = NULL,
                                 color_col = NULL,
                                 color_label = NULL,
                                 group_sep = ' ',
                                 shorten_group = function(x)
                                   abbreviate(x, 60),
                                 ...)
{
  stopifnot(is.character(group_sep) && length(group_sep) == 1)
  stopifnot(is.function(shorten_group) &&
              length(shorten_group) == 1)

  taxonomy <- as(phyloseq::tax_table(x), 'matrix')

  if (is.null(magnitude) && !isFALSE(magnitude)) {
    magnitude <- as(phyloseq::otu_table(x), 'matrix')
    if (!taxa_are_rows(x))
      magnitude <- t(magnitude)
  } else {
    magnitude <- as(magnitude, 'matrix')
    stopifnot(nrow(magnitude) == nrow(taxonomy))
  }

  if (!is.null(color_col)) {
    color <- as.numeric(as(phyloseq::tax_table(x)[color_col], 'matrix')[,1])
  }
  if (is.null(color_label) && !is.null(is.null(color_label))) {
    color_label <- color_col
  }

  if (is.null(dataset_group) && !is.null(group_vars)) {
    if (!is.null(dataset_group)) {
      warning("Both 'dataset_group' and 'group_vars' arguments supplied, 'dataset_group' is ignored")
    }
    stopifnot(is.character(group_vars))
    sdata <- as.data.frame(sample_data(x))
    dataset_group <- do.call(paste, c(sdata[, group_vars], list(sep = group_sep)))
    dataset_group <- unname(shorten_group(dataset_group))
  }

  if (is.null(tax_ranks))
    tax_ranks <- colnames(taxonomy)
  stopifnot(is.character(tax_ranks))

  taxonomy <- taxonomy[, tax_ranks, drop = F]

  make_krona.matrix(
    taxonomy,
    magnitude,
    outfile = outfile,
    dataset_group = dataset_group,
    color = color,
    color_label = color_label,
    ...
  )
}

#' @export
#' @rdname make_krona
make_krona.data.frame <- function(classification, ...) {
  make_krona.matrix(as(classification, 'matrix'), ...)
}

#' @export
#' @rdname make_krona
make_krona.matrix <- function(x,
                              magnitude = NULL,
                              outfile = NULL,
                              dataset_group = NULL,
                              color = NULL,
                              color_label = NULL,
                              color_value_range = NULL,
                              attributes = NULL,
                              dataset_summary_fn = sum,
                              display = NULL,
                              method = NULL,
                              opts = NULL,
                              ...)
{
  stopifnot(is.function(dataset_summary_fn) &&
              length(dataset_summary_fn) == 1)

  # options

  opts <- get_krona_opts(modifyList(opts %||% list(), list(...)))
  display <- get_krona_display_opts(display)

  # prepare/validate classifications

  if (!is.null(opts$unknown_label)) {
    x[is.na(x)] <- opts$unknown_label
  }

  # prepare/validate magnitudes

  # nothing supplied: assign equal weights to every group
  if (is.null(magnitude)) {
    magnitude <- cbind(setNames(rep(1, nrow(x)), rownames(x)))
  }

  magnitude <- as(magnitude, 'matrix')

  if (!is.numeric(magnitude)) {
    stop('The magnitude matrix must be numeric')
  }
  if (any(duplicated(colnames(magnitude)))) {
    stop("Duplicate column names found in the 'magnitude' matrix")
  }
  if (nrow(magnitude) != nrow(x) ||
      !is.null(rownames(magnitude)) && !is.null(rownames(x)) &&
      !identical(rownames(magnitude), rownames(x))) {
    stop(
      paste(
        "The taxa in magnitude matrix and classifications don't match;",
        "their number should be equal and row names are expected to be absent or equal in both."
      )
    )
  }

  # initiate/validate groups vector, and aggregate

  if (is.null(dataset_group)) {
    dataset_group <- rep("1", ncol(magnitude))
  }
  if (length(dataset_group) == 1 && dataset_group == 'separate') {
    if (is.null(colnames(magnitude))) {
      dataset_group <- as.character(1:ncol(magnitude))
    } else {
      dataset_group <- setNames(colnames(magnitude), colnames(magnitude))
    }
  }
  if (!is.vector(dataset_group) ||
      ncol(magnitude) != length(dataset_group) || any(is.na(dataset_group))) {
    stop(
      paste(
        "The 'dataset_group' argument must be either 'separate' or a non-NA vector matching",
        "the number of columns in the magnitude matrix."
      )
    )
  }
  if (!is.null(colnames(magnitude)) && !is.null(names(dataset_group)) &&
      !identical(unname(colnames(magnitude)), unname(names(dataset_group)))) {
    stop(
      paste(
        "The groups and the columns of the magnitude matrix don't match;",
        "their names should either be absent or equal in both."
      )
    )
  }
  dataset_group <- as.character(unname(dataset_group))
  datasets <- unique(dataset_group)

  aggregate_groups <- function(data, group, summary_fn) {
    stopifnot(ncol(data) == length(group))
    l <- lapply(split(seq_len(ncol(data)), group), function(i)
      apply(data[, i, drop = FALSE], 1, summary_fn))
    simplify2array(l, except = NA)
  }

  magnitude <- aggregate_groups(magnitude, dataset_group, dataset_summary_fn)
  # assign same order as 'datasets' (to make sure we are in sync with attributes)
  stopifnot(identical(sort(unname(
    colnames(magnitude)
  )), sort(datasets)))
  magnitude <- magnitude[, datasets, drop = FALSE]

  # initialize (validate) attributes

  if (is.null(attributes)) {
    attributes <- list()
  }

  if (!is.null(color)) {
    if (!is.character(color) || length(color) > 1 ||
        !any(sapply(attributes, function(a)
          identical(a[['name']], color)))) {
      if (is.null(color_label)) {
        stop("'color_label' must be supplied along with 'color' data frame/matrix")
      }
      stopifnot(is.character(color_label) &&
                  length(color_label) == 1)
      # TODO: mono="true" does not seem to work with color (see hueName in code)
      data <- cbind(color)[, rep(1, length(datasets)), drop = F]
      colnames(data) <- datasets
      attributes <- c(list(
        ChartAttribute(
          name = 'color',
          displayName = color_label,
          data = data,
          missing_value = 'NA',
          max_digits = opts$max_digits
        )
      ), attributes)
      color <- 'color'
    }
    cdata_i <- which(sapply(attributes, function(a)
      identical(a$name, color)))[1]
    if (is.na(cdata_i)) {
      stop(sprintf(
        "The color attribute '%s' is not found in the 'attributes' list",
        color
      ))
    }
    # determine value range if not supplied
    if (is.null(color_value_range)) {
      color_value_range <- range(attributes[[cdata_i]]$data, na.rm = T)
    }
    stopifnot(is.numeric(color_value_range) &&
                length(color_value_range) == 2)
  }

  attributes <- lapply(attributes, function(attr) {
    if (!is.list(attr) || is.null(attr$name) || is.null(attr$data)) {
      stop(
        'Each entry in the `attributes` list must be a list with at least `name` and `data` entries'
      )
    }

    if (attr$name == 'n') {
      stop("Attributes cannot have name = 'n' as this is reserved for the magnitudes")
    }

    # handle `data`

    # vectors: convert to matrix with one column per group (equivalent to 'magnitude')
    d <- dim(attr$data)
    if (is.null(d) && is.vector(attr$data)) {
      # vectors: only one value for all datasets -> we need to set 'mono=true'
      attr$data <- cbind(attr$data)
      attr$mono <- TRUE
    } else {
      if (length(d) != 2) {
        stop(sprintf(
          paste(
            "The '%s' attribute data must be a vector or a data frame/matrix"
          ),
          attr$name
        ))
      }

      attr$data <- as(attr$data, 'matrix')

      # aggregate by group if necessary
      stopifnot(length(dim(attr$data)) == 2)
      if (is.null(attr$dataset_summary_fn)) {
        attr$dataset_summary_fn <- if (is.numeric(attr$data)) {
          sum
        } else {
          function(x) {
            u <- unique(x)
            if (length(u) == 1)
              u
            else
              NA
          }
        }
      }
      if (!is.null(colnames(attr$data)) &&
          ncol(attr$data) != length(datasets) ||
          any(is.na(match(datasets, colnames(attr$data))))) {
        if (ncol(attr$data) != ncol(magnitude)) {
          stop(sprintf(
            paste(
              "The data matrix columns of attribute '%s' do not match the magnitude columns",
              "or the grouping"
            ),
            attr$name
          ))
        }
        if (!is.null(colnames(attr$data)) &&
            !is.null(colnames(magnitude)) &&
            !identical(unname(colnames(attr$data)), unname(colnames(magnitude)))) {
          stop(sprintf(
            paste(
              "The column names of the attribute data for '%s' do not not match the",
              "magnitude columns. Column names are expected to be absent or equal in both."
            ),
            attr$name
          ))
        }
        attr$data <- aggregate_groups(attr$data, dataset_group, attr$dataset_summary_fn)
      }

      # assign the same order as datasets
      stopifnot(identical(sort(unname(
        colnames(attr$data)
      )), sort(datasets)))
      attr$data <- attr$data[, datasets, drop = FALSE]
    }

    # match with magnitude rows
    if (is.null(rownames(attr$data)) ||
        is.null(rownames(magnitude))) {
      if (nrow(attr$data) != nrow(magnitude)) {
        stop(sprintf(
          paste(
            "The number of attribute data entries for '%s' does not match the magnitudes",
            "and there are no row names for matching the two."
          ),
          attr$name
        ))
      }
    } else {
      data_only <- setdiff(rownames(attr$data), rownames(magnitude))
      if (length(data_only) > 0 && !isTRUE(attr$allow_extra_data)) {
        warning(sprintf(
          paste(
            "%d of %d data entries of the attribute '%s' are not present in the magnitude matrix.",
            "To silence this warning, set 'allow_extra_data = TRUE' in the attribute settings."
          ),
          length(data_only),
          nrow(attr$data),
          attr$name
        ))
      }
      mag_only <- setdiff(rownames(magnitude), rownames(attr$data))
      if (length(mag_only) > 0) {
        if (is.null(attr$missing_fill)) {
          attr$missing_fill <- NA
        }
        zeros <- matrix(
          attr$missing_fill,
          nrow = length(mag_only),
          ncol = ncol(attr$data),
          dimnames = list(mag_only, colnames(attr$data))
        )
        attr$data <- rbind(attr$data, zeros)
      }
      attr$data <- attr$data[rownames(magnitude), , drop = FALSE]
    }

    #stopifnot(identical(rownames(attr$data), rownames(magnitude)))

    # set other defaults

    if (is.null(attr$displayName)) {
      attr$displayName <- attr$name
    }

    if (is.null(attr$summary_fn)) {
      attr$summary_fn <- if (is.numeric(attr$data)) {
        function(x, n)
          weighted.mean(x, n, na.rm = TRUE)
      } else {
        function(x, n) {
          u <- unique(x)
          if (length(u) == 1)
            u
          else
            NA
        }
      }
    }

    # pre-compute logical vector stating which ranks should be displayed
    attr$display_rank <- if (is.null(attr$only_ranks)) {
      rep(TRUE, 1 + ncol(x))
    } else {
      stopifnot(!is.na(attr$only_ranks))
      all_ranks <- if (is.integer(attr$only_ranks)) {
        attr$only_ranks <- attr$only_ranks #- rank_offset
        attr$only_ranks <- attr$only_ranks[attr$only_ranks > 0]
        seq_len(ncol(x))
      } else {
        colnames(x)
      }
      if (any(!(attr$only_ranks %in% all_ranks))) {
        stop(sprintf(
          paste(
            "Error in attribute '%s': 'only_ranks' references unknown columns.",
            "Make sure that column names are present or indices are within",
            "the column numbers of the classification (`x`)."
          ),
          attr$name
        ))
      }
      c(TRUE, all_ranks %in% attr$only_ranks)
    }

    if (!is.null(attr$text)) {
      attr$text = escape_html_tags(attr$text)
    }

    attr
  })
  # remove zero-abundance rows
  sel_rows <- rowSums(magnitude) > 0
  if (any(!sel_rows)) {
    magnitude <- magnitude[sel_rows, , drop = FALSE]
    x <- x[sel_rows, , drop = FALSE]
    attributes <- lapply(attributes, function(a) {
      a$data <- a$data[sel_rows, , drop = FALSE]
      a
    })
  }

  # used for nested XML generation (without the attribute 'n' containing magnitudes)
  # ('attributes' is used for other info)
  attr_data <- lapply(attributes, function(attr) {
    list(attr$name, attr$data)
  })

  # add the magnitude to the attributes list
  # (just used for XML writing, no summary_fn, the sum is calculated separately)

  attributes <- c(list(
    ChartAttribute(
      name = 'n',
      displayName = opts$total_label,
      data = magnitude
    )
  ), attributes)

  attributes <- prepare_attributes(attributes, opts)

  # Generate Krona XML, stored in 'xml_tree' variable

  line_sep <- if (isTRUE(opts$minify))
    ''
  else
    '\n'
  out <- textConnection('xml_tree', 'w', local = TRUE)
  init_xml(
    out,
    magnitude = 'n',
    attributes = attributes,
    datasets = datasets,
    color = color,
    color_value_range = color_value_range,
    hue_range = opts$hue_range,
    sep = line_sep
  )

  # function for writing a (sub)tree to the output
  write_tree <- function(rank_i,
                         node_name,
                         classification,
                         magnitude,
                         attr_data,
                         out) {
    # print(paste(rank_i, node_name, ncol(classification), nrow(magnitude)))
    node <- list()
    # sum magnitude
    n <- node$n <- unname(colSums(magnitude))

    # first, report the node itself
    if (any(n != 0) && !is.null(attr_data)) {
      for (a in attr_data) {
        name <- a[[1]]
        data <- a[[2]]
        info <- attributes[[name]]
        if (info[['display_rank']][rank_i]) {
          stopifnot(nrow(data) == nrow(magnitude))
          # TODO: named lists probably slower, but it is in line with the tree format
          summary_fn <- info[['summary_fn']]
          if (isTRUE(info[['mono']])) {
            stopifnot(ncol(data) == 1)
            node[[name]] <- summary_fn(data[, 1], rowSums(magnitude))
          } else {
            node[[name]] <- unlist(
              lapply(seq_len(ncol(data)), function(i) {
                summary_fn(data[, i], magnitude[, i])
              }),
              recursive = FALSE,
              use.names = FALSE
            )
          }
        }
      }
    }

    included <- write_node(
      node_name,
      node,
      magnitude = 'n',
      datasets = datasets,
      attributes = attributes,
      out = out,
      sep = line_sep
    )

    # then visit nested nodes
    if (!is.null(classification)) {
      sub_names <- classification[, 1]
      for (sub_name in unique(na.omit(sub_names))) {
        sel <- sub_name == sub_names & !is.na(sub_names)
        # row/column subset of the classification
        sub_class <- if (ncol(classification) > 1) {
          classification[sel, 2:ncol(classification), drop = FALSE]
        } else {
          NULL
        }
        # row subset of magnitude and attribute matrices
        stopifnot(nrow(classification) == nrow(magnitude))
        sub_mag <- magnitude[sel, , drop = FALSE]
        sub_attr <- if (!is.null(attr_data)) {
          lapply(attr_data, function(a) {
            name <- a[[1]]
            data <- a[[2]]
            # stopifnot(nrow(data) == nrow(magnitude))
            list(name, data[sel, , drop = FALSE])
          })
        } else {
          NULL
        }
        write_tree(rank_i + 1, sub_name, sub_class, sub_mag, sub_attr, out)
      }
    }
    if (included)
      close_node(out, end = line_sep)
  }

  write_tree(1, opts$root_label, x, magnitude, attr_data, out)
  finish_xml(out)
  close(out)
  xml_tree <- paste(xml_tree, collapse = line_sep)

  do.call(generate_krona_html, c(list(xml_tree, outfile=outfile), opts))
}

#' @export
#' @rdname make_krona
make_krona.list <- function(x,
                            magnitude = 'n',
                            outfile = NULL,
                            datasets = NULL,
                            attributes = NULL,
                            color = NULL,
                            color_value_range = NULL,
                            opts = NULL,
                            display = NULL,
                            ...)
{
  opts <- get_krona_opts(modifyList(opts %||% list(), list(...)))
  display <- get_krona_display_opts(display)

  # get range of color attribute values if unknown
  if (!is.null(color) && is.null(color_value_range)) {
    get_rng <- function(node) {
      val <- node[[magnitude]] %||% NA
      is_subnode <- unlist(lapply(node, is.list),
                           recursive = FALSE,
                           use.names = FALSE)
      for (sub_node in node[is_subnode]) {
        val <- range(c(val, get_rng(sub_node)), na.rm = TRUE)
      }
      val
    }
  }

  attributes <- c(list(
    ChartAttribute(name = magnitude, displayName = opts$total_label)
  ), attributes)

  attributes <- prepare_attributes(attributes, opts)

  if (is.null(x[[magnitude]])) {
    # magnitudes missing -> auto-fill with equal weights
    n_datasets <- if (is.null(datasets))
      1
    else
      length(datasets)
    fill_mag <- function(node) {
      if (!is.null(node[[magnitude]])) {
        stop(sprintf(
          paste(
            "The magnitude attribute '%s' should either be present or missing in all nodes,",
            "but it should be not be present in some and absent in others",
          ),
          magnitude
        ))
      }
      n <- 0
      for (i in seq_len(length(node))) {
        d <- node[[i]]
        if (is.list(d)) {
          res <- fill_mag(d)
          n <- n + res[[1]]
          node[[i]] <- res[[2]]
        }
      }
      if (n == 0) {
        # no nested items -> assign weight = 1
        n <- 1
      }
      node[[magnitude]] <- rep(n, n_datasets)
      list(n, node)
    }
    res <- fill_mag(x)
    x <- res[[2]]
    # print(str(x))
  }

  #  xml_file <- tempfile('krona_xml', fileext='.xml'); out <- file(xml_file, 'w')
  out <- textConnection('xml_tree', 'w', local = TRUE)
  init_xml(
    out,
    magnitude = magnitude,
    attributes = attributes,
    datasets = datasets,
    color = color,
    color_value_range = color_value_range,
    hue_range = hue_range
  )

  line_sep <- if (isTRUE(opts$minify))
    ''
  else
    '\n'
  visit <- function(node_data) {
    node_name = node_data[['name']]
    if (is.null(node_name) ||
        length(node_name) != 1 || is.na(node_name)) {
      stop("Not all nodes of the classification tree have a single non-NA 'name' attribute")
    }
    is_subnode <- unlist(lapply(node_data, is.list),
                         recursive = FALSE,
                         use.names = FALSE)
    is_attr = !is_subnode & !(names(node_data) %in% 'name')
    included <- write_node(
      node_name,
      node_data[is_attr],
      magnitude = magnitude,
      datasets = datasets,
      attributes = attributes,
      out = out,
      sep = line_sep
    )
    for (d in node_data[is_subnode]) {
      visit(d)
    }
    if (included)
      close_node(out, end = line_sep)
  }
  visit(x)
  finish_xml(out)
  close(out)
  xml_tree <- paste(xml_tree, collapse = line_sep)

  do.call(generate_krona_html, c(list(xml_tree, outfile=outfile), opts))
  # file.remove(xml_file)
}

init_xml <- function(out,
                     magnitude,
                     attributes,
                     datasets = NULL,
                     color = NULL,
                     color_value_range = NULL,
                     hue_range = NULL,
                     sep = '\n') {
  cat('<krona>', sep = sep, file = out)

  # attributes

  cat(
    sprintf('<attributes magnitude="%s">', magnitude),
    sep = sep,
    file = out
  )
  for (attr in attributes) {
    cat(
      sprintf(
        '<attribute display="%s"%s>%s</attribute>',
        attr[['displayName']],
        if (!is.null(attr[['hrefBase']])) {
          sprintf(
            ' hrefBase="%s" target="%s"%s',
            attr[['hrefBase']],
            attr[['short_name']],
            ifelse(isTRUE(attr$mono), ' mono="true"', '')
          )
        } else {
          ''
        },
        attr[['short_name']]
      ),
      sep = sep,
      file = out
    )
  }
  cat('</attributes>', sep = sep, file = out)

  if (!is.null(color)) {
    if (is.null(color_value_range) || length(color_value_range) != 2 ||
        is.null(hue_range) || length(hue_range) != 2) {
      stop("'color_value_range' and 'color_hue_range' are required with 'color'")
    }
    attr <- attributes[[color]]
    if (is.null(attr)) {
      stop(sprintf(
        "The color attribute '%s' is not in the 'attributes' list",
        color
      ))
    }
    cat(
      sprintf(
        '<color attribute="%s" valueStart="%s" valueEnd="%s" hueStart="%s" hueEnd="%s"  default="true"></color>',
        attr$short_name,
        color_value_range[1],
        color_value_range[2],
        hue_range[1],
        hue_range[2]
      ),
      sep = '\n',
      file = out
    )
  }

  if (!is.null(datasets)) {
    d =
      cat(
        '<datasets>',
        paste(sprintf('<dataset>%s</dataset>', datasets), collapse = sep),
        '</datasets>',
        sep = sep,
        file = out
      )
  }
}


escape_html_tags <- function(x) {
  gsub('>', '&gt;', gsub('<', '&lt;', x, fixed = TRUE), fixed = TRUE)
}

write_node <- function(node_name,
                       node_data,
                       magnitude,
                       datasets,
                       attributes,
                       out,
                       sep = '\n') {
  n <- node_data[[magnitude]]
  stopifnot(!is.null(n) && all(!is.na(n)) && is.numeric(n))
  if (all(n == 0)) {
    return(FALSE)
  }
  if (is.null(datasets)) {
    if (length(n) != 1) {
      stop(
        sprintf(
          "Found multiple magnitude values for attribute '%s', but no 'datasets' were specified",
          magnitude
        )
      )
    }
  } else if (length(datasets) != length(n)) {
    stop(
      sprintf(
        "Length mismatch between magnitude values of attribute '%s' and 'datasets'",
        magnitude
      )
    )
  }

  cat(sprintf('<node name="%s">', node_name),
      sep = sep,
      file = out)
  for (attr_name in names(node_data)) {
    info <- attributes[[attr_name]]
    if (is.null(info)) {
      warning(
        paste(
          sprintf("Unknown attribute in tree: '%s'.", attr_name),
          "Maybe you forgot to register it in the 'attributes' list?"
        ),
        noBreaks. = TRUE
      )
      next
    }
    # TODO: how to deal with numeric zeros in coloring attrs?
    value <- node_data[[attr_name]]
    def <- !is.na(value)
    if (!any(def))
      # FIXME: all-NA can result in logical; can we fix this earlier?
      value <- rep(NA_character_, length(value))
    missing_value <- info[['missing_value']]
    fmt_value <- if (is.null(missing_value) ||
                     is.na(missing_value)[1]) {
      character(length(value))
    } else {
      rep(missing_value, length(value))
    }
    fmt_value[def] <- if (is.character(value)) {
      escape_html_tags(value[def])
    } else {
      as.character(signif(value[def], info[['max_digits']]))
      # formatC(value[def], format='f', digits = info[['digits']], drop0trailing = TRUE)
    }
    href <- character(length(value))
    href_builder <- info[['href']]
    if (!is.null(href_builder)) {
      h <- if (is.function(href_builder)) {
        href_builder(node_name, value)
      } else {
        href_builder
      }
      href[def] <- sprintf(' href="%s"', h)
    } else if (!is.null(info[['hrefBase']])) {
      href[def] <- sprintf(' href="%s"', fmt_value[def])
    }
    text_builder <- info[['text']]
    if (!is.null(text_builder)) {
      fmt_value[def] <- if (is.function(text_builder)) {
        text_builder(node_name, value[def])
      } else {
        text_builder
      }
    }

    cat(sprintf('<%s>%s</%s>', info[['short_name']], paste(
      sprintf('<v%s>%s</v>', href, fmt_value), collapse = ''
    ), info[['short_name']]),
    sep = sep,
    file = out)
  }
  TRUE
}

close_node <- function(handle, end = '\n') {
  cat('</node>', sep = end, file = handle)
}

finish_xml <- function(handle) {
  cat('</krona>', sep = '\n', file = handle)
}

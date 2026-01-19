# Generate a chart

This method generates the HTML code for a chart, which it returns or
writes to a file.

## Usage

``` r
make_krona(x, ...)

# S3 method for class 'taxonomyTable'
make_krona(x, tax_ranks = NULL, ...)

# S3 method for class 'phyloseq'
make_krona(
  x,
  magnitude = NULL,
  outfile = NULL,
  tax_ranks = NULL,
  dataset_group = NULL,
  group_vars = NULL,
  color = NULL,
  color_col = NULL,
  color_label = NULL,
  group_sep = " ",
  shorten_group = function(x) abbreviate(x, 60),
  ...
)

# S3 method for class 'data.frame'
make_krona(classification, ...)

# S3 method for class 'matrix'
make_krona(
  x,
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
  ...
)

# S3 method for class 'list'
make_krona(
  x,
  magnitude = "n",
  outfile = NULL,
  datasets = NULL,
  attributes = NULL,
  color = NULL,
  color_value_range = NULL,
  opts = NULL,
  display = NULL,
  ...
)
```

## Arguments

- x:

  A classification matrix/data frame containing a hierarchical
  classification (e.g. taxonomic lineages), a phyloseq object or a tree
  data structure made of nested lists (see *details* below)

- ...:

  Passed on to `make_krona.matrix`, and remaining arguments are
  ultimately passed as
  [ChartOpts](https://markschl.github.io/taxplore/reference/ChartOpts.md)
  as an alternative to `opts` for configuring HTML generation.

- tax_ranks:

  Character vector with phyloseq taxonomy ranks names that should be
  chosen from the taxonomy table (default: all ranks)

- magnitude:

  Specifies the magnitudes (abundances) of the different groups in the
  classification. If missing, equal magnitudes are assumed for all
  entries. Either a vector or matrix/data frame (see *details*)

- outfile:

  Optional output file. If not provided, the HTML output is returned as
  character string.

- dataset_group:

  Optional character vector specifying the grouping of magnitude columns
  or phyloseq samples into distinct datasets. By default, data in
  different columns of matrix-like abundance objects are summed up by
  row and globally displayed as one dataset. The `dataset_group` vector
  must be of length `ncol(magnitude)`. The special value *"separate"*
  assumes that all all columns/phyloseq samples are separate data sets.
  Adjust the by-row summary function with `dataset_summary_fn`.

- group_vars, group_sep, shorten_group:

  Character vector with phyloseq sample variables that define the
  grouping into different datasets (see `dataset_group`. Multiple
  variables are joined together using `group_sep` to form the
  `dataset_group` vector. Overly long strings are further shortened
  using the `shorten_group` function.

- color_col:

  Name of a column in the *phyloseq* taxonomy table, which contains
  numeric values used for coloring (see `color`). *Note* that it is
  rather unusual to store extra (numeric) data in the taxonomy table,
  but it is still possible.

- color_label:

  Label of the color scale (bottom left). Must be supplied if `color` is
  a data vector/matrix. Otherwise, the `name` or `displayName` of the
  [ChartAttribute](https://markschl.github.io/taxplore/reference/ChartAttribute.md)
  is used.

- color_value_range:

  Lower and upper value limits that map to the color range (see
  `hue_range` in
  [ChartOpts](https://markschl.github.io/taxplore/reference/ChartOpts.md)).
  By default, the full [`range()`](https://rdrr.io/r/base/range.html) is
  used.

- attributes:

  Optional list of
  [ChartAttribute](https://markschl.github.io/taxplore/reference/ChartAttribute.md)
  providing more information about nodes of in chart (when clicked), or
  for the coloring.

- dataset_summary_fn:

  Function used to summarize the magnitudes from several samples (see
  `dataset_group`). `sum` is the default, but `mean` is also a good
  choice.

- display:

  Optional
  [ChartDisplayOpts](https://markschl.github.io/taxplore/reference/ChartDisplayOpts.md)
  configuring the initial appearance of the charts when embedded in
  RStudio or rendered documents. See
  [set_chart_display_opts](https://markschl.github.io/taxplore/reference/set_chart_display_opts.md)
  to apply these settings globally for multiple charts.

- opts:

  Optional
  [ChartOpts](https://markschl.github.io/taxplore/reference/ChartOpts.md)
  affecting how HTML charts are generated See also
  [set_chart_opts](https://markschl.github.io/taxplore/reference/set_chart_opts.md)
  to apply these settings globally for multiple charts.

- datasets:

  If `x` is a tree data structure with magnitudes for \>1 dataset
  (stored in 'n' attribute by default), then the names of these data
  sets need to be provided with `datasets` (character vector).

- color::

  Indicate data to be used for custom coloring of the chart. Should be
  one of:

  - Name of a
    [ChartAttribute](https://markschl.github.io/taxplore/reference/ChartAttribute.md)
    provided in the `attributes` list, which has *numeric* data to color
    by.

  - *Numeric vector/matrix* that directly provides the necessary data.
    See
    [ChartAttribute](https://markschl.github.io/taxplore/reference/ChartAttribute.md)
    for information about the data format and how values are aggregated
    within higher classification ranks. `color_label` also needs to be
    specified.

## Value

Krona chart HTML code as character vector

## Matrix-like classification

The classification (`x`) must be one of:

- A *matrix* or *data frame* where each row defines a lineage of the
  hierarchy from left (higher ranks = inner circles in chart) to right
  (lower ranks = outer circles). Usually, an associated `magnitudes`
  vector or matrix/data frame is supplied along, indicating the size
  (weight) of the nodes in the chart. If not provided, equal weights are
  given to all nodes.

- A *Phyloseq object* with at least a `tax_table` and `otu_table`
  component, or a simple `taxonomyTable` with or without additional
  `magnitudes`. Grouping into datasets can be done with `group_vars`
  (requires `sample_data` to be present).

`magnitudes` modify the width of the outermost nodes in the hierarchy
(and the inner nodes along with them). It should be a vector of
`nrow(x)` or a matrix/data frame matching the rows of `x`. By default,
magnitude values from the different columns are summed up by row
(configurable with `dataset_summary_fn`). Optionally samples can be
grouped into datasets (see `dataset_group`). Any vector names/row names
(if present) must match with nammes of `x`.

### Phyloseq objects

If `x` is a *Phyloseq object*, no separate `magnitude` is required as
abundances are taken from the `otu_table()` slot (but `magnitude = ...`
can override it). Set `magnitude = FALSE` to give equal weight to all
taxa.

## Tree data structure

`x` can be a pre-assembled *tree* made of nested lists, which is written
to the Krona XML unmodified. Each node requires at least a `name`
attribute. The optional magnitude attribute (default name:
`magnitude = 'n'`) specifies the node weights for one or multiple
datasets (specified with `datasets`). Additional data can be provided
(see `attributes`).

## See also

[plot_krona](https://markschl.github.io/taxplore/reference/plot_krona.md),
[ChartOpts](https://markschl.github.io/taxplore/reference/ChartOpts.md),
[ChartDisplayOpts](https://markschl.github.io/taxplore/reference/ChartDisplayOpts.md)

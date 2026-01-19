# Chart attribute specification

Attributes provide information about nodes of in the classification
tree, which is displayed in the top-right area of the chart once a node
is clicked. If generating Krona charts from a matrix/data frame/phyloseq
object, both `name` and `data` are required.

If a pre-computed nested tree is provided as `classification`, only
`name` is required to indicate the name of the list entry containing the
data. Also, some other options don't apply: `dataset_summary_fn`,
`allow_extra_data`, `missing_fill`, `only_ranks`.

Numeric data can be used for custom coloring (see `color` in
[make_krona](https://markschl.github.io/taxplore/reference/make_krona.md)).
External links can be displayed by setting `hrefBase` and `href`. Text
data may contain HTML code (automatically escaped).

## Usage

``` r
ChartAttribute(
  name,
  data = NULL,
  displayName = name,
  text = NULL,
  missing_value = NA,
  hrefBase = NULL,
  href = NULL,
  max_digits = NULL,
  dataset_summary_fn = NULL,
  summary_fn = NULL,
  allow_extra_data = FALSE,
  missing_fill = NA,
  only_ranks = NULL
)
```

## Arguments

- name:

  A name or label. In case of generating charts from a tree structure
  (nested lists), `name` identifies the attribute.

- data:

  The attribute data, which can be a vector or matrix/data frame (see
  details)

- displayName:

  Optional longer label displayed next to the attribute value instead of
  the `name`

- text:

  Text displayed for a node, or a function used to generate the text, in
  the form `text(node_name, attribute_value)`

- missing_value:

  Behavior in case of missing attribute values: By default
  (`missing_value = NA`), the attribute is hidden from the list of
  attributes in the top-right corner if the underlying data is `NA` for
  the currently selected node. To explicitly always include the
  attribute in the list, e.g. set `missing_value = 'N/A'`. *Note*: If
  using this attribute for *coloring*, `missing_value` should also be
  set to some character string, otherwise the color for the value 0 is
  assumed. `make_krona(color = ...)` does this automatically.

- hrefBase:

  Optional base URL is prepended to each value (or `href` path). The
  text is turned into a link if `hrefBase` is defined.

- href:

  URL or URL component following the common `hrefBase` prefix, or a
  function for generating it in the form
  `href(node_name, attribute_value)`

- max_digits:

  The number of digits to use when formatting numeric data. The default
  is `max_digits` from
  [ChartOpts](https://markschl.github.io/taxplore/reference/ChartOpts.md).

- summary_fn:

  Summary function for aggregating `data` for higher ranks. The function
  should look as follows: `summary_fn(attribute_data, magnitudes)` where
  `attribute_data` is a vector of values. The default function for
  numeric data calculates a weighted mean:
  `weighted.mean(attribute_data, magnitudes, na.rm=TRUE)`. In case of a
  *character* vector/matrix, the default function assigns an item to a
  lower/inner rank if all nested items are equal, otherwise it assigns
  `NA`.

- allow_extra_data:

  Suppress warnings regarding extra entries in `data` *not* found in the
  classification.

- missing_fill:

  Numeric or character value to use for missing entries that are present
  in the `classification` but not in the attribute `data`. Default: `NA`
  (another good choice for numeric values could be missing_fill = 0).
  Not to be mistaken with `missing_value`, which just controls how
  attributes are displayed.

- only_ranks:

  Optional vector of names or indices of `classification` rank columns
  for which the attribute should be displayed

- dataset_summary_fn::

  Function for a rowwise summary of `data` columns across datasets (see
  `groups` in
  [make_krona](https://markschl.github.io/taxplore/reference/make_krona.md)).
  The function must accept a vector vector of values and return a single
  value. The default is `sum` for numeric values. Character items from a
  group are only retained if are all equal, otherwise `NA` is returned.

## Details

Attributes reflect the structure of the Krona XML format. Even the
abundance information (magnitude) is stored as an XML attribute
([make_krona.matrix](https://markschl.github.io/taxplore/reference/make_krona.md)
uses the name `n` for that).

### How does `data` look like?

It may be provided as:

- A vector with entries corresponding to the different classes in the
  hierarchy; values cannot vary across different datasets, if there are
  any

- A matrix or data frame with (optionally named) columns corresponding
  to data sets (see `dataset_group` in
  [make_krona](https://markschl.github.io/taxplore/reference/make_krona.md)).
  If the number of columns corresponds to the columns of the `magnitude`
  supplied to
  [make_krona](https://markschl.github.io/taxplore/reference/make_krona.md),
  values are aggregated by `dataset_group` with `dataset_summary_fn`.

If if vector names or matrix row names are set both in the `make_krona`
classification *and* the attribute `data`, they will be used for
matching the two. There may be missing values in `data` (see also
`missing_fill`). If there are no row names, `classification` and
attribute `data` entries must align.

Numeric data is aggregated with `summary_fn` (default: average). Text
data is usually only available in the lowest rank (outermost level of
the hierarchy) unless it is identical across all children of a node, in
which case it gets propagated upwards. The behavior can be changed with
`summary_fn`.

### Limitations

Attribute lists are not supported (as in
http://marbl.github.io/Krona/examples/metarep-ec.krona.html)

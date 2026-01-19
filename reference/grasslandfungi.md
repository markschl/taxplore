# Grassland fungi survey data

Dataset from a grassland plot in the Eastern Swiss mountains (1'500 m
elevation) where a total of 54 occurrences of macrofungi were recorded
during two visits in September 2021.

## Usage

``` r
grasslandfungi

grasslandfungi.records
```

## Format

An object of class `data.frame` with 54 rows and 13 columns.

An object of class `data.frame` with 127 rows and 7 columns.

## Source

<https://swissfungi.wsl.ch>

## Details

The data frames contain the taxonomic lineages (one row per taxon) with
associated record counts during the two visits (`visit_1` and
`visit_2`).

`grasslandfungi.records` simply contains the full taxonomic lineages for
*every* record (taxa repeated), without any additional information.

`grasslandfungi` has *one row per taxon*, along with the record counts
from the two surveys (`visit_1` and `visit_2`) and the total record
count (`n_total`). Further, there are *GBIF* and *SwissFungi* taxon IDs
and the IUCN redlist status according to the current Swiss red list of
macrofungi.

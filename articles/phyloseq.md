# Phyloseq datset examples

This tutorial explores real-world datasets provided in the phyloseq
format. [Phyloseq](https://joey711.github.io/phyloseq) is a popular data
format for metagenomic and microbiome/metabarcoding datasets. The
objects usually contain both taxonomic and abundance information.

``` r
library(taxplore)
library(phyloseq)
# ensure nice output in all contexts
taxplore_configure_snapshot()
```

## The GlobalPatterns dataset

The *phyloseq* package includes a high-throughput 16S metabarcoding
dataset from different substrates ([Caporaso et
al. 2010](https://doi.org/10.1073/pnas.1000080107)):

``` r
data(GlobalPatterns)
GlobalPatterns
#> phyloseq-class experiment-level object
#> otu_table()   OTU Table:         [ 19216 taxa and 26 samples ]
#> sample_data() Sample Data:       [ 26 samples by 7 sample variables ]
#> tax_table()   Taxonomy Table:    [ 19216 taxa by 7 taxonomic ranks ]
#> phy_tree()    Phylogenetic Tree: [ 19216 tips and 19215 internal nodes ]
plot_krona(GlobalPatterns)
```

### Multiple datasets

Environmental/microbiome datasets often have many samples, whose
composition can be visualized separately or as sample groups. This is of
course only useful with interactive charts where differences between
groups can be explored by manually selecting them. Static snapshots
e.g. embedded in a PDF document shows only the first dataset.

For phyloseq objects `group_vars = c('var1', 'var2', ...)` can be
specified to specify combinations of
[`sample_data()`](https://rdrr.io/pkg/phyloseq/man/sample_data-methods.html)
groups: Alternatively, supply `dataset_group = 'separate'`

``` r
plot_krona(GlobalPatterns, group_vars = 'SampleType')
```

### Custom coloring

Another nice feature is the possibility to set the fill color depending
on some property of the entries. We reproduce this [differential
abundance analysis
example](http://joey711.github.io/phyloseq-extensions/DESeq2.md) using
data from [Kostic et
al. (2012)](http://www.genome.org/cgi/doi/10.1101/gr.126573.111) and
visualize the results by coloring the taxa according to their
association with colorectal carcinoma.

First, do the differential abundance testing using the *DESeq2* package:

``` r
library(phyloseq)

filepath <- system.file('extdata', 'study_1457_split_library_seqs_and_mapping.zip',
                        package='phyloseq')
kostic <- microbio_me_qiime(filepath)
kostic <- subset_samples(kostic, DIAGNOSIS != 'None')

# use pre-computed log2-fold change and p-values if possible
kostic_da_file <- '_kostic_da.txt'
if (!file.exists(kostic_da_file)) {
  library(DESeq2)
  diagdds <- phyloseq_to_deseq2(kostic, ~ DIAGNOSIS)
  diagdds <- DESeq(diagdds, sfType = 'poscounts', test = 'Wald', fitType = 'parametric')
  res <- results(diagdds, cooksCutoff = F)
  kostic_da <- as.data.frame(res)[,c('log2FoldChange', 'padj')]
  write.table(kostic_da, kostic_da_file, sep = '\t', quote = FALSE)
}
kostic_da <- read.delim(kostic_da_file)
```

After making sure that the taxa are still in the same order in the
results data frame, we plot the phyloseq object and additionally supply
the log2 fold change with respect to the diagnosis (`color = ...`) to
illustrate by the strength of the association (positive or negative)
with colorectal carcinoma. The strong association of *Fusobacterium*
with the cancer is clearly visible.

``` r
library(taxplore)

stopifnot(taxa_names(kostic) == rownames(kostic_da))
plot_krona(kostic,
       color = kostic_da$log2FoldChange,
       color_label = 'avg. log2 fold change',
        # optional, to adjust the color scale
       color_value_range = c(-1.8, 1.8))
```

The above chart also colors non-significant associations. We can set the
log2 fold change to `NA` for these, so only significant nodes are shown.
Higher ranks are still colored if any association of the contained taxa
is significant (see `summary_fn` in
[`ChartAttribute()`](https://markschl.github.io/taxplore/reference/ChartAttribute.md)).

``` r
logfc_sig <- with(kostic_da, ifelse(!is.na(padj) & padj < 0.05, log2FoldChange, NA))
plot_krona(kostic,
       color = logfc_sig,
       color_label = 'avg. log2 fold change (p.adj < 0.05)',
       color_value_range = c(-1.8, 1.8))
```

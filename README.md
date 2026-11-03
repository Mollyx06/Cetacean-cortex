# Cetacean cortex: manuscript analysis workflows

Curated analysis code accompanying **Cetacean cortex**, aligned to the manuscript dated 2026-10-30. The numbered files in this directory are the current workflow entries. Historical versions and exploratory analyses are stored locally in `_archive/` and excluded from Git by `.gitignore`.

This is a collection of analysis workflows, not a single automatic pipeline. Data, manually curated annotations, orthologue tables, FASTA sequences, and cisTarget databases are not bundled. Configure paths and metadata columns before running. The notebooks retain dataset-specific sample and cluster-label examples; those labels must be supplied from the corresponding curated dataset, not reused blindly on a new clustering.

## Workflow order

| Entry | Analysis | Required input | Main output |
|---|---|---|---|
| [01_load_counts.ipynb](01_load_counts.ipynb) | Load snRNA-seq matrices | Filtered Matrix Market matrices, barcodes and genes from the v3 pipeline | AnnData count objects |
| [02_qc_harmony_clustering.ipynb](02_qc_harmony_clustering.ipynb) | QC, normalization and clustering | Count objects from the individual libraries | Integrated Seurat objects and marker tables |
| [03_cell_annotation.ipynb](03_cell_annotation.ipynb) | Cell annotation and excitatory-neuron integration | QC-passed objects and curated cluster labels | Annotated whole-cortex and excitatory-neuron objects |
| [04_markers_and_cell_figures.ipynb](04_markers_and_cell_figures.ipynb) | Marker selection and cell-atlas figures | Annotated Seurat objects | Marker tables, UMAPs, dot plots and composition plots |
| [05_metaneighbor_ortholog.R](05_metaneighbor_ortholog.R) | Cross-species MetaNeighbor | Species count objects, study/type labels and the six-taxon orthologue table | Strict orthologue table and AUROC matrices/heatmaps |
| [06_samap_excitatory.py](06_samap_excitatory.py) | SAMap integration | Excitatory-neuron AnnData objects, gene-matched protein FASTAs and official SAMap checkout | Pairwise homology maps and saved SAMap object |
| [07_tacco_projection.py](07_tacco_projection.py) | Spatial annotation transfer | Annotated reference and spatial section AnnData objects | Projections using empirical and 0.05-floor priors, in separate output folders |
| [08_spatial_figures.ipynb](08_spatial_figures.ipynb) | Spatial expression figures | Spatial objects with curated anatomical labels | Spatial expression plots |
| [09_pyscenic_aucell.ipynb](09_pyscenic_aucell.ipynb) | GRNBoost2, motif pruning and AUCell | Raw counts in `layers['counts']`, matching TF list, motif annotations and ranking databases | Adjacencies, motif-pruned regulons and cell-by-regulon AUC matrix |
| [10_go_enrichment.ipynb](10_go_enrichment.ipynb) | GO Biological Process enrichment | Marker genes and an expressed-gene universe already mapped to human symbols | BH-adjusted enrichment tables and figures |
| [11_bdnf_adcyap1_codetection.R](11_bdnf_adcyap1_codetection.R) | BDNF/ADCYAP1 co-detection | Raw-count Seurat objects and the strict orthologue table produced by step 05 | Threshold-1/2 counts, observed/expected frequencies and descriptive plots |

Steps 05–11 are downstream branches: they do not all consume the output of the immediately preceding number. In particular, step 11 needs the strict gene map from step 05. Spatial files require upstream processing and anatomical labels that these scripts do not generate.

## Running the workflows

1. Supply the input data and edit the configuration blocks and dataset paths. Paths under `/data/work/` and `/data/input/` describe the original analysis server; they are not files included in this repository.
2. Open R notebooks with an IRkernel kernel and Python notebooks with the relevant Python kernel. Run cells in order after confirming the sample-specific paths and annotation maps.
3. Run standalone files with `Rscript 05_metaneighbor_ortholog.R`, `python 06_samap_excitatory.py`, `python 07_tacco_projection.py`, or `Rscript 11_bdnf_adcyap1_codetection.R` in the appropriate environment.

The six-taxon orthologue table must have columns `ortholog_id`, `Bovine`, `NA`, `SA`, `SB`, `Human`, and `Mouse`. Its identifiers must match the count-matrix features. MetaNeighbor reports the actual shared-group count; compare it with the manuscript's 10,707 single-cell and 7,753 spatial groups, rather than forcing the number to match.

SAMap uses the [official workflow](https://github.com/atarashansky/SAMap): pairwise protein FASTAs are passed to the official `map_genes.sh`, followed by `SAMAP.run()` with default algorithm arguments. Configure the checkout path, FASTA paths and AnnData paths in the script. FASTA gene identifiers must match the corresponding expression features. Existing pairwise maps are reused, so regenerate them when inputs change.

## Software

Manuscript versions for the included methods are Seurat v4, MetaNeighbor v1.4.0, TACCO v0.3.0, pySCENIC v0.12, clusterProfiler v4.8 and SAMap v3.0.1. These are reported manuscript versions, not an environment lock generated by executing the code. Additional dependencies include Harmony, Matrix, SingleCellExperiment, pheatmap, org.Hs.eg.db, sceasy, reticulate, Scanpy, AnnData, NumPy, pandas, SciPy, matplotlib, seaborn, Arboreto, ctxcore and Dask. Plotting notebooks also use the R packages imported in their first cells.

Use separate environments for SAMap and pySCENIC/TACCO as needed. SAMap 3.0.1 requires Python 3.11 or newer and BLAST+; its script checks the installed `sc-samap` version. Record package/session versions when rerunning the analyses.

## Coverage and validation

See [MANUSCRIPT_COVERAGE.md](MANUSCRIPT_COVERAGE.md) for retained analyses, missing methodological details and upstream steps. Formatting and syntax checks do not establish reproduction of the manuscript results; full analysis has not been rerun with the original data in this workspace.

## Updating the GitHub repository

Use this directory's numbered files, README, coverage document and `.gitignore` as the current source set. Replace obsolete root-level scripts in the existing repository instead of overlaying the new files and keeping both versions. `.gitignore` excludes the local archive and macOS sidecars; it does not automatically remove files already tracked by Git. The archived `FILE_MAP.json` records the previous-to-current filenames. No remote push is performed by this preparation step.

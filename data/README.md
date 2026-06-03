# Data Placeholders

This repository does not include raw sequencing data or large processed objects. Use the following method-based placeholder layout when reproducing the analysis.

| Placeholder | Description |
|---|---|
| `data/raw/snRNA-seq_filter_matrix/` | Raw or filtered snRNA-seq count matrices. |
| `data/raw/stereo-seq_filter_matrix/` | Raw or filtered Stereo-seq spatial count matrices. |
| `data/raw/spatial_mask_file.h5ad` | Spatial mask or segmented spatial object used for spatial-domain analysis. |
| `data/external/human_reference.rds` | Human cortical reference object for cross-species comparison. |
| `data/external/mouse_reference.rds` | Mouse cortical reference object for cross-species comparison. |
| `data/external/cattle_reference.rds` | Cattle cortical reference object for terrestrial cetartiodactyl comparison. |
| `data/external/cistarget_databases/` | cisTarget ranking databases and motif annotations for pySCENIC. |
| `data/processed/raw_snRNA_h5ad_file` | Per-sample snRNA-seq AnnData object generated after loading. |
| `data/processed/cortex_analysis_file` | Integrated or annotated cortex-level Seurat/AnnData object. |
| `data/processed/excitatory_neuron_file` | Extracted excitatory neuron subset object. |
| `data/processed/sc_reference_file` | Annotated single-cell reference used for spatial mapping and downstream comparison. |
| `data/processed/spatial_bin100_file` | Bin100 spatial object for TACCO/Spateo analysis. |

Recommended real file suffixes are `.h5ad` for AnnData objects, `.rds` for Seurat/R objects, `.csv` for marker or enrichment tables, and `.png`/`.pdf` for exported figures.

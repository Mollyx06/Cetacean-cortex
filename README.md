# Cetacean-cortex

Single-nucleus and spatial transcriptomics analysis of cetacean cortical organization, focused on prefrontal cortex (PFC) and primary visual cortex (V1) across toothed whale species and terrestrial mammal references.

This repository contains the analysis notebooks used to generate a reproducible, GitHub-friendly workflow for the cetacean cortex project. Large intermediate objects and raw sequencing outputs are not included. In notebooks and documentation, local absolute paths have been replaced with method-based placeholders such as `data/processed/sc_reference_file`, `results/tacco/tacco_output_file`, and `results/figures/figure_panel_file`.

## Project Structure

```text
Cetacean-cortex/
├── notebooks/              # Ordered analysis notebooks
├── colabs/                 # Existing Colab-oriented notebooks
├── data/                   # Data manifest and placeholder layout only
├── results/                # Output manifest and placeholder layout only
├── docs/                   # Workflow and method notes
├── config/                 # Example path/configuration files
├── requirements.txt        # Python package dependencies
└── README.md
```

## Analysis Workflow

The main workflow is organized as numbered notebooks:

| Step | Notebook | Purpose |
|---|---|---|
| 01 | `01_load_V3.ipynb` | Load snRNA-seq count matrices and generate per-sample objects. |
| 02 | `02_pre.ipynb` | Quality control, preprocessing, integration, clustering, and marker detection. |
| 03 | `03_annotation.ipynb` | Cell-type annotation and excitatory neuron subset extraction. |
| 04 | `04_Fig2_anno.ipynb` | UMAP, marker, proportion, and annotation evidence plots. |
| 05 | `05_metaneighbor_*.ipynb` | Cross-species similarity analysis with MetaNeighbor. |
| 06 | `06_tacco.ipynb` | Spatial projection of snRNA-seq states onto Stereo-seq bins with TACCO. |
| 07 | `07_Fig3_vis.ipynb` | Spatial and marker visualizations for Fig. 3 analyses. |
| 08 | `08_spateo.ipynb` | Spatial domain and digital layer analysis with Spateo. |
| 09 | `09_Fig4_cci.ipynb` | Cell-cell communication analysis and NeuronChat visualization. |
| 10 | `10_scenic_py.ipynb` | pySCENIC regulon inference and transcription-factor network analysis. |
| 11 | `11_GO_ana.ipynb` | Gene Ontology enrichment analysis. |
| 12 | `12_Fig5_co&bu.ipynb` | BDNF/ADCYAP1 co-expression and comparative visualization. |

See [docs/workflow.md](docs/workflow.md) for a more detailed description of inputs, outputs, and placeholder file names.

## Data Availability

Raw sequencing data, large `.h5ad`/`.rds` objects, spatial images, intermediate model outputs, and generated figure files are intentionally excluded from Git. The expected layout and placeholder names are described in [data/README.md](data/README.md) and [results/README.md](results/README.md).

## Environment

The workflow uses a mixed Python/R ecosystem. Python dependencies are listed in [requirements.txt](requirements.txt). R packages used across notebooks include Seurat, dplyr, ggplot2, patchwork, MetaNeighbor, NeuronChat, clusterProfiler, org.* annotation packages, and related visualization utilities.

For a new machine, copy [config/paths.example.yaml](config/paths.example.yaml) to `config/paths.local.yaml` and map each placeholder to the local data location.

## Notes

- Notebook execution outputs were cleared to keep the repository lightweight.
- Local absolute paths were replaced with repository-relative placeholders.
- Manuscript draft and supplementary method files were used only to organize the public-facing workflow description and are not included in this repository.

# Workflow

This document summarizes the public GitHub workflow derived from the analysis notebooks and manuscript methods. Large local intermediate files are represented with method-based placeholders.

## Biological Scope

The project analyzes cetacean cortical tissue, including prefrontal cortex and primary visual cortex, with terrestrial mammal references for cross-species comparison. The manuscript methods describe stranded cetacean brain tissue collection, fresh-frozen processing, snRNA-seq, Stereo-seq spatial transcriptomics, reference annotation improvement, lamination guidance, cell-type annotation, spatial projection, and cross-species comparative analyses.

## Notebook Order

1. `01_load_V3.ipynb`
   Load filtered snRNA-seq matrices and write per-sample objects as `data/processed/raw_snRNA_h5ad_file`.

2. `02_pre.ipynb`
   Run quality control, preprocessing, sample integration, clustering, and marker detection. Representative outputs are `data/processed/cortex_analysis_file.rds` and marker tables such as `data/processed/deg_annotation.csv`.

3. `03_annotation.ipynb`
   Annotate major cortical cell classes and excitatory neuron subclusters. Outputs include `data/processed/sc_reference_file.rds` and `data/processed/excitatory_neuron_file.rds`.

4. `04_Fig2_anno.ipynb`
   Generate UMAPs, marker dot plots, and cell-type proportion visualizations for annotation evidence. Outputs use `results/figures/figure_panel_file`.

5. `05_metaneighbor_exn4_2026.ipynb`, `05_metaneighbor_exn5.ipynb`, `05_metaneighbor_hm.ipynb`, and `05_metaneighbor_hm_2026.ipynb`
   Compare excitatory neuron subtypes across cetacean, human, mouse, and cattle references with MetaNeighbor. Inputs are placeholder references such as `data/external/human_reference.rds`, `data/external/mouse_reference.rds`, and `data/processed/excitatory_neuron_file.rds`.

6. `06_tacco.ipynb`
   Project snRNA-seq annotations onto Stereo-seq spatial bins using TACCO. Inputs include `data/processed/sc_reference_file.h5ad` and `data/processed/spatial_bin100_file.h5ad`. Outputs use `results/tacco/tacco_output_file`.

7. `07_Fig3_vis.ipynb`
   Visualize spatially mapped cortical cell states, marker expression, and layer-associated patterns. Outputs use `results/figures/figure_panel_file`.

8. `08_spateo.ipynb`
   Run Spateo-based spatial domain identification, digital layer construction, and spatial visualization. Outputs use `results/spateo/spateo_output_file`.

9. `09_Fig4_cci.ipynb`
   Analyze cell-cell communication with NeuronChat and visualize signaling pathways such as neurotrophin, neuropeptide, and NO/cGMP-associated modules. Outputs use `results/neuronchat/neuronchat_output_file`.

10. `10_scenic_py.ipynb`
    Run pySCENIC regulon inference, motif enrichment, AUCell scoring, and TF-target network extraction for excitatory neuron populations. Outputs use `results/pyscenic/pyscenic_output_file`.

11. `11_GO_ana.ipynb`
    Run Gene Ontology enrichment for marker genes and subtype-specific signatures. Outputs use `results/go/go_output_file`.

12. `12_Fig5_co&bu.ipynb`
    Generate comparative BDNF/ADCYAP1 co-expression and cross-species visualization panels. Outputs use `results/figures/figure_panel_file`.

## Reproducibility Notes

- Keep large `.h5ad`, `.rds`, raw matrix, and generated figure files outside Git.
- Use `config/paths.local.yaml` for local machine-specific paths.
- When sharing results publicly, replace local project paths with the placeholders documented in `data/README.md` and `results/README.md`.
- The current notebooks preserve the original analysis logic but clear execution outputs for a lightweight repository.

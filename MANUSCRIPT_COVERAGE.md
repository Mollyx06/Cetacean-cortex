# Manuscript coverage

This document distinguishes executable source coverage from results that have been reproduced. The current code has not been run end-to-end on the original datasets.

| Method | Current scope and limitations |
|---|---|
| Seurat/Harmony | QC (`nFeature_RNA > 1000`, mitochondrial percentage < 5), log normalization, 3,000 variable genes, integration and clustering. Annotation/integration notebooks now use 30 dimensions. Cluster labels and paths remain dataset-specific curated inputs. Confirm mitochondrial feature naming for each species. |
| Marker testing | Wilcoxon, `min.pct = 0.1`, log-fold-change threshold 0.25, and fractional detection difference > 0.5. |
| MetaNeighbor | Strict orthologue mapping, raw-count collapsing before normalization, shared features and AUROC analysis. Four former direct-symbol-intersection notebooks are archived. |
| SAMap | Official pairwise protein homology preparation and default integration at manuscript version 3.0.1. Input sequence identifiers and expression features must match. |
| TACCO | One batch script includes both empirical-prior sensitivity analysis and the shared 0.05-floor analysis. The old single-section projection/plotting notebook is archived. |
| Spatial visualization | Existing expression/anatomical-label plots are retained. These plots do not implement spatial-domain discovery or cortical-axis inference. |
| pySCENIC/AUCell | GRNBoost2, motif pruning and AUCell retained. The old module-weight network figures and arbitrary weight filtering are archived. The manuscript's active-regulon rule (Z > 5 and adjusted P < 0.05) remains unimplemented because the Z definition and statistical test are unspecified. |
| GO | Human-symbol BP enrichment with expressed-feature background and BH adjustment. Human-symbol mapping must already be present in the input; membership in OrgDb alone is not evidence of orthology. |
| BDNF/ADCYAP1 | Raw-count co-detection at thresholds 1 and 2, marginal expected frequency and observed/expected ratio. Cross-species comparisons are descriptive. The old summed-expression visualization is archived and is not used as the co-detection statistic. |

## Steps awaiting analysis records

- **NeuronChat:** the former notebook runs inference but does not explicitly implement the manuscript's BH-adjusted q < 0.05 rule. It is archived pending verification of the original permutation P-values, adjustment scope and output structure.
- **Spateo:** the former notebook uses a manually contoured example. The finalized domain selection, Moran's I analysis and cross-section comparison settings are missing. It is archived rather than used as the manuscript's complete spatial-axis workflow.
- **NTRK2:** candidate curation, custom transcript references, original read remapping and isoform support require the actual reference files and alignment/counting settings. No provisional replacement script is included.
- **Upstream experiments and processing:** histology tracing/registration, SAW/Stereopy processing and genome annotation with IsoQuant, Gffcompare, TransDecoder, DIAMOND and BUSCO are not recreated here.

These gaps should be resolved against the final analysis record or reflected in the manuscript's code-availability statement before claiming full computational reproducibility.

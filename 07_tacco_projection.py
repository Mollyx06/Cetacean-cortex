"""Project all Stereo-seq sections with empirical and 0.05-floor priors."""

from pathlib import Path

import anndata as ad
import pandas as pd
import scanpy as sc
import tacco as tc


REFERENCE_PATH = Path("/data/work/Data_Ex/combined/EXN_harmony_nasa_res0_5_annotated.h5ad")
SPATIAL_DIR = Path("/data/work/bin100_labeled/04_HE_subset")
OUTPUT_ROOT = Path("/data/work/TACCO/bin100_HE_output")
ANNOTATION_COLUMN = "annotation"
RESULT_KEY = "pred_celltype"
MIN_REFERENCE_PRIOR = 0.05

if not REFERENCE_PATH.is_file():
    raise FileNotFoundError(REFERENCE_PATH)
if not SPATIAL_DIR.is_dir():
    raise FileNotFoundError(SPATIAL_DIR)

reference = sc.read_h5ad(REFERENCE_PATH)
reference = reference[reference.obs[ANNOTATION_COLUMN].notna()].copy()
reference = reference[reference.obs[ANNOTATION_COLUMN] != "Other"].copy()
empirical_prior = reference.obs[ANNOTATION_COLUMN].value_counts(normalize=True)
floored_prior = empirical_prior.clip(lower=MIN_REFERENCE_PRIOR)


def run_projection(source_path: Path, prior: pd.Series, output_dir: Path) -> None:
    spatial = sc.read_h5ad(source_path)
    spatial.X = spatial.X.astype("float32")
    tc.tl.annotate(
        spatial,
        reference,
        ANNOTATION_COLUMN,
        result_key=RESULT_KEY,
        annotation_prior=prior,
        verbose=False,
    )
    probabilities = spatial.obsm[RESULT_KEY].copy()
    spatial.obs[RESULT_KEY] = probabilities.idxmax(axis=1).astype("category")
    spatial.obs[f"{RESULT_KEY}_max_probability"] = probabilities.max(axis=1)
    output_dir.mkdir(parents=True, exist_ok=True)
    spatial.write_h5ad(output_dir / source_path.name, compression="gzip")


spatial_files = sorted(SPATIAL_DIR.glob("*.h5ad"))
if not spatial_files:
    raise FileNotFoundError(f"No .h5ad sections found in {SPATIAL_DIR}")

for spatial_path in spatial_files:
    run_projection(spatial_path, empirical_prior, OUTPUT_ROOT / "unadjusted_prior")
    run_projection(spatial_path, floored_prior, OUTPUT_ROOT / "prior_floor_005")

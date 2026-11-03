"""Run SAMap's default workflow for the manuscript excitatory-neuron datasets.

Prepare one AnnData file per species and all pairwise protein homology maps first.
The homology maps follow the official SAMap map_genes.sh workflow (bidirectional
BLASTP for protein FASTA inputs). SAMAP.run() is then called with its defaults.
"""

from pathlib import Path
from itertools import combinations
import pickle
from importlib.metadata import version
import subprocess

from samap import SAMAP


# Inputs must be the species-specific excitatory AnnData objects described in Methods.
INPUTS = {
    "Na": Path("/data/work/samap/Na_excitatory.h5ad"),
    "Sa": Path("/data/work/samap/Sa_excitatory.h5ad"),
    "Hs": Path("/data/work/samap/Hs_excitatory.h5ad"),
    "Mm": Path("/data/work/samap/Mm_excitatory.h5ad"),
}
PROTEIN_FASTA = {
    "Na": Path("/data/work/samap/fasta/Na.proteins.fa"),
    "Sa": Path("/data/work/samap/fasta/Sa.proteins.fa"),
    "Hs": Path("/data/work/samap/fasta/Hs.proteins.fa"),
    "Mm": Path("/data/work/samap/fasta/Mm.proteins.fa"),
}
SAMAP_REPO = Path("/data/software/SAMap")
WORK_DIR = Path("/data/work/samap")
MAP_DIR = WORK_DIR / "maps"
OUTPUT_DIR = WORK_DIR / "output"

EXPECTED_VERSION = "3.0.1"
installed_version = version("sc-samap")
if installed_version != EXPECTED_VERSION:
    raise RuntimeError(
        f"Methods specifies SAMap {EXPECTED_VERSION}; found {installed_version}."
    )

missing = [str(path) for path in INPUTS.values() if not path.is_file()]
if missing:
    raise FileNotFoundError("Missing SAMap AnnData inputs:\n" + "\n".join(missing))
missing_fasta = [str(path) for path in PROTEIN_FASTA.values() if not path.is_file()]
if missing_fasta:
    raise FileNotFoundError("Missing protein FASTA inputs:\n" + "\n".join(missing_fasta))

map_genes = SAMAP_REPO / "map_genes.sh"
if not map_genes.is_file():
    raise FileNotFoundError(f"Official SAMap map_genes.sh not found: {map_genes}")

WORK_DIR.mkdir(parents=True, exist_ok=True)
for (species_1, fasta_1), (species_2, fasta_2) in combinations(PROTEIN_FASTA.items(), 2):
    pair_dir = MAP_DIR / f"{species_1}{species_2}"
    forward = pair_dir / f"{species_1}_to_{species_2}.txt"
    reverse = pair_dir / f"{species_2}_to_{species_1}.txt"
    if forward.is_file() and reverse.is_file():
        continue
    subprocess.run(
        [
            "bash",
            str(map_genes),
            "--tr1", str(fasta_1), "--t1", "prot", "--n1", species_1,
            "--tr2", str(fasta_2), "--t2", "prot", "--n2", species_2,
        ],
        cwd=WORK_DIR,
        check=True,
    )

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Leave all algorithm arguments at the package defaults used by the standard workflow.
samap = SAMAP(sams={key: str(path) for key, path in INPUTS.items()}, f_maps=str(MAP_DIR) + "/")
samap.run()

with (OUTPUT_DIR / "cetacean_human_mouse_excitatory_samap.pkl").open("wb") as handle:
    pickle.dump(samap, handle, protocol=pickle.HIGHEST_PROTOCOL)

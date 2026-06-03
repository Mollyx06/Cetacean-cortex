# Result Placeholders

Generated outputs are excluded from Git by default. The notebooks write to method-based result locations:

| Placeholder | Description |
|---|---|
| `results/figures/figure_panel_file` | Main and supplementary figure panels exported as `.png` or `.pdf`. |
| `results/tacco/tacco_output_file` | TACCO spatial annotation outputs, typically `.h5ad` or `.rds`. |
| `results/spateo/spateo_output_file` | Spateo spatial domain, digitalization, and layer outputs. |
| `results/neuronchat/neuronchat_output_file` | NeuronChat cell-cell communication results. |
| `results/pyscenic/pyscenic_output_file` | pySCENIC regulon, motif, AUCell, and TF-target network outputs. |
| `results/go/go_output_file` | GO enrichment tables and plots. |

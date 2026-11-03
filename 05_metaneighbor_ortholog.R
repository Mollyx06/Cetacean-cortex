suppressPackageStartupMessages({
  library(Seurat)
  library(Matrix)
  library(SingleCellExperiment)
  library(MetaNeighbor)
  library(pheatmap)
})

# Choose one manuscript comparison and edit the input paths/label columns.
# The table must be the six-taxon annotation-supported mapping from Table S5.
analysis_set <- "single_cell" # "single_cell" or "spatial"
ortholog_file <- "/data/work/00_Figs_method/ortholog_6species_1to1.tsv"
output_dir <- "/data/work/00_Figs_plan/metaneighbor_ortholog"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

single_cell_config <- list(
  Na = list(path = "/data/work/Data_Ex/combined/sep_NASA/NA_PFC_EXN_annotated.rds", species_col = "NA", label_col = "annotation"),
  Sa = list(path = "/data/work/Data_Ex/combined/sep_NASA/SA_PFC_EXN_annotated.rds", species_col = "SA", label_col = "annotation"),
  Hs = list(path = "/data/work/Data_Ex/human_sci_EXN.rds", species_col = "Human", label_col = "cellType_layer"),
  Mm = list(path = "/data/work/Data_Ex/mouse_cortex_EXN_labeled.rds", species_col = "Mouse", label_col = "Layer")
)
spatial_config <- list(
  Na = list(path = "data/spatial/Na_spatial.rds", species_col = "NA", label_col = "region"),
  Sa = list(path = "data/spatial/Sa_spatial.rds", species_col = "SA", label_col = "region"),
  Sb = list(path = "data/spatial/Sb_spatial.rds", species_col = "SB", label_col = "region"),
  Bu = list(path = "data/spatial/Bu_spatial.rds", species_col = "Bovine", label_col = "region"),
  Hs = list(path = "data/spatial/Hs_spatial.rds", species_col = "Human", label_col = "region"),
  Mm = list(path = "data/spatial/Mm_spatial.rds", species_col = "Mouse", label_col = "region")
)

comparison_members <- list(
  single_cell = c("Na", "Sa", "Hs", "Mm"),
  spatial = c("Na", "Sa", "Sb", "Bu", "Hs", "Mm")
)
members <- comparison_members[[analysis_set]]
if (is.null(members)) stop("analysis_set must be 'single_cell' or 'spatial'.")
dataset_config <- if (analysis_set == "single_cell") single_cell_config else spatial_config

if (!file.exists(ortholog_file)) stop("Missing orthologue table: ", ortholog_file)
orthologs <- read.delim(
  ortholog_file,
  sep = "\t",
  check.names = FALSE,
  stringsAsFactors = FALSE,
  na.strings = ""
)
required_columns <- c("ortholog_id", "Bovine", "NA", "SA", "SB", "Human", "Mouse")
if (!all(required_columns %in% names(orthologs))) {
  stop("Orthologue table must contain: ", paste(required_columns, collapse = ", "))
}

# Keep only groups with one unique, non-missing gene identifier in every taxon.
species_columns <- c("Bovine", "NA", "SA", "SB", "Human", "Mouse")
strict <- Reduce(`&`, lapply(species_columns, function(column) {
  values <- trimws(orthologs[[column]])
  !is.na(values) & nzchar(values) &
    !(duplicated(values) | duplicated(values, fromLast = TRUE))
}))
orthologs <- orthologs[strict, , drop = FALSE]
strict_map_path <- "/data/work/00_Figs_method/ortholog_6species_1to1_strict.tsv"
dir.create(dirname(strict_map_path), recursive = TRUE, showWarnings = FALSE)
write.table(orthologs, strict_map_path, sep = "\t", quote = FALSE, row.names = FALSE, na = "")

get_counts <- function(object) {
  tryCatch(
    GetAssayData(object, assay = "RNA", layer = "counts"),
    error = function(e) GetAssayData(object, assay = "RNA", slot = "counts")
  )
}

map_counts <- function(counts, species_column) {
  map_index <- match(rownames(counts), orthologs[[species_column]])
  keep <- which(!is.na(map_index))
  if (!length(keep)) stop("No input genes mapped for column ", species_column)
  mapped_id <- orthologs$ortholog_id[map_index[keep]]
  levels <- unique(mapped_id)
  collapse <- sparseMatrix(
    i = match(mapped_id, levels),
    j = seq_along(mapped_id),
    x = 1,
    dims = c(length(levels), length(mapped_id))
  )
  collapsed <- collapse %*% counts[keep, , drop = FALSE]
  rownames(collapsed) <- levels
  collapsed
}

expression_matrices <- list()
cell_metadata <- list()
for (dataset in members) {
  cfg <- dataset_config[[dataset]]
  if (!file.exists(cfg$path)) stop("Missing dataset RDS: ", cfg$path)
  object <- readRDS(cfg$path)
  metadata <- object[[]]
  if (!cfg$label_col %in% names(metadata)) {
    stop(dataset, " is missing metadata column '", cfg$label_col, "'.")
  }
  counts <- get_counts(object)
  metadata <- metadata[colnames(counts), , drop = FALSE]
  mapped_counts <- map_counts(counts, cfg$species_col)
  library_size <- Matrix::colSums(mapped_counts)
  normalized <- log1p(mapped_counts %*% Diagonal(x = 10000 / pmax(library_size, 1)))
  rownames(normalized) <- rownames(mapped_counts)
  prefixed_cells <- paste(dataset, colnames(counts), sep = "|")
  colnames(normalized) <- prefixed_cells
  expression_matrices[[dataset]] <- normalized
  cell_metadata[[dataset]] <- data.frame(
    study_id = dataset,
    cell_type = as.character(metadata[[cfg$label_col]]),
    row.names = prefixed_cells,
    stringsAsFactors = FALSE
  )
}

common_orthologs <- sort(Reduce(intersect, lapply(expression_matrices, rownames)))
if (!length(common_orthologs)) stop("No common ortholog_id values across selected datasets.")
message("Shared strict one-to-one ortholog groups: ", length(common_orthologs))

expression_matrices <- lapply(expression_matrices, function(x) x[common_orthologs, , drop = FALSE])
combined_expression <- do.call(cbind, expression_matrices)
combined_metadata <- do.call(rbind, unname(cell_metadata))
combined_metadata <- combined_metadata[colnames(combined_expression), , drop = FALSE]
sce <- SingleCellExperiment(
  assays = list(RNA = combined_expression),
  colData = combined_metadata
)

variable_genes <- variableGenes(dat = sce, exp_labels = sce$study_id)
aurocs <- MetaNeighborUS(
  var_genes = variable_genes,
  dat = sce,
  study_id = sce$study_id,
  cell_type = sce$cell_type,
  fast_version = TRUE
)

write.csv(
  aurocs,
  file.path(output_dir, paste0("MetaNeighbor_", analysis_set, "_AUROC.csv")),
  quote = FALSE
)
pdf(file.path(output_dir, paste0("MetaNeighbor_", analysis_set, "_AUROC.pdf")), width = 12, height = 12)
pheatmap(aurocs, clustering_distance_rows = "euclidean", clustering_distance_cols = "euclidean", clustering_method = "complete")
dev.off()

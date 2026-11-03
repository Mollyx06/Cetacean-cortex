suppressPackageStartupMessages({
  library(SeuratObject)
  library(Matrix)
  library(dplyr)
  library(purrr)
  library(tibble)
  library(ggplot2)
})

# Edit these paths and metadata columns to match the five analysed datasets.
datasets <- tribble(
  ~dataset, ~species, ~path, ~population_col, ~ortholog_col,
  "Na", "Neophocaena asiaeorientalis asiaeorientalis", "/data/work/Data_Ex/combined/sep_NASA/NA_PFC_EXN_annotated.rds", "annotation", "NA",
  "Sa", "Stenella attenuata", "/data/work/Data_Ex/combined/sep_NASA/SA_PFC_EXN_annotated.rds", "annotation", "SA",
  "Bu", "Bos taurus", "/data/work/Data_cortex/B1_PFC/datab_ex.rds", "annotation", "Bovine",
  "Mm", "Mus musculus", "/data/work/Data_cortex/MU_PFC/sc_mouse_cortex_with_layer.rds", "Layer", "Mouse",
  "Hs", "Homo sapiens", "/data/work/Data_cortex/HM_PFC/sc_human_PFC_with_layer.rds", "Layer", "Human"
)

ortholog_file <- "/data/work/00_Figs_method/ortholog_6species_1to1_strict.tsv"
output_dir <- "/data/work/00_Figs_plan/BDNF_ADCYAP1_co_detection"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
if (!file.exists(ortholog_file)) stop("Missing strict one-to-one map: ", ortholog_file)
orthologs <- read.delim(ortholog_file, check.names = FALSE, stringsAsFactors = FALSE)
bdnf_row <- which(orthologs$Human == "BDNF")
adcyap1_row <- which(orthologs$Human == "ADCYAP1")
if (length(bdnf_row) != 1L || length(adcyap1_row) != 1L) {
  stop("Expected unique BDNF and ADCYAP1 rows in the orthologue table.")
}

get_raw_counts <- function(object) {
  counts <- tryCatch(
    GetAssayData(object, assay = "RNA", layer = "counts"),
    error = function(e) GetAssayData(object, assay = "RNA", slot = "counts")
  )
  if (is.null(counts) || nrow(counts) == 0L) {
    stop("Raw RNA counts are required for the manuscript co-detection definition.")
  }
  counts
}

extract_cells <- function(dataset, species, path, population_col, ortholog_col) {
  if (!file.exists(path)) stop("Input RDS does not exist: ", path)
  object <- readRDS(path)
  counts <- get_raw_counts(object)
  metadata <- object[[]]
  if (!population_col %in% names(metadata)) {
    stop("Metadata column '", population_col, "' is missing in ", dataset)
  }
  if (!identical(colnames(counts), rownames(metadata))) {
    metadata <- metadata[colnames(counts), , drop = FALSE]
  }

  if (!ortholog_col %in% names(orthologs)) {
    stop("Missing orthologue column '", ortholog_col, "'.")
  }
  bdnf_symbol <- orthologs[[ortholog_col]][bdnf_row]
  adcyap1_symbol <- orthologs[[ortholog_col]][adcyap1_row]
  find_feature <- function(symbol) {
    hit <- which(toupper(rownames(counts)) == toupper(symbol))
    if (length(hit) != 1L) {
      stop(dataset, ": expected one ", symbol, " feature; found ", length(hit))
    }
    hit
  }

  bdnf <- find_feature(bdnf_symbol)
  adcyap1 <- find_feature(adcyap1_symbol)
  tibble(
    dataset = dataset,
    species = species,
    population = as.character(metadata[[population_col]]),
    bdnf_count = as.numeric(counts[bdnf, ]),
    adcyap1_count = as.numeric(counts[adcyap1, ])
  )
}

cell_data <- pmap_dfr(datasets, extract_cells)

summarise_detection <- function(data, threshold, group_columns) {
  data %>%
    mutate(
      bdnf_positive = bdnf_count >= threshold,
      adcyap1_positive = adcyap1_count >= threshold,
      double_positive = bdnf_positive & adcyap1_positive
    ) %>%
    group_by(across(all_of(group_columns))) %>%
    summarise(
      n_total = n(),
      n_bdnf_positive = sum(bdnf_positive),
      n_adcyap1_positive = sum(adcyap1_positive),
      n_double_positive = sum(double_positive),
      pct_bdnf_positive = 100 * n_bdnf_positive / n_total,
      pct_adcyap1_positive = 100 * n_adcyap1_positive / n_total,
      pct_double_positive = 100 * n_double_positive / n_total,
      expected_double_positive_pct = 100 *
        (n_bdnf_positive / n_total) * (n_adcyap1_positive / n_total),
      observed_expected_ratio = if_else(
        expected_double_positive_pct > 0,
        pct_double_positive / expected_double_positive_pct,
        NA_real_
      ),
      .groups = "drop"
    ) %>%
    mutate(raw_count_threshold = threshold)
}

dataset_summary <- map_dfr(c(1L, 2L), ~ summarise_detection(
  cell_data, .x, c("dataset", "species")
))
population_summary <- map_dfr(c(1L, 2L), ~ summarise_detection(
  cell_data, .x, c("dataset", "species", "population")
))

write.csv(
  dataset_summary,
  file.path(output_dir, "BDNF_ADCYAP1_co_detection_by_dataset.csv"),
  row.names = FALSE
)
write.csv(
  population_summary,
  file.path(output_dir, "BDNF_ADCYAP1_co_detection_by_population.csv"),
  row.names = FALSE
)

primary <- dataset_summary %>%
  filter(raw_count_threshold == 1L) %>%
  mutate(label = paste0(n_double_positive, "/", n_total))

p <- ggplot(primary, aes(dataset, pct_double_positive, fill = dataset)) +
  geom_col(width = 0.68, colour = "black", linewidth = 0.25) +
  geom_text(aes(label = label), vjust = -0.4, size = 3) +
  labs(x = NULL, y = "Double-positive cells (%)") +
  theme_classic() +
  theme(legend.position = "none")

ggsave(
  file.path(output_dir, "BDNF_ADCYAP1_co_detection.png"),
  p, width = 6.5, height = 4.2, dpi = 300
)

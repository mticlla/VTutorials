## code to prepare `vdata` dataset goes here

library(tidyverse)
library(tidytacos)

# The full dataset of Isala
# Files downloaded from:
# https://github.com/LebeerLab/Citizen-science-map-of-the-vaginal-microbiome/tree/main/data/isala
# The full dataset of Isala counts
isala_counts_file <- "./data-raw/asv_counts.tsv.gz"
# The full dataset of Isala taxa (ASVs)
isala_taxa_file <- "./data-raw/asv_spec.tsv"
# The full dataset of Isala samples
isala_samples_file <-  "./data-raw/metadata.tsv"

# Upload files
isala_counts <- readr::read_tsv(isala_counts_file, show_col_types = FALSE)
isala_taxa <- readr::read_tsv(isala_taxa_file, show_col_types = FALSE,
                              col_select = c(-1))
isala_samples <- readr::read_tsv(isala_samples_file, show_col_types = FALSE)

# Create the tidyamplicons object
isala_counts_matrix <- as.matrix(isala_counts[,-1])
rownames(isala_counts_matrix) <- isala_counts %>% dplyr::pull(bioSampleId)

isala_profiles <- tidytacos::create_tidytacos(isala_counts_matrix)

isala_profiles <- tidytacos:::change_id_taxa(isala_profiles,
                                             taxon_id_new = taxon)
# Add metadata of taxa
isala_profiles <- isala_profiles %>%
  tidytacos::add_metadata(
    dplyr::left_join(isala_taxa, isala_profiles$taxa,
                     by=dplyr::join_by(taxon_id)) %>%
      dplyr::rename(sequence=taxon.x, taxon=taxon.y),
    table_type = "taxa"
  )

# Add metadata of samples
isala_profiles <- isala_profiles %>%
  tidytacos::add_metadata(
    dplyr::left_join(isala_samples, isala_profiles$samples,
                     by=dplyr::join_by(bioSampleId==sample)) %>%
      dplyr::rename(sample = bioSampleId),
    table_type = "sample"
  )

# Select a random subsample of Isala
n_size <- 200
set.seed(100)
isala_subsample_ids <- sample(isala_counts$bioSampleId, n_size)

vdata <- isala_profiles %>%
  tidytacos::filter_samples(sample %in% isala_subsample_ids)

usethis::use_data(vdata, overwrite = TRUE)

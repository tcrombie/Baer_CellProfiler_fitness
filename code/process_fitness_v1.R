library(tidyverse)

# set working directory
setwd(paste0(dirname(rstudioapi::getActiveDocumentContext()$path),"/.."))

# load sayran's data
man_dat <- data.table::fread("data/20220817_Sayran_Worm counts.csv") %>%
  tidyr::separate(`Plate ID`, into = c("plate", "well", "strain", "row")) %>%
  dplyr::select(strain, well, man_well_count_bf = BF, man_well_count_gfp = GFP, man_frac_gfp = frac_gfp)

# load CellProfiler data
cp_gfp_counts <- data.table::fread("/Users/tim/repos/Baer_CellProfiler_fitness/CellProfiler/output/GFPobjects.csv") %>%
  dplyr::select(ImageNumber, ObjectNumber, Metadata_Strain, Metadata_Well, Metadata_image_type) %>%
  dplyr::group_by(Metadata_Well) %>%
  dplyr::mutate(well_count_gfp = n()) %>%
  dplyr::distinct(Metadata_Well, .keep_all = T) %>%
  dplyr::select(strain = Metadata_Strain, well = Metadata_Well, well_count_gfp)

cp_bf_counts <- data.table::fread("/Users/tim/repos/Baer_CellProfiler_fitness/CellProfiler/output/NonOverlappingWorms.csv") %>%
  dplyr::select(ImageNumber, ObjectNumber, Metadata_Strain, Metadata_Well, Metadata_image_type) %>%
  dplyr::group_by(Metadata_Well) %>%
  dplyr::mutate(well_count_bf = n()) %>%
  dplyr::distinct(Metadata_Well, .keep_all = T) %>%
  dplyr::select(strain = Metadata_Strain, well = Metadata_Well, well_count_bf)

join_df <- full_join(cp_gfp_counts, cp_bf_counts) %>%
  dplyr::ungroup() %>%
  dplyr::filter(strain != "00") %>%
  dplyr::mutate(frac_gfp = well_count_gfp/well_count_bf) %>%
  dplyr::left_join(., man_dat)

# show agreement
agreement_plot <- ggplot(join_df) +
  aes(x = man_frac_gfp, y = frac_gfp, label = well) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, linetype = 2, color = "black") +
  ggrepel::geom_text_repel(min.segment.length = 0) +
  xlim(0,1) +
  ylim(0,1) +
  theme_bw() +
  labs(x = "Manual (well fraction GFP+)", y = "CellProfiler (well fraction GFP+)", title = "Method agreement")
cowplot::ggsave2(agreement_plot, filename = "plots/agreement_plot.png", width = 7.5, height = 7.5)

# corelation


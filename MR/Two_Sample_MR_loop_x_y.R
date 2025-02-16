# This script is to run two sample MR using PHQ-9 and depression phenotypes as the exposure

library(remotes)
library(TwoSampleMR)
library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(R.utils)
library(ieugwasr)
library(ggplot2)

# Create empty data frames
mr_all_results <- data.frame()
mr_all_het <- data.frame()
mr_all_pleio <- data.frame()

# Set working directory
setwd("/scratch/users/k20113596/Rosalind_Transfer/MR/lhcMR/lhcMR_out/")

exposure_files <- list.files(pattern = "PHQ9_|MDD_sumstats")
outcome_files <- list.files(pattern = "no_APOE")

for (i in exposure_files) {
  for (j in outcome_files) {
    # Read in GWAS files
    exposure_file <- fread(i)
    outcome_file <- fread(j)

    # Clean exposure and outcome names
    exposure_name <- str_remove_all(i, "_cont_full_mtag_meta_with_N.txt.gz|_munged_MAF_0.01.txt.gz|MDD_sumstats_|PHQ9_")
    outcome_name <- str_remove_all(j, "_munged_MAF_0.01_no_APOE.txt.gz|AD_sumstats_")

    print("No APOE included in this analysis...")
    print(paste0("Exposure name is ", exposure_name))
    print(paste0("Outcome name is ", outcome_name))

    # Add phenotype names to files
    exposure_file$Phenotype <- exposure_name
    outcome_file$Phenotype <- outcome_name

    # Format the exposure data
    exposure_data <- format_data(
      exposure_file,
      type = "exposure",
      snps = NULL,
      header = TRUE,
      phenotype_col = "Phenotype",
      snp_col = "SNP",
      beta_col = "BETA",
      se_col = "SE",
      eaf_col = "EAFREQ",
      effect_allele_col = "EFFECT_ALLELE",
      other_allele_col = "NON_EFFECT_ALLELE",
      pval_col = "P",
      samplesize_col = "N",
      min_pval = 1e-200,
      z_col = "Z",
      chr_col = "CHR",
      pos_col = "BP",
      log_pval = FALSE
    )

    # Set the clumping p-value threshold
    clump_p <- ifelse(min(exposure_data$pval.exposure) <= 5e-8, 5e-8, 5e-6)

    # Clump the exposure data
    exposure_data_clumped <- exposure_data %>%
      rename(rsid = SNP, pval = pval.exposure) %>%
      ieugwasr::ld_clump(
        clump_r2 = 0.001,
        clump_p = clump_p,
        clump_kb = 10000,
        plink_bin = genetics.binaRies::get_plink_binary(), 
        bfile = "/scratch/users/k20113596/Rosalind_Transfer/LAVA/LD_files/g1000_eur/EUR"
      ) %>%
      rename(SNP = rsid, pval.exposure = pval)

    # Format the outcome data
    outcome_data <- format_data(
      outcome_file,
      type = "outcome",
      snps = exposure_data_clumped$SNP,
      header = TRUE,
      phenotype_col = "Phenotype",
      snp_col = "SNP",
      beta_col = "BETA",
      se_col = "SE",
      eaf_col = "EAFREQ",
      effect_allele_col = "EFFECT_ALLELE",
      other_allele_col = "NON_EFFECT_ALLELE",
      pval_col = "P",
      samplesize_col = "N",
      min_pval = 1e-200,
      z_col = "Z",
      chr_col = "CHR",
      pos_col = "BP",
      log_pval = FALSE
    )

    harmonised_data <- harmonise_data(
      exposure_dat = exposure_data_clumped, 
      outcome_dat = outcome_data, 
      action = 1
    )

    # Re-clump if there are less than 5 genome-wide significant loci
    if (nrow(harmonised_data) < 5) {
      exposure_data_clumped <- exposure_data %>%
        rename(rsid = SNP, pval = pval.exposure) %>%
        ieugwasr::ld_clump(
          clump_r2 = 0.001,
          clump_p = 5e-6,
          clump_kb = 10000,
          plink_bin = genetics.binaRies::get_plink_binary(), 
          bfile = "/scratch/users/k20113596/Rosalind_Transfer/LAVA/LD_files/g1000_eur/EUR"
        ) %>%
        rename(SNP = rsid, pval.exposure = pval)

      outcome_data <- format_data(
        outcome_file,
        type = "outcome",
        snps = exposure_data_clumped$SNP,
        header = TRUE,
        phenotype_col = "Phenotype",
        snp_col = "SNP",
        beta_col = "BETA",
        se_col = "SE",
        eaf_col = "EAFREQ",
        effect_allele_col = "EFFECT_ALLELE",
        other_allele_col = "NON_EFFECT_ALLELE",
        pval_col = "P",
        samplesize_col = "N",
        min_pval = 1e-200,
        z_col = "Z",
        chr_col = "CHR",
        pos_col = "BP",
        log_pval = FALSE
      )

      harmonised_data <- harmonise_data(
        exposure_dat = exposure_data_clumped, 
        outcome_dat = outcome_data, 
        action = 1
      )
    }

    # Write harmonised data to file
    write.table(
      harmonised_data, 
      file = paste0("/scratch/users/k20113596/Rosalind_Transfer/MR/TwoSampleMR/MR_harmonised_data/MR_harmonised_data_", exposure_name, "_", outcome_name, "_no_apoe_x_y.txt"), 
      sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE
    )

    # Perform MR analysis
    mr_results <- mr(harmonised_data)
    mr_het <- mr_heterogeneity(harmonised_data)
    mr_pleio <- mr_pleiotropy_test(harmonised_data)

    # Combine MR results
    mr_all_results <- rbind(mr_all_results, mr_results)
    mr_all_het <- rbind(mr_all_het, mr_het)
    mr_all_pleio <- rbind(mr_all_pleio, mr_pleio)

    # Generate scatter plot
    mr_scatter <- mr_scatter_plot(mr_results, harmonised_data)
    ggsave(
      mr_scatter[[1]], 
      filename = paste0("/scratch/users/k20113596/Rosalind_Transfer/MR/TwoSampleMR/MR_scatters/mr_scatter_", exposure_name, "_", outcome_name, "_no_apoe.png"), 
      width = 7, height = 7
    )
  }
}

# Write combined results to files
write.table(mr_all_results, file = paste0("/scratch/users/k20113596/Rosalind_Transfer/MR/TwoSampleMR/all_MR_analysis_results_x_y_no_apoe.txt"), sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
write.table(mr_all_het, file = paste0("/scratch/users/k20113596/Rosalind_Transfer/MR/TwoSampleMR/all_MR_het_results_x_y_no_apoe.txt"), sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
write.table(mr_all_pleio, file = paste0("/scratch/users/k20113596/Rosalind_Transfer/MR/TwoSampleMR/all_MR_pleio_results_x_y_no_apoe.txt"), sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

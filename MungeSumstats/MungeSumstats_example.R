# This is an example script for munging summary statistics using the MungeSumstats package in R
# For all except GLAD ref_genome = "GRCh37" and the convert_ref_genome command removed

library(MungeSumstats)
library(data.table)
library(dplyr)
library(stringr)

# Set working directory
setwd("/scratch/users/k20113596/Rosalind_Transfer/Output/GLAD_gwas/Step_2/GLAD_PHQ9_cont_combined/")

# Load the predefined column headers for summary statistics
data("sumstatsColHeaders")

# List all text files in the directory
files_of_interest <- list.files(pattern = "PHQ9_GLAD_cont_nov_2022_")

print(files_of_interest)

# Loop through each file
for (i in files_of_interest) {
  
  # Read in GWAS summary statistics file
  df <- fread(i, header = TRUE, data.table = FALSE)
  
  # Extract trait name from file name
  trait_name <- str_remove(i, pattern = "PHQ9_GLAD_cont_nov_2022_")
  trait_name <- str_remove(trait_name, pattern = ".txt")
  
  # Calculate P values from the log p values
  df$P <- 10^(-df$LOG10P)
  
  # Create Z column
  df$Z <- df$BETA / df$SE
  
  # Filter allele frequency in cases and controls
  df <- df %>%
    filter(A1FREQ >= 0.01 & A1FREQ <= 0.99)
  
  # Rename columns as desired
  colnames(df)[colnames(df) == "A1FREQ"] <- "EAF"
  colnames(df)[colnames(df) == "ALLELE0"] <- "A1"
  colnames(df)[colnames(df) == "ALLELE1"] <- "A2"  # This is the effect allele in MungeSumstats
  colnames(df)[colnames(df) == "CHROM"] <- "CHR"
  colnames(df)[colnames(df) == "GENPOS"] <- "BP"
  colnames(df)[colnames(df) == "ID"] <- "SNP"
  
  # Format summary statistics using MungeSumstats
  format_sumstats(
    path = df,
    ref_genome = "GRCh38",  # Set reference genome build for the summary statistics
    convert_ref_genome = "GRCh37",  # Set genome build for conversion if necessary
    dbSNP = 144,
    convert_small_p = TRUE,  # Convert p-values outside of R's range to 0
    convert_large_p = TRUE,  # Convert p-values over 1 to 1
    convert_neg_p = TRUE,  # Convert negative p-values to 0
    compute_z = FALSE,  # Do not compute Z-scores
    force_new_z = FALSE,  # Do not force new Z-score computation if column already exists
    compute_n = 0L,  # Do not compute missing N for SNPs
    convert_n_int = TRUE,  # Round N if it's not an integer
    impute_beta = FALSE,  # Do not impute missing effect values
    impute_se = FALSE,  # Do not impute missing standard error values
    analysis_trait = NULL,  # No specific trait analysis
    INFO_filter = 0.7,  # Filter on INFO column if present
    FRQ_filter = 0,  # No filtering on minor allele frequency (MAF) if set to 0
    pos_se = TRUE,  # Check and remove SNPs with negative standard errors
    effect_columns_nonzero = FALSE,  # Do not remove SNPs with zero beta effect
    N_std = 5,  # Remove SNPs with >5 SDs above mean N
    N_dropNA = TRUE,  # Drop rows where N is missing
    rmv_chrPrefix = TRUE,  # Remove "chr" prefix if present in CHR column
    on_ref_genome = TRUE,  # Check all SNPs are on the reference genome and impute if missing
    strand_ambig_filter = FALSE,  # Do not remove strand ambiguous SNPs
    allele_flip_check = TRUE,  # Check and flip reference allele (A1)
    allele_flip_drop = TRUE,  # Drop SNPs if neither allele matches the reference genome
    allele_flip_z = TRUE,  # Flip Z-score column along with the allele
    allele_flip_frq = TRUE,  # Flip effect allele column
    bi_allelic_filter = TRUE,  # Remove non-biallelic SNPs
    snp_ids_are_rs_ids = TRUE,  # Define SNPs IDs as RSIDs
    remove_multi_rs_snp = FALSE,  # Keep only the first RSID if multiple RSIDs are present
    frq_is_maf = TRUE,  # Set true, stops renaming of column if major allele freq is inferred
    indels = TRUE,  # Exclude indels
    sort_coordinates = TRUE,  # Sort the coordinates of the resulting summary statistics
    nThread = 1,  # Number of threads for analysis
    save_path = paste0("/scratch/users/k20113596/Rosalind_Transfer/Output/GLAD_gwas/Step_2/GLAD_PHQ9_cont_munged/PHQ9_GLAD_cont_nov_2022_", trait_name, "_munged.txt"),
    write_vcf = FALSE,  # Do not write VCF format file
    tabix_index = FALSE,  # Ignore for VCF command
    return_data = TRUE,  # Return data in specified format
    return_format = "data.table",  # Return format as data table
    ldsc_format = FALSE,  # Format for use in LDSC
    log_folder_ind = FALSE,  # Do not log filtered out SNPs
    log_mungesumstats_msgs = TRUE,  # Log all messages
    log_folder = "/scratch/users/k20113596/Rosalind_Transfer/Output/GLAD_gwas/Step_2/GLAD_PHQ9_cont_munged/PHQ9_GLAD_cont_munged_logs",
    imputation_ind = FALSE,  # Do not add imputation steps
    force_new = FALSE,  # 
    mapping_file = sumstatsColHeaders
  )
}

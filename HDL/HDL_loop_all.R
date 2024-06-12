library(HDL)
library(data.table)
library(dplyr)
library(tidyr)
library(stringr)

# Set working directory
setwd("/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/HDL/HDL_wrangled/")

# List files for depression and Alzheimer's disease
DEP_files <- list.files(pattern = "PHQ9_|MDD_")
print(DEP_files)

AD_files <- list.files(pattern = "AD_")
print(AD_files)

# Path to LD reference
LD.path <- "/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/HDL/UKB_imputed_SVD_eigen99_extraction/"

# Loop over each pair of depression and Alzheimer's disease files
for (i in DEP_files) {
  for (j in AD_files) {
    
    # Read in GWAS files
    gwas1.df <- readRDS(i)
    gwas2.df <- readRDS(j)
    
    # Remove pattern from trait names
    DEP_trait_name <- str_remove(i, pattern = ".hdl.rds")
    AD_trait_name <- str_remove(j, pattern = ".hdl.rds")
    
    # Define output file path
    output_file <- file.path("/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/HDL/HDL_output/",
                             paste0(DEP_trait_name, "_", AD_trait_name, "_HDL.txt"))
    
    # Perform HDL regression
    HDL.rg(gwas1.df, gwas2.df, LD.path, 
           Nref = 335265, 
           N0 = min(gwas1.df$N, gwas2.df$N), 
           output.file = output_file, 
           eigen.cut = "automatic", 
           jackknife.df = FALSE, 
           intercept.output = FALSE, 
           fill.missing.N = NULL, 
           lim = exp(-18))
  }
}

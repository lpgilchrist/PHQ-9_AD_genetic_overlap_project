# Load necessary libraries
library(data.table)
library(tidyverse)
library(psych)
library(skimr)

# Set working directory
setwd("~/Desktop/GLAD/GLAD_Data/")

# Read and filter self-reported ethnicity to retain only those self-reported as White
ethnicity <- readRDS("ethnicity_glad_clean.rds") %>%
  filter(grepl("White", dem.what_is_your_ethnic_origin)) %>%
  select(ID)

# Write ethnicity IDs to a text file
write.table(ethnicity, "ethnicity_glad_EUR_IDs.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Read and filter age data, then inner join with ethnicity IDs
age <- readRDS("age_glad_clean.rds") %>%
  select(ID, dem.how_old_are_you_now.txt) %>%
  inner_join(ethnicity, by = "ID")

# Read and filter mental health diagnosis data to retain cases, then anti-join with age data
diagnosis <- readRDS("mhd_glad_clean.rds") %>%
  select(ID, mhd.bipolar_disorder_numeric, mhd.schizophrenia_numeric, mhd.psychosis_numeric) %>%
  filter(mhd.bipolar_disorder_numeric == 1 | mhd.schizophrenia_numeric == 1 | mhd.psychosis_numeric == 1)

age_EUR_diagnosis_rm <- age %>%
  anti_join(diagnosis, by = "ID")

# Read and filter prescription data to retain those with psychosis prescription, then anti-join with previous data
prescription <- readRDS("cidip_glad.rds") %>%
  select(externalDataReference, cidip.health_professional_prescribed_experiences) %>%
  rename(ID = externalDataReference, psychosis_prescription = cidip.health_professional_prescribed_experiences) %>%
  filter(psychosis_prescription == 1)

age_EUR_diagnosis_prescription_rm <- age_EUR_diagnosis_rm %>%
  anti_join(prescription, by = "ID")

# Read in sex data
sex <- fread("/scratch/prj/bioresource/Public/GLADv2/GLADv2_sex.txt") %>%
  select(V1, V3) %>%
  rename(ID = V1, sex = V3)

# Read in the principal components (PCs)
PCs <- fread("/scratch/prj/bioresource/Public/GLADv2/v2_genotyping_data/pca_projection/GLADb08b09b12b16b17_b38_EUR_maf1_sample95.SNP95.hwe10.nodup.ALL_PCA_Projection.sscore") %>%
  select(IID, PC1_AVG, PC2_AVG, PC3_AVG, PC4_AVG, PC5_AVG, PC6_AVG, PC7_AVG, PC8_AVG, PC9_AVG, PC10_AVG) %>%
  rename(ID = IID)

# Read in the batch file
batch <- fread("/scratch/prj/bioresource/Public/GLADv2/GLADv2_Batches.txt") %>%
  rename(ID = IID)

# Rename age column and create age-squared column
age_EUR_diagnosis_prescription_rm <- age_EUR_diagnosis_prescription_rm %>%
  rename(age = dem.how_old_are_you_now.txt) %>%
  mutate(age_squared = age^2)

# Join the relevant data frames
age_EUR_sex <- age_EUR_diagnosis_prescription_rm %>%
  inner_join(sex, by = "ID") %>%
  relocate(sex, .after = ID)

age_EUR_sex_PCs <- age_EUR_sex %>%
  inner_join(PCs, by = "ID")

age_EUR_sex_PCs_batch <- age_EUR_sex_PCs %>%
  inner_join(batch, by = "ID") %>%
  relocate(Batch, .after = age_squared)

# Add FID and rename ID to IID
age_EUR_sex_PCs_batch <- age_EUR_sex_PCs_batch %>%
  mutate(FID = ID) %>%
  rename(IID = ID) %>%
  relocate(FID, .before = IID)

# Write the final data frame to a text file
write.table(age_EUR_sex_PCs_batch, "GLAD_covariates_QCd.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Covariates are in: /scratch/users/k20113596/Rosalind_Transfer/Datasets/GLAD/Covariates/GLAD_covariates_QCd.txt

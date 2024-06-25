# This script is for cleaning the phenotype data from PROTECT for use in GWAS

# Load necessary libraries
library(data.table)
library(dplyr)
library(tidyr)
library(readxl)
library(stringr)
library(lubridate) 

# Read in the full demographic data from the Excel file
df <- read_excel("PROT_UK_DA_071_Demographics_BASELINE_V3.6.xlsx")


# Rename TEC ID column for easier manipulation
df <- df %>% 
  rename(TEC_ID = "TEC ID")

# Remove rows with no TEC ID and duplicate TEC IDs
df <- df[!grepl("NO TEC", df$TEC_ID), ]
df <- df[!duplicated(df$TEC_ID), ]



# Select relevant columns
df <- df %>%
  select(TEC_ID, SEX, DOB, ETH)

# Write the demographic data to a text file
write.table(df, "PROTECT_covariates_raw.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Read in the questionnaire date file for age calculation
questionnaire_date <- fread("PROTECT_questionnaire_date.txt")
questionnaire_date <- questionnaire_date[!duplicated(questionnaire_date$TEC_ID), ]

# Join with covariate file
covar <- df %>%
  inner_join(questionnaire_date, by = "TEC_ID")

covar <- data.table(covar)

# Check for duplicates
sum(duplicated(covar$TEC_ID))  # 0


# Separate the questionnaire date into date and time
covar <- covar %>%
  separate(DateCompleted, c("date", "time"), " ")

# Remove the time column as it's not needed
covar$time <- NULL

# Separate the date of birth into day, month, and year
covar <- covar %>%
  separate(DOB, c("birth_day", "birth_month", "birth_year"), "/")

# Remove rows with missing values
covar <- covar[complete.cases(covar), ]

# Correct date of birth format
covar$DOB_corrected <- paste0(covar$birth_year, "-", covar$birth_month, "-", covar$birth_day)

# Calculate age in years
covar$age <- time_length(difftime(covar$date, covar$DOB_corrected), "years")



# Remove decimal places from age
covar$age_in_years <- as.integer(covar$age)

# Remove redundant columns
covar <- covar %>%
  select(-c(date, DOB_corrected, birth_month, birth_day, age))

# Create an age squared column
covar$age_squared <- covar$age_in_years^2

# Filter out non-white ethnicities (ETH > 5)
covar <- covar %>%
  filter(ETH <= 5)

# Check the number of rows after filtering by ethnicity
nrow(covar)  # 12676

# Remove the ethnicity column as it's redundant now
covar$ETH <- NULL

# Read in the batch data
all_batchs_PROTECT <- fread("all_batchs_PROTECT.txt")
all_batchs_PROTECT <- all_batchs_PROTECT %>%
  rename(TEC_ID = IID)

# Match the covariate and batch data
covar_batch <- covar %>%
  inner_join(all_batchs_PROTECT, by = "TEC_ID")

# Rename TEC_ID to IID
covar_batch <- covar_batch %>%
  rename(IID = TEC_ID)

# Read in the PC file
pcs <- fread("top20_pcs_reformatted_europeans.csv")

# Join covariate and batch data with PCs
covar_batch_pcs <- covar_batch %>%
  inner_join(pcs, by = "IID")

# Relocate FID column
covar_batch_pcs <- covar_batch_pcs %>%
  relocate(FID, .before = IID)

# Write the covariate data to a text file
write.table(covar_batch_pcs, "PROTECT_covariates_EUR.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Apply exclusions
covar <- fread("PROTECT_covariates_EUR.txt")
previous_diagnosis <- fread("previous_diagnosis_FID.txt")
previous_prescription <- fread("previous_prescription.txt") %>%
  select(TEC_ID)
pheno <- fread("PROTECT_PHQ_9_pheno_QC.txt")

# Exclude individuals with age > 5SD above the mean age
Max <- mean(covar$age_in_years) + (5 * sd(covar$age_in_years))
covar <- covar %>%
  filter(age_in_years < Max)

# Filter out individuals with previous diagnosis and prescription
previous_prescription <- previous_prescription %>%
  filter(TEC_ID != "NO TEC")

previous_diagnosis <- previous_diagnosis %>%
  rename(IID = TEC_ID)

previous_prescription <- previous_prescription %>%
  rename(IID = TEC_ID)

covar <- covar %>%
  anti_join(previous_diagnosis, by = "IID") %>%
  anti_join(previous_prescription, by = "IID")

# Match with the phenotype data
covar_for_matching <- covar %>%
  select(IID)

pheno <- pheno %>%
  rename(IID = TEC_ID) %>%
  distinct(IID) %>%
  inner_join(covar_for_matching, by = "IID")

# Update covariate data based on matched phenotype data
covar <- covar %>%
  inner_join(select(pheno, IID), by = "IID")


# Write the covariate and phenotype data to text files
write.table(pheno, "PROTECT_PHQ_9_phenos_QC.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
write.table(covar, "PROTECT_PHQ_9_covariates_QC.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Extract FID and IID columns for downsampling the PLINK files
participants_of_interest <- pheno %>%
  select(FID, IID)

write.table(participants_of_interest, "PROTECT_PHQ_9_participants_of_interest.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)


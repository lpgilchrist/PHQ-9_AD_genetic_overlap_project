### This is an R script to extract each of the covariates from the UKB, clean, and merge them together
library(data.table)
library(tidyverse)
library(dplyr)
library(ukbkings)

## Self-reported white ancestry

prj_dir <- "/scratch/datasets/ukbiobank/ukb18177"
f <- bio_field(prj_dir)

# Extract self-reported ancestry
f %>%
    select(field, name) %>%
    filter(str_detect(name, "ethnic_background_f21000")) %>%
    bio_field_add("ethnic_background.txt")

system("cat ethnic_background.txt")

# Write data as rds
bio_phen(prj_dir, field = "ethnic_background.txt", out = "ethnic_background")

# Read into R as a data frame
df <- readRDS("ethnic_background.rds")

# Select required columns for filtering
df <- df[, 1:2]

# Rename columns for easier filtering
names(df) <- c('FID', 'ancestry')

# Filter for self-reported white ethnicity
df <- df %>% filter(ancestry %in% c(1, 1001, 1002, 1003))

# Check for duplicates
sum(duplicated(df$FID)) 
# 0

# Extract FIDs for filtering the covariate file
covar_eur_fid <- df %>% select(FID)


# Write for use later
write.table(covar_eur_fid, "/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Covariates/UKB_self_report_European.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

q()

### Extract the first 16 Principal Components for use as covariates in GWAS
PCs <- fread("/scratch/groups/ukbiobank/KCL_Data/Genotypes/kylie_application/ukb1817_sqc_v2.txt")

PC_reduced <- PCs %>%
    select(V1, V2, 28:43)

names(PC_reduced) <- c("FID", "IID", paste0("PC", 1:16))


# Write the PC file for later merging
write.table(PC_reduced, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/PC_1_to_16.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)



### Extract the date at which they took the mental health and pain questionnaires
f <- bio_field(prj_dir)

f %>%
    select(field, name) %>%
    filter(str_detect(name, "when_pain_questionnaire_completed")) %>%
    bio_field_add("pain_questionnaire_date.txt")

f %>%
    select(field, name) %>%
    filter(str_detect(name, "date_of_completing_mental_health_questionnaire")) %>%
    bio_field_add("mental_health_questionnaire_date.txt")

# Write data as rds
bio_phen(prj_dir, field = "pain_questionnaire_date.txt", out = "pain_questionnaire_date")
bio_phen(prj_dir, field = "mental_health_questionnaire_date.txt", out = "mental_health_questionnaire_date")

# Read in as data frames
pain_date <- readRDS("pain_questionnaire_date.rds")
mhq_date <- readRDS("mental_health_questionnaire_date.rds")

# Rename columns
names(pain_date) <- c("FID", "pain_questionnaire_date")
names(mhq_date) <- c("FID", "mhq_questionnaire_date")

# Filter for complete cases
pain_date <- pain_date[complete.cases(pain_date), ]


mhq_date <- mhq_date[complete.cases(mhq_date), ]


# Write files for later
write.table(pain_date, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/pain_date.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
write.table(mhq_date, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/mhq_date.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

## Extract batch
batch <- fread("/scratch/groups/ukbiobank/KCL_Data/Genotypes/kylie_application/ukb1817_sqc_v2.txt")

batch <- batch %>%
    select(V1, V2, V6)

names(batch) <- c("FID", "IID", "batch")
write.table(batch, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/batch.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# For assessment centre code
f <- bio_field(prj_dir)

f %>%
    select(field, name) %>%
    filter(str_detect(name, "uk_biobank_assessment_centre")) %>%
    bio_field_add("assessment_centre.txt")

# Write data as rds
bio_phen(prj_dir, field = "assessment_centre.txt", out = "assessment_centre")

# Read in as data frames
assessment_centre <- readRDS("assessment_centre.rds")

# Select relevant columns
assessment_centre <- assessment_centre %>%
    select(eid, "54-0.0_ukb37667")

# Rename columns
names(assessment_centre) <- c("FID", "assessment_centre")
write.table(assessment_centre, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/ukb_assessment_centre.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

## Extract sex, birth month, and birth year
f %>%
    select(field, name) %>%
    filter(str_detect(name, "sex_f31")) %>%
    bio_field_add("demographics.txt")

f %>%
    select(field, name) %>%
    filter(str_detect(name, "month_of_birth")) %>%
    bio_field_add("demographics.txt")

f %>%
    select(field, name) %>%
    filter(str_detect(name, "year_of_birth_f34")) %>%
    bio_field_add("demographics.txt")

# Write data as rds
bio_phen(prj_dir, field = "demographics.txt", out = "demographics")

# Read into R as a data frame
df <- readRDS("demographics.rds")
ncol(df) # 7

# Rename columns
names(df) <- c('FID', 'sex', 'birth_year', 'birth_month', 'sex_2', 'birth_year_2', 'birth_month_2')

# Select the first three columns
df <- df %>% select(FID, sex, birth_year, birth_month)
write.table(df, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/sex_age.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Merge fields to create a single covariate file
setwd("/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Covariates/")

# Calculate age at the date of the questionnaire
# Read in the required files
sex_age <- fread("sex_age.txt")
mhq_date <- fread("mhq_date.txt")
pain_date <- fread("pain_date.txt")

# Merge the data frames
mhq_age <- sex_age %>%
    inner_join(mhq_date)


pain_age <- sex_age %>%
    inner_join(pain_date)


# Calculate age at time of MHQ
mhq_age <- mhq_age %>%
    separate(mhq_questionnaire_date, c("q_year", "q_month", "q_day"), "-")

mhq_age$year_diff <- as.numeric(mhq_age$q_year) - mhq_age$birth_year

# Transform difference in years into months
mhq_age$year_diff_in_months <- mhq_age$year_diff * 12

# Calculate the difference between birth month and month of questionnaire
mhq_age$month_diff <- as.numeric(mhq_age$q_month) - mhq_age$birth_month

# Add the difference in months and the difference in years to get age in months
mhq_age$year_diff_in_months_final <- mhq_age$year_diff_in_months + mhq_age$month_diff

# Transform age in months into age in years
mhq_age$age_at_mhq <- mhq_age$year_diff_in_months_final / 12

# Select required columns
mhq_age <- mhq_age %>%
    select(FID, age_at_mhq)

# Calculate age at time of pain questionnaire
pain_age <- pain_age %>%
    separate(pain_questionnaire_date, c("q_year", "q_month", "q_day"), "-")

pain_age$year_diff <- as.numeric(pain_age$q_year) - pain_age$birth_year

# Transform difference in years into months
pain_age$year_diff_in_months <- pain_age$year_diff * 12

# Calculate the difference between birth month and month of questionnaire
pain_age$month_diff <- as.numeric(pain_age$q_month) - pain_age$birth_month

# Add the difference in months and the difference in years to get age in months
pain_age$year_diff_in_months_final <- pain_age$year_diff_in_months + pain_age$month_diff

# Transform age in months into age in years
pain_age$age_at_pain <- pain_age$year_diff_in_months_final / 12

# Select required columns
pain_age <- pain_age %>%
    select(FID, age_at_pain)

# Write files for use later
write.table(mhq_age, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/mhq_age.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
write.table(pain_age, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/pain_age.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Load covariate files to merge together
self_report_euro <- fread("UKB_self_report_European.txt")
PC_1_16 <- fread("PC_1_to_16.txt")
batch <- fread("batch.txt")
assessment_centre <- fread("ukb_assessment_centre.txt")
mhq_age <- fread("mhq_age.txt")
pain_age <- fread("pain_age.txt")
sex_age <- fread("sex_age.txt")

# Merge files
covar_mhq <- self_report_euro %>%
    inner_join(PC_1_16, by = "FID") %>%
    inner_join(batch, by = "FID") %>%
    inner_join(assessment_centre, by = "FID") %>%
    inner_join(mhq_age, by = "FID") %>%
    inner_join(sex_age, by = "FID")


covar_pain <- self_report_euro %>%
    inner_join(PC_1_16, by = "FID") %>%
    inner_join(batch, by = "FID") %>%
    inner_join(assessment_centre, by = "FID") %>%
    inner_join(pain_age, by = "FID") %>%
    inner_join(sex_age, by = "FID")


# Write files for Regenie
write.table(covar_mhq, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/covar_mhq.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
write.table(covar_pain, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/covar_pain.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

q()

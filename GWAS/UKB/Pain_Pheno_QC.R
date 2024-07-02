###### Extract PHQ-9 data from the Pain Questionnaire #######

library(data.table)
library(tidyverse)
library(ukbkings)

prj_dir <- "/scratch/datasets/ukbiobank/ukb18177"
f <- bio_field(prj_dir)

# Extract the PHQ items from the pain questionnaire
f %>%
  select(field, name) %>%
  filter(str_detect(name, "over_the_last_two_weeksuses")) %>%
  bio_field_add("pain_phq_list.txt")

# Extract the date of completion of the pain questionnaire for age calculation as covariate
f %>%
  select(field, name) %>%
  filter(str_detect(name, "when_pain_questionnaire_completed")) %>%
  bio_field_add("pain_questionnaire_date.txt")

system("cat pain_phq_list.txt")
system("cat pain_questionnaire_date.txt")

# Write data as rds
bio_phen(prj_dir, field = "pain_phq_list.txt", out = "pain_phq_data")
bio_phen(prj_dir, field = "pain_questionnaire_date.txt", out = "pain_questionnaire_date")

# Read into R as a data frame
df <- readRDS("pain_phq_data.rds")
date <- readRDS("pain_questionnaire_date.rds")

# Write questionnaire date for use in creating covariate file
write.table(date, "/scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Covariates/pain_questionnaire_date.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Rename PHQ items in the pain questionnaire
names(df) <- c('FID', 'anhedonia', 'depressed_mood', 'sleep_problems', 'fatigue', 'appetite_changes', 'inadequacy', 'concentration', 'psychomotor', 'suicidal')
df$IID <- df$FID
df <- df %>% relocate(IID, .after = FID)

write.table(df, "/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/pain_phq_preQC.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

#################################

df <- fread("/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/pain_phq_preQC.txt")

#Recode the PHQ9 so it reflects the original PHQ score scale of 1 to 3
df[,3:11][df[,3:11] == -521] <- 0
df[,3:11][df[,3:11] == -522] <- 1
df[,3:11][df[,3:11] == -523] <- 2
df[,3:11][df[,3:11] == -524] <- 3


# Create PHQ-9 sum score
df$PHQ_9_sum_score <- rowSums(df[, 3:11])

# Remove all 'prefer not to answer' and 'don't know' responses
df <- df %>% filter(across(c(depressed_mood, anhedonia, appetite_changes, sleep_problems, psychomotor, fatigue, inadequacy, concentration, suicidal), ~ . >= 0))

# Remove all NAs
df <- df[complete.cases(df), ]

write.table(df, "/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/pain_PHQ_NArm_all_ancestry.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Read in the covariate file of only EUR ancestry
EUR <- fread("/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Covariates/Pain_Covariates_Final/pain_questionnaire_covariates_EUR_nov_2022.txt") %>% select(FID, IID)

# Match this EUR ancestry list with the phenotype file
df_EUR_only <- df %>% inner_join(EUR)

write.table(df_EUR_only, "/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/Pain_Phenos_Final/PHQ_pain_NArm_EUR_QC_nov_2022.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Write a participant list for PLINK filtering
df_EUR_only_FID <- df_EUR_only %>% select(FID, IID)

write.table(df_EUR_only_FID, "/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/PHQ_pain_FIDs_for_plink_nov_2022.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)





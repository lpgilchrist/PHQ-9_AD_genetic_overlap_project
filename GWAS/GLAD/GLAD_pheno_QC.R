# SLURM job command for setting up the environment
# srun --partition=brc,shared --mem=30G --nodes=1 --ntasks=1 --pty /bin/bash -l
# cd /scratch/groups/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Covariates
# conda activate ukbkings
# R

# Load necessary libraries
library(data.table)
library(tidyverse)
library(psych)
library(skimr)

# Set working directory
setwd("~/Desktop/GLAD/GLAD_Data/")

# Read in PHQ-9 data
PHQ9 <- readRDS("phq9_glad_clean.rds")

# Select and rename the numeric columns
PHQ9 <- PHQ9 %>%
  select(ID, 
         phq9.little_interest_or_pleasure_in_doing_things_numeric, 
         phq9.poor_appetite_or_overeating_numeric, 
         phq9.trouble_concentrating_reading_newspaper_numeric, 
         phq9.feeling_down_depressed_or_hopeless_numeric,
         phq9.feeling_tired_or_having_little_energy_numeric, 
         phq9.feeling_bad_failure_family_numeric,
         phq9.moving_fidgety_noticed_opposite_numeric, 
         phq9.staying_asleep_sleeping_trouble_numeric,
         phq9.dead_hurting_thoughts_numeric) %>%
  rename(Anhedonia = phq9.little_interest_or_pleasure_in_doing_things_numeric,
         Appetite_Changes = phq9.poor_appetite_or_overeating_numeric,
         Concentration = phq9.trouble_concentrating_reading_newspaper_numeric,
         Depressed_Mood = phq9.feeling_down_depressed_or_hopeless_numeric,
         Fatigue = phq9.feeling_tired_or_having_little_energy_numeric,
         Inadequacy = phq9.feeling_bad_failure_family_numeric,
         Psychomotor = phq9.moving_fidgety_noticed_opposite_numeric,
         Sleep_Problems = phq9.staying_asleep_sleeping_trouble_numeric,
         Suicidal_Thoughts = phq9.dead_hurting_thoughts_numeric)

# Filter out 'Don't Knows' and 'Prefer not to answers'
PHQ9 <- PHQ9 %>%
  filter(Anhedonia >= 0, Appetite_Changes >= 0, Concentration >= 0, Depressed_Mood >= 0, 
         Fatigue >= 0, Inadequacy >= 0, Psychomotor >= 0, Sleep_Problems >= 0, Suicidal_Thoughts >= 0)


# Create a sumscore column
PHQ9 <- PHQ9 %>%
  mutate(PHQ_9_Sum_Score = rowSums(select(., Anhedonia:Suicidal_Thoughts)))

# Select the EUR participant IDs with diagnosis and prescription removed
EUR_ids <- age_EUR_diagnosis_prescription_rm %>% select(ID)

# Join with the PHQ9 data
PHQ9 <- PHQ9 %>%
  inner_join(EUR_ids, by = "ID")

# Rename ID column and create IID column
PHQ9 <- PHQ9 %>%
  rename(FID = ID) %>%
  mutate(IID = FID) %>%
  relocate(IID, .after = FID)

# Write the filtered PHQ-9 data to a text file
write.table(PHQ9, "GLAD_PHQ9_filtered_EUR.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Write FID and IID to a separate text file
FIDs <- PHQ9 %>%
  select(FID, IID)

write.table(FIDs, "GLAD_Pheno_FIDs_for_PLINK.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

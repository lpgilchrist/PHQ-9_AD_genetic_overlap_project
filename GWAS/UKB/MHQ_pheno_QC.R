### Extraction of PHQ-9 data from the MHQ questionnaire

# Navigate to UKB phenotypes
# cd /scratch/groups/ukbiobank/ukb18177_glanville/phenotypes

################################################################
####### Extract the nine depression items on the PHQ-9 #########
################################################################

# 1. Find the column for each phenotype using the grep function

# psychomotor (column 13017)
# concentration (column 13007)
# sleep problems (column 13016)
# fatigue (column 13018)
# appetite changes (column 13010)
# anhedonia (column 13013)
# depressed mood (column 13009)
# suicidal (column 13012)
# inadequacy (column 13006)

# 2. Save the depression phenotypes to a new file
awk '{print $1, $13009, $13013, $13010, $13016, $13017, $13018, $13006, $13007, $13012}' ukb18177_glanville_phenotypes.txt > /scratch/groups/ukbiobank/Edinburgh_Data/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/dep_symptoms_only.txt

####################################################################
####################### Clean the phenotypes #######################
####################################################################

# Move to UKB directory where the phenotype files are saved
cd /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes

# Load the R module
module load apps/R/3.6.0
R

# Load required packages
library(psych)
library(dplyr)
library(data.table)

# Read in the phenotype file
dep <- fread("dep_symptoms_only.txt")

# Give the columns names
names(dep) <- c('FID', 'depressed_mood', 'anhedonia', 'appetite_changes', 'sleep_problems', 'psychomotor', 'fatigue', 'inadequacy', 'concentration', 'suicidal')

# Add in IID column and relocate to after FID
dep$IID <- dep$FID
dep <- dep %>% relocate(IID, .after = FID)

# Remove all 'prefer not to answer' responses
dep <- dep %>% filter(across(c(depressed_mood, anhedonia, appetite_changes, sleep_problems, psychomotor, fatigue, inadequacy, concentration, suicidal), ~ . >= 0))

# Remove all NAs
dep <- dep[complete.cases(dep), ]

# Recode the PHQ9 so it reflects the original PHQ score scale of 1 to 3
dep[,3:11][dep[,3:11] == 1 ] <- 0
dep[,3:11][dep[,3:11] == 2 ] <- 1
dep[,3:11][dep[,3:11] == 3 ] <- 2
dep[,3:11][dep[,3:11] == 4 ] <- 3

write.table(dep, "/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/mhq_PHQ_NArm_all_ancestry.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Filter for European only
EUR <- fread("/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Covariates/MHQ_Covariates_Final/MHQ_covariates_EUR_nov_2022.txt") %>% select(FID)

dep_EUR_only <- dep %>% inner_join(EUR)

# Create PHQ 9 sum score item
dep_EUR_only$PHQ_9_sum_score <- rowSums(dep_EUR_only[, 3:11])

write.table(dep_EUR_only, "/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/MHQ_Phenos_Final/MHQ_PHQ_NArm_EUR_nov_2022.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Write a participant list for PLINK filtering
dep_EUR_only_FID <- dep_EUR_only %>% select(FID, IID)

write.table(dep_EUR_only_FID, "/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/PHQ_MHQ_FIDs_for_plink_nov_2022.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)



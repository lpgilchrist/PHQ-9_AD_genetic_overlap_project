library(data.table)
library(dplyr)
library(stringr)

# Set working directory
setwd("/scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/GLAD_scores/")

# List all profile files
files <- list.files(pattern = "_scores.profile")

# Initialize an empty data table for all scores
all_scores <- data.table()

# Loop over each file
for (i in files) {
  
  # Extract the name for the PRS from the file name
  name <- str_remove(i, "GLAD_AD_sumstats_")
  name <- str_remove(name, "_scores.profile")
  name <- str_remove(name, "_munged_MAF_0.01")
  
  # Read data from file and select relevant columns
  df <- fread(i) %>%
    select(ID1, ID2, Profile_1) %>%
    rename(FID = ID1, IID = ID2) %>%
    rename_with(~ name, Profile_1)
  
  # Merge data into all_scores data table
  if (nrow(all_scores) == 0) {
    all_scores <- df
  } else {
    all_scores <- inner_join(all_scores, df)
  }
}

# Write merged data to a file
write.table(all_scores, file = "/scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/GLAD_scores/all_AD_prs_scores.txt",
            sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Read merged scores data
all_scores <- fread("/scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/GLAD_scores/all_AD_prs_scores.txt")

# Read phenotype data
GLAD_pheno <- fread("/scratch/users/k20113596/Rosalind_Transfer/Datasets/GLAD/Phenotypes/GLAD_PHQ9_filtered_EUR.txt")

# Read covariate data
GLAD_covar <- fread("/scratch/users/k20113596/Rosalind_Transfer/Datasets/GLAD/Covariates/GLAD_covariates_QCd.txt")

# Merge scores, phenotype, and covariate data
all <- inner_join(all_scores, GLAD_pheno) %>%
  inner_join(GLAD_covar)

# Write merged data with phenotype and covariates to file
write.table(all, file = "/scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/GLAD_scores/all_AD_prs_scores_w.phenos.txt",
            sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Run regression with APOE
score_cols <- c("Bellenguez", "Jansen", "Kunkle", "Marioni", "Wightman", "Wightman_UKB")
phq_cols <- c("Anhedonia", "Appetite_Changes", "Concentration", "Depressed_Mood",
              "Fatigue", "Inadaquacy", "Psychomotor", "Sleep_Problems", "Suicidal_Thoughts", "PHQ_9_Sum_Score")

# Adjust sex variable
all$sex[all$sex == 1] <- 0
all$sex[all$sex == 2] <- 1
all$sex <- as.numeric(all$sex)

# Convert selected columns to numeric
all[, 15:24] <- lapply(all[, 15:24], as.numeric)

all_results_apoe <- data.frame()

# Loop over each phenotype and PRS combination
for (i in phq_cols) {
  
  # Run null model
  null_formula <- paste0("scale(", i, ") ~ age + sex + PC1_AVG + PC2_AVG + PC3_AVG + PC4_AVG + PC5_AVG + PC6_AVG + PC7_AVG + PC8_AVG + PC9_AVG + PC10_AVG")
  null <- lm(formula = null_formula, data = all)
  
  # Loop over each PRS
  for (j in score_cols) {
    
    # Run model
    model_formula <- paste0("scale(", i, ") ~ scale(", j, ") + age + sex + PC1_AVG + PC2_AVG + PC3_AVG + PC4_AVG + PC5_AVG + PC6_AVG + PC7_AVG + PC8_AVG + PC9_AVG + PC10_AVG")
    model <- lm(formula = model_formula, data = all)
    
    # Print summary of each model
    print(summary(model))
    
    # Calculate R-squared
    r2 <- summary(model)$r.squared - summary(null)$r.squared
    
    # Extract coefficients, standard errors, and p-values
    summary_stats <- summary(model)
    coef_estimate <- summary_stats$coefficients[paste0("scale(", j, ")"), "Estimate"]
    se <- summary_stats$coefficients[paste0("scale(", j, ")"), "Std. Error"]
    p_value <- summary_stats$coefficients[paste0("scale(", j, ")"), "Pr(>|t|)"]
    
    # Create a data frame with results
    results <- data.frame(
      PRS = j,
      Outcome = i,
      r2 = r2,
      estimate = coef_estimate,
      se = se,
      p_value = p_value
    )
    
    # Append results to all_results_apoe data frame
    all_results_apoe <- rbind(all_results_apoe, results)
  }
}

# Adjust p-values using FDR correction
p <- all_results_apoe$p_value
fdr <- p.adjust(p, method = "fdr")
all_results_apoe$FDR <- fdr

# Write results to file
write.table(all_results_apoe, file = "/scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/GLAD_scores/GLAD_AD_PRS_results_w.apoe.txt",
            sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Run regression with no APOE
score_cols <- c("Bellenguez_no_APOE", "Jansen_no_APOE", "Kunkle_no_APOE", "Marioni_no_APOE", "Wightman_no_APOE", "Wightman_UKB_no_APOE")

all_results_no_apoe <- data.frame()

# Loop over each phenotype and PRS combination
for (i in phq_cols) {
  
  # Run null model
  null_formula <- paste0("scale(", i, ") ~ age + sex + PC1_AVG + PC2_AVG + PC3_AVG + PC4_AVG + PC5_AVG + PC6_AVG + PC7_AVG + PC8_AVG + PC9_AVG + PC10_AVG")
  null <- lm(formula = null_formula, data = all)
  
  # Loop over each PRS
  for (j in score_cols) {
    
    # Run model
    model_formula <- paste0("scale(", i, ") ~ scale(", j, ") + age + sex + PC1_AVG + PC2_AVG + PC3_AVG + PC4_AVG + PC5_AVG + PC6_AVG + PC7_AVG + PC8_AVG + PC9_AVG + PC10_AVG")
    model <- lm(formula = model_formula, data = all)
    
    # Print summary of each model
    print(summary(model))
    
    # Calculate R-squared
    r2 <- summary(model)$r.squared - summary(null)$r.squared
    
    # Extract coefficients, standard errors, and p-values
    summary_stats <- summary(model)
    coef_estimate <- summary_stats$coefficients[paste0("scale(", j, ")"), "Estimate"]
    se <- summary_stats$coefficients[paste0("scale(", j, ")"), "Std. Error"]
    p_value <- summary_stats$coefficients[paste0("scale(", j, ")"), "Pr(>|t|)"]
    
    # Create a data frame with results
    results <- data.frame(
      PRS = j,
      Outcome = i,
      r2 = r2,
      estimate = coef_estimate,
      se = se,
      p_value = p_value
    )
    
    # Append results to all_results_no_apoe data frame
    all_results_no_apoe <- rbind(all_results_no_apoe, results)
  }
}

# Adjust p-values using FDR correction
p <- all_results_no_apoe$p_value
fdr <- p.adjust(p, method = "fdr")
all_results_no_apoe$FDR <- fdr

# Write results to file
write.table(all_results_no_apoe, file = "/scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/GLAD_scores/GLAD_AD_PRS_results_no.apoe.txt",
            sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

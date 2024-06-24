library(remotes)
library(MRPRESSO)
library(data.table)
library(stringr)
library(dplyr)
library(tidyr)

setwd("/scratch/users/k20113596/Rosalind_Transfer/MR/TwoSampleMR/MR_harmonised_data")

# Initialize data frames for storing results
mr_presso_main_results <- data.frame()
mr_presso_outliers <- data.frame()

# List all files matching the pattern "no_apoe"
mr_files <- list.files(pattern = "no_apoe")
print(mr_files)

# Process each file
for (i in mr_files) {
    df <- fread(i)
    df <- df %>% select(exposure, outcome, beta.outcome, beta.exposure, se.outcome, se.exposure)
    df <- as.data.frame(df)

    # Run MR-PRESSO
    full_results <- mr_presso(
        BetaOutcome = "beta.outcome", 
        BetaExposure = "beta.exposure", 
        SdOutcome = "se.outcome", 
        SdExposure = "se.exposure", 
        OUTLIERtest = TRUE, 
        DISTORTIONtest = TRUE, 
        data = df, 
        NbDistribution = 1000,  
        SignifThreshold = 0.05
    )

    print(full_results)
    print(paste0("The phenotype pair is ", df[1, 1], " and ", df[1, 2]))

    main_results <- full_results$`Main MR results`
    global_test_stat <- full_results$`MR-PRESSO results`$`Global Test`$RSSobs
    global_test_pval <- full_results$`MR-PRESSO results`$`Global Test`$Pvalue
    distortion_test <- full_results$`MR-PRESSO results`$`Distortion Test`$`Distortion Coefficient`
    distortion_pval <- full_results$`MR-PRESSO results`$`Distortion Test`$Pvalue

    # Extract exposure and outcome
    Exposure <- df[1, 1] %>% as.data.frame()
    Outcome <- df[1, 2] %>% as.data.frame()

    # Process uncorrected results
    uncorrected <- main_results[1, ] %>% 
        select(-`MR Analysis`, -`T-stat`, -Exposure) %>%
        rename(
            MR_PRESSO_uncorrected_BETA = `Causal Estimate`,
            MR_PRESSO_uncorrected_SE = Sd,
            MR_PRESSO_uncorrected_pval = `P-value`
        )

    # Process corrected results
    corrected <- main_results[2, ] %>%
        select(-`MR Analysis`, -`T-stat`, -Exposure) %>%
        rename(
            MR_PRESSO_corrected_BETA = `Causal Estimate`,
            MR_PRESSO_corrected_SE = Sd,
            MR_PRESSO_corrected_pval = `P-value`
        )

    # Combine results into a single table
    results_table <- data.frame(
        Exposure, Outcome,
        uncorrected, corrected
    )

    results_table$MR_PRESSO_global_test_stat <- global_test_stat
    results_table$MR_PRESSO_global_test_pval <- global_test_pval

    # Process outliers
    if (!is.null(full_results$`MR-PRESSO results`$`Outlier Test`$Pvalue)) {
        outliers <- full_results$`MR-PRESSO results`$`Outlier Test` %>%
            as.data.table() %>%
            mutate(
                distortion_test = distortion_test,
                distortion_pval = distortion_pval
            )
        outlier_table <- data.frame(Exposure, Outcome, outliers)
        mr_presso_outliers <- rbind(mr_presso_outliers, outlier_table)
    } else {
        print("No outliers detected...")
    }

    # Append results to main results data frame
    mr_presso_main_results <- rbind(mr_presso_main_results, results_table)
}

# Write results to files
write.table(mr_presso_main_results, file = "/scratch/users/k20113596/Rosalind_Transfer/MR/TwoSampleMR/mr_presso_results_no_apoe.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
write.table(mr_presso_outliers, file = "/scratch/users/k20113596/Rosalind_Transfer/MR/TwoSampleMR/mr_presso_outliers_no_apoe.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

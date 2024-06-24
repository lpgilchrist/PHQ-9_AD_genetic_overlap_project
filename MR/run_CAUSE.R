###########################################
############## RUN CAUSE ##################
###########################################

## Step 1: Format data for CAUSE

library(readr)
library(dplyr)
library(data.table)
library(stringr)
library(cause)
library(genetics.binaRies)
library(ggplot2)
library(R.utils)
library(tidyr)

# Initialize data frames to store results
mr_cause_elpd <- data.frame()
mr_cause_effects <- data.frame()
mr_cause_sharing <- data.frame()

print("Starting MR analysis with CAUSE!")
print("Beginning loop...")

setwd("/scratch/users/k20113596/Rosalind_Transfer/MR/lhcMR/lhcMR_out/")

# List exposure and outcome files
exposure_file <- list.files(pattern = "PHQ9_|MDD_")
outcome_file <- list.files(pattern = "no_APOE")

print(exposure_file)
print(outcome_file)

# Read in the GWAS summary statistics files
for (i in exposure_file) {
    for (j in outcome_file) {
        X1 <- fread(i) %>% rename(A1 = EFFECT_ALLELE, A2 = NON_EFFECT_ALLELE)
        X2 <- fread(j) %>% rename(A1 = EFFECT_ALLELE, A2 = NON_EFFECT_ALLELE)

        # Extract exposure and outcome names
        exposure_name <- str_remove(i, pattern = "_cont_full_mtag_meta_with_N.txt.gz") %>% 
            str_remove(pattern = "_munged_MAF_0.01.txt.gz") %>% 
            str_remove(pattern = "MDD_sumstats_") %>% 
            str_remove(pattern = "PHQ9_")
        outcome_name <- str_remove(j, pattern = ".txt.gz") %>% 
            str_remove(pattern = "_munged_MAF_0.01") %>% 
            str_remove(pattern = "AD_sumstats_")

        print(paste0("Exposure is: ", exposure_name))
        print(paste0("Outcome is: ", outcome_name))

        # Merge the GWAS files and align the effect sizes
        print("Merging GWAS...")
        X <- gwas_merge(X1, X2, 
                        snp_name_cols = c("SNP", "SNP"), 
                        beta_hat_cols = c("BETA", "BETA"), 
                        se_cols = c("SE", "SE"), 
                        A1_cols = c("A1", "A1"), 
                        A2_cols = c("A2", "A2"), 
                        pval_cols = c("P", "P"))

        print("Merging complete!")
        print("Printing top of merged GWAS dataframe")
        print(head(X))

        ## Step 2: Calculate the nuisance parameters
        print("Step 2: Calculating the nuisance parameters...")
        set.seed(100)
        varlist <- with(X, sample(snp, size = 1000000, replace = FALSE))
        params <- est_cause_params(X, varlist)

        print("Nuisance parameters calculated: stored as params")
        print("Printing rho:")
        print(head(params$rho))
        print("Printing mix_grid:")
        print(head(params$mix_grid))

        ## Step 3: LD pruning
        print("Step 3: LD pruning using 1KG reference panel...")
        r2_thresh <- 0.01
        pval_thresh <- 0.001
        print(paste0("r2 threshold is: ", r2_thresh))
        print(paste0("p-value threshold is: ", pval_thresh))

        print("Clumping starts...")
        X_clump <- X %>%
            rename(rsid = snp, pval = p1) %>%
            ieugwasr::ld_clump(clump_r2 = r2_thresh,
                               clump_p = pval_thresh,
                               clump_kb = 10000,
                               plink_bin = genetics.binaRies::get_plink_binary(), 
                               bfile = "/scratch/users/k20113596/Rosalind_Transfer/LAVA/LD_files/g1000_eur/EUR")

        print("Clumping complete!")
        print("Selecting top variants...")
        top_vars <- X_clump$rsid
        print(paste0("The number of top variants is: ", nrow(X_clump)))

        ## Step 4: Fit CAUSE
        print("Step 4: Fitting CAUSE...")
        res <- cause(X = X, variants = top_vars, param_ests = params)

        print("Model has been fit...")
        print("Printing results...")
        print(res$elpd)

        # Create p-value column for z-scores
        print("Getting p-values...")
        results <- res$elpd
        results$p <- pnorm(q = results$z, lower.tail = TRUE)
        results$Exposure <- exposure_name
        results$Outcome <- outcome_name
        results$nSNPs <- length(top_vars)

        print(paste0("Printing ELPD results for ", exposure_name, " as a continuous variable with ", outcome_name))
        print(results)

        print("Printing summary of results, where gamma is the effect size of the exposure on the outcome, eta is the effect size of correlated pleiotropy, and q is the proportion of variants with correlated pleiotropy:")
        res_cause_est <- summary(res, ci_size = 0.95)
        print(res_cause_est)

        effects_table <- data.frame(exposure_name, outcome_name,
                                    length(top_vars),
                                    matrix(c(res_cause_est$quants[[2]][, 1],
                                             res_cause_est$quants[[2]][, 2],
                                             res_cause_est$quants[[2]][, 3]), nrow = 1))
        colnames(effects_table) <- c("Exposure", "Outcome", "nSNPs", "gamma", "gamma_lower", "gamma_upper", "eta", "eta_lower", "eta_upper", "q", "q_lower", "q_upper")

        sharing_table <- data.frame(exposure_name, outcome_name,
                                    length(top_vars),
                                    matrix(c(res_cause_est$quants[[1]][, 1],
                                             res_cause_est$quants[[1]][, 2],
                                             res_cause_est$quants[[1]][, 3]), nrow = 1))
        colnames(sharing_table) <- c("Exposure", "Outcome", "nSNPs", "gamma", "gamma_lower", "gamma_upper", "eta", "eta_lower", "eta_upper", "q", "q_lower", "q_upper")

        print("Printing p-value for causal model compared to sharing model...")
        print(summary(res)$p)

        print("Printing p-values for the three models...")
        print("Sharing model vs null:")
        print(pnorm(res$elpd$z[1], lower.tail = TRUE))
        print("Causal model vs null:")
        print(pnorm(res$elpd$z[2], lower.tail = TRUE))
        print("Causal model vs Sharing model:")
        print(pnorm(res$elpd$z[3], lower.tail = TRUE))

        print(res$loos[[3]])
        print(loo::pareto_k_table(res$loos[[3]]))

        mr_cause_elpd <- rbind(mr_cause_elpd, results)
        mr_cause_effects <- rbind(mr_cause_effects, effects_table)
        mr_cause_sharing <- rbind(mr_cause_sharing, sharing_table)

        # Uncomment below lines to save plots if needed
        # jpeg(paste0("/scratch/users/k20113596/Rosalind_Transfer/MR/CAUSE/cause_plots/mr_cause_results_", exposure_name, "_", outcome_name, ".png"), width = 12, height = 10, units = 'in', res = 300, family = "Helvetica")
        # plot(res)
        # dev.off()

        print("Moving on to next MR analysis...")
    }
}

print("Loop finished!")

print("Writing table...")

write.table(mr_cause_elpd, file = "/scratch/users/k20113596/Rosalind_Transfer/MR/CAUSE/mr_cause_elpd_no_apoe.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
write.table(mr_cause_effects, file = "/scratch/users/k20113596/Rosalind_Transfer/MR/CAUSE/mr_cause_effects_no_apoe.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
write.table(mr_cause_sharing, file = "/scratch/users/k20113596/Rosalind_Transfer/MR/CAUSE/mr_cause_sharing_no_apoe.txt", sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

print("Done!")

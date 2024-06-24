########################################
#### To run across all genome loci #####
########################################

# Load LAVA library
library(LAVA)

# Set paths

# Input info file path
input_info_file <- "/scratch/users/k20113596/Rosalind_Transfer/LAVA/input_info_path_files/PHQ_cont_MDD_AD.input.info.txt"

# Sample overlap file (can be set to NULL if there is no overlap)
sample_overlap_file <- "/scratch/users/k20113596/Rosalind_Transfer/LAVA/sample_overlap/PHQ_cont_MDD_AD_sample.overlap.txt"

# Reference genome file (1KG)
ref_prefix <- "/scratch/users/k20113596/Rosalind_Transfer/LAVA/LD_files/g1000_eur/EUR"

# Phenotype file paths and names
phenos <- c("PHQ9_Anhedonia_cont", "PHQ9_Appetite_Changes_cont", "PHQ9_Concentration_cont", "PHQ9_Depressed_Mood_cont", 
            "PHQ9_Fatigue_cont", "PHQ9_Inadequacy_cont", "PHQ_9_Sum_Score_cont", "PHQ9_Psychomotor_cont", 
            "PHQ9_Sleep_Problems_cont", "PHQ9_Suicidal_Thoughts_cont", "MDD_Howard", "MDD_Wray", "AD_Bellenguez", 
            "AD_Jansen", "AD_Wightman_UKB", "AD_Marioni", "AD_Wightman", "AD_Kunkle")

# Path for output
output_path <- "/scratch/users/k20113596/Rosalind_Transfer/LAVA/LAVA_out/"

# Read in loci data
loci = read.loci("/scratch/users/k20113596/Rosalind_Transfer/LAVA/locus_file/blocks_s2500_m25_f1_w200.GRCh37_hg19.locfile.txt"); n.loc = nrow(loci)

# Create the input object
input <- process.input(input_info_file, sample_overlap_file, ref_prefix, phenos)

# Set univariate p-value threshold
univ_p_thresh <- 2e-5

# Analyse
print(paste("Starting LAVA analysis for", n_loc, "loci"))
progress <- ceiling(quantile(1:n_loc, seq(0.05, 1, 0.05)))  # Print progress

u <- list()
b <- list()

for (i in 1:n_loc) {
    if (i %in% progress) print(paste("..", names(progress[which(progress == i)])))  # Print progress
    
    locus <- process.locus(loci[i, ], input)  # Process locus
    
    # Check if the locus can be defined before calling the analysis functions
    if (!is.null(locus)) {
        # Extract some general locus info for the output
        loc_info <- data.frame(locus = locus$id, chr = locus$chr, start = locus$start, stop = locus$stop, n_snps = locus$n.snps, n_pcs = locus$K)
        
        # Run the univariate and bivariate tests
        loc_out <- run.univ.bivar(locus, univ_thresh = univ_p_thresh)
        u[[i]] <- cbind(loc_info, loc_out$univ)
        if (!is.null(loc_out$bivar)) b[[i]] <- cbind(loc_info, loc_out$bivar)
    }
}

# Save the output
write.table(do.call(rbind, u), paste0(output_path, "PHQ_9_AD.univ.lava"), row.names = FALSE, quote = FALSE, col.names = TRUE)
write.table(do.call(rbind, b), paste0(output_path, "PHQ_9_AD.bivar.lava"), row.names = FALSE, quote = FALSE, col.names = TRUE)

print(paste0("Done! Analysis output written to ", output_path, ".*.lava"))

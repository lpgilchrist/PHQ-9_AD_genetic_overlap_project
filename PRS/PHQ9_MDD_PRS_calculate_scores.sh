#!/bin/bash -l

#SBATCH --job-name=AD_PRS_ADNI_calculate_scores
#SBATCH --mem=20G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition cpu
#SBATCH --output=/scratch/prj/proitsi/lachlan/LDAK/ADNI_scores/AD_PRS_ADNI_calculate_scores.log
#SBATCH --time=0-8:00

### Use LDAK to calculate the PRS in ADNI

cd /scratch/prj/proitsi/lachlan/LDAK/PHQ9_MDD_sumstats/

# Define sumstat names

# List all files in the directory
SUMSTAT_FILES=(*)

# Loop over files
for file in "${SUMSTAT_FILES[@]}"; do
    # Remove the .txt extension
    SUMSTAT="${file%.txt}"

# Calculate scores for ADNI
for SUMSTAT in "${SUMSTAT_DATA[@]}"; do
    /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/Software/ldak5.2.linux --calc-scores /scratch/prj/proitsi/lachlan/LDAK/ADNI_scores/ADNI_${SUMSTAT}_scores \
        --scorefile /scratch/prj/proitsi/lachlan/LDAK/Out/scores/${SUMSTAT}_bayesr.effects \
        --bfile /scratch/prj/proitsi/lachlan/target/final_target/ADNI_PRS_target --power 0
done

# Calculate scores for GERAD
for SUMSTAT in "${SUMSTAT_DATA[@]}"; do
    /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/Software/ldak5.2.linux --calc-scores /scratch/prj/proitsi/lachlan/LDAK/GERAD_scores/GERAD_${SUMSTAT}_scores \
        --scorefile /scratch/prj/proitsi/lachlan/LDAK/Out/scores/${SUMSTAT}_bayesr.effects \
        --bfile /scratch/prj/proitsi/lachlan/target/final_target/GERAD_PRS_target --power 0
done

# Calculate scores for ANMerge
for SUMSTAT in "${SUMSTAT_DATA[@]}"; do
    /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/Software/ldak5.2.linux --calc-scores /scratch/prj/proitsi/lachlan/LDAK/ANMerge_scores/ANMerge_${SUMSTAT}_scores \
        --scorefile /scratch/prj/proitsi/lachlan/LDAK/Out/scores/${SUMSTAT}_bayesr.effects \
        --bfile /scratch/prj/proitsi/lachlan/target/final_target/ANMerge_PRS_target --power 0
done

# sbatch -p cpu /scratch/prj/proitsi/lachlan/NMH_resubmission/scripts/AD_PRS_calculate_scores.sh

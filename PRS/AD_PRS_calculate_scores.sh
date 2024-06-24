#!/bin/bash -l

#SBATCH --job-name=AD_PRS_PROTECT_calculate_scores
#SBATCH --mem=20G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition cpu
#SBATCH --output=/scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/PROTECT_scores/AD_PRS_PROTECT_calculate_scores.log
#SBATCH --time=0-8:00

### Use LDAK to calculate the PRS in PROTECT

# Change directory to the PROTECT scores directory
cd /scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/PROTECT_scores/

# Define array of sumstat data files
SUMSTAT_DATA=("AD_sumstats_Wightman_UKB_munged_MAF_0.01" "AD_sumstats_Wightman_UKB_munged_MAF_0.01_no_APOE" "AD_sumstats_Wightman_munged_MAF_0.01" "AD_sumstats_Wightman_munged_MAF_0.01_no_APOE" "AD_sumstats_Marioni_munged_MAF_0.01" "AD_sumstats_Marioni_munged_MAF_0.01_no_APOE" "AD_sumstats_Kunkle_munged_MAF_0.01" "AD_sumstats_Kunkle_munged_MAF_0.01_no_APOE" "AD_sumstats_Jansen_munged_MAF_0.01" "AD_sumstats_Jansen_munged_MAF_0.01_no_APOE" "AD_sumstats_Bellenguez_munged_MAF_0.01" "AD_sumstats_Bellenguez_munged_MAF_0.01_no_APOE")

# Calculate scores for PROTECT
for SUMSTAT in "${SUMSTAT_DATA[@]}"; do
    /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/Software/ldak5.2.linux --calc-scores /scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/PROTECT_scores/PROTECT_${SUMSTAT}_scores \
        --scorefile /scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/Out/scores/${SUMSTAT}_bayesr.effects \
        --bfile /scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/target/final_target/PROTECT_PRS_target --power 0
done

# Calculate scores for GLAD
for SUMSTAT in "${SUMSTAT_DATA[@]}"; do
    /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/Software/ldak5.2.linux --calc-scores /scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/GLAD_scores/GLAD_${SUMSTAT}_scores \
        --scorefile /scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/LDAK/Out/scores/${SUMSTAT}_bayesr.effects \
        --bfile /scratch/prj/proitsi/lachlan/NMH_resubmission/AD_PRS/target/final_target/GLAD_PRS_target --power 0
done

# sbatch -p cpu /scratch/prj/proitsi/lachlan/NMH_resubmission/scripts/AD_PRS_calculate_scores.sh

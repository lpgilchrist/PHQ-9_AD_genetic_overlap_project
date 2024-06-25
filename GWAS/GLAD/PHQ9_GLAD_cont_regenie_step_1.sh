#!/bin/bash -l

#SBATCH --mem=20G
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --partition cpu
#SBATCH --output=/scratch/users/k20113596/Rosalind_Transfer/Output/GLAD_gwas/Step_1/PHQ9_GLAD_cont_regenie_step_1.out
#SBATCH --job-name=PHQ9_GLAD_cont_regenie_step_1.out


# set input paths
cleandatapathpheno=/scratch/users/k20113596/Rosalind_Transfer/Datasets/GLAD/Phenotypes/
cleandatapathgeno=/scratch/users/k20113596/Rosalind_Transfer/Datasets/GLAD/Genotyped/
cleandatapathcovariates=/scratch/users/k20113596/Rosalind_Transfer/Datasets/GLAD/Covariates/


# set output paths
outputpath=/scratch/users/k20113596/Rosalind_Transfer/Output/GLAD_gwas/Step_1/
scriptspath=/scratch/users/k20113596/Rosalind_Transfer/Scripts/

cd  ${outputpath}

# load regenie env
module load anaconda3/2021.05-gcc-9.4.0

source activate regenie_env

regenie \
  --step 1 \
  --bed ${cleandatapathgeno}GLADb08b09b12b16b17_b38_EUR_maf1_sample95.SNP95.hwe10.chr_1_22 \
  --extract ${cleandatapathgeno}GLADb08b09b12b16b17_b38_EUR_maf1_sample95.SNP95.hwe10.GLAD_participants.non_alt_chr.het_dropped.SEX_1.dups_removed.IBD_outliers_removed.snplist \
  --keep ${cleandatapathgeno}GLADb08b09b12b16b17_b38_EUR_maf1_sample95.SNP95.hwe10.GLAD_participants.non_alt_chr.het_dropped.SEX_1.dups_removed.IBD_outliers_removed.fam \
  --phenoFile ${cleandatapathpheno}GLAD_PHQ9_filtered_EUR.txt \
  --catCovarList sex,Batch \
  --maxCatLevels 106 \
  --covarFile ${cleandatapathcovariates}GLAD_covariates_QCd.txt \
  --bsize 1000 \
  --lowmem \
  --lowmem-prefix ${outputpath}tmp_rg_PHQ9_GLAD_cont \
  --out ${outputpath}PHQ9_GLAD_cont_regenie_step_1_fit_out


### This script is an adapted version of Ryan Arathimos' script at https://github.com/applyfun/gwas_methods/blob/main/regenie_gwas_step1.sh

### sbatch -p cpu /scratch/users/k20113596/Rosalind_Transfer/Scripts/PHQ9_GLAD_cont_regenie_step_1.sh

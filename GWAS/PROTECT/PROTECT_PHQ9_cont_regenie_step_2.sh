#!/bin/sh -l

#SBATCH --mem=50G
#SBATCH --nodes=1
#SBATCH --ntasks=50
#SBATCH --partition cpu
#SBATCH --output=/scratch/users/k20113596/Rosalind_Transfer/Output/PROTECT_gwas/PROTECT_step_2/PROTECT_step_2_cont/PROTECT_PHQ9_cont_regenie_step_2.out
#SBATCH --job-name=PROTECT_PHQ9_cont_regenie_step_2
#SBATCH --time=0-48:00

cd /scratch/users/k20113596/Scripts/

# set input paths
cleandatapathpheno=/scratch/users/k20113596/Rosalind_Transfer/Datasets/PROTECT/Pheno_QC/
cleandatapathgeno=/scratch/users/k20113596/Rosalind_Transfer/Datasets/PROTECT/Genotype_QC/
cleandatapathcovariates=/scratch/users/k20113596/Rosalind_Transfer/Datasets/PROTECT/Covar_QC/
imputeddata=/scratch/prj/brc_mh/PROTECT/data/imputed/data/

# set output paths
outputpath1=/scratch/users/k20113596/Rosalind_Transfer/Output/PROTECT_gwas/PROTECT_step_1/PROTECT_step_1_cont/
outputpath2=/scratch/users/k20113596/Rosalind_Transfer/Output/PROTECT_gwas/PROTECT_step_2/PROTECT_step_2_cont/
scriptspath=/scratch/users/k20113596/Rosalind_Transfer/Scripts/


module load anaconda3/2021.05-gcc-9.4.0

source activate regenie_env_3.2

regenie \
  --step 2 \
  --bed ${imputeddata}postimputation_merged_rsids_maf \
  --covarFile ${cleandatapathcovariates}PROTECT_PHQ_9_covariates_QC.txt \
  --catCovarList SEX,batch \
  --maxCatLevels 106 \
  --phenoFile ${cleandatapathpheno}PROTECT_PHQ_9_phenos_QC.txt \
  --keep ${cleandatapathgeno}PROTECT_downsampled_using_protect_snplist_GENO0.02_MAF0.01_MIND_0.01_CAUC_SEX_HET_EUR_HWE0.00000001.fam \
  --bsize 400 \
  --force-qt \
  --minINFO 0.7 \
  --minMAC 5 \
  --pred ${outputpath1}PROTECT_PHQ9_cont_regenie_step_1_fit_out_pred.list \
  --out ${outputpath2}PROTECT_PHQ9_cont_regenie_step_2_out

echo Done

### This script is an adapted version of Ryan Arathimos' script at https://github.com/applyfun/gwas_methods/blob/main/regenie_gwas_step2.sh

### sbatch -p cpu /scratch/users/k20113596/Rosalind_Transfer/Scripts/PROTECT_GWAS/PROTECT_PHQ9_cont_regenie_step_2_nov_2022.sh

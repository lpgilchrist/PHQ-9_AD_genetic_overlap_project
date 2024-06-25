#!/bin/bash -l

#SBATCH --mem=20G
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --partition cpu
#SBATCH --output=/scratch/users/k20113596/Rosalind_Transfer/Output/PROTECT_gwas/PROTECT_step_1/PROTECT_step_1_cont/PROTECT_PHQ9_cont_regenie_step_1.out
#SBATCH --job-name=PROTECT_PHQ9_cont_regenie_step_1


# set input paths
cleandatapathpheno=/scratch/users/k20113596/Rosalind_Transfer/Datasets/PROTECT/Pheno_QC/
cleandatapathgeno=/scratch/users/k20113596/Rosalind_Transfer/Datasets/PROTECT/Genotype_QC/
cleandatapathcovariates=/scratch/users/k20113596/Rosalind_Transfer/Datasets/PROTECT/Covar_QC/


# set output paths
outputpath=/scratch/users/k20113596/Rosalind_Transfer/Output/PROTECT_gwas/PROTECT_step_1/PROTECT_step_1_cont/
scriptspath=/scratch/users/k20113596/Rosalind_Transfer/Scripts/

cd  ${outputpath}



# load regenie env
module load anaconda3/2021.05-gcc-9.4.0

source activate regenie_env_3.2


regenie \
  --step 1 \
  --bed /scratch/users/k20113596/Rosalind_Transfer/Datasets/PROTECT/Genotype_QC/PROTECT_binary_23_chr \
  --extract ${cleandatapathgeno}PROTECT_downsampled_using_protect_snplist_GENO0.02_MAF0.01_MIND_0.01_CAUC_SEX_HET_EUR_HWE0.00000001.snplist \
  --phenoFile ${cleandatapathpheno}PROTECT_PHQ_9_phenos_QC.txt \
  --keep ${cleandatapathgeno}PROTECT_downsampled_using_protect_snplist_GENO0.02_MAF0.01_MIND_0.01_CAUC_SEX_HET_EUR_HWE0.00000001.fam \
  --catCovarList SEX,batch \
  --force-qt \
  --maxCatLevels 106 \
  --covarFile ${cleandatapathcovariates}PROTECT_PHQ_9_covariates_QC.txt \
  --bsize 1000 \
  --lowmem \
  --lowmem-prefix ${outputpath}tmp_rg_PROTECT_PHQ9_cont \
  --out ${outputpath}PROTECT_PHQ9_cont_regenie_step_1_fit_out


### This script is an adapted version of Ryan Arathimos' script at https://github.com/applyfun/gwas_methods/blob/main/regenie_gwas_step1.sh

### sbatch -p cpu /scratch/users/k20113596/Rosalind_Transfer/Scripts/PROTECT_GWAS/PROTECT_PHQ9_cont_regenie_step_1_nov_2022.sh

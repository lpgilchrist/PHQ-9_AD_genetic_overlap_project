#!/bin/sh -l

#SBATCH --job-name=PHQ9_MHQ_cont_regenie_step2
#SBATCH --partition=cpu
#SBATCH --output=/scratch/users/k20113596/Rosalind_Transfer/Output/GLAD_gwas/Step_2/PHQ9_GLAD_cont_regenie_step_2.%A_%a.out
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-22%22
#SBATCH --time=0-48:00


cd /scratch/users/k20113596/Rosalind_Transfer/Scripts/

# set input paths
cleandatapathpheno=/scratch/users/k20113596/Rosalind_Transfer/Datasets/GLAD/Phenotypes/
cleandatapathgeno=/scratch/users/k20113596/Rosalind_Transfer/Datasets/GLAD/Genotyped/
cleandatapathcovariates=/scratch/users/k20113596/Rosalind_Transfer/Datasets/GLAD/Covariates/
imputeddata=/scratch/prj/bioresource/data/GLAD/05.imputed/GLADv2/pfiles/

# set output paths
outputpath1=/scratch/users/k20113596/Rosalind_Transfer/Output/GLAD_gwas/Step_1/
outputpath2=/scratch/users/k20113596/Rosalind_Transfer/Output/GLAD_gwas/Step_2/
scriptspath=/scratch/users/k20113596/Rosalind_Transfer/Scripts/

# load regenie module and assign array task ID as Chromosome number
echo ${SLURM_ARRAY_TASK_ID}
CHR=${SLURM_ARRAY_TASK_ID}
echo ${CHR}

module load anaconda3/2021.05-gcc-9.4.0

source activate regenie_env

regenie \
  --step 2 \
  --pgen ${imputeddata}GLADv2_chr${CHR} \
  --covarFile ${cleandatapathcovariates}GLAD_covariates_QCd.txt \
  --catCovarList sex,Batch \
  --maxCatLevels 106 \
  --phenoFile ${cleandatapathpheno}GLAD_PHQ9_filtered_EUR.txt \
  --keep ${cleandatapathgeno}GLADb08b09b12b16b17_b38_EUR_maf1_sample95.SNP95.hwe10.GLAD_participants.non_alt_chr.het_dropped.SEX_1.dups_removed.plink2_ver.psam \
  --bsize 400 \
  --minINFO 0.7 \
  --minMAC 5 \
  --pred ${outputpath1}PHQ9_GLAD_cont_regenie_step_1_fit_out_pred.list \
  --split \
  --out ${outputpath2}PHQ9_GLAD_cont_regenie_step_2_chr_${CHR}_out

echo Done

### This script is an adapted version of Ryan Arathimos' script at https://github.com/applyfun/gwas_methods/blob/main/regenie_gwas_step2.sh

### sbatch -p cpu /scratch/users/k20113596/Rosalind_Transfer/Scripts/PHQ9_GLAD_cont_regenie_step_2.sh

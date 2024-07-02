#!/bin/sh -l

#SBATCH --job-name=PHQ9_Pain_cont_regenie_step2_nov_2022
#SBATCH --partition cpu
#SBATCH --output=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_pain_cont_step_2_nov_2022/PHQ9_pain_cont_regenie_step_2_nov_2022.%A_%a.out
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-22%22
#SBATCH --time=0-28:00


cd /scratch/groups/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Scripts/REGENIE_scripts/

# set input paths
cleandatapathpheno=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/Pain_Phenos_Final/
cleandatapathgeno=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Genotype_QC/
cleandatapathcovariates=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Covariates/Pain_Covariates_Final/
imputeddata=/scratch/prj/ukbiobank/ukb18177_glanville/imputed/

# set output paths
outputpath1=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_1/PHQ_pain_cont_step_1_nov_2022/
outputpath2=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_pain_cont_step_2_nov_2022/
scriptspath=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Scripts/REGENIE_scripts/

# load regenie module and assign array task ID as Chromosome number
echo ${SLURM_ARRAY_TASK_ID}
CHR=${SLURM_ARRAY_TASK_ID}
echo ${CHR}

module load anaconda3/2021.05-gcc-9.4.0

source activate regenie_env_3.2

regenie \
  --step 2 \
  --bgen ${imputeddata}ukb18177_glanville_imp_chr${CHR}_MAF1_INFO4_v1.bgen \
  --sample ${imputeddata}ukb18177_glanville_chr1.sample \
  --covarFile ${cleandatapathcovariates}pain_questionnaire_covariates_EUR_nov_2022.txt \
  --catCovarList sex,batch,assessment_centre \
  --force-qt \
  --maxCatLevels 106 \
  --phenoFile ${cleandatapathpheno}PHQ_pain_NArm_EUR_QC_nov_2022.txt \
  --keep ${cleandatapathgeno}wukb18177_PHQ9_pain_questionnaire_nov_2022_MAF0.01_GENO0.02_MIND0.02_CAUC1_UKBQC1_HWE0.00000001_SEX1.fam \
  --bsize 400 \
  --minINFO 0.7 \
  --minMAC 5 \
  --pred ${outputpath1}PHQ9_pain_cont_regenie_step_1_nov_2022_fit_out_pred.list \
  --out ${outputpath2}PHQ9_pain_cont_regenie_step_2_nov_2022_chr_${CHR}_out

echo Done

### This script is an adapted version of Ryan Arathimos' script at https://github.com/applyfun/gwas_methods/blob/main/regenie_gwas_step2.sh

### sbatch -p cpu /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Scripts/REGENIE_scripts/PHQ9_pain_cont_regenie_step_2_nov_2022.sh

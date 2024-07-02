#!/bin/bash -l

#SBATCH --mem=20G
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --partition cpu
#SBATCH --output=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_1/PHQ_pain_cont_step_1_nov_2022/PHQ9_pain_cont_regenie_step_1_nov_2022.out
#SBATCH --job-name=PHQ9_pain_cont_regenie_step_1_nov_2022

# set input paths
cleandatapathpheno=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Phenotypes/Pain_Phenos_Final/
cleandatapathgeno=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Genotype_QC/
cleandatapathcovariates=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Covariates/Pain_Covariates_Final/
ukbpath=/datasets/ukbiobank/ukb18177/genotyped/


# set output paths
outputpath=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_1/PHQ_pain_cont_step_1_nov_2022/
scriptspath=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Scripts/REGENIE_scripts/

cd  ${outputpath}


# load regenie module
# load regenie env
module load anaconda3/2021.05-gcc-9.4.0

source activate regenie_env_3.2

regenie \
  --step 1 \
  --bed  /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_1/PHQ_pain_cont_step_1/tmp_ukb18177_glanville_binary_23_chr \
  --extract ${cleandatapathgeno}wukb18177_PHQ9_pain_questionnaire_nov_2022_MAF0.01_GENO0.02_MIND0.02_CAUC1_UKBQC1_HWE0.00000001_SEX1.snplist \
  --phenoFile ${cleandatapathpheno}PHQ_pain_NArm_EUR_QC_nov_2022.txt \
  --keep ${cleandatapathgeno}wukb18177_PHQ9_pain_questionnaire_nov_2022_MAF0.01_GENO0.02_MIND0.02_CAUC1_UKBQC1_HWE0.00000001_SEX1.fam \
  --catCovarList sex,batch,assessment_centre \
  --force-qt \
  --maxCatLevels 106 \
  --covarFile ${cleandatapathcovariates}pain_questionnaire_covariates_EUR_nov_2022.txt \
  --bsize 1000 \
  --lowmem \
  --lowmem-prefix ${outputpath}tmp_rg_PHQ9_pain_cont_nov_2022 \
  --out ${outputpath}PHQ9_pain_cont_regenie_step_1_nov_2022_fit_out


### This script is an adapted version of Ryan Arathimos' script at https://github.com/applyfun/gwas_methods/blob/main/regenie_gwas_step1.sh

### sbatch -p cpu /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Scripts/REGENIE_scripts/PHQ9_pain_cont_regenie_step_1_nov_2022.sh

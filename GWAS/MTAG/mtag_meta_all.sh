#!/bin/bash -l

#SBATCH --mem=40G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --partition cpu
#SBATCH --output=/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/mtag_meta.out
#SBATCH --job-name=mtag_meta
#SBATCH --time=0-24:00


## This script is for running MTAG to combine the UKB sample ## 

module load anaconda3/2021.05-gcc-9.4.0

source activate mtag_env

cd /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/

python ./mtag.py \
--sumstats /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_MHQ_cont_step_2_nov_2022/PHQ9_MHQ_cont_nov_2022_munged/MHQ_cont_nov_2022_munged_MAF_0.01/PHQ9_MHQ_cont_nov_2022_Anhedonia_munged_MAF_0.01.txt,/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin/metal_cont/metal_for_downstream/META_UKB_pain_GLAD_PROTECT_Anhedonia_cont_for_downstream.txt \
--snp_name SNP \
--chr_name CHR \
--bpos_name BP \
--a1_name EFFECT_ALLELE \
--a2_name NON_EFFECT_ALLELE \
--eaf_name EAFREQ \
--z_name Z \
--n_name N \
--n_min 0.0 \
--maf_min 0.0000001 \
--std_betas \
--incld_ambig_snps \
--perfect_gencov \
--equal_h2 \
--stream_stdout \
--out /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/PHQ9_Anhedonia_cont_full



python ./mtag.py \
--sumstats /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_MHQ_cont_step_2_nov_2022/PHQ9_MHQ_cont_nov_2022_munged/MHQ_cont_nov_2022_munged_MAF_0.01/PHQ9_MHQ_cont_nov_2022_Appetite_Changes_munged_MAF_0.01.txt,/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin/metal_cont/metal_for_downstream/META_UKB_pain_GLAD_PROTECT_Appetite_Changes_cont_for_downstream.txt \
--snp_name SNP \
--chr_name CHR \
--bpos_name BP \
--a1_name EFFECT_ALLELE \
--a2_name NON_EFFECT_ALLELE \
--eaf_name EAFREQ \
--z_name Z \
--n_name N \
--n_min 0.0 \
--maf_min 0.0000001 \
--std_betas \
--incld_ambig_snps \
--perfect_gencov \
--equal_h2 \
--stream_stdout \
--out /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/PHQ9_Appetite_Changes_cont_full





python ./mtag.py \
--sumstats /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_MHQ_cont_step_2_nov_2022/PHQ9_MHQ_cont_nov_2022_munged/MHQ_cont_nov_2022_munged_MAF_0.01/PHQ9_MHQ_cont_nov_2022_Concentration_munged_MAF_0.01.txt,/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin/metal_cont/metal_for_downstream/META_UKB_pain_GLAD_PROTECT_Concentration_cont_for_downstream.txt \
--snp_name SNP \
--chr_name CHR \
--bpos_name BP \
--a1_name EFFECT_ALLELE \
--a2_name NON_EFFECT_ALLELE \
--eaf_name EAFREQ \
--z_name Z \
--n_name N \
--n_min 0.0 \
--maf_min 0.0000001 \
--std_betas \
--incld_ambig_snps \
--perfect_gencov \
--equal_h2 \
--stream_stdout \
--out /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/PHQ9_Concentration_cont_full




python ./mtag.py \
--sumstats /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_MHQ_cont_step_2_nov_2022/PHQ9_MHQ_cont_nov_2022_munged/MHQ_cont_nov_2022_munged_MAF_0.01/PHQ9_MHQ_cont_nov_2022_Depressed_Mood_munged_MAF_0.01.txt,/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin/metal_cont/metal_for_downstream/META_UKB_pain_GLAD_PROTECT_Depressed_Mood_cont_for_downstream.txt \
--snp_name SNP \
--chr_name CHR \
--bpos_name BP \
--a1_name EFFECT_ALLELE \
--a2_name NON_EFFECT_ALLELE \
--eaf_name EAFREQ \
--z_name Z \
--n_name N \
--n_min 0.0 \
--maf_min 0.0000001 \
--std_betas \
--incld_ambig_snps \
--perfect_gencov \
--equal_h2 \
--stream_stdout \
--out /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/PHQ9_Depressed_Mood_cont_full



python ./mtag.py \
--sumstats /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_MHQ_cont_step_2_nov_2022/PHQ9_MHQ_cont_nov_2022_munged/MHQ_cont_nov_2022_munged_MAF_0.01/PHQ9_MHQ_cont_nov_2022_Fatigue_munged_MAF_0.01.txt,/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin/metal_cont/metal_for_downstream/META_UKB_pain_GLAD_PROTECT_Fatigue_cont_for_downstream.txt \
--snp_name SNP \
--chr_name CHR \
--bpos_name BP \
--a1_name EFFECT_ALLELE \
--a2_name NON_EFFECT_ALLELE \
--eaf_name EAFREQ \
--z_name Z \
--n_name N \
--n_min 0.0 \
--maf_min 0.0000001 \
--std_betas \
--incld_ambig_snps \
--perfect_gencov \
--equal_h2 \
--stream_stdout \
--out /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/PHQ9_Fatigue_cont_full




python ./mtag.py \
--sumstats /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_MHQ_cont_step_2_nov_2022/PHQ9_MHQ_cont_nov_2022_munged/MHQ_cont_nov_2022_munged_MAF_0.01/PHQ9_MHQ_cont_nov_2022_Inadequacy_munged_MAF_0.01.txt,/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin/metal_cont/metal_for_downstream/META_UKB_pain_GLAD_PROTECT_Inadequacy_cont_for_downstream.txt \
--snp_name SNP \
--chr_name CHR \
--bpos_name BP \
--a1_name EFFECT_ALLELE \
--a2_name NON_EFFECT_ALLELE \
--eaf_name EAFREQ \
--z_name Z \
--n_name N \
--n_min 0.0 \
--maf_min 0.0000001 \
--std_betas \
--incld_ambig_snps \
--perfect_gencov \
--equal_h2 \
--stream_stdout \
--out /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/PHQ9_Inadequacy_cont_full



python ./mtag.py \
--sumstats /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_MHQ_cont_step_2_nov_2022/PHQ9_MHQ_cont_nov_2022_munged/MHQ_cont_nov_2022_munged_MAF_0.01/PHQ9_MHQ_cont_nov_2022_Psychomotor_munged_MAF_0.01.txt,/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin/metal_cont/metal_for_downstream/META_UKB_pain_GLAD_PROTECT_Psychomotor_cont_for_downstream.txt \
--snp_name SNP \
--chr_name CHR \
--bpos_name BP \
--a1_name EFFECT_ALLELE \
--a2_name NON_EFFECT_ALLELE \
--eaf_name EAFREQ \
--z_name Z \
--n_name N \
--n_min 0.0 \
--maf_min 0.0000001 \
--std_betas \
--incld_ambig_snps \
--perfect_gencov \
--equal_h2 \
--stream_stdout \
--out /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/PHQ9_Psychomotor_cont_full



python ./mtag.py \
--sumstats /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_MHQ_cont_step_2_nov_2022/PHQ9_MHQ_cont_nov_2022_munged/MHQ_cont_nov_2022_munged_MAF_0.01/PHQ9_MHQ_cont_nov_2022_Sleep_Problems_munged_MAF_0.01.txt,/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin/metal_cont/metal_for_downstream/META_UKB_pain_GLAD_PROTECT_Sleep_Problems_cont_for_downstream.txt \
--snp_name SNP \
--chr_name CHR \
--bpos_name BP \
--a1_name EFFECT_ALLELE \
--a2_name NON_EFFECT_ALLELE \
--eaf_name EAFREQ \
--z_name Z \
--n_name N \
--n_min 0.0 \
--maf_min 0.0000001 \
--std_betas \
--incld_ambig_snps \
--perfect_gencov \
--equal_h2 \
--stream_stdout \
--out /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/PHQ9_Sleep_Problems_cont_full



python ./mtag.py \
--sumstats /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_MHQ_cont_step_2_nov_2022/PHQ9_MHQ_cont_nov_2022_munged/MHQ_cont_nov_2022_munged_MAF_0.01/PHQ9_MHQ_cont_nov_2022_Suicidal_Thoughts_munged_MAF_0.01.txt,/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin/metal_cont/metal_for_downstream/META_UKB_pain_GLAD_PROTECT_Suicidal_Thoughts_cont_for_downstream.txt \
--snp_name SNP \
--chr_name CHR \
--bpos_name BP \
--a1_name EFFECT_ALLELE \
--a2_name NON_EFFECT_ALLELE \
--eaf_name EAFREQ \
--z_name Z \
--n_name N \
--n_min 0.0 \
--maf_min 0.0000001 \
--std_betas \
--incld_ambig_snps \
--perfect_gencov \
--equal_h2 \
--stream_stdout \
--out /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/PHQ9_Suicidal_Thoughts_cont_full





python ./mtag.py \
--sumstats /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_MHQ_cont_step_2_nov_2022/PHQ9_MHQ_cont_nov_2022_munged/MHQ_cont_nov_2022_munged_MAF_0.01/PHQ9_MHQ_cont_nov_2022_PHQ-9_Sum_Score_munged_MAF_0.01.txt,/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin/metal_cont/metal_for_downstream/META_UKB_pain_GLAD_PROTECT_PHQ-9_Sum_Score_cont_for_downstream.txt \
--snp_name SNP \
--chr_name CHR \
--bpos_name BP \
--a1_name EFFECT_ALLELE \
--a2_name NON_EFFECT_ALLELE \
--eaf_name EAFREQ \
--z_name Z \
--n_name N \
--n_min 0.0 \
--maf_min 0.0000001 \
--std_betas \
--incld_ambig_snps \
--perfect_gencov \
--equal_h2 \
--stream_stdout \
--out /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/mtag/mtag_output/PHQ9_PHQ-9_Sum_Score_cont_full


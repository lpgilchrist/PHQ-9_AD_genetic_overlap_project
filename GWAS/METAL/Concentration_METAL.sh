#################################################################################
######### This script is to meta-analyse the EoP, GLAD and PROTECT data ########
#################################################################################

cd /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/METAL/METAL/build/bin

./metal

SCHEME STDERR
AVERAGEFREQ ON
MINMAXFREQ ON
CUSTOMVARIABLE TotalSampleSize
TRACKPOSITIONS ON

# === DESCRIBE AND PROCESS THE FIRST INPUT FILE ===
# This is the UKB EoP Questionnaire GWAS
MARKER SNP
Chromosome CHR
Position BP
ALLELE EFFECT_ALLELE NON_EFFECT_ALLELE
FREQ EAFREQ
EFFECT BETA
STDERR SE
PVALUE P
LABEL TotalSampleSize as N
PROCESS /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/REGENIE/Out/Step_2/PHQ_pain_cont_step_2_nov_2022/PHQ9_pain_cont_nov_2022_munged/PHQ9_pain_cont_munged_MAF_0.01/PHQ9_pain_cont_nov_2022_Concentration_munged_MAF_0.01.txt


# === DESCRIBE AND PROCESS THE SECOND INPUT FILE ===
# This is the GLAD GWAS
MARKER SNP
Chromosome CHR
Position BP
ALLELE EFFECT_ALLELE NON_EFFECT_ALLELE
FREQ EAFREQ
EFFECT BETA
STDERR SE
PVALUE P
LABEL TotalSampleSize as N
PROCESS /scratch/users/k20113596/Rosalind_Transfer/Output/GLAD_gwas/Step_2/GLAD_PHQ9_cont_munged/PHQ9_GLAD_cont_munged_combined/PHQ_GLAD_cont_munged_combined_MAF_0.01/PHQ9_GLAD_cont_regenie_Concentration_munged_MAF_0.01.txt

# === DESCRIBE AND PROCESS THE THIRD INPUT FILE ===
# This is the PROTECT GWAS
MARKER SNP
Chromosome CHR
Position BP
ALLELE EFFECT_ALLELE NON_EFFECT_ALLELE
FREQ EAFREQ
EFFECT BETA
STDERR SE
PVALUE P
LABEL TotalSampleSize as N
PROCESS /scratch/users/k20113596/Rosalind_Transfer/Output/PROTECT_gwas/PROTECT_step_2/PROTECT_cont_munged/PROTECT_cont_munged_MAF_0.01/PROTECT_cont_nov_2022_concentration_problems_munged_MAF_0.01.txt

OUTFILE META_UKB_pain_GLAD_PROTECT_Concentration_cont_pos_tracked .txt
ANALYZE

QUIT


#!/bin/bash -l

#SBATCH --job-name=AD_MegaPRS
#SBATCH --mem=50G
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --partition cpu
#SBATCH --output=/scratch/prj/proitsi/lachlan/LDAK/Out/AD_MegaPRS_out.log
#SBATCH --time=0-24:00

cd /scratch/prj/proitsi/lachlan/LDAK/PHQ9_MDD_sumstats/


# Define sumstats

# List all files in the directory
SUMSTAT_FILES=(*)

# Loop over files
for file in "${SUMSTAT_FILES[@]}"; do
    # Remove the .txt extension
    SUMSTAT="${file%.txt}"

    # Calculate the tagging file and heritability matrix assuming the BLD-LDAK Model 
    if [ ! -f "/scratch/prj/proitsi/lachlan/LDAK/Out/${SUMSTAT}_bld.ldak.tagging" ]; then
        /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/Software/ldak5.2.linux --calc-tagging /scratch/prj/proitsi/lachlan/LDAK/Out/${SUMSTAT}_bld.ldak --bfile /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/1KG_ref/EUR --extract /scratch/prj/proitsi/lachlan/LDAK/use.snps/${SUMSTAT}_use.snps --ignore-weights YES --power -.25 --annotation-number 65 --annotation-prefix /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/SNP_Annotations/bld --window-cm 1 --save-matrix YES --max-threads 8
    fi

    # Estimate heritability per predictor
    if [ ! -f "/scratch/prj/proitsi/lachlan/LDAK/Out/${SUMSTAT}_bld.ldak.ind.hers" ]; then
        /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/Software/ldak5.2.linux --sum-hers /scratch/prj/proitsi/lachlan/LDAK/Out/${SUMSTAT}_bld.ldak --tagfile /scratch/prj/proitsi/lachlan/LDAK/Out/${SUMSTAT}_bld.ldak.tagging --summary /scratch/prj/proitsi/lachlan/sumstats/hapmap3/${SUMSTAT}.txt --check-sums NO --matrix /scratch/prj/proitsi/lachlan/LDAK/Out/${SUMSTAT}_bld.ldak.matrix --max-threads 8
    fi

    # Calculate cors
    if [ ! -f "/scratch/prj/proitsi/lachlan/LDAK/Out/${SUMSTAT}_cors.cors.bin" ]; then
        /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/Software/ldak5.2.linux --calc-cors /scratch/prj/proitsi/lachlan/LDAK/Out/${SUMSTAT}_cors --bfile /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/1KG_ref/EUR --window-cm 3 --extract /scratch/prj/proitsi/lachlan/LDAK/use.snps/${SUMSTAT}_use.snps --max-threads 8
    fi

  # Construct the prediction model
    if [ ! -f "/scratch/prj/proitsi/lachlan/LDAK/Out/scores/${SUMSTAT}_bayesr.effects" ]; then
		/scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/Software/ldak5.2.linux --mega-prs /scratch/prj/proitsi/lachlan/LDAK/Out/scores/${SUMSTAT}_bayesr --model bayesr --ind-hers /scratch/prj/proitsi/lachlan/LDAK/Out/${SUMSTAT}_bld.ldak.ind.hers --summary /scratch/prj/proitsi/lachlan/sumstats/hapmap3/${SUMSTAT}.txt --cors /scratch/prj/proitsi/lachlan/LDAK/Out/${SUMSTAT}_cors --cv-proportion .1 --high-LD /scratch/prj/ukbiobank/usr/Lachlan/polygenic_paper/LDAK/High_LD/highld/genes.predictors.used --window-cm 1 --extract /scratch/prj/proitsi/lachlan/LDAK/use.snps/${SUMSTAT}_use.snps --max-threads 8
    fi
done


# submit: sbatch -p cpu /scratch/prj/proitsi/lachlan/NMH_resubmission/scripts/PHQ9_MDD_MegaPRS.sh


#!/bin/bash

#SBATCH --job-name="BEDvcf"
#SBATCH -o 98_log_files/log-BED0.05
#SBATCH -c 1
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yourAddress
#SBATCH --time=0-02:00
#SBATCH --mem=2G

# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# Load needed software
module load vcftools/0.1.12b

# Get current time
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)

# Copy script as it was run
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
INPUT="okis.bc.recode.vcf"

# Running the program
vcftools --gzvcf $INPUT --recode --max-missing 0.1 --maf 0.05 \
    --stdout|grep 'C	T'|grep -v '#'|grep -v ^$|awk '{print $1"\t"$2-1"\t"$2}' \
    > okis_southernBC_SNPs_Juin12-2018_maf0.05_CT.bed

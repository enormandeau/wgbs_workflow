#!/bin/bash

#SBATCH -J "methpipe_x"
#SBATCH -o 98_log_files/methpipe_x.out
#SBATCH -c 2
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yourAddress
#SBATCH --time=3-00:00
#SBATCH --mem=20G

# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# Load needed software
module load methpipe/3.4.3

# Get current time
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)

# Copy script as it was run
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
GENOME="04_reference/genome_filtered.fna"
DATA_FOLDER="05_results"
DATAINPUT="03_trimmed"
#base=__BASE__
SAMPLE="01_info_file/sample_name_x"

# Running the program
cat "$SAMPLE" | while read i  
do

    LC_ALL=C sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 \
        -o "$DATA_FOLDER"/"$i".mr.sorted_start "$DATA_FOLDER"/"$i".mr

    # Compress .mr file
    gzip "$DATA_FOLDER"/"$i".mr

    # Remove putative PCR duplicates
    duplicate-remover -S "$DATA_FOLDER"/"$i".dremove_stat.txt \
        -o "$DATA_FOLDER"/"$i".mr.dremove "$DATA_FOLDER"/"$i".mr.sorted_start

    rm "$DATA_FOLDER"/"$i".mr.sorted_start

    LC_ALL=C sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 \
        -o "$DATA_FOLDER"/"$i".mr.dremove.sort "$DATA_FOLDER"/"$i".mr.dremove

    rm "$DATA_FOLDER"/"$i".mr.dremove

    # Compute methylation level
    methcounts -cpg-only -c $GENOME -o "$DATA_FOLDER"/"$i".meth "$DATA_FOLDER"/"$i".mr.dremove.sort

    # Compute symmetric CpGs contexts
    symmetric-cpgs -o "$DATA_FOLDER"/"$i"_CpG.meth "$DATA_FOLDER"/"$i".meth

    # Compute methylation stats
    levels -o "$DATA_FOLDER"/"$i".levels "$DATA_FOLDER"/"$i".meth

    # Compute conversion rate
    bsrate -c $GENOME -o "$DATA_FOLDER"/"$i".bsrate "$DATA_FOLDER"/"$i".mr.dremove.sort

    rm "$DATA_FOLDER"/"$i".mr.dremove.sort

done

#!/bin/bash

# NOTE: moving to srun instead of sbatch
###SBATCH -J "align"
###SBATCH -o 98_log_files/%j_align
###SBATCH -c 5
###SBATCH -p large
###SBATCH --mail-type=ALL
###SBATCH --mail-user=yourAddress
###SBATCH --time=20-00:00
###SBATCH --mem=32G

# Move to directory where job was submitted
##cd $SLURM_SUBMIT_DIR

# Get current time
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)

# Copy script as it was run
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Load needed software
module load samtools/1.8

# Global variables
INDEX="04_reference/index_genome.dbindex"
DATAFOLDER="03_trimmed"
DATAOUTPUT="05_results"
SAMPLE="$1"

echo "Using $SAMPLE"

# Running the program
cat "$SAMPLE" | while read i  
do
    echo "  Treating sample $i"

    zcat "$DATAFOLDER"/"$i"_R1.fastq.gz > "$DATAFOLDER"/"$i"_R1.fastq
    zcat "$DATAFOLDER"/"$i"_R2.fastq.gz > "$DATAFOLDER"/"$i"_R2.fastq

    walt -i $INDEX -m 6 -t 5 -k 10 -N 5000000 \
        -1 "$DATAFOLDER"/"$i"_R1.fastq \
        -2 "$DATAFOLDER"/"$i"_R2.fastq \
        -o "$DATAOUTPUT"/"$i".mr

    rm "$DATAFOLDER"/"$i"_R*.fastq

    gzip "$DATAOUTPUT"/"$i".mr
done

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

# Load needed software
module load samtools/1.8
module load methpipe/3.4.3

# Get current time
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)

# Copy script as it was run
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
GENOME_INDEX="04_reference/index_genome.dbindex"
DATAFOLDER="03_trimmed"
DATAOUTPUT="05_results"
SAMPLE="$1"

echo "Using $SAMPLE"

# Running the program
cat "$SAMPLE" | while read i  
do
    echo "######################"
    echo "  Treating sample $i"
    echo "######################"

    zcat "$DATAFOLDER"/"$i"_R1.fastq.gz | head -40000 > "$DATAFOLDER"/"$i"_R1.fastq
    zcat "$DATAFOLDER"/"$i"_R2.fastq.gz | head -40000 > "$DATAFOLDER"/"$i"_R2.fastq

    # Aligning with WALT
    # TODO Check walt parameters
    walt -i $GENOME_INDEX -m 6 -t 1 -k 10 -N 5000000 \
        -1 "$DATAFOLDER"/"$i"_R1.fastq \
        -2 "$DATAFOLDER"/"$i"_R2.fastq \
        -o "$DATAOUTPUT"/"$i".mr

    rm "$DATAFOLDER"/"$i"_R*.fastq

    # Methpipe pipeline
    LC_ALL=C sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 \
        -o "$DATAOUTPUT"/"$i".mr.sorted_start "$DATAOUTPUT"/"$i".mr

    # Compress .mr file
    gzip "$DATAOUTPUT"/"$i".mr

    # Remove putative PCR duplicates
    duplicate-remover -S "$DATAOUTPUT"/"$i".dremove_stat.txt \
        -o "$DATAOUTPUT"/"$i".mr.dremove "$DATAOUTPUT"/"$i".mr.sorted_start

    rm "$DATAOUTPUT"/"$i".mr.sorted_start

    LC_ALL=C sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 \
        -o "$DATAOUTPUT"/"$i".mr.dremove.sort "$DATAOUTPUT"/"$i".mr.dremove

    rm "$DATAOUTPUT"/"$i".mr.dremove

    # Compute methylation level
    methcounts -cpg-only -c $GENOME_INDEX -o "$DATAOUTPUT"/"$i".meth "$DATAOUTPUT"/"$i".mr.dremove.sort

    # Compute symmetric CpGs contexts
    symmetric-cpgs -o "$DATAOUTPUT"/"$i"_CpG.meth "$DATAOUTPUT"/"$i".meth

    # Compute methylation stats
    levels -o "$DATAOUTPUT"/"$i".levels "$DATAOUTPUT"/"$i".meth

    # Compute conversion rate
    bsrate -c $GENOME_INDEX -o "$DATAOUTPUT"/"$i".bsrate "$DATAOUTPUT"/"$i".mr.dremove.sort

    rm "$DATAOUTPUT"/"$i".mr.dremove.sort
    echo

done

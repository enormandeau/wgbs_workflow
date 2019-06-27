#!/bin/bash

print_help () {
    echo ""
    echo "Usage:"
    echo "    srun -c 1 --mem 32G -p large --time 21-00:00 -J waltAlign -o 98_log_files/waltAlign_%j.log ./00_scripts/05_align.sh <SAMPLE_FILE>"
    echo ""
    echo "Where:"
    echo "    SAMPLE_FILE is a file containing samples (the part before _R1, _R2 or _trimmed_...)"
    echo ""
}

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
TRIMMED_FOLDER="03_trimmed"
RESULT_FOLDER="05_results"
SAMPLE_FILE="$1"

if [ -z "$SAMPLE_FILE" ]
then
    print_help
    exit
fi 

# Running the pipeline
cat "$SAMPLE_FILE" | while read SAMPLE
do
    echo "######################"
    echo "  Treating sample $SAMPLE"

    zcat "$TRIMMED_FOLDER"/"$SAMPLE"_trimmed_fastp_R1.fastq.gz > "$TRIMMED_FOLDER"/"$SAMPLE"_R1.fastq
    zcat "$TRIMMED_FOLDER"/"$SAMPLE"_trimmed_fastp_R2.fastq.gz > "$TRIMMED_FOLDER"/"$SAMPLE"_R2.fastq

    # Aligning with WALT
    # TODO Check walt parameters
    walt -i $GENOME_INDEX -m 6 -t 1 -k 10 -N 5000000 \
        -1 "$TRIMMED_FOLDER"/"$SAMPLE"_R1.fastq \
        -2 "$TRIMMED_FOLDER"/"$SAMPLE"_R2.fastq \
        -o "$RESULT_FOLDER"/"$SAMPLE".mr

    rm "$TRIMMED_FOLDER"/"$SAMPLE"_R*.fastq

    # Methpipe pipeline
    LC_ALL=C sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 \
        -o "$RESULT_FOLDER"/"$SAMPLE".mr.sorted_start "$RESULT_FOLDER"/"$SAMPLE".mr

    # Delete .mr file
    rm "$RESULT_FOLDER"/"$SAMPLE".mr

    # Remove putative PCR duplicates
    duplicate-remover -S "$RESULT_FOLDER"/"$SAMPLE".dremove_stat.txt \
        -o "$RESULT_FOLDER"/"$SAMPLE".mr.dremove "$RESULT_FOLDER"/"$SAMPLE".mr.sorted_start

    rm "$RESULT_FOLDER"/"$SAMPLE".mr.sorted_start

    LC_ALL=C sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 \
        -o "$RESULT_FOLDER"/"$SAMPLE".mr.dremove.sort "$RESULT_FOLDER"/"$SAMPLE".mr.dremove

    rm "$RESULT_FOLDER"/"$SAMPLE".mr.dremove
done

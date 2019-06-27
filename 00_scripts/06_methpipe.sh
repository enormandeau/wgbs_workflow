#!/bin/bash

print_help () {
    echo ""
    echo "Usage:"
    echo "    cat sample_names.txt | parallel -j 20 srun -c 1 --mem 20G -p medium --time 7-00:00 -J methpipe -o 98_log_files/methpipe_%j.log ./00_scripts/06_methpipe.sh {}"
    echo ""
    echo "Where:"
    echo "    SAMPLE_NAME is the part before _R1, _R2 or _trimmed_..."
    echo ""
}

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
GENOME_INDEX="04_reference/index_genome.dbindex"
TRIMMED_FOLDER="03_trimmed"
RESULT_FOLDER="05_results"
SAMPLE="$1"

if [ -z "$SAMPLE" ]
then
    print_help
    exit
fi 

# Compute methylation level
methcounts -cpg-only -c $GENOME_INDEX -o "$RESULT_FOLDER"/"$SAMPLE".meth \
    "$RESULT_FOLDER"/"$SAMPLE".mr.dremove.sort

# Compute symmetric CpGs contexts
symmetric-cpgs -o "$RESULT_FOLDER"/"$SAMPLE"_CpG.meth \
    "$RESULT_FOLDER"/"$SAMPLE".meth

# Compute methylation stats
levels -o "$RESULT_FOLDER"/"$SAMPLE".levels "$RESULT_FOLDER"/"$SAMPLE".meth

# Compute conversion rate
bsrate -c $GENOME_INDEX -o "$RESULT_FOLDER"/"$SAMPLE".bsrate \
    "$RESULT_FOLDER"/"$SAMPLE".mr.dremove.sort

rm "$RESULT_FOLDER"/"$SAMPLE".mr.dremove.sort

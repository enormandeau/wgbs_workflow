#!/bin/bash

#SBATCH -J "index"
#SBATCH -o 98_log_files/index.out
#SBATCH -c 1
#SBATCH -p large
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yourAddress
#SBATCH --time=20-00:00
#SBATCH --mem=20G

#'usage
#makedb -c <genome folder or file> -o <index file>
#'
# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# Get current time
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)

# Copy script as it was run
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Running the program
#use genome_filtered.fa if removing C-T SNPs from the reference genome 
#("00_scripts/utility_scripts/05_prepare_reference_filter.sh
GENOME="04_reference/genome_filtered.fa"
INDEX="04_reference/index_genome.dbindex"

# Running the program
makedb -c $GENOME -o $INDEX

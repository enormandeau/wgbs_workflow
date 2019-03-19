#!/bin/bash

#SBATCH -J "prepirqnge.__BASE__"
#SBATCH -o 98_log_files/log-prepirange.__BASE__.out
#SBATCH -c 1
#SBATCH -p large
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yourAddress
#SBATCH --time=20-00:00
#SBATCH --mem=2G

# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# Get current time
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)

# Copy script as it was run
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
base=__BASE__

# Prepare file for dss
cat 06_statistics/"$base".dmr.txt | \
    grep -v chr|awk '{print $2"\t"$3"\t"$4"\t""+""\t"$NF}' \
        > 06_statistics/"$base".temp

cat 01_info_files/header_irange.txt 06_statistics/"$base".temp \
    > 06_statistics/"$base".iranges

# Clean up
rm 06_statistics/"$base".*.temp


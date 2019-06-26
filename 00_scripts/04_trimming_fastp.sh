#!/bin/bash

#SBATCH -J TrimClean_fastp
#SBATCH -o 98_log_files/log-trimming.fastp.out
#SBATCH -c 1 
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yourAddress
#SBATCH --time=07-00:00
#SBATCH --mem=10G

# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR 

# Load needed software
module load cutadapt
module load fastqc/0.11.2 

# Get current time
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)

# Copy script as it was run
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
LENGTH=100
QUAL=25
DATA="02_data"
OUTPUT="03_trimmed"

# ls *.fastq.gz | awk -F"R" '{print $1}' | uniq > ../03_info_file/names_databrut

# Running the program
for i in $(ls $DATA/*.fastq.gz | perl -pe 's/_R[12]\.fastq\.gz$/_/' | sort -u)
do
name=$(basename "$i")

  fastp -i "$i"R1.fastq.gz -I "$i"R2.fastq.gz \
        -o $OUTPUT/"$name"trimmed_fastp_R1.fastq.gz \
        -O $OUTPUT/"$name"trimmed_fastp_R2.fastq.gz  \
        --length_required="$LENGTH" \
        --qualified_quality_phred="$QUAL" \
        --correction \
        --trim_tail1=1 \
        --trim_tail2=1 \
        --json $OUTPUT/"$name" \
        --html $OUTPUT/"$name"  \
        --report_title="$name"report.html

done 2>&1 | tee 98_log_files/"$TIMESTAMP"_trim_fastp_wgbs.log

#!/bin/bash
#SBATCH -D ./ 
#SBATCH --job-name="prepare_file_Dss"
#SBATCH -o 98_log_files/prepare_dss.out
#SBATCH -c 1
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=type_your_mail@ulaval.ca
#SBATCH --time=3-00:00
#SBATCH --mem=20G

cd $SLURM_SUBMIT_DIR

# Global variables
DATA_FOLDER="05_results"
#base=__BASE__

SAMPLE="01_info_file/sample_name.txt"

cat "$SAMPLE" | while read i  
do

# prepare file for dss
awk '{print $1,$2,$6}' "$DATA_FOLDER"/"$i"_CpG.meth >"$DATA_FOLDER"/"$i".dss.1.temp
awk '{printf "%.0f\n",$5*$6}' "$DATA_FOLDER"/"$i"_CpG.meth >"$DATA_FOLDER"/"$i".dss.2.temp
paste "$DATA_FOLDER"/"$i".dss.1.temp "$DATA_FOLDER"/"$base".dss.2.temp >"$DATA_FOLDER"/"$i".temp.dss
cat 01_info_files/header.dss "$DATA_FOLDER"/"$i".temp.dss|sed 's/\t/ /g' >"$DATA_FOLDER"/"$i".dss

# clean up
rm "$DATA_FOLDER"/"$i".*.temp
rm "$DATA_FOLDER"/"$i".*temp.dss

done


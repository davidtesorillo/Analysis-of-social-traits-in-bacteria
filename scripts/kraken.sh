#!/bin/sh
# Predict Proteins for each Assembly
#SBATCH --job-name=ID
#SBATCH --mail-type=ALL 
#SBATCH --mail-user=davidtesorillo@hotmail.com 
#SBATCH --nodes=1
# Load modules
module load kraken2/

# Execute
for file in ../MAGs/*.fasta; do
       kraken2 --db /projects/mjolnir1/data/databases/kraken2/kraken2_standard/20220926/ $file --output "${file}_out" --report  "${file}_report" --use-names
done
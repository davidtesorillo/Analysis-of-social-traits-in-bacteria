#!/bin/sh
# Predict Proteins for each Assembly
#SBATCH --job-name=ID
#SBATCH --mail-type=ALL 
#SBATCH --mail-user=davidtesorillo@hotmail.com 
#SBATCH --nodes=1
#SBATCH --time=8:00:00

# Load modules
module load transdecoder/

# Execute
for file in ../MAGs/*.fasta; do
        TransDecoder.LongOrfs -t "$file"; 
        # Default; ORFs of at least 100 amino acids long
        TransDecoder.Predict -t "$file";
done
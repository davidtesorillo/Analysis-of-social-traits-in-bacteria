# Generation of the Metagenome Assembly Genomes

Once we have perform the selection of the 50 samples we continue with the generation of MAGs for each sample. For this purpose we use the online service [PATRIC](https://www.bv-brc.org/). We used the Genome Assembly tool with default options:
- Assembly strategy: Auto
- Trim reads before assembly: True
- Racon iterations: 2
- Pilon iterations: 2
- Min contig length: 300
- Min contig covarage: 5

The MAGs were rename using the following syntax: 
$$patientID\_dayNN\_contigs.fasta$$
where ID correspond to the patient ID and NN to the day the sample was taken. 
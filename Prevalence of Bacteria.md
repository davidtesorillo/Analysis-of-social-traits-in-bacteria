# Prevalence of Bacteria

In our GO analysis we need to know the prevalence of each bacteria in our data set. For this purpose we need to generate a count table where we have the number of reads that map to each contig. 

To generate this table we are going to do the following:
1. Since our initial analysis was done using PATRIC we did not downloaded the data. To get the data, we are going to use the online service [Galaxy](https://usegalaxy.eu/). Specifically, we are going to use **Faster**. Provinding a list of SRA codes (one per line) we can download the fastq files associated to each sample. 
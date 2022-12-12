# Taxonomic Classification

We have generated 50 MAGs from our data set. We need to peform a taxonomic classification for each contig in order to know from which bacteria it came from. To perform this taxonomic classification we are going to use [kraken2](https://ccb.jhu.edu/software/kraken2/). 
The script used for taxonomic classification can be found under [[kraken.sh]]

## Output

### File 1: Output (Kraken wiki)
Each sequence (or sequence pair) classified by Kraken 2 results in a single line of output. Kraken 2's output lines contain five tab-delimited fields; from left to right, they are:
1.  "C"/"U": a one letter code indicating that the sequence was either classified or unclassified.
2.  The sequence ID, obtained from the FASTA/FASTQ header.
3.  The taxonomy ID Kraken 2 used to label the sequence; this is 0 if the sequence is unclassified.
4.  The length of the sequence in bp. In the case of paired read data, this will be a string containing the lengths of the two sequences in bp, separated by a pipe character, e.g. "98|94".
5.  A space-delimited list indicating the LCA mapping of each _k_-mer in the sequence(s). For example, "562:13 561:4 A:31 0:1 562:3" would indicate that:
    -   the first 13 _k_-mers mapped to taxonomy ID #562
    -   the next 4 _k_-mers mapped to taxonomy ID #561
    -   the next 31 _k_-mers contained an ambiguous nucleotide
    -   the next _k_-mer was not in the database
    -   the last 3 _k_-mers mapped to taxonomy ID #562

### File 2: Report

Kraken 2's standard sample report format is tab-delimited with one line per taxon. The fields of the output, from left-to-right, are as follows:
1.  Percentage of fragments covered by the clade rooted at this taxon
2.  Number of fragments covered by the clade rooted at this taxon
3.  Number of fragments assigned directly to this taxon
4.  A rank code, indicating (U)nclassified, (R)oot, (D)omain, (K)ingdom, (P)hylum, (C)lass, (O)rder, (F)amily, (G)enus, or (S)pecies. Taxa that are not at any of these 10 ranks have a rank code that is formed by using the rank code of the closest ancestor rank with a number indicating the distance from that rank. E.g., "G2" is a rank code indicating a taxon is between genus and species and the grandparent taxon is at the genus rank.
5.  NCBI taxonomic ID number
6.  Indented scientific name
# Prevalence of Bacteria

In order to get the prevalence of each bacteria in each sample we are going to use kraken2 directly on the SRA using the online tool PATRIC. This way, we are able to get an estimate of how many reads are assigned to each bacteria. Once we have the report, we can merge the counts to the bacteria we identified in our data-set when doing the taxonomic classification of the contigs. 
Note, since we are using reads for taxonomic classification we loose information and therefore we would need to move to the genus level instead of the species level to avoid loosing too much information.


# GO Analysis

In our previous analysis we generated several files for each sample in each patient. 

1. Pannzer2 (GO file): Here we have a compilation of the predicted peptides for each sample in each patient and their predicted GO hit. 
2. Kraken2
	1. Kraken output: file generated providing the contig files to kraken2. Here we have information of the taxonomic classification for each contig, i.e., each contig is assigned a name.
	2. Kraken report: file that summarises the number of fragments (contigs in this case) assigned to each taxonomic level.
	3. Kraken complete report: file generated providing the SRA to kraken2. Here we have a summary of the number of reads associated to each taxonomic level. Note, this is only an estimate as we are using very short sequences for this taxonomic classification.
4. Json files: python created files from the kraken report used to obtain the genus, family and class name of the species bacteria assigned to each contig (Python dictionary that is used in R scripts assigned a contig classified into a specific bacteria species to the corresponding genus, family and class. This files were individually generated for each sample in each patient from the kraken reports).

In total, we are analysing 49 samples from 5 patients.
- 10 samples from 668.
- 10 samples from 1042.
- 10 samples from 1179.
- 10 samples form 1252.
- 9 samples from FMT.0092.

For each sample we have 1 GO file, 1 kraken output, 1 kraken report, 1 kraken complete report and 3 JSON files. Therefore, we have a total of $49*7=343$ files. 

For our analysis, we create different R scripts. 

## myFunctions.R

Rscript use as a module where all the functions used in our analysis are included. A detailed description can be found in the file.

## loadingdata.R

Rscript use to load the 343 files into the enviornment. 

## GenerateData.R

Rscript that combines the information of the 343 file into one dataframe that is afterwards saved into a txt file. 

In this script, we invoke the different functions we defined in our module `myFunctions.R`. A few comments have to be made about our analysis:

1. The data is read and combine going sample by sample. For each sample we first filter the 7 associated files we generated and we provide these files to our main function (`get.data`). 

The first section, of our analysis we do some filtering of the GO hits. For each sample we use the ARGOT PPV, a normalise value of the ARGOT score that goes from 0 to 1 to select only those hits with a PPV value greater than 0.5. As a result, we remove hits that are possibly spurious, however, we have to note that each peptide in each sample can have more than 1 GO hit associated to it. 

In the second section, we perform a taxonomic assignment for each contig. Using the kraken output file and the JSON files we assign the species, genus, family and class name of each peptide looking at the contig it came from. Therefore, besides the information provided in the Go files, we add 4 more columns which represent the taxonomic classification.

In the third section, we add the prevalence taking the kraken complete report and looking at the previous columns added with the taxonomic name. Note, we loose information here because some bacteria species, genus, family or class detected in the taxonomic analysis using the contigs might not be found in the taxonomic classification using the raw reads, we assign `NA` to these missing data.

In the last section, we remove hits that are non-bacteria using the kraken reports. We extract the non-bacteria species, genus, etc. and remove those from our dataframe.

After performing this analysis on each sample, we combine everything ending up with a big dataframe that compiles the data of the 49 samples. In total we end up with:
-  2,055,351 hits 

However, there is problem in this dataframe. We assigned the species value to the name assigned to the contig in the kraken report, however, some contigs were classified with names from the genus, family, order or other levels different to the species level. Therefore, we do an additional correction, removing all the hits that have assigned a name which is not from the species or genus level. Finally, those hits with genus names assigned were corrected by moving the genus name to the genus column and then also the corresponding prevalence and removing the name from the species column. Although, not many hits are included here, we decided to do this in order to avoid loosing more information as the genus level is not to far high in the taxonomic tree. After this correction, we end up with:
- 2,032,214 hits (-23,137 hits)  - Dataframe called `patients.filt`

The final dataframe, compiles the complete dataset of the 49 samples. The next step, was to filter out social hits. For this, we have a dataframe that compiles all the GO hits associated to social traits. We filter using the GO ID and also save the information into a txt file.

## Analysis

Before continuing our analysis, we need to do one more "correction". As we mentioned before, each peptide can have not one but several GO hits associated to it which can either be from the same GO class or from different ones. This is important in our social analysis, because in some GO hits the MF (Molecular Function) GO class might not be classified as social but the BP (Biological Process) associated to the peptide might be. So, we might be interested in counting that peptide (and the corresponding bacteria) as social. 

What we want to have is for each peptide up to 3 GO hits (1 for each GO class) and the hit should have the highest social score. 

Taking our initial dataframe `patient.filt` we do this "filtering". We separate the data into the 3 GO classes and then take the hit with the highest ARGOT score for each peptide. This way we reduce the data from 2,055,351 hits to 1,258,741 hits (Dataframe name `patients.GO`)

Afterwards, we filter out to extract the social hits ending up with 5,046 social hits. ==This number is different from the dataframe obtained previously 5,738 because there we included the whole dataset, which one is better?==

#### Some Summary
| Information                     | Total dataset | Social dataset |
| ------------------------------- | ------------- | -------------- |
| Total hits                      | ==1,258,741==     |==5,046==          |
| Unique peptides                 | 683,959       | 4,364          |
| Unique GO IDs                   | 3,231         | 34             |
| Hits Missing Species Prevalence | 420,909       | 1,236          |
| Hits Missing Genus Prevalence   | 120,246       | 270            |
| Hits Missing Family Prevalence  | 821           | 0              |
| Hits Missing Class Prevalence   | 25,831        | 83             |


The  filtering we do is to try to end up with GO hits that we can trust. 

## How similar are the patients?

Taking our data (Dataframe `patients.GO` with 1,258,741 hits) we compile a summary table where we have:
- PatientID
- TimePoint
- Species, Genus, Family, Class and their prevalence
- Is social or not category

Once we have our table, we analysed the diversity, i.e., how many unique different bacterias we have in each sample per patient. To analyse this, we just count the number of unique species name in each Patient and sample. We obtained the following plot:
![[Diversity_per_sample.png]]
In the previous plot, we can observe that the general tendency is that at the beginning (before the transplantation) we have a higher diversity (more number of different bacterias), however, it decreases in the middle samples (the next few days after the transplantation) and then it recovers a bit towards the end (when a few weeks have pass since the transplantation.)

It is also interesting to see how the diversity changes for social bacterias
![[Social_diversity_per_sample.png]]
In the previous plot, we have the same thing as before, but in this case we have in a bolder color the number of counts that correspond to social bacteria. 

How does this correlate with the number of total counts (reads) ?


library (tidyverse)
library(jsonlite)

path <- "/Users/david/Desktop/PUK/Patients/."

folders <- list.dirs(path , full.names = TRUE, recursive = TRUE)
go.folders <- folders[str_detect(folders, "GO")]
kraken.folders <-
  folders[str_detect(folders, "kraken") &
            str_detect(folders, "complete") == FALSE]

################### Load Pannzer output with GO hits  ###############
# Load GO data
for (d in go.folders) {
  go.files <- list.files(d)
  for (filename in go.files) {
    filepath <- file.path(d, filename)
    assign(paste (c("Patient", filename),  collapse = ""), read.csv(filepath,
                                                                    sep = "\t"))
    assign (paste (c("Patient", filename),  collapse = ""),
            eval(parse(text = paste (
              c("Patient", filename),  collapse = ""
            ))) %>%
              mutate (IDs = filename) %>% relocate (IDs))
  }
}

################### Load kraken output ##############################

for (d in kraken.folders) {
  ## KRAKEN OUTPUT
  kraken.files <-
    list.files(path = d, pattern = "_out")
  for (file in 1:length(kraken.files)) {
    filepath <- file.path(d, kraken.files[file])
    assign(kraken.files[file], read.csv(filepath,
                                        sep = "\t", header = F))
    assign(kraken.files[file], eval(parse(text = kraken.files[file])) %>% select(2:3))
  }
  ## KRAKEN REPORT
  kraken.report <-
    list.files(path = d, pattern = "_report")
  for (file in 1:length(kraken.report)) {
    filepath <- file.path(d, kraken.report[file])
    assign(kraken.report[file], read.csv(filepath, sep = "\t", header = F))
  }
}

# KRAKEN COMPLETE FROM RAW READS
path2 <- "../../../Patients/kraken_complete/"
prevalence.kraken <- list.files(path2, pattern = "report")

for (f in prevalence.kraken) {
  filepath <- file.path(path2, f)
  assign(f, read.csv(filepath,
                     sep = "\t", header = F))
}

################### Load JSON files #################################

# Json files to return class name
path3 <- "../../../Patients/kraken_complete/json_files/"
json.files <-
  list.files(path = path3, pattern = ".json")
for (i in 1:length(json.files)) {
  filepath <- file.path(path3, json.files[i])
  assign(json.files[i], read_json(filepath,
                                  simplifyVector = TRUE)) # Read files
}

# Json files to return genus name
path4 <- "../../../Patients/kraken_complete/json_files/genus/"
genus.json.files <-
  list.files(path = path4, pattern = "genus")
for (i in 1:length(genus.json.files)) {
  filepath <- file.path(path4, genus.json.files[i])
  assign(genus.json.files[i],
         read_json(filepath,
                   simplifyVector = TRUE)) # Read files
}

# Json files to return family name
path5 <- "../../../Patients/kraken_complete/json_files/family/"
family.json.files <-
  list.files(path = path5, pattern = "family")
for (i in 1:length(family.json.files)) {
  filepath <- file.path(path5, family.json.files[i])
  assign(family.json.files[i],
         read_json(filepath,
                   simplifyVector = TRUE)) # Read files
}

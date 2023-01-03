# Load libraries
library(tidyverse)
library(jsonlite)
library(readxl)

# Function -  filter.data.by.PPV ##############################################
# For each sample we have a pannzer output file which has the GO terms        #
# predicted for each peptide. We do an initial filtering selecting only those #
# GO terms with a PPV value greater than 0.5                                  #
filter.data.by.PPV <- function (x) {
  # X is a df
  x.filt <- x %>%
    filter(ARGOT_PPV > 0.5) %>%
    mutate (PatientID = str_extract(IDs, "^[0-9A-Z.]*")) %>%
    mutate (TimePoint = as.numeric (gsub ("_", "-", gsub(
      "day", "", str_extract(IDs, "day[_]*[0-9]+")
    )))) %>%
    relocate(TimePoint) %>%
    relocate (PatientID)  %>%
    select(-IDs)
  return (x.filt)
}

# Function - species.name #####################################################
# For each sample we have a kraken output file that contains the taxonomic    #
# name of the species assign to each contig. We update the data df with this  #
species.name <- function(data, kraken) {
  # data and kraken are dfs
  data.temp <- data %>%
    mutate(species = gsub("p[0-9]+", "", qpid))
  kraken.temp <- kraken %>%
    mutate(V2 = apply(., 1, function(row)
      paste(c(row[1], "."), collapse = "")))
  
  vector <- kraken.temp$V3
  names(vector) <- kraken.temp$V2
  
  data.temp$species <- vector[data.temp$species]
  data.temp <- data.temp %>%
    mutate (species = gsub (" \\(taxid [0-9]+\\)", "", species))
  return (data.temp)
}

# Function - species.genus ####################################################
# For each sample we have a json file that has the name of a bacteria genus   #
# and then a list of the species name inside that class (dictionary format of #
# python). We use this to append the species class name to each contig        #
species.genus <- function(data, json) {
  # data is a df and json is a json file
  # loaded  using jsonlite library
  vector <- unlist(json)
  
  get.genus <- function(x) {
    bact.name <- names(vector)[vector == x[11]]
    bact.name <- gsub("[0-9]+", "", bact.name)
    bact.name <- unique (bact.name)
    
    if (length (bact.name) == 0) {
      bact.name <- "NaN"
    }
    return(bact.name)
  }
  
  
  apply(data, 1, get.genus) -> bacteria.genus
  data$species.genus <- bacteria.genus
  
  return(data)
}

# Function - species.family ####################################################
# For each sample we have a json file that has the name of a bacteria family   #
# and then a list of the species name inside that class (dictionary format of #
# python). We use this to append the species class name to each contig        #
species.family <- function(data, json) {
  # data is a df and json is a json file
  # loaded  using jsonlite library
  vector <- unlist(json)
  
  get.family <- function(x) {
    bact.name <- names(vector)[vector == x[11]]
    bact.name <- gsub("[0-9]+", "", bact.name)
    bact.name <- unique (bact.name)
    
    if (length (bact.name) == 0) {
      bact.name <- "NaN"
    }
    return(bact.name)
  }
  
  
  apply(data, 1, get.family) -> bacteria.family
  data$species.family <- bacteria.family
  
  return(data)
}



# Function - species.class ####################################################
# For each sample we have a json file that has the name of a bacteria class   #
# and then a list of the species name inside that class (dictionary format of #
# python). We use this to append the species class name to each contig        #
species.class <- function(data, json) {
  # data is a df and json is a json file
  # loaded  using jsonlite library
  vector <- unlist(json)
  get.classes <- function(x) {
    bact.name <- names(vector)[vector == x[11]]
    bact.name <- gsub("[0-9]+", "", bact.name)
    bact.name <- unique (bact.name)
    
    if (length (bact.name) == 0) {
      bact.name <- "NaN"
    }
    return(bact.name)
  }
  
  
  apply(data, 1, get.classes) -> bacteria.class
  data$species.class <- bacteria.class
  
  return(data)
}



# Function - species.prevalence ###############################################
# To be updated                                                               #

species.prevalence <- function(data, report) {
  data.temp <- data %>%
    mutate(species.covarage = species)
  
  vector <- trimws(report$V6)
  names(vector) <- report$V2
  
  unlist(apply (data.temp, 1, function(x)
    ifelse (
      length (which (vector == x[length(x)])) > 0,
      as.numeric(names(which (vector == x[length(x)]))), NA
    ))) -> covarage
  
  data.temp$species.covarage <- covarage
  return(data.temp)
}

# Function - genus.prevalence #################################################
# To be updated                                                               #
genus.prevalence <- function(data, report) {
  data.temp <- data %>%
    mutate(genus.covarage = species.genus)
  
  vector <- trimws(report$V6)
  names(vector) <- report$V2
  
  unlist(apply (data.temp, 1, function(x)
    ifelse (
      length (which (vector == x[length(x)])) == 1,
      as.numeric(names(which (vector == x[length(x)]))), NA
    ))) -> covarage
  
  data.temp$genus.covarage <- covarage
  return(data.temp)
}

# Function - family.prevalence #################################################
# To be updated                                                               #
family.prevalence <- function(data, report) {
  data.temp <- data %>%
    mutate(family.covarage = species.family)
  
  vector <- trimws(report$V6)
  names(vector) <- report$V2
  
  unlist(apply (data.temp, 1, function(x)
    ifelse (
      length (which (vector == x[length(x)])) == 1,
      as.numeric(names(which (vector == x[length(x)]))), NA
    ))) -> covarage
  
  data.temp$family.covarage <- covarage
  return(data.temp)
}



# Function - class.prevalence #################################################
# To be updated                                                               #
class.prevalence <- function(data, report) {
  data.temp <- data %>%
    mutate(class.covarage = species.class)
  
  vector <- trimws(report$V6)
  names(vector) <- report$V2
  
  unlist(apply (data.temp, 1, function(x)
    ifelse (
      length (which (vector == x[length(x)])) == 1,
      as.numeric(names(which (vector == x[length(x)]))), NA
    ))) -> covarage
  
  data.temp$class.covarage <- covarage
  return(data.temp)
}


# Function - remove.non.bacteria.data #########################################
# Quality control on the data to remove anything associated to non-bacteria   #
# data. This is done after the species name is included                       #
remove.non.bacteria.data <- function(data, report) {
  cut_off_pos <-
    c(
      which (trimws(report$V6) == "Viruses"),
      which (trimws(report$V6) == "Archaea"),
      which (trimws(report$V6) == "Eukaryota")
    )
  
  if (length(cut_off_pos) != 0) {
    template <- report[min(cut_off_pos):length(report$V1), ]
    
    data <- data %>%
      filter(!species %in% trimws(template$V6))
    return (data)
  } else{
    return (data)
  }
}


# Function - get.data  ########################################################
# Main function that for each sample combine the pannzer output with the      #
# taxonomic classification of each contig (species and class)                 #
# it also includes the prevalence (TBU)                                       #
get.data <-
  function(sample,
           kraken,
           report,
           complete_report,
           json,
           genus.json,
           family.json) {
    ## Main function to generate the data
    # Filter data
    sample.filt <- filter.data.by.PPV(sample)
    
    # Update data with bacteria species name
    sample.filt <- species.name(sample.filt, kraken)
    # Update data with bacteria genus name
    sample.filt <- species.genus(sample.filt, genus.json)
    # Update data with bacteria family name
    sample.filt <- species.family(sample.filt, family.json)
    # Update data with bacteria classes name
    sample.filt <- species.class(sample.filt, json)
    
    
    # Update data with bacteria covarage
    sample.filt <- species.prevalence(sample.filt, complete_report)
    # Update data with bacteria genus covarage
    sample.filt <- genus.prevalence(sample.filt, complete_report)
    # Update data with bacteria family covarage
    sample.filt <- family.prevalence(sample.filt, complete_report)
    # Update data with bacteria classes covarage
    sample.filt <- class.prevalence(sample.filt, complete_report)
    
    
    # Remove Non-bacteria rows
    sample.filt <- remove.non.bacteria.data(sample.filt, report)
    
    return (sample.filt)
  }


# Function - social.go.hits ###################################################
# Returns a df with the Social GO terms                                       #
social.go.hits <- function() {
  # Function that return a df with the
  # social go terms
  multiplesheets <- function(fname) {
    # getting info about all excel sheets
    sheets <- excel_sheets(fname)
    tibble <-
      lapply(sheets, function(x)
        read_excel(
          fname,
          sheet = x,
          col_names = TRUE,
          skip = 2
        ))
    data_frame <- lapply(tibble, as.data.frame)
    # assigning names to data frames
    names(data_frame) <- sheets
    return(data_frame)
  }
  path <-
    "/Users/david/Desktop/PUK/PUK Vault/Github Repository/data/pnas.2016046118.sd01.xlsx"
  multiplesheets(path) -> excel.sheets
  excel.sheets$SI6_final_GO_terms_list %>%
    mutate(goid = as.numeric(gsub("\\D", "", GO_id))) -> go.hits
  return(go.hits)
}


filter.GO.classes.by.Argot <- function (df) {
  df.filt <- df %>%
    group_by(qpid) %>%
    filter(ARGOT_score == max(ARGOT_score)) %>%
    as.data.frame()
  return (df.filt)
}

# Load required libraries
library (tidyverse)

# Complete data-set
samples <- read.csv("../data/samples.csv")

# Filter data to get only
# samples with Shot-gun data
samples.filt <- samples %>% 
  filter(AccessionShotgun != "") 

# Selection of the patients
samples.filt %>% 
  group_by(PatientID) %>% 
  summarise(N.Samples = length(SampleID)) %>% 
  arrange(-N.Samples) %>% 
  filter (N.Samples > 5) -> patients.to.consider

# Functions
get.patient.info <- function(df, ID){
  # Get data with the PatientID == ID
  data <- df %>% 
    filter(PatientID == ID)  %>% 
    arrange (DayRelativeToNearestHCT) %>% 
    select(c(SampleID, PatientID, DayRelativeToNearestHCT, AccessionShotgun))
}

get.10.samples <- function(df){
  # Selection of 10 samples
  step <- round(length(df$SampleID)/10)
  positions <- seq(from=1, to=length(df$SampleID), by =step)[1:10]
  return (df[positions, ] )
}

write.into.file <- function (df, name){
  # Save data into a file
  newname <- paste (c("../data/", name), collapse="")
  write.table(
    df,
    row.names = F,
    col.names = F,
    file = newname,
    quote = F
  )
}

# Save data
for (ID in patients.to.consider$PatientID[1:5]){
  data <- get.patient.info (samples.filt, ID)
  data.samples <- get.10.samples (data)
  write.into.file(data.samples, paste (c("Patient", ID, "_samples.txt"), collapse=""))
}
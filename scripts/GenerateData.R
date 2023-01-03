library (tidyverse)

# Combine data
patients.filt <- data.frame()

for (patient in go.folders) {
  go.files <- list.files(patient)
  kraken.files <-
    str_extract(
      list.files(path, recursive = T, pattern = "out"),
      "patient[0-9A-Z.]+_day[_0-9]+_out"
    )
  kraken.report <-
    unique (str_extract(
      list.files(path, recursive = T, pattern = "report"),
      "patient[0-9A-Z.]+_day[_0-9]+_report"
    ))
  
  for (sample in 1:length(go.files)) {
    go <- paste (c("Patient", go.files[sample]), collapse = "")
    patientcode <- str_extract(go.files[sample], "^[0-9A-Z.]+")
    daycode <- str_extract(go.files[sample], "day[_0-9]+")
    kraken <-
      kraken.files[str_detect(kraken.files, paste(c(daycode, "_"), collapse = "")) &
                     str_detect(kraken.files, paste(c("t", patientcode, "_"), collapse = ""))][1]
    report <-
      kraken.report[str_detect(kraken.report, paste(c(daycode, "_"), collapse = "")) &
                      str_detect(kraken.report, paste(c("t", patientcode, "_"), collapse = ""))][1]
    
    complete.report <-
      prevalence.kraken[str_detect(prevalence.kraken, paste(c(daycode, "_"), collapse = "")) &
                          str_detect(prevalence.kraken, paste(c("t", patientcode, "_"), collapse = ""))]
    json <-
      json.files [str_detect(json.files, paste(c(daycode, "_"), collapse = "")) &
                    str_detect(json.files, paste(c("t", patientcode, "_"), collapse = ""))]
    genus.json <-
      genus.json.files [str_detect(genus.json.files, paste(c(daycode, "_"), collapse = "")) &
                          str_detect(genus.json.files, paste(c("t", patientcode, "_"), collapse = ""))]
    
    family.json <-
      family.json.files [str_detect(family.json.files, paste(c(daycode, "_"), collapse = "")) &
                           str_detect(family.json.files, paste(c("t", patientcode, "_"), collapse = ""))]
    
    patients.filt <-
      rbind(patients.filt,
            get.data(
              eval(parse(text = go)),
              eval(parse(text =
                           kraken)),
              eval(parse(text = report)),
              eval(parse(text =
                           complete.report)),
              eval(parse(text = json)),
              eval(parse(text = genus.json)),
              eval(parse(text = family.json))
            ))
  }
  
}


# Correction
# Remove contigs that do not have species or genus names assigned
# Besides, remove everything that is unclassified 
taxonomic.group <- c("U", "R", "D", "K", "P", "C", "O", "F")
genus.to.save <- data.frame()
groups.to.remove <- data.frame()

for (file in  kraken.report[!is.na (kraken.report)]) {
  for (group in taxonomic.group) {
    save <- eval(parse(text = file)) %>% filter (str_detect (V4, group))
    groups.to.remove <- rbind(groups.to.remove, save)
  }
  
  save <-
    eval(parse(text = file)) %>% filter (str_detect (V4, "G"))
  genus.to.save <- rbind(genus.to.save, save)
}

groups.to.remove %>%
  select (c(V4, V6)) %>%
  mutate (group = trimws(V6)) %>%
  distinct() -> groups.to.remove

genus.to.save %>%
  filter (!str_detect(V4, "1")) %>% 
  select (c(V4, V6)) %>%
  mutate (group = trimws(V6)) %>%
  distinct() -> genus.to.save

patients.filt %>%
  mutate (species.genus = ifelse(species %in% genus.to.save$group,
                                 species,
                                 species.genus)) %>%
  filter (!species %in% groups.to.remove$group) %>%
  filter (!str_detect(species, "unclassified")) -> patients.filt.2

patients.filt.2 %>%
  mutate (genus.covarage = ifelse(species == species.genus, species.covarage, genus.covarage)) %>% 
  mutate (species = ifelse(species == species.genus, NA, species)) %>% 
  mutate (species.covarage= ifelse(species == species.genus, NA, species.covarage))-> patients.filt.2


# Before filtering: 2,055,351 hits
# After filtering: 2,032,214 (-23,137 hits)

write.table(
  patients.filt.2,
  "../data/Data_5_Patients.txt",
  quote = F,
  sep = "\t",
  row.names = F,
  col.names = T
)

### Social data
GO.Social <- social.go.hits()
patients.social <- patients.filt.2 %>% filter (goid %in% GO.Social$goid)

write.table(
  patients.social,
  "../data/Data_5_Patients_Social.txt",
  quote = F,
  sep = "\t",
  row.names = F,
  col.names = T
)

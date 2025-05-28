
library(tidyverse)

datadir <- "../Data/Pulse_Survey"

zipped_files <- sort(list.files(datadir, pattern = "\\.zip"))

for(i in 1:length(zipped_files)) {
  curr_zip <- zipped_files[i]
  print(paste(curr_zip, i, "/", length(zipped_files)))
  
  outdir <- substr(curr_zip, 1, str_length(curr_zip) - 4)
  outdir <- file.path(datadir, outdir)
  if (!dir.exists(outdir)) {
    dir.create(outdir)
    curr_zip_fp <- file.path(datadir, curr_zip)
    unzip(curr_zip_fp, exdir = outdir)
  }
}

print("DONE")


unzipped_dirs <- list.dirs(path = datadir, recursive = FALSE)

mi_energy_resps <- data.frame()

for (i in 1:length(unzipped_dirs)) {
  curr_dir <- unzipped_dirs[i]
  print(curr_dir)
  
  survey_filename <- list.files(path = curr_dir, pattern = "pulse[0-9]{4}_puf_[0-9]{2}\\.csv")[1]
  curr_survey <- read.csv(file.path(curr_dir, survey_filename))
  
  if ("ENERGY" %in% colnames(curr_survey)) {
    curr_survey <- curr_survey %>%
      filter(EST_ST == 26) %>%
      select(SCRAM, WEEK, HWEIGHT, PWEIGHT, ENERGY, HSE_TEMP, ENRGY_BILL)
    
    mi_energy_resps <- mi_energy_resps %>%
      bind_rows(curr_survey)
  }
}

write.csv(mi_energy_resps, file.path(outdir, "mi_energy_resps.csv"), row.names = FALSE)


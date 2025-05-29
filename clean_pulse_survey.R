
# Libraries=====================================================================
library(tidyverse)
library(readxl)
library(janitor)

# Helper functions==============================================================
source("create_pulse_survey_metadata.R")
source("extract_data.R")

# Directory structure===========================================================
outdir <- "../../Data/Pulse_Survey/Database"

pulse_survey_dir <- "../../Data/Pulse_Survey/Data_tables"
pulse_survey_files <- list.files(pulse_survey_dir, pattern = "^pulse_survey", full.names = TRUE, recursive = TRUE)

# Data cleaning=================================================================

# Create metadata tables from first pulse survey file
metadata <- create_pulse_survey_metadata(pulse_survey_files[1])

write.table(
  metadata$geographic_areas,
  file = file.path(outdir, "geographic_areas.csv"),
  sep = ",",
  row.names = FALSE,
  col.names = FALSE
)

write.table(
  metadata$questions,
  file = file.path(outdir, "questions.csv"),
  sep = ",",
  row.names = FALSE
)

write.table(
  metadata$responses,
  file = file.path(outdir, "responses.csv"),
  sep = ",",
  row.names = FALSE
)

write.table(
  metadata$demo_groups,
  file = file.path(outdir, "demo_groups.csv"),
  sep = ",",
  row.names = FALSE,
  col.names = FALSE
)

pulse_survey_db <- data.frame()

pulse_survey_files <- pulse_survey_files[1:8]

for (curr_file in pulse_survey_files) {
  print(paste0("Processing...", curr_file))
  
  # Only grab the relevant sheets (ie US, AL, AZ, DC, FL, GA, etc)
  relevant_sheets <- excel_sheets(curr_file)
  relevant_sheets <- relevant_sheets[grepl("^[A-Z]{2}$", relevant_sheets)]
  
  # Iterate and read all relevant sheets and clean
  for (curr_sheet in relevant_sheets) {
    print(paste0("Processing sheet...", curr_sheet))
    curr_df <- extract_data(curr_file, curr_sheet, metadata)
    pulse_survey_db <- pulse_survey_db %>%
      bind_rows(curr_df)
  }
}

write.csv(
  pulse_survey_db,
  file.path(outdir, "pulse_survey_db_2021.csv"),
  row.names = FALSE
)

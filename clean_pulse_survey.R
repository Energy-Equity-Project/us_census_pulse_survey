
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

write.csv(
  metadata$geographic_areas,
  file.path(outdir, "geographic_areas.csv"),
  row.names = FALSE
)

write.csv(
  metadata$questions,
  file.path(outdir, "questions.csv"),
  row.names = FALSE
)

write.csv(
  metadata$responses,
  file.path(outdir, "responses.csv"),
  row.names = FALSE
)

write.csv(
  metadata$demo_groups,
  file.path(outdir, "demo_groups"),
  row.names = FALSE
)

totals <- data.frame()
disagregated_data <- data.frame()

pulse_survey_files <- pulse_survey_files[1:8]

for (curr_file in pulse_survey_files) {
  print(paste0("Processing...", curr_file))
  
  # Only grab the relevant sheets (ie US, AL, AZ, DC, FL, GA, etc)
  relevant_sheets <- excel_sheets(curr_file)
  relevant_sheets <- relevant_sheets[grepl("^[A-Z]{2}$", relevant_sheets)]
  
  # Iterate and read all relevant sheets and clean
  for (curr_sheet in relevant_sheets) {
    print(paste0("Processing sheet...", curr_sheet))
    curr_dfs <- extract_data(curr_file, curr_sheet, metadata)
    totals <- totals %>%
      bind_rows(curr_dfs$totals)
    
    disagregated_data <- disagregated_data %>%
      bind_rows(curr_dfs$disagregated_data)
  }
}

write.csv(
  totals,
  file.path(outdir, "totals_2021.csv"),
  row.names = FALSE
)

write.csv(
  disagregated_data,
  file.path(outdir, "disagregated_data_2021.csv"),
  row.names = FALSE
)


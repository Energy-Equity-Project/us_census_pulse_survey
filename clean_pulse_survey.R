
# Libraries=====================================================================
library(tidyverse)
library(readxl)
library(janitor)

# Helper functions==============================================================
source("create_pulse_survey_metadata.R")

# Directory structure===========================================================
pulse_survey_dir <- "../../Data/Pulse_Survey/Data_tables"
pulse_survey_files <- list.files(pulse_survey_dir, pattern = "^pulse_survey", full.names = TRUE, recursive = TRUE)

# Data cleaning=================================================================

# Create metadata tables from first pulse survey file
metadata <- create_pulse_survey_metadata(pulse_survey_files[1])

for (curr_file in pulse_survey_files) {
  
  # Only grab the relevant sheets (ie US, AL, AZ, DC, FL, GA, etc)
  relevant_sheets <- excel_sheets(curr_file)
  relevant_sheets <- relevant_sheets[grepl("^[A-Z]{2}$", relevant_sheets)]
  
  # Iterate and read all relevant sheets and clean
  for (curr_sheet in relevant_sheets) {
    dfs <- extract_data(fp, curr_sheet, metadata)
  }
}



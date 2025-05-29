
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



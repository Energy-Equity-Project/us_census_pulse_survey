
# Libraries=====================================================================
library(tidyverse)
library(readxl)
library(janitor)

# Function: Extracts data responses from each sheet (US, states, metro area) in the pulse survey spreadsheets
extract_data <- function(fp, sheet_name, metadata) {
  
  # Create question response expanded table
  question_response_df <- metadata$question_metadata %>%
    select(question_short_name) %>%
    expand_grid(
      metadata$response_metadata %>%
        select(response_short_name)
    )
  
  # Read the data portion of the sheet
  totals <- data.frame(
    demo_category = "total",
    demo_option = "total",
    value = unname(unlist(read_excel(fp, sheet = sheet_name, range = "C8:Q8", col_names = FALSE)))
  ) %>%
    cbind(
      question_response_df
    )
  
  return(list(
    totals = totals
  ))
}
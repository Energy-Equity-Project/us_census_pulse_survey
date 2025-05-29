
# Libraries=====================================================================
library(tidyverse)
library(readxl)
library(janitor)

# Function: Extracts data responses from each sheet (US, states, metro area) in the pulse survey spreadsheets
extract_data <- function(fp, sheet_name, metadata) {
  
  # Extract survey metadata from first sheet
  us_sheet <- read_excel(fp, sheet = "US", col_names = FALSE, n_max = 4)
  
  # Parse metadata about table name and number
  title_text <- us_sheet[[1, 1]]
  source_text <- us_sheet[[2, 1]]
  
  table_number <- str_extract(title_text, "Housing Table (\\d+)", group = 1) %>% as.numeric()
  table_name <- str_extract(title_text, "Table \\d+\\. ([^,]+)", group = 1)
  
  # Extract cycle/week information - handle both "Cycle XX" and "Week XX" patterns
  cycle_match <- str_extract(source_text, "(Cycle|Week) (\\d+)", group = 2)
  cycle_type <- case_when(
    str_detect(source_text, "Cycle \\d+") ~ "cycle",
    str_detect(source_text, "Week \\d+") ~ "week",
    TRUE ~ "unknown"
  )
  cycle_number <- cycle_match
  
  # Create question response expanded table
  question_response_df <- metadata$questions %>%
    select(question_id) %>%
    expand_grid(
      metadata$responses %>%
        select(response_id)
    ) %>%
    mutate(question_response_id = paste0(question_id, "_", response_id))
  
  # Total responses by question (no disagregation)
  totals <- data.frame(
    demo_category = "total",
    demo_option = "total",
    value = unname(unlist(read_excel(fp, sheet = sheet_name, range = "C8:Q8", col_names = FALSE)))
  ) %>%
    # Add question and response data
    cbind(
      question_response_df %>%
        select(-question_response_id)
    ) %>%
    # Add geographic area data
    cbind(
      metadata$geographic_areas %>%
        filter(geo_code == sheet_name) %>%
        select(geo_id) %>%
        distinct()
    ) %>%
    # Add table cycle type (week/cycle) and number
    mutate(
      cycle_type = cycle_type,
      cycle_number_number = cycle_number
    )
  
  # Extract disagregated data
  disagregated_data <- read_excel(fp, sheet = sheet_name, range = "C9:Q200", col_names = FALSE) %>%
    drop_na()
  
  # Add question and response id as column names for identification
  colnames(disagregated_data) <- question_response_df$question_response_id
  
  disagregated_data <- disagregated_data %>%
    mutate(across(everything(), as.numeric)) %>%
    # Add demographic data
    cbind(
      metadata$demo_groups %>%
        select(demo_id)
    ) %>%
    # restructure dataframe for final database format
    pivot_longer(
      -c(demo_id),
      names_to = "question_response_id",
      values_to = "value"
    ) %>%
    mutate(value = as.numeric(value)) %>%
    # These are not NAs anymore they are true 0s
    replace_na(list(value = 0)) %>%
    # Add geographic area data
    cbind(
      metadata$geographic_areas %>%
        filter(geo_code == sheet_name) %>%
        select(geo_id) %>%
        distinct()
    ) %>%
    # Separate between question and response id
    separate(question_response_id, into = c("question_id", "response_id"), sep = "_") %>%
    mutate(question_id = as.numeric(question_id),
           response_id = as.numeric(response_id)) %>%
    # Add table cycle type (week/cycle) and number
    mutate(
      cycle_type = cycle_type,
      cycle_number_number = cycle_number
    )
  
  df <- totals %>%
    bind_rows(disagregated_data) %>%
    # reorganize column order
    select(cycle_type, cycle_number, geo_id, demo_id, question_id, response_id, value)
  
  return(df)
}
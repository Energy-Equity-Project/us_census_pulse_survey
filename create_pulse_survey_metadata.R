
# Libraries=====================================================================
library(tidyverse)
library(readxl)
library(janitor)
library(tidycensus)

# Function: Creates metadata tables from one of the pulse survey spreadsheets
create_pulse_survey_metadata <- function(fp) {
  
  # Get all sheet names
  sheet_names <- excel_sheets(fp)
  
  # GEOGRAPHIC AREAS metadata table
  geographic_areas <- data.frame(
    geo_id = seq_along(sheet_names),
    geo_code = sheet_names,
    geo_name = case_when(
      sheet_names == "US" ~ "United States",
      sheet_names == "DC" ~ "Washington D.C.",
      nchar(sheet_names) == 2 ~ paste(state.name[match(sheet_names, state.abb)]),
      str_detect(sheet_names, "Metro_Area") ~ str_replace_all(sheet_names, "_", " "),
      TRUE ~ sheet_names
    ),
    geo_type = case_when(
      sheet_names == "US" ~ "country",
      nchar(sheet_names) == 2 | sheet_names == "DC" ~ "state",
      str_detect(sheet_names, "Metro_Area") ~ "metro_area",
      TRUE ~ "other"
    )
  ) %>%
    # Adding FIPS codes for each state
    left_join(
      fips_codes %>%
        select(state, fips_code = state_code) %>%
        distinct(),
      by = c("geo_code"="state")
    ) %>%
    mutate(fips_code = as.character(fips_code)) %>%
    mutate(fips_code = case_when(
      is.na(fips_code) ~ "NA",
      TRUE ~ fips_code
    ))
  
  # QUESTIONS metadata table
  # Read row to get list of questions
  questions <- read_excel(fp, sheet = "US", range = "C5:Q5", col_names = FALSE)
  
  question_metadata <- data.frame(
    question = unname(unlist(questions[1, ]))
  ) %>%
    distinct() %>%
    # Create shortcodes for easy reference
    mutate(
      question_short_name = case_when(
        str_detect(question, "reduced or forwent expenses") ~ "reduced_expenses_energy",
        str_detect(question, "kept home at a temperature") ~ "unsafe_temperature",
        str_detect(question, "unable to pay an energy bill") ~ "unable_pay_energy",
        TRUE ~ paste0("category_", row_number())
      )
    ) %>%
    mutate(question_id = row_number()) %>%
    # reorganize column order
    select(question_id, question, question_short_name)
  
  # RESPONSES metadata table
  # Read row to get responses
  responses <- read_excel(fp, sheet = "US", range = "C6:Q6", col_names = FALSE)
  response_metadata <- data.frame(
    response = unname(unlist(responses[1, ]))
  ) %>%
    distinct() %>%
    # Create short codes for easy reference
    mutate(
      response_short_name = case_when(
        response == "Almost every month" ~ "almost_monthly",
        response == "Some months" ~ "some_months",
        response == "1 or two months" ~ "one_two_months",
        response == "Never" ~ "never",
        response == "Did not report" ~ "no_report",
        TRUE ~ "other"
      ),
      response_id = row_number()
    ) %>%
    # reorganize column order
    select(response_id, response, response_short_name)
  
  # DEMOGRAPHIC metadata
  # (note: not all years and cycles have the same set of demographic groups)
  demo_metadata <- read_excel(fp, sheet = "US", range = "A9:B200", col_names = FALSE) %>%
    clean_names() %>%
    rename(demo_option = x1,
           demo_category = x2) %>%
    filter(!is.na(demo_option) &
             !str_detect(demo_option, "^\\*")) %>%
    mutate(demo_category = as.character(demo_category)) %>%
    mutate(demo_category = case_when(
      is.na(demo_category) ~ demo_option,
      str_detect(demo_category, "^[0-9]+$") ~ NA,
      TRUE ~ "error"
    )) %>%
    fill(demo_category, .direction = "down") %>%
    filter(demo_option != demo_category) %>%
    mutate(demo_id = row_number()) %>%
    bind_rows(
      data.frame(
        demo_option = c("total"),
        demo_category = c("total"),
        demo_id = 0
      )
    ) %>%
    # reorganizing column order
    select(demo_id, demo_option, demo_category)
  
  return(list(
    geographic_areas = geographic_areas,
    questions = question_metadata,
    responses = response_metadata,
    demo_groups = demo_metadata
  ))
}

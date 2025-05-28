
library(tidyverse)
library(readxl)


datadir <- "../Data/Pulse_Survey/HPS_Week63_PUF_CSV"

pulse_survey_raw <- read.csv(file.path(datadir, "pulse2023_puf_63.csv"))
other <- read.csv(file.path(datadir, "pulse2023_repwgt_puf_63.csv"))

mi <- df %>%
  filter(EST_ST == 26)

# Notes:
  # HWEIGHT: multiply responses by HWEIGHT to get the corresponding number of
  #          households that would have given this response
  # PWEIGHT: multiple responses by PWEIGHT to get the corresponding number of
  #          people that would have given this response

# Estimated total population = 7,735,119 (estimated responses)
est_total_pop <- sum(mi$PWEIGHT)

# ENERGY:
  # In the last 12 months, how many months did your household reduce or forego
  # expenses for basic household necessities, such as medicine or food, in order
  # to pay an energy bill?

  # 1) Almost every month - 8.63%
  # 2) Some months - 9.95%
  # 3) 1 or 2 months - 7.25%
  # 4) Never - 52.8%
  # -99) Question seen but category not selected - 0.7%
  # -88) Missing / Did not report - 20.6%

mi %>%
  group_by(ENERGY, PWEIGHT) %>%
  tally() %>%
  ungroup() %>%
  mutate(n = n * PWEIGHT) %>%
  group_by(ENERGY) %>%
  summarize(n = sum(n)) %>%
  ungroup() %>%
  mutate(percent = 100 * n / est_total_pop)

# HSE_TEMP:
 # In the last 12 months, how many months did your household keep your home at a
  # temperature that you felt was unsafe or unhealthy?

  # 1) Almost every month - 5.25%
  # 2) Some months - 6.73%
  # 3) 1 or 2 months - 4.39%
  # 4) Never - 62.2%
  # -99) Question seen but category not selected - 0.8%
  # -88) Missing / Did not report - 20.6%

mi %>%
  group_by(HSE_TEMP, PWEIGHT) %>%
  tally() %>%
  ungroup() %>%
  mutate(n = n * PWEIGHT) %>%
  group_by(HSE_TEMP) %>%
  summarize(n = sum(n)) %>%
  ungroup() %>%
  mutate(percent = 100 * n / est_total_pop)

# FIXIT: run correlations for specific timeframe
  # connect this information to Arrearages DTE timeseries (potentially timeseries)
  # incorporate racial data for Pulse survey (look for question and include as additional column)

# ENRGY_BILL:
  # In the last 12 months, how many times was your household unable to pay an
  # energy bill or unable to pay the full bill amount?

  # 1) Almost every month - 4.71%
  # 2) Some months - 7.55%
  # 3) 1 or 2 months - 6.05%
  # 4) Never - 60.3%
  # -99) Question seen but category not selected - 0.77%
  # -88) Missing / Did not report - 20.6%

mi %>%
  group_by(ENRGY_BILL, PWEIGHT) %>%
  tally() %>%
  ungroup() %>%
  mutate(n = n * PWEIGHT) %>%
  group_by(ENRGY_BILL) %>%
  summarize(n = sum(n)) %>%
  ungroup() %>%
  mutate(percent = 100 * n / est_total_pop)


# Timeseries--------------------------------------------------------------------
tmp <- mi_energy_resps %>%
  group_by(WEEK, ENERGY, PWEIGHT) %>%
  tally() %>%
  mutate(n = n * PWEIGHT) %>%
  group_by(WEEK, ENERGY) %>%
  summarize(n = sum(n, na.rm = TRUE)) %>%
  ungroup()

timeseries_df <- expand_grid(
  WEEK = seq(18, 63),
  ENERGY = c(-99, -88, 1, 2, 3, 4)
) 

energy_timeseries <- timeseries_df %>%
  left_join(
    mi_energy_resps %>%
      group_by(WEEK, ENERGY, PWEIGHT) %>%
      tally() %>%
      mutate(n = n * PWEIGHT) %>%
      group_by(WEEK, ENERGY) %>%
      summarize(n = sum(n, na.rm = TRUE)) %>%
      ungroup(),
    by = c("WEEK", "ENERGY")
  ) %>%
  # Replace where data was unavailable with 0s
  replace_na(list(n = 0))

energy_timeseries %>%
  filter(WEEK > 47) %>%
  # Remove missing or did not report answers
  filter(ENERGY != -99 &
           ENERGY != -88) %>%
  # Adding answer descriptions
  mutate(ENERGY = as.factor(ENERGY)) %>%
  mutate(energy_classification = case_when(
    ENERGY == 4 ~ "Never",
    ENERGY == 3 ~ "1 or 2 months",
    ENERGY == 2 ~ "Some months",
    ENERGY == 1 ~ "Almost every month",
    TRUE ~ "error"
  )) %>%
  mutate(energy_classification = factor(energy_classification, levels = c("Never", "1 or 2 months", "Some months", "Almost every month", "error"))) %>%
  filter(ENERGY != 4) %>%
  # Line plot of data
  ggplot(aes(x = WEEK, y = n, color = energy_classification)) +
  geom_line() +
  geom_point() +
  theme_bw() +
  labs(x = "WEEK", y = "Population", title = "How many months did your household reduce or forego expenses\nfor basic household necessities in order to pay an energy bill?")

hse_timeseries <- timeseries_df %>%
  rename(HSE_TEMP = ENERGY) %>%
  left_join(
    mi_energy_resps %>%
      group_by(WEEK, HSE_TEMP, PWEIGHT) %>%
      tally() %>%
      mutate(n = n * PWEIGHT) %>%
      group_by(WEEK, HSE_TEMP) %>%
      summarize(n = sum(n, na.rm = TRUE)) %>%
      ungroup(),
    by = c("WEEK", "HSE_TEMP")
  ) %>%
  # Replace where data was unavailable with 0s
  replace_na(list(n = 0))

hse_timeseries %>%
  filter(WEEK > 47) %>%
  # Remove missing or did not report answers
  filter(HSE_TEMP != -99 &
           HSE_TEMP != -88) %>%
  # Adding answer descriptions
  mutate(HSE_TEMP = as.factor(HSE_TEMP)) %>%
  mutate(classification = case_when(
    HSE_TEMP == 4 ~ "Never",
    HSE_TEMP == 3 ~ "1 or 2 months",
    HSE_TEMP == 2 ~ "Some months",
    HSE_TEMP == 1 ~ "Almost every month",
    TRUE ~ "error"
  )) %>%
  mutate(classification = factor(classification, levels = c("Never", "1 or 2 months", "Some months", "Almost every month", "error"))) %>%
  # Line plot of data
  filter(HSE_TEMP != 4) %>%
  ggplot(aes(x = WEEK, y = n, color = classification)) +
  geom_line() +
  geom_point() +
  theme_bw()

energy_bill_timeseries <- timeseries_df %>%
  rename(ENRGY_BILL = ENERGY) %>%
  left_join(
    mi_energy_resps %>%
      group_by(WEEK, ENRGY_BILL, PWEIGHT) %>%
      tally() %>%
      mutate(n = n * PWEIGHT) %>%
      group_by(WEEK, ENRGY_BILL) %>%
      summarize(n = sum(n, na.rm = TRUE)) %>%
      ungroup(),
    by = c("WEEK", "ENRGY_BILL")
  ) %>%
  # Replace where data was unavailable with 0s
  replace_na(list(n = 0))

energy_bill_timeseries %>%
  filter(WEEK > 47) %>%
  # Remove missing or did not report answers
  filter(ENRGY_BILL != -99 &
           ENRGY_BILL != -88) %>%
  # Adding answer descriptions
  mutate(ENRGY_BILL = as.factor(ENRGY_BILL)) %>%
  mutate(classification = case_when(
    ENRGY_BILL == 4 ~ "Never",
    ENRGY_BILL == 3 ~ "1 or 2 months",
    ENRGY_BILL == 2 ~ "Some months",
    ENRGY_BILL == 1 ~ "Almost every month",
    TRUE ~ "error"
  )) %>%
  mutate(classification = factor(classification, levels = c("Never", "1 or 2 months", "Some months", "Almost every month", "error"))) %>%
  # Line plot of data
  ggplot(aes(x = WEEK, y = n, color = classification)) +
  geom_line() +
  geom_point() +
  theme_bw()


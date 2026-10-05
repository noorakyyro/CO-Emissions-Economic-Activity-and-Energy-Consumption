# 01_cleaning.R
# Import OWID CO2 data, build GDP per capita, restrict to countries in 2022,
# and save the analysis dataset.
#
# Data: download owid-co2-data.csv from https://github.com/owid/co2-data
# and save it as data/owid_co2.csv (see README).

library(tidyverse)
library(countrycode)

dir.create("data", showWarnings = FALSE)
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

raw_path <- "data/owid_co2.csv"
if (!file.exists(raw_path)) stop("Missing ", raw_path, ". See README for the download link.")

co2_data <- read_csv(raw_path, show_col_types = FALSE)

# --- Checks ------------------------------------------------------------------
required <- c("country", "year", "gdp", "population",
              "co2_per_capita", "energy_per_capita")
missing_cols <- setdiff(required, names(co2_data))
if (length(missing_cols) > 0) stop("Missing columns: ", paste(missing_cols, collapse = ", "))

dups <- co2_data %>% count(country, year) %>% filter(n > 1)
if (nrow(dups) > 0) stop("Duplicate country-year observations found")

# --- GDP per capita (total PPP GDP / population) ----------------------------
co2_data <- co2_data %>%
  mutate(
    gdp_per_capita = if_else(
      !is.na(gdp) & !is.na(population) & population > 0,
      gdp / population,
      NA_real_
    )
  )

# --- Coverage by year (used to choose the analysis year) --------------------
year_coverage <- co2_data %>%
  group_by(year) %>%
  summarise(
    n_observations = n(),
    countries_with_co2    = sum(!is.na(co2_per_capita)),
    countries_with_gdp    = sum(!is.na(gdp_per_capita)),
    countries_with_energy = sum(!is.na(energy_per_capita)),
    complete_all_three    = sum(complete.cases(co2_per_capita, gdp_per_capita, energy_per_capita)),
    .groups = "drop"
  )
write_csv(year_coverage, "output/tables/year_coverage.csv")

year_coverage %>%
  filter(year >= 1990) %>%
  arrange(desc(complete_all_three)) %>%
  print(n = 10)

# --- Analysis dataset: 2022, complete cases ----------------------------------
analysis_year <- 2022

analysis_2022 <- co2_data %>%
  filter(year == analysis_year) %>%
  select(country, co2_per_capita, gdp_per_capita, energy_per_capita) %>%
  drop_na()

# OWID also contains aggregates (e.g. regions, income groups). countrycode only
# recognises real countries, so entities without a continent are dropped.
analysis_2022 <- analysis_2022 %>%
  mutate(
    continent = countrycode(country, origin = "country.name", destination = "continent"),
    region    = countrycode(country, origin = "country.name", destination = "region")
  )

dropped <- analysis_2022 %>% filter(is.na(continent)) %>% pull(country)
message("Dropped non-country entities: ", paste(dropped, collapse = ", "))

analysis_2022 <- analysis_2022 %>%
  filter(!is.na(continent)) %>%
  mutate(
    log_co2    = log(co2_per_capita),
    log_gdp    = log(gdp_per_capita),
    log_energy = log(energy_per_capita),
    # Quartiles of GDP per capita (NOT official World Bank income groups)
    gdp_quartile = cut(
      gdp_per_capita,
      breaks = quantile(gdp_per_capita, probs = seq(0, 1, 0.25)),
      labels = c("Lowest quartile", "Second quartile", "Third quartile", "Highest quartile"),
      include.lowest = TRUE
    )
  )

message("Countries in analysis dataset: ", nrow(analysis_2022))
write_csv(analysis_2022, "data/analysis_2022.csv")

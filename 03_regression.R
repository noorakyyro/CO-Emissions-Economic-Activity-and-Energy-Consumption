# 03_regression.R
# Baseline linear models, multicollinearity check, main log-log model,
# diagnostics, and sensitivity analysis. Saves models for the figures script.

library(tidyverse)
library(broom)

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("output/models", recursive = TRUE, showWarnings = FALSE)

analysis_2022 <- read_csv("data/analysis_2022.csv", show_col_types = FALSE)

# --- Baseline models (levels) --------------------------------------------------
model_1 <- lm(co2_per_capita ~ gdp_per_capita, data = analysis_2022)
model_2 <- lm(co2_per_capita ~ gdp_per_capita + energy_per_capita, data = analysis_2022)
summary(model_1)
summary(model_2)

# --- Multicollinearity -----------------------------------------------------------
cor(analysis_2022$gdp_per_capita, analysis_2022$energy_per_capita)
car::vif(model_2)

# --- Main model: log-log ------------------------------------------------------------
model_log <- lm(log_co2 ~ log_gdp + log_energy, data = analysis_2022)
summary(model_log)

par(mfrow = c(2, 2)); plot(model_log); par(mfrow = c(1, 1))

# --- Influential observations ----------------------------------------------------------
diagnostics <- analysis_2022 %>%
  mutate(
    std_residual   = rstandard(model_log),
    leverage       = hatvalues(model_log),
    cooks_distance = cooks.distance(model_log)
  ) %>%
  arrange(desc(cooks_distance)) %>%
  select(country, co2_per_capita, gdp_per_capita, energy_per_capita,
         std_residual, leverage, cooks_distance)

print(head(diagnostics, 10))
write_csv(head(diagnostics, 10), "output/tables/top10_influential.csv")

influential_countries <- diagnostics %>% slice_head(n = 3) %>% pull(country)
message("Excluded in sensitivity analysis: ", paste(influential_countries, collapse = ", "))

# --- Sensitivity analysis: drop the 3 most influential countries ------------------------
model_log_sensitivity <- lm(
  log_co2 ~ log_gdp + log_energy,
  data = filter(analysis_2022, !country %in% influential_countries)
)
summary(model_log_sensitivity)

coef(model_log)
coef(model_log_sensitivity)

# --- Save results ---------------------------------------------------------------------------
results <- bind_rows(
  tidy(model_log, conf.int = TRUE) %>% mutate(model = "Main (all countries)"),
  tidy(model_log_sensitivity, conf.int = TRUE) %>% mutate(model = "Excluding 3 most influential")
)
write_csv(results, "output/tables/regression_results.csv")

glance(model_log) %>% mutate(model = "Main") %>%
  bind_rows(glance(model_log_sensitivity) %>% mutate(model = "Sensitivity")) %>%
  write_csv("output/tables/model_fit.csv")

saveRDS(list(main = model_log, sensitivity = model_log_sensitivity,
             excluded = influential_countries), "output/models/models.rds")

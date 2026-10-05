# 04_visualisations.R
# Four portfolio figures. Run after 01-03.

library(tidyverse)
library(broom)
library(scales)

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

analysis_2022 <- read_csv("data/analysis_2022.csv", show_col_types = FALSE)
models <- readRDS("output/models/models.rds")

theme_set(theme_minimal(base_size = 12))

# 1. CO2 vs GDP (log-log, matching the model) --------------------------------------
p1 <- ggplot(analysis_2022, aes(gdp_per_capita, co2_per_capita)) +
  geom_point(colour = "steelblue", size = 2, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, colour = "firebrick") +
  scale_x_log10(labels = comma) +
  scale_y_log10(labels = comma) +
  labs(title = "Richer countries tend to emit more CO2 per person",
       subtitle = "Country-level data, 2022; both axes on log scales",
       x = "GDP per capita (2011 international-$)",
       y = "CO2 emissions per capita (tonnes)")
ggsave("output/figures/01_co2_vs_gdp.png", p1, width = 7, height = 5, dpi = 300)

# 2. CO2 vs energy ---------------------------------------------------------------------
p2 <- ggplot(analysis_2022, aes(energy_per_capita, co2_per_capita)) +
  geom_point(colour = "steelblue", size = 2, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, colour = "firebrick") +
  scale_x_log10(labels = comma) +
  scale_y_log10(labels = comma) +
  labs(title = "CO2 emissions track energy use closely",
       subtitle = "Country-level data, 2022; both axes on log scales",
       x = "Energy use per capita (kWh)",
       y = "CO2 emissions per capita (tonnes)")
ggsave("output/figures/02_co2_vs_energy.png", p2, width = 7, height = 5, dpi = 300)

# 3. Overview: GDP vs energy, colour = continent, size = CO2 ----------------------------
p3 <- ggplot(analysis_2022, aes(gdp_per_capita, energy_per_capita,
                                colour = continent, size = co2_per_capita)) +
  geom_point(alpha = 0.7) +
  scale_x_log10(labels = comma) +
  scale_y_log10(labels = comma) +
  labs(title = "GDP, energy use and CO2 emissions together, 2022",
       x = "GDP per capita (2011 international-$, log scale)",
       y = "Energy use per capita (kWh, log scale)",
       colour = "Continent", size = "CO2 per capita\n(tonnes)")
ggsave("output/figures/03_overview.png", p3, width = 8, height = 5.5, dpi = 300)

# 4. Coefficient plot: main model vs sensitivity analysis -----------------------------------

coefs <- bind_rows(
  tidy(models$main, conf.int = TRUE) %>% 
    mutate(model = "All countries"),
  tidy(models$sensitivity, conf.int = TRUE) %>% 
    mutate(model = "Excluding 3 most influential")
) %>%
  filter(term != "(Intercept)") %>%
  mutate(term = case_when(
    term == "log_gdp" ~ "log GDP per capita",
    term == "log_energy" ~ "log energy use per capita",
    TRUE ~ term
  ))

p4 <- ggplot(coefs, aes(estimate, term, colour = model)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high),
                  position = position_dodge(width = 0.5)) +
  labs(title = "Energy use is the dominant correlate of CO2 per capita",
       subtitle = "Log-log regression estimates with 95% confidence intervals",
       x = "Estimated coefficient (elasticity)", y = NULL, colour = NULL) +
  theme(legend.position = "bottom")
ggsave("output/figures/04_coefficients.png", p4, width = 7.5, height = 4, dpi = 300)


# 02_exploration.R
# Descriptive statistics and exploratory plots.

library(tidyverse)

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("output/tables",  recursive = TRUE, showWarnings = FALSE)

analysis_2022 <- read_csv("data/analysis_2022.csv", show_col_types = FALSE) %>%
  mutate(gdp_quartile = factor(gdp_quartile, levels = c("Lowest quartile", "Second quartile",
                                                        "Third quartile", "Highest quartile")))

# --- Summary statistics -------------------------------------------------------
summary_stats <- analysis_2022 %>%
  summarise(across(
    c(co2_per_capita, gdp_per_capita, energy_per_capita),
    list(mean = mean, median = median, sd = sd, min = min, max = max)
  )) %>%
  pivot_longer(everything(), names_to = c("variable", "stat"),
               names_pattern = "(.*)_(mean|median|sd|min|max)$") %>%
  pivot_wider(names_from = stat, values_from = value)
print(summary_stats)
write_csv(summary_stats, "output/tables/summary_stats.csv")

# Highest and lowest countries
analysis_2022 %>% slice_max(co2_per_capita, n = 10) %>% print()
analysis_2022 %>% slice_min(co2_per_capita, n = 10) %>% print()

# --- Correlations ---------------------------------------------------------------
cors <- cor(analysis_2022[, c("co2_per_capita", "gdp_per_capita", "energy_per_capita")])
log_cors <- cor(analysis_2022[, c("log_co2", "log_gdp", "log_energy")])
print(round(cors, 2))
print(round(log_cors, 2))
write.csv(round(log_cors, 3), "output/tables/log_correlations.csv")

# --- Exploratory plots ------------------------------------------------------------
# Raw distribution is heavily right-skewed -> motivates the log transformation
p_hist <- ggplot(analysis_2022, aes(co2_per_capita)) +
  geom_histogram(bins = 40, fill = "steelblue", colour = "white") +
  labs(title = "Distribution of CO2 emissions per capita, 2022",
       x = "CO2 emissions per capita (tonnes)", y = "Number of countries") +
  theme_minimal()
ggsave("output/figures/explore_hist_co2.png", p_hist, width = 7, height = 4.5, dpi = 300)

p_top <- analysis_2022 %>%
  slice_max(co2_per_capita, n = 10) %>%
  ggplot(aes(co2_per_capita, fct_reorder(country, co2_per_capita))) +
  geom_col(fill = "firebrick") +
  labs(title = "Top 10 CO2 emitters per capita, 2022",
       x = "CO2 emissions per capita (tonnes)", y = NULL) +
  theme_minimal()
ggsave("output/figures/explore_top10_co2.png", p_top, width = 7, height = 4.5, dpi = 300)

p_box <- ggplot(analysis_2022, aes(gdp_quartile, co2_per_capita, fill = gdp_quartile)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_viridis_d() +
  labs(title = "CO2 per capita by GDP-per-capita quartile, 2022",
       x = NULL, y = "CO2 emissions per capita (tonnes)") +
  theme_minimal()
ggsave("output/figures/explore_box_quartile.png", p_box, width = 7, height = 4.5, dpi = 300)

p_cont <- ggplot(analysis_2022, aes(gdp_per_capita, co2_per_capita)) +
  geom_point(aes(colour = energy_per_capita), size = 1.5, alpha = 0.8) +
  scale_colour_viridis_c(option = "plasma") +
  scale_x_log10(labels = scales::comma) +
  facet_wrap(~ continent) +
  labs(title = "GDP, CO2 and energy use by continent, 2022",
       x = "GDP per capita (2011 international-$, log scale)",
       y = "CO2 emissions per capita (tonnes)", colour = "Energy per capita\n(kWh)") +
  theme_minimal()
ggsave("output/figures/explore_by_continent.png", p_cont, width = 9, height = 6, dpi = 300)

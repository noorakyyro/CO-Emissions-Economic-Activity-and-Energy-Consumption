# CO₂ Emissions, Economic Activity and Energy Use

## Overview

This project examines the relationship between **CO₂ emissions per capita, economic activity, and energy use across countries** using country-level data for 2022.

The analysis combines exploratory data analysis with multiple linear regression to investigate:

- How CO₂ emissions per capita vary across countries
- The relationship between GDP per capita and CO₂ emissions
- The relationship between energy use per capita and CO₂ emissions
- How GDP and energy use are associated with CO₂ emissions when considered simultaneously
- Whether the main regression results are sensitive to influential observations

The project was developed as a self-directed data analysis project to demonstrate an end-to-end workflow in **R**, including data cleaning, exploratory analysis, statistical modelling, diagnostics, sensitivity analysis, and visualisation.

---

## Research Questions

The analysis addresses the following questions:

1. How are GDP per capita and energy use per capita associated with CO₂ emissions per capita across countries?
2. How does the relationship between economic activity and CO₂ emissions change when energy use is taken into account?
3. How robust are the regression results to influential countries?

---

## Data

The analysis uses data from the **Our World in Data CO₂ and Greenhouse Gas Emissions dataset**.

The original dataset contains country- and year-level information on CO₂ emissions, population, GDP, energy use, and other environmental and economic indicators.

Source:

**Our World in Data – CO₂ and Greenhouse Gas Emissions Dataset**  
https://github.com/owid/co2-data

The analysis uses **2022** observations.

GDP per capita is calculated from total GDP and population:

```text
GDP per capita = GDP / population
```

Only observations with complete data for:

- CO₂ emissions per capita
- GDP per capita
- Energy use per capita

are included in the main analysis.

OWID's dataset also contains regional and other aggregate entities. These are removed by using `countrycode` to identify observations with a valid continent classification, leaving country-level observations for the analysis.

---

## Methodology

### 1. Data cleaning

The cleaning script:

- Imports the OWID dataset
- Checks that required variables are present
- Checks for duplicate country-year observations
- Calculates GDP per capita
- Examines data coverage across years
- Selects 2022 for the main analysis
- Removes observations with missing values
- Identifies countries and assigns continent and region information
- Creates logarithmic transformations of the main variables
- Divides countries into four GDP-per-capita quartiles

The GDP-per-capita groups are **sample quartiles**, not official World Bank income groups.

The following logarithmic variables are created:

```text
log_co2
log_gdp
log_energy
```

The log transformation is used because the country-level variables are strongly right-skewed and the relationships are more appropriately examined on a multiplicative scale.

---

### 2. Exploratory analysis

The exploratory analysis includes:

- Summary statistics
- Highest and lowest CO₂-emitting countries per capita
- Correlations between the main variables
- Correlations between their logarithmic transformations
- Distribution of CO₂ emissions per capita
- CO₂ emissions by GDP-per-capita quartile
- Relationships between GDP, CO₂ emissions, energy use, and continent

The exploratory analysis helps establish the main patterns in the data and motivates the use of logarithmic transformations.

---

### 3. Regression analysis

Three regression specifications are considered.

#### Baseline model 1

A simple level-level model:

```text
CO₂ per capita ~ GDP per capita
```

#### Baseline model 2

A multiple level-level model:

```text
CO₂ per capita ~ GDP per capita + Energy use per capita
```

#### Main model

The main analysis uses a log-log multiple linear regression:

```text
log(CO₂ per capita) ~ log(GDP per capita) + log(Energy use per capita)
```

In this specification, coefficients can be interpreted as elasticities: a one-percent difference in an explanatory variable is associated with an estimated percentage difference in CO₂ emissions per capita, holding the other variable constant.

---

### 4. Multicollinearity

The relationship between GDP per capita and energy use per capita is examined using:

- Their correlation
- The variance inflation factor (VIF)

This provides a check for potential multicollinearity between the two explanatory variables.

---

### 5. Model diagnostics

The main log-log regression is examined using:

- Standardised residuals
- Leverage
- Cook's distance

The observations with the largest Cook's distance are identified as potentially influential.

---

### 6. Sensitivity analysis

The three most influential countries identified from Cook's distance are excluded and the main log-log model is estimated again.

The coefficients and model fit of the original and sensitivity models are compared.

This tests whether the main findings depend strongly on a small number of influential observations.

---

## Key Findings

The exploratory analysis shows a clear positive association between **GDP per capita and CO₂ emissions per capita** when the two variables are considered on their own. Higher-income countries generally have higher CO₂ emissions per person, although there is substantial variation between countries.

The relationship between **energy use per capita and CO₂ emissions per capita** is particularly strong.

The multiple log-log regression provides a more nuanced picture. In the model controlling for energy use, the estimated coefficient for GDP per capita is negative, while the coefficient for energy use is strongly positive.

The main model produced approximately:

| Variable | Coefficient |
|---|---:|
| Log GDP per capita | -0.117 |
| Log energy use per capita | 0.987 |

After excluding the three most influential countries, the coefficients were approximately:

| Variable | Coefficient |
|---|---:|
| Log GDP per capita | -0.160 |
| Log energy use per capita | 1.043 |

The similarity between the main and sensitivity estimates suggests that the broad pattern is not driven entirely by the three most influential observations.

The difference between the bivariate GDP relationship and the GDP coefficient in the multiple regression is important: the regression coefficient for GDP represents its **conditional association with CO₂ emissions after accounting for energy use**, rather than the overall relationship between GDP and CO₂.

These results should be interpreted as **associations rather than causal effects**.

---

## Visualisations

The final portfolio contains four main figures.

### 1. CO₂ emissions and GDP

A log-log scatter plot showing the relationship between GDP per capita and CO₂ emissions per capita, with a fitted linear regression line and 95% confidence interval.

### 2. CO₂ emissions and energy use

A log-log scatter plot showing the relationship between energy use per capita and CO₂ emissions per capita.

### 3. GDP, energy use and CO₂ together

A multivariate overview showing:

- GDP per capita on the x-axis
- Energy use per capita on the y-axis
- Continent represented by colour
- CO₂ emissions per capita represented by point size

### 4. Regression coefficients

A coefficient plot comparing the main regression with the sensitivity analysis.

The plot shows estimated coefficients and 95% confidence intervals for GDP per capita and energy use per capita.

---

## Project Structure

```text
co2-emissions-analysis/
│
├── R/
│   ├── 01_cleaning.R
│   ├── 02_exploration.R
│   ├── 03_regression.R
│   └── 04_visualisations.R
│
├── data/
│   └── analysis_2022.csv
│
├── output/
│   ├── figures/
│   │   ├── 01_co2_vs_gdp.png
│   │   ├── 02_co2_vs_energy.png
│   │   ├── 03_overview.png
│   │   └── 04_coefficients.png
│   │
│   ├── tables/
│   │   ├── year_coverage.csv
│   │   ├── summary_stats.csv
│   │   ├── log_correlations.csv
│   │   ├── top10_influential.csv
│   │   ├── regression_results.csv
│   │   └── model_fit.csv
│   │
│   └── models/
│       └── models.rds
│
├── README.md
└── co2-analysis.Rproj
```

---

## Reproducibility

The scripts are designed to be run sequentially:

```text
01_cleaning.R
       ↓
02_exploration.R
       ↓
03_regression.R
       ↓
04_visualisations.R
```

### Step 1: Obtain the data

Download the OWID CO₂ dataset from:

https://github.com/owid/co2-data

Save the downloaded CSV as:

```text
data/owid_co2.csv
```

### Step 2: Install the required R packages

```r
install.packages(c(
  "tidyverse",
  "countrycode",
  "broom",
  "car",
  "scales"
))
```

### Step 3: Run the scripts

Run the four scripts in the `R/` directory in numerical order.

The scripts automatically create the required output directories and save the processed dataset, tables, model objects, and figures.

---

## Limitations

Several limitations should be considered when interpreting the results.

### Cross-sectional analysis

The analysis uses observations from a single year, 2022. It therefore describes differences between countries rather than changes over time.

### Association, not causation

Regression coefficients represent statistical associations. The analysis does not establish that changes in GDP or energy use cause changes in CO₂ emissions.

### Country-level aggregation

The data are aggregated at the country level. Relationships observed between countries may not necessarily apply to individuals, households, firms, or other units of analysis.

### Model specification

The regression includes GDP per capita and energy use per capita but does not account for all other factors that may influence CO₂ emissions, such as industrial structure, energy sources, climate, trade, population density, or environmental policies.

### Influential observations

Although a sensitivity analysis is performed, influential observations can still affect the estimates. The removal of three observations is a diagnostic exercise rather than a claim that these countries are inappropriate to include in the analysis.

### GDP and energy use are closely related

GDP per capita and energy use per capita are strongly related across countries. Although their correlation and VIF are examined, this relationship makes interpretation of their individual coefficients in the multiple regression more difficult.

---

## Tools and Skills Demonstrated

**R**

- `tidyverse`
- `ggplot2`
- `dplyr`
- `broom`
- `countrycode`
- `car`
- `scales`

**Data analysis**

- Data cleaning and validation
- Missing-data handling
- Variable construction
- Exploratory data analysis
- Descriptive statistics
- Correlation analysis
- Data transformation
- Multiple linear regression
- Multicollinearity assessment
- Regression diagnostics
- Influence analysis
- Sensitivity analysis

**Data visualisation**

- Scatter plots
- Log-scaled axes
- Boxplots
- Multivariate visualisation
- Regression lines and confidence intervals
- Regression coefficient plots

---

## Purpose

This project was developed as a self-directed portfolio project to demonstrate practical skills in **data cleaning, exploratory analysis, statistical modelling, visualisation, and reproducible analysis using R**.

The emphasis is on a transparent and reproducible analytical workflow rather than model complexity.

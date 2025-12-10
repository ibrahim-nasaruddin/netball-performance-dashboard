# Netball Performance Dashboard (R Shiny)

**Author:** Ibrahim Nasaruddin (Master of Sport Analytics Student, 2025-26)
**Role:** Part-Time Performance Analyst, HPSI Singapore

[![R](https://img.shields.io/badge/R-%23276DC3.svg?logo=r&logoColor=white)](#)
[![RStudio](https://img.shields.io/badge/RStudio-4285F4?logo=rstudio&logoColor=white)](#)
[![GitHub](https://img.shields.io/badge/GitHub-%23121011.svg?logo=github&logoColor=white)](#)
[![CSV](https://img.shields.io/badge/Data-CSV-blue)](#)

## Overview
This is a production-ready R Shiny dashboard designed to automate post-match reporting for Netball. It transforms raw coding data (e.g., from Hudl Sportscode) into interactive visualisations.

## Key Features
* **Interactive Court Maps:** Visualising pass flows and defensive actions on a custom netball court grid.
* **Momentum Analysis:** Automated detection of scoring runs (4+ goals).
* **KPI Tracking:** Dynamic R/A/G (Red-Amber-Green) coloring for shooting and feed accuracy.

## How to Run
1.  Clone this repository.
2.  Open `app.R` in RStudio.
3.  Run `shiny::runApp()`.
4.  Upload the sample CSV provided in the `data/` folder.

## 📊 How to Test the Dashboard
To see the dashboard in action, you need a dataset that matches the specific Hudl Sportscode output structure used by this tool.

**⚠️ Important:** If you upload a random CSV, the app will likely crash because it looks for specific column headers (e.g., `Row`, `Quarter`, `Shot Outcome`).

**Please use the sample dataset provided in this repository:**
1. Download the sample file: [data/mock_netball_data.csv](https://github.com/ibrahim-nasaruddin/netball-performance-dashboard/blob/main/data/mock_netball_data.csv)
2. Open the [Live Dashboard](https://8k17oa-ibrahim0bin0nasaruddin.shinyapps.io/Netball-Performance-Dashboard/).
3. In the "Upload & Config" tab, upload this `mock_netball_data.csv` file.
4. Click **Process Data**.

## ⚠️ Data Schema & Sportscode Compatibility

**Crucial Note for Analysts:**
This dashboard is designed to ingest data exported from a specific **Hudl Sportscode Tagging Panel** (Code Window).

Since Sportscode allows for infinite customisation of button names and output labels, **this tool is not universal for all Sportscode CSVs.**

### Schema Requirements
The R code explicitly looks for specific string patterns to generate the visualisations. If you wish to use your own data, it must follow this naming convention, or you will need to adjust the string matching in `app.R`:

* **Row Names:** Must contain `"SGP Shot"`, `"OPP Shot"`, `"SGP CPA"`, `"SGP Gains"`, etc.
* **Column Headers:** Must include standard Sportscode export headers like `Row`, `Quarter`, `Start time`.
* **Outcome Labels:** Shooting logic looks for strings like `"Goal"` or `"Miss"`. Passing logic looks for `"1st Phase Pass"`, etc.

**Recommendation:**
To test the app, please use the provided sample dataset in this repository first (download link above). If adapting for your own team, you may consider renaming your rows in the CSV to match the dummy data structure rather than rewriting the R code, unless you are already au fait with editing the app.R file.

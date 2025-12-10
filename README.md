# Netball Performance Dashboard (R Shiny)

**Author:** Ibrahim Nasaruddin (Master of Sport Analytics Student)
**Role:** Performance Analyst, HPSI

## Overview
This is a production-ready R Shiny dashboard designed to automate post-match reporting for Netball. It transforms raw coding data (e.g., from Hudl Sportscode) into interactive visualisations.

## Key Features
* **Interactive Court Maps:** Visualizing pass flows and defensive actions on a custom netball court grid.
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
1. Download the sample file: [data/test.csv](https://github.com/ibrahim-nasaruddin/netball-performance-dashboard/blob/main/data/test.csv)
2. Open the [Live Dashboard](https://8k17oa-ibrahim0bin0nasaruddin.shinyapps.io/Netball-Performance-Dashboard/).
3. In the "Upload & Config" tab, upload this `test.csv` file.
4. Click **Process Data**.

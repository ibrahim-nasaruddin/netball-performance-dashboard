# Netball Match Summary Dashboard (R Shiny & Python Streamlit)

**Author:** Ibrahim Nasaruddin (Master of Sport Analytics Student, 2025-26)
**Role:** Part-Time Performance Analyst, HPSI Singapore

[![R](https://img.shields.io/badge/R-%23276DC3.svg?logo=r&logoColor=white)](#)
[![RStudio](https://img.shields.io/badge/RStudio-4285F4?logo=rstudio&logoColor=white)](#)
[![Shiny](https://img.shields.io/badge/Shiny-blue?logo=r&logoColor=white)](#)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)](#)
[![Streamlit](https://img.shields.io/badge/Streamlit-FF4B4B?logo=streamlit&logoColor=white)](#)
[![Plotly](https://img.shields.io/badge/Plotly-3F4F75?logo=plotly&logoColor=white)](#)

## 📋 Overview
This repository grew out of my work building post‑match reports for netball in both R and Python. It packages the workflows I actually use into two production‑ready dashboards: one in R (Shiny) and one in Python (Streamlit).

The dashboards are designed for coaches and performance staff who need quick, repeatable insights after matches, without diving back into Hudl Sportscode timelines or spreadsheets. My aim was to turn messy event logs into views that support conversations about shooting efficiency, CPA/DCPA quality, and where gains and turnovers really happen on court.

I originally built this dashboard in R/Shiny and then rebuilt it in Python/Streamlit as a learning exercise. Doing the same project twice helped me deepen my Python skills and directly compare how each stack feels for day‑to‑day performance analysis work.

## 📂 Repository Structure
To keep the environments clean, the project is divided into two distinct sub-directories:

```text
netball-match-dashboard/
│
├── r_shiny/                  # 🟢 The Original R Version
│   ├── app.R                 # Main Shiny application
│   └── mock_netball_data.csv # Raw data sample
│
├── streamlit_python/         # 🔴 The New Python Version
│   ├── dashboard.py          # Main Streamlit application
│   ├── requirements.txt      # Python dependencies
│   └── ready_for_dashboard.csv # Enriched data sample (with Positions/Shot Zones)
│
└── README.md                 # Documentation
```

## 🚀 Getting Started

**1. Clone this repository:**
```bash
git clone https://github.com/ibrahim-nasaruddin/netball-performance-dashboard.git

cd netball-performance-dashboard
```
**2. Then choose one of the options below (Python Streamlit or R Shiny).**


## Pick your path!
**Option 1: Python Streamlit Version (Interactive)**

Best for: Exploring interactive charts, shot maps, and dynamic momentum flows.

- **Navigate to the folder:**
```Bash
cd streamlit_python
```
- **Install dependencies:**
```Bash
pip install -r requirements.txt
```
- **Run the App:**
```Bash
streamlit run dashboard.py
```
- **Load Data:**

When the browser opens, look for the sidebar.

Upload the `mock_netball_data_streamlit.csv` file located inside the `data/` folder.

**Option 2: R Shiny Version (Statistical)**

Best for: Viewing standard fixed reports and high-fidelity static plots.

- **Open RStudio.**

- **Open File:** Navigate to `r_shiny/app.R`.

- **Run App:** Click the `Run App` button (or type `shiny::runApp('r_shiny')` in the console).

- **Load Data:** In the "Upload & Config" tab, upload the `mock_netball_data.csv` file located in the `data/` folder.

## Data Schema & Sportscode Compatibility
**Crucial Note for Analysts**: Both dashboards are engineered to ingest data from a specific Hudl Sportscode Tagging Panel. They rely on strict naming conventions in the CSV export. Since Sportscode allows for infinite customisation of button names and output labels, this tool is not universal for all Sportscode CSVs.

**Schema Requirements**

The R code explicitly looks for specific string patterns to generate the visualisations. If you wish to use your own data, it must follow this naming convention, or you will need to adjust the string matching in app.R:

- **Row Names:** Must contain "SGP Shot", "OPP Shot", "SGP CPA", "SGP Gains", etc.
- **Column Headers:** Must include standard Sportscode export headers like Row, Quarter, Start time.
- **Outcome Labels:** Shooting logic looks for strings like "Goal" or "Miss". Passing logic looks for "1st Phase Pass", etc.
- **Recommendation:** To test the app, please use the provided sample dataset in this repository first (download link above). If adapting for your own team, you may consider renaming your rows in the CSV to match the dummy data structure rather than rewriting the R code, unless you are already au fait with editing the app.R file.



**1. The "Raw" Data (Used by R)**
The R Shiny app expects the standard export columns:

- **Row:** Event names (e.g., "Home Shot", "Home CPA").

- **Shot Outcome:** Descriptive strings (e.g., "Home Goal", "Home Miss").

- **Quarter, Start time:** Time stamps.

**2. The "Enriched" Data (Used by Python)**
The Python Streamlit app utilizes an enriched dataset (ready_for_dashboard.csv) which contains two additional contextual columns not found in the raw export:
- **Position:** The player's on-court position (GS, GA, WA, etc.).
- **Shot Location:** Contextual zones (Inner Circle, Outer Circle, Circle Edge).

> If you upload the raw CSV to the Python app, the "Shooting Analysis" charts (Stacked Bars & Zone Maps) will remain hidden to prevent errors.

# Features Breakdown
**1. Momentum Analysis**
- **Goal:** Visualise "Swings" in the match.

- **Logic:** The dashboard programmatically identifies Scoring Runs (defined as 4+ consecutive goals by one team) and highlights them on the timeline.

- **Tech:** Uses geom_rect (R) and Plotly Shapes (Python) to draw overlays behind the score line.

**2. Spatial Passing Networks**
- **Goal:** Track how the ball moves from the Centre Pass to the Goal Circle.

- **Logic:** Parses "1st Receiver" and "2nd Receiver" data to map connection frequencies.

- **Tech:** Maps logical court zones (e.g., "Centre Third Left") to physical X/Y coordinates to draw flow paths.

**3. Defensive Heatmaps**
- **Goal:** Identify where on court the team is winning (Gains) or losing (Turnovers) possession.

- **Tech:** Aggregates event coordinates into a bins/grid to visualise density.

## Contact
If you have questions about the data structure or the Sportscode scripting used to generate this data, feel free to reach out via email.

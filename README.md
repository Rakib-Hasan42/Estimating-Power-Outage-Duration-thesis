# Estimation of Power Outage Duration Induced by Hurricanes and Tropical Storms in Florida (Masters Thesis)
This repository contains all data processing, modeling, and analysis scripts developed for my Master’s thesis

---
## Repository Structure
---

```
│
├── DATA/ # Raw, processed datasets and processing code
│ ├── combined final data set/
│ ├── hurricane/
│ │ └── event outage data/
│ │ └── ndvi/
│ │ └── previous 3 days lag/
│ │ └── previous day lag/
│ │ └── precipitation/
│ │ └── weather/
│ ├── land cover/
│ ├── outage season data/
│ ├── population/
│ ├── tropical storm/
│ │ ├── ndvi/
│ │ ├── previous day lag/
│ │ ├── power outage data/
│ │ ├── precipitation/
│ │ ├── previous 3 days avg/
│ │ ├── weather data/
│ ├── initial NDVI extract.Rmd
│
├── model/ # Model training and evaluation scripts
│ ├── log convert/ #RF on log-transformed duration
│ ├── model with all variables/ # RF using all input features
│ ├── RF # Random Forest model
│ ├── QRF # Quantile Regression Forest
│ ├── XGBOOST # XGBoost model
│ ├── Ensemble # Combines models into an ensemble
│ ├── model with all variables/
│ │ └── RF with all variables.Rmd 
├── .gitignore # Git ignore file
├── README.md # You are here
```
---
## Links of large raw datasets required for reproduction
outage dataset: https://figshare.com/s/417a4f147cf1357a5391
land Cover: https://www.usgs.gov/programs/gap-analysis-project/science/land-cover-data-download
shapefile: https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html
ndvi datasets: https://www.ncei.noaa.gov/data/land-normalized-difference-vegetation-index/access/

---

---
## Instruction of use
Need to change the file path according to necessity.
For large datasets, they need to be downloaded from the sites.

---


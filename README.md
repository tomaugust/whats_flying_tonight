# What's flying tonight?
A Shiny app for exploring moth species likely to be flying near a UK location and date.

## Status

Under development

## Requirements

- R 4.0 or newer
- R packages:
  - `shiny`
  - `shinyjs`
  - `sp`
  - `RCurl`
  - `RJSONIO`
  - `plyr`
  - `testthat`
  - `shinytest2`

## How to run locally

From the project root:

```r
install.packages(c(
  'shiny',
  'shinyjs',
  'sp',
  'RCurl',
  'RJSONIO',
  'plyr',
  'testthat',
  'shinytest2'
))

setwd('c:/Users/tomaug/OneDrive - UKCEH/Whats-flying-tonight/whats_flying_tonight')
shiny::runApp()
```

If you prefer to run from another working directory, use the app folder path:

```r
shiny::runApp('c:/path/to/whats_flying_tonight')
```

## Data

The app depends on these data files and folders:

- `data/country_polygons/GBR.rds`
- `data/UKMoths/speciesData_newNames2017.rdata`
- `data/UKMoths/images/Images_requested_with_filenames.csv`
- `data/Additional images.csv`

The `scripts/internal/` folder contains helper functions that are sourced at startup.

## Notes

- The app is designed for UK locations and converts latitude/longitude to UK hectad grid references.
- Results should be treated as "previously recorded nearby at this time of year," not a real-time forecast.

## Testing

Run the test suite from the app root with:

```r
library(testthat)
test_dir('tests/testthat', reporter = 'summary')
```

![Preview](preview.png)

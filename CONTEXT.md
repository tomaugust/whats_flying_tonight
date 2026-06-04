# Project Context

## Project
- Repository: `whats_flying_tonight`
- Purpose: Shiny app to show moth species likely to be flying near a UK location and date.
- Main app entrypoint: `app.R`
- Core modules in `R/`: `app_ui.R`, `app_server.R`, `data_load.R`, `location.R`, `settings.R`, `about.R`

## Current state
- App is currently structured as a Shiny app that sources modularized R files from `R/`.
- Uses browser geolocation and manual place search to convert location to UK hectad references.
- Loads species and image metadata from `data/` and `data/UKMoths/`.
- Renders a dynamic result list via `output$UI`.

## Recent actions
- Staged and committed current working tree changes.
- Ran tests successfully with `Rscript` and `testthat`.
- Updated `README.md` with dependencies, local run instructions, data requirements, and test instructions.
- Updated `dev-plan` with a clearer structure, concrete phase tasks, and an acceptance checklist.

## Current tasks and priorities
1. Maintain current data pipeline; avoid rewriting core species/location logic first.
2. Improve documentation and onboarding by keeping `README.md` up to date.
3. Plan UI modernization in phases: stabilize, refresh UI, refactor internals.
4. Future improvements identified in `dev-plan`:
   - modernize UI with `bslib`
   - replace legacy JS/CSS dependencies
   - improve location flow and error states
   - add response filtering/search in results
   - modularize server logic and add helper tests

## Notes for handoff
- Use the existing app as the reference implementation when making UI or logic changes.
- Preserve the current `gatherData`, grid-ref conversion, and species lookup behavior until the new UI is stable.
- The current test suite lives under `tests/testthat/` and passes with `test_dir('tests/testthat', reporter='summary')`.

## Useful paths
- Root: `c:\Users\tomaug\OneDrive - UKCEH\Whats-flying-tonight\whats_flying_tonight`
- Data loader: `R/data_load.R`
- Location module: `R/location.R`
- Settings module: `R/settings.R`
- App UI: `R/app_ui.R`
- App server: `R/app_server.R`
- Dev plan: `dev-plan`
- README: `README.md`
- Test root: `tests/testthat/`

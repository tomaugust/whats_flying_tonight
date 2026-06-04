load_app_data <- function(envir = parent.frame()) {
  source_scripts <- list.files('scripts/internal/', full.names = TRUE)
  for (script in source_scripts) {
    source(script, local = envir)
  }

  # GBR <- raster::getData(country = 'GBR', level = 1)
  GBR <- readRDS('data/country_polygons/GBR.rds')

  image_information <- read.csv(file = 'data/UKMoths/images/Images_requested_with_filenames.csv',
                                header = TRUE,
                                stringsAsFactors = FALSE)
  additional_image_info <- read.csv(file = 'data/Additional images.csv',
                                    header = TRUE,
                                    stringsAsFactors = FALSE)
  image_information <- rbind(image_information, additional_image_info)

  species_data_env <- new.env(parent = emptyenv())
  load('data/UKMoths/speciesData_newNames2017.rdata', envir = species_data_env)

  list(
    GBR = GBR,
    image_information = image_information,
    speciesDataRaw = species_data_env$speciesDataRaw
  )
}

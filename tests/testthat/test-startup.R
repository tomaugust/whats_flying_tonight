test_that("app entry points source cleanly", {
  app <- source_app()

  expect_true(is.function(app$app_ui))
  expect_true(is.function(app$app_server))
  expect_true(is.function(app$load_app_data))

  ui_obj <- with_app_dir(app$app_ui())
  expect_s3_class(ui_obj, "shiny.tag.list")
})

test_that("required runtime assets are present", {
  required_paths <- c(
    "app.R",
    "R/app_ui.R",
    "R/app_server.R",
    "data/country_polygons/GBR.rds",
    "data/datum_vars.rdata",
    "data/helmert_trans_vars.rdata",
    "data/UKMoths/speciesData_newNames2017.rdata",
    "data/UKMoths/images/Images_requested_with_filenames.csv",
    "data/Additional images.csv",
    "data/hectad_counts",
    "www/images/startup.gif",
    "www/images/no_image_thumb.gif",
    "www/images/no_image.gif",
    "www/images/species",
    "www/phenology"
  )

  with_app_dir({
    expect_true(all(file.exists(required_paths)))
  })
})

test_that("startup data files load and have expected objects", {
  with_app_dir({
    app <- source_app()
    app_data <- app$load_app_data()
  })

  expect_named(app_data, c("GBR", "image_information", "speciesDataRaw"))
  expect_s4_class(app_data$GBR, "SpatialPolygonsDataFrame")
  expect_true(nrow(app_data$image_information) > 0)
  expect_true(nrow(app_data$speciesDataRaw) > 0)
})

test_that("load_app_data sources internal helper functions used by the server", {
  app <- source_app()

  with_app_dir({
    app$load_app_data(envir = app)
  })

  expected_helpers <- c(
    "gatherData",
    "geoCode",
    "gps_latlon2gr",
    "monthsdays",
    "neigh_smooth",
    "reformat_gr"
  )

  for (helper_name in expected_helpers) {
    expect_true(exists(helper_name, envir = app, inherits = FALSE))
    expect_true(is.function(get(helper_name, envir = app, inherits = FALSE)))
  }
})

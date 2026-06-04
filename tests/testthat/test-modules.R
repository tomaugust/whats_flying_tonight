test_that("about_ui exposes the expected controls and panel", {
  app <- source_app()

  about_html <- as.character(with_app_dir(app$about_ui()))

  expect_match(about_html, 'id="about_button"', fixed = TRUE)
  expect_match(about_html, 'id="about_exit"', fixed = TRUE)
  expect_match(about_html, 'id="about_display"', fixed = TRUE)
  expect_match(about_html, "What's flying tonight", fixed = TRUE)
  expect_true(is.function(app$about_server))
})

test_that("settings_ui exposes the expected controls and panel", {
  app <- source_app()

  settings_html <- as.character(with_app_dir(app$settings_ui()))

  expected_ids <- c(
    'id="settings_display"',
    'id="setting_button"',
    'id="settings_exit"',
    'id="location_man"',
    'id="submit"',
    'id="googlelocation"',
    'id="use_date"',
    'id="month_man"',
    'id="day_selector"',
    'id="sortBy"',
    'id="NtoShow"'
  )

  for (expected_id in expected_ids) {
    expect_match(settings_html, expected_id, fixed = TRUE)
  }
  expect_true(is.function(app$settings_server))
})

test_that("settings date helpers derive day-month and Julian day", {
  app <- source_app()

  expect_true(is.function(app$settings_day_month))
  expect_true(is.function(app$settings_jday))
  expect_equal(app$settings_day_month(TRUE, 19, "May"), "19-May")
  expect_equal(app$settings_day_month(FALSE, 1, "Jan", as.POSIXct("2026-06-04")), "04-Jun")
  expect_equal(app$settings_jday("19-May"), as.POSIXlt(as.Date("19-May", "%d-%b"))$yday)
})

test_that("location module exposes server and coordinate conversion helpers", {
  app <- source_app()

  expect_true(is.function(app$location_server))
  expect_true(is.function(app$location_to_hectad))
})

test_that("location_to_hectad converts known coordinates and handles outside UK", {
  app <- source_app()
  app_data <- with_app_dir(app$load_app_data(envir = app))

  with_app_dir({
    expect_equal(app$location_to_hectad(51.5726252643099, -1.15602754938942, app_data$GBR), "SU58")
    expect_equal(app$location_to_hectad(40.7128, -74.0060, app_data$GBR), "notuk")
  })
})

test_that("app_ui composes the extracted panels and output placeholders", {
  app <- source_app()

  app_html <- as.character(with_app_dir(app$app_ui()))

  expected_ids <- c(
    'id="loading"',
    'id="geolocation_denied"',
    'id="settings_display"',
    'id="about_display"',
    'id="UI"',
    'id="bottom-box"'
  )

  for (expected_id in expected_ids) {
    expect_match(app_html, expected_id, fixed = TRUE)
  }
})

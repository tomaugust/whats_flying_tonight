test_that("app launches and renders expected static controls", {
  skip_if_not_installed("shinytest2")

  app <- shinytest2::AppDriver$new(
    app_dir,
    name = "wft-smoke",
    load_timeout = 10000,
    check_names = FALSE,
    shiny_args = list(host = "127.0.0.1")
  )
  on.exit(app$stop(), add = TRUE)

  expect_match(app$get_text("#loading"), "Loading")
  expect_match(app$get_text("#setting_button"), "Settings")
  expect_match(app$get_text("#about_button"), "About")
})

test_that("about panel opens and closes from the footer button", {
  skip_if_not_installed("shinytest2")

  app <- shinytest2::AppDriver$new(
    app_dir,
    name = "wft-about",
    load_timeout = 10000,
    check_names = FALSE,
    shiny_args = list(host = "127.0.0.1")
  )
  on.exit(app$stop(), add = TRUE)

  expect_false(app$get_js("$('#about_display').is(':visible')"))

  app$click(selector = "#about_button")
  app$wait_for_js("$('#about_display').is(':visible')", timeout = 3000)

  expect_true(app$get_js("$('#about_display').is(':visible')"))
  expect_match(app$get_text("#about_display"), "What's flying tonight")

  app$click(selector = "#about_exit")
  app$wait_for_js("!$('#about_display').is(':visible')", timeout = 3000)

  expect_false(app$get_js("$('#about_display').is(':visible')"))
})

test_that("settings panel opens and closes from the footer button", {
  skip_if_not_installed("shinytest2")

  app <- shinytest2::AppDriver$new(
    app_dir,
    name = "wft-settings",
    load_timeout = 10000,
    check_names = FALSE,
    shiny_args = list(host = "127.0.0.1")
  )
  on.exit(app$stop(), add = TRUE)

  expect_false(app$get_js("$('#settings_display').is(':visible')"))
  expect_true(app$get_js("
    var button = document.getElementById('setting_button');
    var rect = button.getBoundingClientRect();
    var topElement = document.elementFromPoint(rect.left + rect.width / 2, rect.top + rect.height / 2);
    button === topElement || button.contains(topElement);
  "))

  app$click(selector = "#setting_button")
  app$wait_for_js("$('#settings_display').is(':visible')", timeout = 3000)

  expect_true(app$get_js("$('#settings_display').is(':visible')"))
  expect_match(app$get_text("#settings_display"), "Set location manually")
  expect_match(app$get_text("#settings_display"), "Use different date")
  expect_match(app$get_text("#settings_display"), "Sort by")

  app$click(selector = "#settings_exit")
  app$wait_for_js("!$('#settings_display').is(':visible')", timeout = 3000)

  expect_false(app$get_js("$('#settings_display').is(':visible')"))
})

test_that("manual location search resolves a known UK place", {
  skip_if_not_installed("shinytest2")

  app <- shinytest2::AppDriver$new(
    app_dir,
    name = "wft-location-search",
    load_timeout = 10000,
    check_names = FALSE,
    shiny_args = list(host = "127.0.0.1")
  )
  on.exit(app$stop(), add = TRUE)

  app$click(selector = "#setting_button")
  app$wait_for_js("$('#settings_display').is(':visible')", timeout = 3000)
  app$set_inputs(location_man = "Wallingford")
  app$click(selector = "#submit")
  app$wait_for_js("$('#googlelocation').text().indexOf('Wallingford') >= 0", timeout = 15000)

  expect_match(app$get_text("#googlelocation"), "Wallingford")
})

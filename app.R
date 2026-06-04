app_env <- new.env(parent = globalenv())

source("R/data_load.R", local = app_env)
source("R/about.R", local = app_env)
source("R/settings.R", local = app_env)
source("R/location.R", local = app_env)
source("R/app_ui.R", local = app_env)
source("R/app_server.R", local = app_env)

app_data <- app_env$load_app_data(envir = app_env)

shiny::shinyApp(
  ui = app_env$app_ui(),
  server = function(input, output, session) {
    app_env$app_server(input, output, session, app_data = app_data)
  }
)

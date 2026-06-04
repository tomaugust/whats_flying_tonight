
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyjs)

app_ui <- function() {
  fluidPage(
  
  useShinyjs(),
  
  tags$head(
    
    HTML(paste0('<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=no"/>
          <meta name="mobile-web-app-capable" content="yes">
          <meta name="apple-mobile-web-app-capable" content="yes">
          <meta name="apple-mobile-web-app-title" content="What',"'",'s flying tonight">
          <meta name="application-name" content="What',"'",'s flying tonight">
          <link rel="icon" href="favicon.ico" type="image/x-icon" >
          <link rel="apple-touch-icon" sizes="57x57" href="apple-touch-icon-57x57.png" >
          <link rel="apple-touch-icon" sizes="72x72" href="apple-touch-icon-72x72.png" >
          <link rel="apple-touch-icon" sizes="76x76" href="apple-touch-icon-76x76.png" >
          <link rel="apple-touch-icon" sizes="114x114" href="apple-touch-icon-114x114.png" >
          <link rel="apple-touch-icon" sizes="120x120" href="apple-touch-icon-120x120.png" >
          <link rel="apple-touch-icon" sizes="144x144" href="apple-touch-icon-144x144.png" >
          <link rel="apple-touch-icon" sizes="152x152" href="apple-touch-icon-152x152.png" >
          <link rel="apple-touch-icon" sizes="180x180" href="apple-touch-icon-180x180.png" >')),
    # Include our custom CSS
    includeCSS("styles.css"),
    includeCSS("lightbox.css"),
    includeCSS('addtohomescreen.css'),
    includeScript("google_analytics.js"),
    includeScript(path = 'www/location.js'),
    includeScript(path = 'www/addtohomescreen.js'),
    tags$script('addToHomescreen({
                                  icon: false
                             });')
  ),

  # Loading text
  div(id = 'loading',
      h3('Loading...'),
      p("Using your location and today's date to build your custom report"),
      img(src = 'images/startup.gif', alt = 'loading', style = 'margin-top: 20px; background: #ffffff85;'),
      br(),
      actionButton("skip_load", "Skip")),
  # No gelocation text
  hidden(h5(id = 'geolocation_denied',
            align = 'center',
            paste("You have denied access to your location.",
                  "To allow access clear your cache for this page", 
                  "and then select 'allow' when prompted"))
  ),
  settings_panel_ui(),
  # hidden(h5(id = 'hectad_unknown',
  #           align = 'center',
  #           paste("The location selected is unknown.",
  #                 "Try selecting a new manual location",
  #                 "in the settings menu"))
  # ),
  htmlOutput('UI'),
  div(id = 'bottom-box'),
  settings_controls_ui(),
  about_ui(),
  
    includeScript("lightbox.js")
  )
}

about_ui <- function() {
  tagList(
    actionButton('about_button', 'About'),
    hidden(actionButton('about_exit', 'X')),
    div(id = 'about_display',
        a(href = 'http://butterfly-conservation.org/',
          target = '_blank',
          img(src = 'BClogo.gif', style = 'width: 93%; max-width: 300px; display: block; margin-top: 8px; margin-left: auto; margin-right: auto; border: 10px; border-style: solid; border-color: white;')),
        p(HTML(paste("What's flying tonight uses UK sightings of larger (macro-) moths gathered by the <a class = 'about', href =",
                "'http://www.mothscount.org/text/27/national_moth_recording_scheme.html'",
                " target='_blank'> National Moth Recording scheme</a> from 2005 to 2013.",
                "The list shows the larger moth species previously recorded in this area (a block of nine 10km x 10km grid squares centred on your location) at around this date (a nine-day period centred on today’s date) and the number of sightings of each.")),
                style = 'width: 98%; max-width: 300px; font-size: small; text-align: center; color: white; display: block; background-color: dimgray; margin-top: 5px; margin-bottom: 5px; margin-left: auto; margin-right: auto; padding: 1px 1px 1px 1px;'),
        p(HTML(paste0("Site built by the <a class = 'about', href = 'http://www.brc.ac.uk/', target = '_blank'>Biological Records Centre</a>,",
                      " supported by the <a class = 'about', href = 'http://www.ceh.ac.uk/', target = '_blank'>Centre for Ecology & Hydrology</a>",
                      ", <a class = 'about', href = 'http://butterfly-conservation.org/', target = '_blank'>Butterfly Conservation</a>",
                      ", <a class = 'about', href = 'http://www.ukmoths.org.uk/', target = '_blank'>UKmoths</a>",
                      ", and the <a class = 'about', href = 'http://jncc.defra.gov.uk/', target = '_blank'>Joint Nature Conservation Committee</a>.",
                      " This application is hosted by the <a class = 'about', href = 'http://www.ceh.ac.uk/our-science/science-areas/environmental-informatics', target = '_blank'>CEH’s Environment Informatics Programme</a>.")),
          style = 'width: 98%; max-width: 300px; font-size: small; text-align: center; color: white; display: block; background-color: dimgray; margin-top: 5px; margin-bottom: 5px; margin-left: auto; margin-right: auto; padding: 1px 1px 1px 1px;'),
        p(HTML(paste("<a class = 'about', href = 'http://www.ukmoths.org.uk/use-of-images/', target = '_blank'>Images are the copyright of their owners</a>")),
          style = 'width: 98%; max-width: 300px; font-size: small; text-align: center; color: white; display: block; background-color: dimgray; margin-top: 5px; margin-bottom: 5px; margin-left: auto; margin-right: auto; padding: 1px 1px 1px 1px;'),
        a(href = 'http://www.brc.ac.uk/',
          target = '_blank',
          img(src = 'BRClogo.png', style = 'width: 93%; max-width: 300px; display: block; margin-left: auto; margin-right: auto;')))
  )
}

about_server <- function(input, output, session) {
  observeEvent(input$about_button,
               {
                 shinyjs::hide(id = 'settings_display', anim = TRUE,
                      animType = 'fade', time = 0.2)
                 shinyjs::show(id = 'about_exit',  anim = TRUE,
                      animType = 'fade', time = 0.2)
                 shinyjs::show(id = 'about_display',  anim = TRUE,
                      animType = 'fade', time = 0.2)
                 shinyjs::hide(id = 'setting_button', anim = TRUE,
                      animType = 'fade', time = 0.2)
               })

  observeEvent(input$about_exit,
               {
                 shinyjs::hide(id = 'about_display', anim = TRUE,
                      animType = 'fade', time = 0.2)
                 shinyjs::hide(id = 'settings_display', anim = TRUE,
                      animType = 'fade', time = 0.2)
                 shinyjs::hide(id = 'settings_exit',  anim = TRUE,
                      animType = 'fade', time = 0.2)
                 shinyjs::hide(id = 'about_exit',  anim = TRUE,
                      animType = 'fade', time = 0.2)
                 shinyjs::show(id = 'about_button', anim = TRUE,
                      animType = 'fade', time = 0.2)
                 shinyjs::show(id = 'setting_button', anim = TRUE,
                      animType = 'fade', time = 0.2)
               })
}

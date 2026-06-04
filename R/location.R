location_to_hectad <- function(lat, long, GBR) {
  my_point <- SpatialPoints(coords = data.frame(long, lat),
                            proj4string = CRS(proj4string(obj = GBR)))
  country <- over(my_point, GBR)$NAME_1

  if(identical(country, 'Northern Ireland')){ # NI
    gr <- gps_latlon2gr(latitude = lat, longitude = long, out_projection = 'OSNI')
    return(reformat_gr(gr$GRIDREF, prec_out = 10000))
  } else if(is.na(country)){ # Outside UK
    return('notuk')
  } else { # GB
    gr <- gps_latlon2gr(latitude = lat, longitude = long, out_projection = 'OSGB')
    return(reformat_gr(gr$GRIDREF, prec_out = 10000))
  }
}

location_server <- function(input, output, session, GBR) {
  # Get hectad using browser geolocation
  hectad_loc <- reactive({
    if(!is.null(input$lat)){
      # lat <- 54.592104
      # long <- -5.967430#ni
      # long <- -1.967430#uk
      # long <- -150.967430#notuk

      return(location_to_hectad(lat = input$lat, long = input$long, GBR = GBR))
    }
  })

  observe({
    if(!is.null(input$lat)){
      cat(paste('lat:', input$lat))
      cat(paste('\nlong:', input$long))
    }
  })

  # Read in the Google location when the button is pressed
  location_man <- eventReactive(input$submit, {
    return(input$location_man)
  })

  GCode <- reactive ({
    textLocation <- location_man()
    cat('\n', textLocation, '\n')
    str(textLocation)
    GCode <- geoCode(paste0(as.character(textLocation), ', UK'))
    return(GCode)
  })

  output$googlelocation <- renderText({
    cat('\n', GCode()[4], '\n')
    if(is.na(GCode()[4])){
      return('Location unknown')
    } else {
      return(GCode()[4])
    }
  })

  # Select hectad to use
  hectad <- reactive({
    if(input$skip_load > 0 & input$submit == 0){
      return('skip')
    } else if(!is.null(input$lat) & input$submit == 0){
      hectad_loc()
    } else if(location_man() != ''){

      GCode_progress <- shiny::Progress$new()
      # Make sure it closes when we exit this reactive, even if there's an error
      on.exit(GCode_progress$close())

      GCode_progress$set(message = "Resolving location", value = 0.2)

      GCode <- GCode()

      if(any(is.na(GCode[1:2]))){ # error message like no data

        return(NULL)

      }

      lat <- as.numeric(GCode[1])
      long <- as.numeric(GCode[2])

      cat(lat,long) # without this cat the next line fails
      # I HAVE NO IDEA WHY!

      return(location_to_hectad(lat = lat, long = long, GBR = GBR))

      GCode_progress$set(message = "Resolving location", value = 1)

      # input$hectad_man
    } else {
      return(NULL)
    }
  })

  # If geolocation is not given this is displayed and the loading text is hidden
  observe({
    if(!is.null(input$geolocation) & is.null(input$lat)){
      cat(paste('Geo:', input$geolocation))
      if(!input$geolocation & input$submit == 0){
        shinyjs::hide('loading', anim = FALSE)
        shinyjs::show(id = 'geolocation_denied', anim = TRUE, animType = 'fade')
      } else if(!input$geolocation & location_man() != ''){
        shinyjs::hide(id = 'geolocation_denied', anim = TRUE, animType = 'fade')
      }
    }
  })

  list(
    hectad = hectad,
    location_man = location_man
  )
}

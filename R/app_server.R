# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)
library(shinyjs)
library(sp)
library(RCurl)
library(RJSONIO)
library(plyr)

app_server <- function(input, output, session, app_data) {
  GBR <- app_data$GBR
  image_information <- app_data$image_information
  speciesDataRaw <- app_data$speciesDataRaw

  location <- location_server(input, output, session, GBR)
  hectad <- location$hectad
  location_man <- location$location_man

  settings <- settings_server(input, output, session)
  dayMonth <- settings$dayMonth
  jDay <- settings$jDay
  
  # Gather the data
  speciesData_raw <- reactive({
    if(input$skip_load > 0 & input$submit == 0){
      cat(paste('\nHectad:', 'skip', '\n'))
      return('skip')
    } else if(!is.null(hectad())){
      
      cat(paste('\nHectad:', hectad(), '\n'))
      
      if(identical(hectad(), 'notuk')) return(hectad())

      recData <- gatherData(hectad = hectad(),
                            jDay = jDay(),
                            radius = 1,
                            dayBuffer = 4)
      
      if(identical(recData, NA)){
        return(NA)
      } else if(nrow(recData) == 0){
        return(NULL)
      } else {
        speciesData <- merge(x = recData, y = speciesDataRaw,
                             by.x = 'species', by.y = 'new_concept',
                             all.x = TRUE, all.y = FALSE, sort = FALSE)
        return(speciesData)
      }
      
    }
  }) 
  
  # Sort the data
  speciesData <- reactive({
    
    if(any(identical(speciesData_raw(), 'notuk'),
           identical(speciesData_raw(), 'skip'),
           identical(speciesData_raw(), NA),
           is.null(speciesData_raw()))){
      return(speciesData_raw())
    }
    
    if(nrow(speciesData_raw()) != 0){
      if(input$sortBy == 'records'){
        return(speciesData_raw())
      } else if(input$sortBy == 'english'){
        return(speciesData_raw()[order(gsub('^the[[:space:]]', '', tolower(speciesData_raw()$new_englishname))),])
      } else if(input$sortBy == 'latin'){
        return(speciesData_raw()[order(speciesData_raw()$new_binomial), ])
      }
    } else {
      return(speciesData_raw())
    }
  })
  
  # how many species to show
  n_to_show <- reactive({
    
    if(input$NtoShow == 'All'){
      return(nrow(speciesData()))
    } else if(input$NtoShow == 'Top 10'){
      return(min(nrow(speciesData()), 10))
    } else if(input$NtoShow == 'Top 25'){
      return(min(nrow(speciesData()), 25))
    } else if(input$NtoShow == 'Top 50'){
      return(min(nrow(speciesData()), 50))
    } else if(input$NtoShow == 'Top 100'){
      return(min(nrow(speciesData()), 100))
    }
    
  })

  # Build species divs
  divList <- reactive({
    
    if(!is.null(hectad())){
      
      html <- list()
      
      speciesData <- speciesData()
      
      cat(str(speciesData))
      
      if(identical(speciesData, 'notuk')){ 
        # if na there no hectad data files for their locations
        # or the surrounding area, tell them they need to be
        # in the UK
        temp_html <- tags$div(id = 'notuk',
                              align = 'center',
                              tags$span('Sorry, you are currently outside the UK. Use settings to view data from another location')
        )
        
        html <- list(temp_html)
        
      } else if(identical(speciesData, 'skip')){
        temp_html <- tags$div(id = 'nodata',
                              align = 'center',
                              tags$span('Please choose a location in the settings menu')
        )
        
        html <- list(temp_html)
        
      } else {
      
        Report_progress <- shiny::Progress$new()
        # Make sure it closes when we exit this reactive, even if there's an error
        on.exit(Report_progress$close())
        
        Report_progress$set(message = "Building report", value = 0.1)        
        
        # If data are present build the species panels
        if(!is.null(speciesData)){
          
          # Add location div at the top
          hec_div <- tags$div(id = 'tet_top',
                              align = 'center',
                              tags$div(span('Showing larger moths likely to be flying in',
                                            a(hectad(), href = paste('http://www.bnhs.co.uk/focuson/grabagridref/html/index.htm?gr=',
                                                                     hectad(),
                                                                     '&en100=false&en1000=false&en2000=false',
                                                                     sep = ''),
                                              target = '_blank'),
                                            'on', dayMonth())
                              )
          )
          
          html <- append(html, list(hec_div))
          
          for(i in 1:n_to_show()){
            
            big_phenology <- speciesData[i, 'phenobig']
            small_phenology <- speciesData[i, 'phenosmall']
            
            # Create species gallery links
            galleryLinks <- list()
            
            sp_name <- gsub('.', '', gsub('/', '', gsub(' ', '_', speciesData[i, 'NAME'])), fixed = TRUE)
            images_dir <- 'www/images/species'
            species_dir <- file.path(images_dir, sp_name)
            thumb_dir <- file.path(images_dir, sp_name, 'thumbnail')
            
            if(dir.exists(species_dir)){ 
              # there is a folder for this species
              if(dir.exists(thumb_dir)){
                # thumbnail dir exists
                # add thumbnail
                thumb_images <- list.files(thumb_dir, pattern = 'jpg$')
                thumb_small <- thumb_images[grep('^thumbnail_', thumb_images)][1]
                thumb_big <- thumb_images[grep('^thumbnail_', thumb_images, invert = TRUE)][1]
                thumb_credit <- image_information$CONTRIBUTOR[image_information$FILENAME == thumb_big]
                
                gal_temp <-  tags$a(href = gsub('^www/', '', file.path(thumb_dir, thumb_big)),
                                    'data-lightbox' = speciesData[i,'new_binomial'],
                                    'data-title' = paste(speciesData[i,'new_englishname'],
                                                         speciesData[i,'new_binomial'],
                                                         paste('Credit: ', thumb_credit[1]),
                                                         sep = ' - '),
                                    style = 'width: 100%',
                                    div(style = paste("background: url('",
                                                      gsub('^www/', '', file.path(thumb_dir, thumb_small)),
                                                      "') no-repeat center center; width: 100%; height: 124px;", sep = ''))
                                    )
                
                galleryLinks <- append(galleryLinks, list(gal_temp))
                
                # Then add the rest of the gallery
                if(length(list.files(species_dir, pattern = 'jpg$')) > 0 ){
                  # If there are gallery images
                  for(j in list.files(species_dir, pattern = 'jpg$')){
                    
                    im_credit <- image_information$CONTRIBUTOR[image_information$FILENAME == j]
                    
                    gal_temp <- tags$a(href = gsub('^www/', '', file.path(species_dir, j)),
                                       'data-lightbox' = speciesData[i, 'new_binomial'],
                                       'data-title' = paste(speciesData[i, 'new_englishname'],
                                                            speciesData[i, 'new_binomial'],
                                                            paste('Credit: ', im_credit[1]),
                                                            sep = ' - '))
                    galleryLinks <- append(galleryLinks, list(gal_temp))
                    
                  }
                }
              } else {
                # If no thumbnail exists
                # use 'no image'
                thumb_small <- 'images/no_image_thumb.gif'
                thumb_big <- 'images/no_image.gif'
                
                gal_temp <-  tags$a(href = thumb_big,
                                    'data-lightbox' = speciesData[i, 'new_binomial'],
                                    'data-title' = paste(speciesData[i,'new_englishname'],
                                                         speciesData[i,'new_binomial'],
                                                         'No image available', sep = ' - '),
                                    img(src = thumb_small,
                                        tabindex = 1,
                                        align = 'middle',
                                        height = '100%',
                                        alt = 'No species'))
                galleryLinks <- append(galleryLinks, list(gal_temp))
                
              }
              
            } else {
              # there is no image folder for this species
              # use 'no image'
              thumb_small <- 'images/no_image_thumb.gif'
              thumb_big <- 'images/no_image.gif'
              
              gal_temp <-  tags$a(href = thumb_big,
                                  'data-lightbox' = speciesData[i, 'new_binomial'],
                                  'data-title' = paste(speciesData[i,'new_englishname'],
                                                       speciesData[i,'new_binomial'],
                                                       ' - No image available'),
                                  img(src = thumb_small,
                                      tabindex = 1,
                                      align = 'middle',
                                      height = '100%',
                                      alt = 'No species'))
              galleryLinks <- append(galleryLinks, list(gal_temp))
            }
  
            gallery <- tagList(galleryLinks)
            
            # Create the species div
            temp_html <- tags$div(id = 'species',
                                  align = 'center',
                             
                                 ## left image
                                 tags$div(id = 'image',
                                          HTML(as.character(htmltools::renderTags(gallery)$html))
                                 ),
                             
                                 ## Right text
                                 tags$div(id = 'speciestext',
                                      p(a(href = speciesData[i, 'URL'],
                                        target = '_blank',
                                        strong(speciesData[i,'new_englishname'])),
                                        em(paste0('(', speciesData[i,'new_binomial'], ')')),
                                        style = 'margin: 0px 0 0px;'),
                                      tags$span(paste(speciesData[i,'nrec'],
                                                      ifelse(speciesData[i,'nrec'] > 1, 'records', 'record'))
                                                ),
                                      br(),
                                      ## Phenology plot
                                      a(href = big_phenology,
                                        'data-lightbox' = big_phenology,
                                        'data-title' = paste('Phenology:',
                                                             speciesData[i,'new_englishname'],
                                                             speciesData[i,'new_binomial'],
                                                             sep = ' - '),
                                        img(src = small_phenology,
                                            align = 'middle',
                                            tabindex = 1,
                                            width = '100%',
                                            alt = paste('Phenology:',
                                                        speciesData[i,'new_englishname'],
                                                        speciesData[i,'new_binomial'],
                                                        sep = ' - ')))
                             )
            )
              
            html <- append(html, list(temp_html))
            
            # If this the last species say what show length we are working with
            if(i == n_to_show()){
              
              # Create the species div
              show_n_html <- tags$div(id = 'show_n',
                                    align = 'center',
                                    
                                    ## left image
                                    tags$div(id = 'show_length',
                                             paste('Showing', input$NtoShow, '- this can be changed in settings')
                                    ))
              
              html <- append(html, list(show_n_html))
              
            }
            
            Report_progress$inc(0.9/n_to_show())        
            
          } # end of species loop
        } else { # No data available
          
          if(is.null(hectad())){
            temp_html <- tags$div(id = 'nodata',
                                  align = 'center',
                                  tags$span('Unknown location: please choose a new location in the settings menu')
            )
          } else{
            temp_html <- tags$div(id = 'nodata',
                                  align = 'center',
                                  tags$span('There are no records of moths in this area at this time of year')
                                  )
          }
          
          
          html <- list(temp_html)
          
        }
      }

      tagList(html)
    } 
  })

  # output species divs
  output$UI <- renderUI({
    
    divList()
    
  })
  
  # Loading div
  observe({
    if(!is.null(divList())){
      hide('loading', anim = FALSE)
    }
  })
  

  ###############################
  ## Settings and About boxes ###
  ###############################
  
  about_server(input, output, session)
  
}

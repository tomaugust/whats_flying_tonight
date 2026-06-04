settings_ui <- function() {
  tagList(
    settings_panel_ui(),
    settings_controls_ui()
  )
}

settings_panel_ui <- function() {
  tagList(
    div(id = 'settings_display',
        tags$b(id = 'location_title', 'Set location manually'),
        br(),
        # checkboxInput('use_man',
        #               'Use different location?',
        #               FALSE),
        # selectInput('hectad_man',
        #             label = NULL,
        #             sort(gsub('.rdata$',
        #                       '',
        #                       list.files('data/hectad_counts/',
        #                                  pattern = '.rdata$'))),
        #             selectize = TRUE,
        #             multiple = FALSE, width = '100px'),
        div(class = 'row',
            div(class = 'span4',
                div(id = 'month_man_div',
                    textInput(inputId = 'location_man',
                              label = NULL, value = '',
                              placeholder = 'e.g. Selbourne, Hampshire',
                              width = '100%')),
                actionButton("submit", "Go", width = '44px')
            )
        ),
        textOutput('googlelocation'),
        div(id = 'date_title', tags$b('Date')),
        checkboxInput('use_date',
                      'Use different date?',
                      FALSE),
        div(class = 'row',
            div(class = 'span4',
                div(id = 'month_man_div',
                    selectInput('month_man',
                                selected = format(Sys.Date(), '%b'),
                                label = NULL,
                                format(ISOdate(2004,1:12,1),"%b"),
                                selectize = TRUE,
                                multiple = FALSE, width = '80px')),
                uiOutput('day_selector')
            )
        ),
        radioButtons('sortBy',
                     label = 'Sort by',
                     choices = list('Number of records' = 'records',
                                    'Common name' = 'english',
                                    'Scientific name' = 'latin')),
        tags$b(id = 'date_title', 'Show...'),
        br(),
        selectInput('NtoShow',
                    label = NULL,
                    c('All', 'Top 10', 'Top 25', 'Top 50', 'Top 100'),
                    selectize = FALSE,
                    multiple = FALSE,
                    selected = 'Top 50',
                    width = '100px')
    )
  )
}

settings_controls_ui <- function() {
  tagList(
    actionButton('setting_button', 'Settings'),
    hidden(actionButton('settings_exit', 'X'))
  )
}

settings_day_month <- function(use_date, day_man, month_man, current_time = Sys.time()) {
  if(!use_date){
    format(current_time, '%d-%b')
  } else if(use_date){
    paste(day_man,
          month_man,
          sep = '-')
  }
}

settings_jday <- function(day_month) {
  as.POSIXlt(as.Date(day_month, '%d-%b'))$yday
}

settings_server <- function(input, output, session) {
  dayMonth <- reactive({
    settings_day_month(input$use_date, input$day_man, input$month_man)
  })

  jDay <- reactive({
    settings_jday(dayMonth())
  })

  output$day_selector <- renderUI({
    # tagList(
      selectInput('day_man',
                  label = NULL,
                  selected = as.numeric(format(Sys.Date(), '%d')),
                  1:monthsdays(input$month_man),
                  selectize = TRUE,
                  multiple = FALSE, width = '60px')
    # )
  })

  outputOptions(output, 'day_selector', suspendWhenHidden=FALSE)

  observeEvent(input$setting_button,
               {
                 shinyjs::show(id = 'settings_display', anim = TRUE,
                               animType = 'fade', time = 0.2)
                 shinyjs::show(id = 'settings_exit',  anim = TRUE,
                               animType = 'fade', time = 0.2)
                 shinyjs::hide(id = 'about_button', anim = TRUE,
                               animType = 'fade', time = 0.2)
                 shinyjs::hide(id = 'about_display', anim = TRUE,
                               animType = 'fade', time = 0.2)
               })

  observeEvent(input$settings_exit,
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

  list(
    dayMonth = dayMonth,
    jDay = jDay
  )
}

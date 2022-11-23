#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
    output$dynamicmaptimeslider = renderUI({
      sliderInput(inputId = "dynamicmaptimestep", 
                  label = "Date:",
                  min = as.Date(input$daterange1[1],"%Y-%m-%d"),
                  max = as.Date(input$daterange1[2],"%Y-%m-%d"),
                  value = as.Date(input$daterange1[2]), timeFormat="%Y-%m-%d", 
                  step = 1,
                  animate = animationOptions(interval = 300))
    })
  

    output$RatMap = renderPlot({
      
      ggmap(nyc) + 
        geom_point(data = data %>% filter(Date >= input$daterange1[1],
                                          Date < input$dynamicmaptimestep)
                              , aes(x=Longitude, y=Latitude), 
                              alpha=0.25, color='brown', size=0.5)  + 
        geom_point(data = data %>% filter(Date == input$dynamicmaptimestep)
                   , aes(x=Longitude, y=Latitude), 
                   alpha=1, color='blue', size=1)  + 
      labs(title="NYC 311 Rodent Sightings", 
           subtitle = paste("From ", input$daterange1[1], " to ", input$dynamicmaptimestep))

    })
    
    output$DailyComplaints = renderPlot({
      daily_reports %>% filter(Date >= input$daterange1[1],
                               Date <= input$daterange1[2]) %>%
                        ggplot(aes(x=Date, y=Reports)) +
                        geom_point(col='brown') + 
        labs(title="NYC 311 Rodent Sightings", 
             subtitle = paste("From ", input$daterange1[1], " to ", input$daterange1[2]),
             y = 'Daily Rodent Sightings', x = 'Date')
    })
    
    output$LocationChart = renderPlot({
      data %>%  filter(Date >= input$daterange1[1],
                       Date <= input$daterange1[2]) %>%
                ggplot(aes(x=fct_rev(fct_infreq(Location.Type)))) + 
                geom_bar(col='black', fill='brown') + coord_flip() +
                labs(title = "NYC 311 Rodent Sightings by Location Type", 
                     subtitle = paste("From ", input$daterange1[1], " to ", input$daterange1[2]),
                     x='Location Type', y = 'Total Reports') +
                theme(axis.text = element_text(size=10))
    })
    
    output$tempreportlinearplot = renderPlot({
      ggplot(data=daterange1(), aes(x=TMIN, y=Reports)) +
        geom_point(col='brown') +
        geom_smooth(method='lm') +
        labs(title="NYC 311 Daily Rodent Sightings and Daily Minimum Temperature",
             x = "Daily Minimum Temperature (ºC)",
             y = "Daily Rodent Sightings")
    })
    
    output$tempreporttimeplot = renderPlot({
      ggplot(data=daterange1()) +
        geom_point(aes(x=Date, y=Reports, colour='Daily Rodent Sightings')) +
        geom_point(aes(x=Date, y=TMIN, colour='Daily Minimum temperature')) +
        scale_y_continuous(sec.axis=sec_axis(~., name='Daily Minimum Temperature')) +
        labs(title = "Daily NYC 311 Rodent Sightings and Minimum Temperature",
             color='Data Source') +
        theme(legend.position='bottom')
      
    })
    
    
    daterange1 = reactive({
      daily_reports %>% filter(Date >= input$daterange1[1],
                               Date <= input$daterange1[2])
    })
    
    daterange2 = reactive({
      daily_reports %>% filter(Date >= input$daterange2[1],
                               Date <= input$daterange2[2])
    })
    
    output$TemperaturesComparisonChart = renderPlot({
      ggplot(data=daterange1(), aes(x=Date, y=TMIN, col='Primary Date Range')) +
      geom_point() +
      geom_point(data=daterange2(), aes(x=Date, y=TMIN, col='Secondary Date Range')) +
      labs(title="Daily Minimum Temperature Over Time", 
           subtitle=paste("From ", input$daterange1[1], " to ", input$daterange1[2], 
                          " and ", input$daterange2[1], " to ", input$daterange2[2])) +
      ylab("Daily Minimum Temperature (ºC)")
    })
    
    output$ReportsComparisonChart = renderPlot({
      ggplot(data=daterange1(), aes(x=Date, y=Reports, col='Primary Date Range')) +
      geom_point() +
      geom_point(data=daterange2(), aes(x=Date, y=Reports, col='Secondary Date Range')) +
      labs(title="311 Rodent Sightings Per Day", 
           subtitle=paste("From ", input$daterange1[1], " to ", input$daterange1[2], 
                          " and ", input$daterange2[1], " to ", input$daterange2[2])) +
      ylab("Daily Rodent Sightings")
    })
    
    output$ttest = renderPrint({
      ttest = t.test(daterange1()$Reports, daterange2()$Reports)
      ttest
    })
    
    output$wilcoxtest = renderPrint({
      wilcoxtest = wilcox.test(daterange1()$Reports, daterange2()$Reports)
      wilcoxtest
    })

    
    
})

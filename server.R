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
  

    output$RatMap = renderPlot({
      
      ggmap(nyc) + geom_point(data = data %>% filter(Date >= input$daterange1[1],
                                                     Date <= input$daterange1[2])
                              
                              , aes(x=Longitude, y=Latitude), 
                              color='brown', size=0.1)

    })
    
    output$DailyComplaints = renderPlot({
      daily_reports %>% filter(Date >= input$daterange1[1],
                               Date <= input$daterange1[2]) %>%
                        ggplot(aes(x=Date, y=Reports)) +
                        geom_point(col='brown')
    })
    
    output$LocationChart = renderPlot({
      data %>%  filter(Date >= input$daterange1[1],
                       Date <= input$daterange1[2]) %>%
                ggplot(aes(x=fct_rev(fct_infreq(Location.Type)))) + 
                geom_bar(col='black', fill='brown') + coord_flip() +
                labs(x='Location Type', y = 'Total Reports') +
                theme(axis.text = element_text(size=5))
    })
    
    
    output$TemperaturesChart1 = renderPlot({
      daily_reports %>%  filter(Date >= input$daterange1[1],
                                 Date <= input$daterange1[2]) %>%
                          ggplot(aes(x=Date, y=TMIN)) +
                          geom_point()
    })
    
    output$TemperaturesChart2 = renderPlot({
      daily_reports %>%  filter(Date >= input$daterange2[1],
                                 Date <= input$daterange2[2]) %>%
                          ggplot(aes(x=Date, y=TMIN)) +
                          geom_point()
    })
      
    comparison_ols = reactive({
      group1indices = which((daily_reports$Date >= input$daterange1[1]) & (daily_reports$Date <= input$daterange1[2]))
      group2indices = which((daily_reports$Date >= input$daterange2[1]) & (daily_reports$Date <= input$daterange2[2]))
      
      comparison_ols = lm(Reports ~ TMIN, daily_reports[c(group1indices, group2indices),])
      # 
      # group1predictions = predict(comparison_ols, daily_reports[group1indices,])
      # group1residuals = daily_reports[group1indices,]$Reports - group1predictions
      # group2predictions = predict(comparison_ols, daily_reports[group2indices,])
      # group2residuals = daily_reports[group2indices,]$Reports - group2predictions
      # 
      # daily_reports %>% mutate(
      #                   group1predictions = group1predictions,
      #                   group2predictions = group2predictions,
      #                   group1residuals = group1residuals,
      #                   group2residuals = group2residuals
      # )
    })
    
    
    output$FittedComplaints1 = renderPlot({
      
      predictions = predict(comparison_ols(), daily_reports %>% 
                                              filter(Date >= input$daterange1[1],
                                                     Date <= input$daterange1[2]))

      daily_reports %>%  filter(Date >= input$daterange1[1],
                                Date <= input$daterange1[2]) %>%
                         mutate(Predictions = predictions) %>%
                         ggplot(aes(x=Date)) +
                                geom_point(aes(y=Reports), col='brown') +
                                geom_line(aes(y=Predictions), col='blue') +
                                geom_segment(aes(y=Predictions, 
                                                 xend=Date, yend=Reports), 
                                             col='red', alpha=0.1)
                        
    })
    
    output$FittedComplaints2 = renderPlot({
      
      predictions = predict(comparison_ols(), daily_reports %>% 
                              filter(Date >= input$daterange2[1],
                                     Date <= input$daterange2[2]))
      
      daily_reports %>%  filter(Date >= input$daterange2[1],
                                Date <= input$daterange2[2]) %>%
        mutate(Predictions = predictions) %>%
        ggplot(aes(x=Date)) +
        geom_point(aes(y=Reports), col='brown') +
        geom_line(aes(y=Predictions), col='blue') +
        geom_segment(aes(y=Predictions, 
                         xend=Date, yend=Reports), 
                     col='red', alpha=0.1)
      
    })
    
    
})

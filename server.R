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
                theme(axis.text = element_text(size=10))
    })
    
    output$tempreportlinearplot = renderPlot({
      ggplot(data=daterange1(), aes(x=TMIN, y=Reports)) +
         geom_point(col='brown') +
         geom_smooth(method='lm')
    })
    
    output$tempreporttimeplot = renderPlot({
      ggplot(data=daterange1()) +
        geom_point(aes(x=Date, y=Reports, colour='Reports', col='brown')) +
        geom_point(aes(x=Date, y=TMIN, colour='TMIN', col='black')) +
        scale_y_continuous(sec.axis=sec_axis(~., name='TMIN')) +
        labs(color='Data Source') +
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
      geom_point(data=daterange2(), aes(x=Date, y=TMIN, col='Secondary Date Range'))
    })
    
    output$ReportsComparisonChart = renderPlot({
      ggplot(data=daterange1(), aes(x=Date, y=Reports, col='Primary Date Range')) +
        geom_point() +
        geom_point(data=daterange2(), aes(x=Date, y=Reports, col='Secondary Date Range'))
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

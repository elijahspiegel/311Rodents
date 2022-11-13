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
  

    output$RatMap <- renderPlot({
      
      ggmap(nyc) + geom_point(data = data %>% filter(Date >= input$daterange[1],
                                                     Date <= input$daterange[2])
                              
                              , aes(x=Longitude, y=Latitude), 
                              color='brown', size=0.1)

    })

})

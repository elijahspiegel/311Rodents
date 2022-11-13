#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


shinyUI(fluidPage(

    # Application title
    titlePanel("NYC 311 Rodent Complaints"),

    # Sidebar with a date range input
    sidebarLayout(
        sidebarPanel(
            dateRangeInput("daterange",
                           "Date Range of Complaints",
                           start = '2010-01-01',
                           end = '2022-',
                           min = '2010-01-01',
                           max = '2022-11-02',
                        )
        ),

        mainPanel(
            plotOutput("RatMap")
        )
    )
))

#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shinydashboard)

dashboardPage(
  dashboardHeader(title='NYC 311 Rodent Complaints'),
  
  dashboardSidebar(
    
    dateRangeInput("daterange1",
                   "Date Range of Complaints",
                   start = '2010-01-01',
                   end = '2022-11-02',
                   min = '2010-01-01',
                   max = '2022-11-02',
    ),
    
    
    dateRangeInput("daterange2",
                   "Date Range of Complaints",
                   start = '2010-01-01',
                   end = '2022-11-02',
                   min = '2010-01-01',
                   max = '2022-11-02',
    )
  ),
  
  dashboardBody(
    tabsetPanel(
      tabPanel('Complaint Visualizations', 
               fluidRow(
                 plotOutput("RatMap"),
               plotOutput("DailyComplaints"),
               plotOutput("LocationChart")
               ),
               ),
               
      
      tabPanel('Comparison', 
               "Daily minimum temperatures over date ranges",
               
               fluidRow(
                 plotOutput("TemperaturesComparisonChart"),
               ),

               "Predicted report counts based on OLS against daily minimum temperatures",

               fluidRow(
                 plotOutput("ReportsComparisonChart"),
               ),
               
              verbatimTextOutput("ttest")
               
      )
    )
  )
)

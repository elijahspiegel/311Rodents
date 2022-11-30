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
  dashboardHeader(title='NYC Rodents'),
  
  dashboardSidebar(
    
    dateRangeInput("daterange1",
                   "Primary Date Range",
                   start = '2010-01-01',
                   end = '2022-11-02',
                   min = '2010-01-01',
                   max = '2022-11-02',
    )
    
  ),
  
  dashboardBody(
    tabsetPanel(
      tabPanel('Complaint Exploration', 
         fluidRow(
            uiOutput("dynamicmaptimeslider"),
            plotOutput("RatMap"),
            plotOutput("DailyComplaints"),
            plotOutput("LocationChart")
         ),
      ),
      
      tabPanel('Temperature Exploration',
          fluidRow(
            plotOutput("tempreportlinearplot"),
            plotOutput("tempreporttimeplot")
          )         
      ),
               
      
      tabPanel('Date Range Comparisons', 
               
         dateRangeInput("daterange2", "Secondary Date Range",
                        start = '2010-01-01', end = '2022-11-02',
                        min = '2010-01-01', max = '2022-11-02',),
         
         fluidRow(
           plotOutput("TemperaturesComparisonChart"),
           plotOutput("ReportsComparisonChart"),
         ),
        
         fluidRow(
          verbatimTextOutput("ttest"),
          verbatimTextOutput("wilcoxtest")
         ),
      ),
      
      tabPanel('Borough Exploration',
               fluidRow(
                 plotOutput("boroughsightingschart"),
                 plotOutput("boroughchart"),
                 plotOutput("boroughchartpercapita"),
                 plotOutput("boroughchartpersqmi"),
                 plotOutput("boroughchartperdensity")
                 
               )         
      ),
      
      tabPanel('Open Restaurants Exploration',
               fluidRow(
                 plotOutput("restaurantsightingsgraph")
               )
      )
      
    )
  )
)

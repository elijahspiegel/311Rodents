# 311Rodents

This web app visualizes NYC 311 reports of rat and mouse sightings from 2010 to 2022. 
To use this dashboard, first download the datasets described in 'Sources of data' below and place them in a folder titled 'data'.  

The complaint exploration tab has an animated display of rodent sightings across New York City over the primary date range selected, as well as a visualization of the total sightings per day over the primary date range and a bar chart describing the types of locations associated with the sightings.  

The temperature exploration tab has a scatterplot depicting daily total rodent sightings across the city against daily minimum temperatures over the primary date range selected, as well as a visualization showing the relationship between these two variables over time.

The date range comparisons tab allows the user to select a secondary date range to compare with the primary date range. The daily minimum temperature and daily total rodent sightings across the city are visualized for both date ranges. The tab also includes the statistical results of comparing the daily total rodent sighting between the two date ranges with a T-test and with the Wilcoxon rank sum test.

The borough exploration tab breaks down the daily total rodent sightings during the primary date range between the boroughs of New York City, visualizing these values over time as well as in total, per capita, per square mile, and per density (person per square mile) across the boroughs.  

The Open Restaurants exploration tab includes a visualization of the relationship between the total rodent sightings per person for each zip code since the beginning of New York City's Open Restaurants program and the total number of accepted Open Restaurant applications per person for the respective zip code. The statistical results associated with a linear regression on these values is also included.


Sources of data:  
311RodentData.csv downloaded from [NYC OpenData](https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9), using a filter to export only data with 'Rodent' Complaint Type.  
NOAA_GHCN_NY_Cntrl_Pk.csv downloaded from NOAA GHCN database using an [interface tool from Aaron Penne](https://github.com/aaronpenne/get_noaa_ghcn_data) to access historical data from the [New York Central Park Tower station](https://www.ncdc.noaa.gov/cdo-web/datasets/GHCND/stations/GHCND:USW00094728/detail) (station ID USW00094728).  
Open_Restaurant_Applications.csv downloaded from [NYC OpenData](https://data.cityofnewyork.us/Transportation/Open-Restaurant-Applications/pitm-atqc)  
nyc_zip_borough_neighborhoods_pop.csv downloaded from [BetaNYC](https://data.beta.nyc/en/dataset/pediacities-nyc-neighborhoods/resource/7caac650-d082-4aea-9f9b-3681d568e8a5)

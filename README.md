# 311Rodents

This web app visualizes NYC 311 reports of rat sightings, mouse sightings, and signs of rodents from 2010 to 2022. 
Visualizations are provided over geographic and temporal extent. 


Sources of data:  
311RodentData.csv downloaded from [NYC OpenData](https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9), using a filter to export only data with 'Rodent' Complaint Type.  
NOAA_GHCN_NY_Cntrl_Pk.csv downloaded from NOAA GHCN database using an [interface tool from Aaron Penne](https://github.com/aaronpenne/get_noaa_ghcn_data) to access historical data from the [New York Central Park Tower station](https://www.ncdc.noaa.gov/cdo-web/datasets/GHCND/stations/GHCND:USW00094728/detail) (station ID USW00094728).  
Open_Restaurant_Applications.csv downloaded from [NYC OpenData](https://data.cityofnewyork.us/Transportation/Open-Restaurant-Applications/pitm-atqc)
nyc_zip_borough_neighborhoods_pop.csv downloaded from [BetaNYC](https://data.beta.nyc/en/dataset/pediacities-nyc-neighborhoods/resource/7caac650-d082-4aea-9f9b-3681d568e8a5)

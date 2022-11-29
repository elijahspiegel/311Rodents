library(ggmap)
library(tidyverse)
library(lubridate)

### Preparing background map

nyc = get_stamenmap(bbox = c(left= -74.26, bottom = 40.49, 
                             right = -73.6, top = 40.92), 
                    zoom = 11,
                    maptype='terrain')


### Preparing data

data_raw = read_csv('./data/311RodentData.csv')
# Basic formatting to rename and select relevant columns, set date formatting
data = data_raw %>% mutate(Date = as.Date(mdy_hms(`Created Date`)),
                           Closed.Date = as.Date(mdy_hms(`Closed Date`)),
                           Location.Type = `Location Type`,
                           Incident.Zip = `Incident Zip`,
                           Due.Date = as.Date(mdy_hms(`Due Date`)),
                           Resolution = `Resolution Description`,
                           Resolution.Date = as.Date(mdy_hms(`Resolution Action Updated Date`)),
                           Community.Board = `Community Board`) %>% 
  select('Date', 'Closed.Date', 'Descriptor',
         'Location.Type', 'Incident.Zip', 'City',
         'Status', 'Due.Date', 'Resolution',
         'Resolution.Date', 'Community Board',
         'Borough', 'Latitude', 'Longitude')

# Keep only sightings and signs, i.e. exclude rat bites and condition attracting rodents
data = data %>% filter(Descriptor == 'Rat Sighting' | Descriptor == 'Mouse Sighting')


# Check for NA values in columns, drop those missing data (missing resolution allowed)
sapply(data, function(y) any(is.na(y))) # displays which cols have NA values
data = data %>% drop_na('Incident.Zip', 'Borough', 'City', 'Latitude', 
                        'Longitude', 'Location.Type')
sapply(data, function(y) any(is.na(y))) 

# Join with weather data
weatherdata = read_csv('./data/NOAA_GHCN_NY_Cntrl_Pk.csv') %>%
  select('YEAR', 'MONTH', 'DAY',
         'TMAX', 'TMIN', 'PRCP', 'SNOW') %>%
  mutate(Date = make_date(YEAR, MONTH, DAY),
         TMAX = TMAX / 10,
         TMIN = TMIN / 10) %>%
  filter(YEAR >= 2010)

data = data %>% inner_join(weatherdata)

# Generate info with lat-long

data_geo = data %>% select('Date', 'Latitude', 'Longitude')

# Generate daily report totals with weather data

daily_reports = data %>% group_by(Date) %>%
  summarize(Reports = n()) %>%
  inner_join(weatherdata) 

daily_reports_boro = data %>% group_by(Date, Borough) %>%
  summarize(Reports = n()) %>%
  inner_join(weatherdata) 


boroughstats = data.frame(
  # Statistics from Wikipedia, sourced from 2020 census
  Population = c(1472654, 2736074, 1694263, 2405464, 495747),
  Area = c(42.2, 69.4, 22.7, 108.7, 57.5),
  Density = c(34920, 39438, 74781, 22125, 8618)
)
rownames(boroughstats) = c('BRONX', 'BROOKLYN', 'MANHATTAN', 'QUEENS', 'STATEN ISLAND')


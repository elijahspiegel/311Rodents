library(ggmap)
library(tidyverse)
library(lubridate)

### Preparing background map

nyc = get_stamenmap(bbox = c(left=-74.25, bottom = 40.5, 
                             right = -73.7, top = 40.87), 
                    zoom = 11,
                    maptype='terrain')

# ggmap(nyc) 

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
data = data %>% filter(Descriptor == 'Rat Sighting' | Descriptor == 'Mouse Sighting' | Descriptor == 'Signs of Rodents')


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

# Generate daily report totals with weather data

daily_reports = data %>% group_by(Date) %>%
  summarize(Reports = n()) %>%
  inner_join(weatherdata) 

# Sample map
# ggmap(nyc) + geom_point(data=data, aes(x=Longitude, y=Latitude), color='brown', size=0.1)

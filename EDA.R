library(tidyverse)
library(lubridate)
data_raw = read_csv('./data/311RodentData.csv')

colnames(data_raw)

# Basic formatting to rename and select relevant columns, set date formatting
data = data_raw %>% mutate(Created.Date = mdy_hms(`Created Date`),
                           Closed.Date = mdy_hms(`Closed Date`),
                           Location.Type = `Location Type`,
                           Incident.Zip = `Incident Zip`,
                           Due.Date = mdy_hms(`Due Date`),
                           Resolution = `Resolution Description`,
                           Resolution.Date = mdy_hms(`Resolution Action Updated Date`),
                           Community.Board = `Community Board`) %>% 
                    select('Created.Date', 'Closed.Date', 'Descriptor',
                           'Location.Type', 'Incident.Zip', 'City',
                           'Status', 'Due.Date', 'Resolution',
                           'Resolution.Date', 'Community Board',
                           'Borough', 'Latitude', 'Longitude') %>%
                    mutate(YEAR = year(Created.Date),
                           MONTH = month(Created.Date),
                           DAY= day(Created.Date))

# Keep only sightings and signs, i.e. exclude rat bites and condition attracting rodents
data = data %>% filter(Descriptor == 'Rat Sighting' | Descriptor == 'Mouse Sighting' | Descriptor == 'Signs of Rodents')


# Check for NA values in columns, drop those missing geographic data
sapply(data, function(y) any(is.na(y))) # displays which cols have NA values
data = data %>% drop_na('Incident.Zip', 'Borough', 'City', 'Latitude', 'Longitude')
sapply(data, function(y) any(is.na(y))) 

# Join with weather data
weatherdata = read_csv('./data/NOAA_GHCN_NY_Cntrl_Pk.csv') %>%
              select('YEAR', 'MONTH', 'DAY',
                     'TMAX', 'TMIN', 'PRCP', 'SNOW') %>%
              mutate(MONTH = as.double(MONTH),
                     DAY = as.integer(DAY),
                     TMAX = TMAX / 10,
                     TMIN = TMIN / 10) %>%
              filter(YEAR >= 2010)

data = data %>% inner_join(weatherdata)

# Reports by month, over years
data %>% ggplot(aes(x=month(Created.Date))) + 
         geom_bar(fill='brown', colour='black') +
         facet_wrap(vars(year(Created.Date)))

# Reports by Location Type
data %>%  ggplot(aes(x=fct_rev(fct_infreq(Location.Type)))) + 
          geom_bar(col='black', fill='red') + coord_flip() +
          labs(x='Location Type', y = 'Total Reports (2010-2022)') +
          theme(axis.text = element_text(size=5))





library(tidyverse)
library(lubridate)
library(car)
data_raw = read_csv('./data/311RodentData.csv')

colnames(data_raw)

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


# Check for NA values in columns, drop those missing geographic data
sapply(data, function(y) any(is.na(y))) # displays which cols have NA values
data = data %>% drop_na('Incident.Zip', 'Borough', 'City', 'Latitude', 'Longitude')
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

# Reports by month, over years
data %>% ggplot(aes(x=month(Date))) + 
         geom_bar(fill='brown', colour='black') +
         facet_wrap(vars(year(Date)))

# Reports by Location Type
data %>%  ggplot(aes(x=fct_rev(fct_infreq(Location.Type)))) + 
          geom_bar(col='black', fill='red') + coord_flip() +
          labs(x='Location Type', y = 'Total Reports (2010-2022)') +
          theme(axis.text = element_text(size=5))

# Simple linear regression

daily_reports = data %>% group_by(Date) %>%
                         summarize(Reports = n()) %>%
                         inner_join(weatherdata) 

daily_reports %>% ggplot(aes(x=TMIN, y=Reports)) +
                  geom_point() +
                  geom_smooth(method='lm') +
                  facet_wrap(vars(YEAR))

ols = lm(Reports~.-Date -YEAR -MONTH -DAY, daily_reports)
summary(ols)
plot(ols)
avPlots(ols)

boxcox = boxCox(ols)
lambda = boxcox$x[which(boxcox$y == max(boxcox$y))]
boxcox_reports = ((daily_reports$Reports ^ lambda) - 1)/lambda
boxcox_ols = lm(boxcox_reports~daily_reports$TMIN)
summary(boxcox_ols)
plot(boxcox_ols)
plot(daily_reports$TMIN, boxcox_reports)







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

summary(data)

# Reports by month, over years
data %>% ggplot(aes(x=month(Date))) + 
         geom_bar(fill='brown', colour='black') +
         facet_wrap(vars(year(Date)))

# Reports by Location Type
data %>%  ggplot(aes(x=fct_rev(fct_infreq(Location.Type)))) + 
          geom_bar(col='black', fill='brown') + coord_flip() +
          labs(x='Location Type', y = 'Total Reports (2010-2022)') +
          theme(axis.text = element_text(size=5))

# Generate daily report totals with weather data

daily_reports = data %>% group_by(Date) %>%
                         summarize(Reports = n()) %>%
                         inner_join(weatherdata) 

# Plot overall line of best fit for reports against tmin
daily_reports %>% ggplot(aes(x=TMIN, y=Reports)) +
                  geom_point() +
                  geom_smooth(method='lm')

# Reports over time
daily_reports %>% ggplot(aes(x=Date, y=Reports)) +
                  geom_point()

# TMIN over time
daily_reports %>% ggplot(aes(x=Date, y=TMIN)) +
                  geom_point()

ol_fulls = lm(Reports ~ TMAX + TMIN + PRCP + SNOW, daily_reports)
summary(ols_full)
plot(ols_full)
avPlots(ols_full)

ols = lm(Reports ~ TMIN, daily_reports)
plot(ols)
summary(ols)

residuals = daily_reports$Reports - predict(ols)

# Feature engineering for cyclical data
daily_reports = daily_reports %>% mutate(MONTH = as.numeric(MONTH))
for (i in 2010:2022) {
    ols_sin = lm(Reports ~ TMIN + 
                   (YEAR > i) +
                   sin(((pi/6) * MONTH)) + 
                   cos(((pi/6) * MONTH)), daily_reports)
    print(i)
    print(summary(ols_sin))
}

# T-test, Wilcoxon Rank Sum Test

group1indices = which((daily_reports$YEAR >= 2010) & (daily_reports$YEAR <= 2011))
group2indices = which((daily_reports$YEAR >= 2012) & (daily_reports$YEAR <= 2013))

t.test(daily_reports$Reports[group1indices], daily_reports$Reports[group2indices])

wilcox.test(daily_reports$Reports[group1indices], daily_reports$Reports[group2indices])


# Residuals over time
daily_reports %>% mutate(residuals = residuals) %>%
                  ggplot(aes(x=Date, y=residuals)) +
                  geom_point()

# Comparing residuals of model trained on from one time period against another

comparison_ols = lm(Reports ~ TMIN, daily_reports[c(group1indices, group2indices),])
summary(comparison_ols)
plot(comparison_ols)

group1predictions = predict(comparison_ols, daily_reports[group1indices,])
group1residuals = daily_reports[group1indices,]$Reports - group1predictions
group2predictions = predict(comparison_ols, daily_reports[group2indices,])
group2residuals = daily_reports[group2indices,]$Reports - group2predictions

t.test(group1residuals, group2residuals)

mean(group1residuals)
mean(group2residuals)

# visualize residuals of each group
group1df = data.frame(Predictions=group1predictions, Residuals = group1residuals, Group = '1')
group2df = data.frame(Predictions=group2predictions, Residuals = group2residuals, Group = '2')

rbind(group1df, group2df) %>% ggplot(aes(x=Predictions, y=Residuals)) + 
                              geom_point(aes(col=Group))

# Boxcox model

boxcox = boxCox(ols)
lambda = boxcox$x[which(boxcox$y == max(boxcox$y))]
boxcox_reports = ((daily_reports$Reports ^ lambda) - 1)/lambda
boxcox_ols = lm(boxcox_reports~daily_reports$TMIN)
summary(boxcox_ols)
plot(boxcox_ols)
plot(daily_reports$TMIN, boxcox_reports)

boxcoxresiduals = boxcox_reports - predict(boxcox_ols)

daily_reports %>% mutate(Residuals = boxcoxresiduals) %>%
  ggplot(aes(x=Date, y=Residuals)) +
  geom_point()


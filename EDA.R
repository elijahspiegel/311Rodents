library(tidyverse)
library(lubridate)
data_raw = read_csv('./311RodentData.csv')
colnames(data_raw)

data = data_raw %>% mutate(Created.Date = `Created Date`,
                           Closed.Date = `Closed Date`,
                           Location.Type = `Location Type`,
                           Incident.Zip = `Incident Zip`,
                           Due.Date = `Due Date`,
                           Resolution = `Resolution Description`,
                           Resolution.Date = `Resolution Action Updated Date`,
                           Community.Board = `Community Board`) %>% 
                    select('Created.Date', 'Closed.Date', 'Descriptor',
                           'Location.Type', 'Incident.Zip', 'City',
                           'Status', 'Due.Date', 'Resolution',
                           'Resolution.Date', 'Community Board',
                           'Borough', 'Latitude', 'Longitude') %>%
                    mutate(Created.Date = mdy_hms(Created.Date),
                           Closed.Date = mdy_hms(Closed.Date),
                           Due.Date = mdy_hms(Due.Date),
                           Resolution.Date = mdy_hms(Resolution.Date))

data = data %>% filter(Descriptor == 'Rat Sighting' | Descriptor == 'Mouse Sighting' | Descriptor == 'Signs of Rodents')

data %>% filter(Descriptor == 'Rat Sighting' | Descriptor == 'Mouse Sighting' | Descriptor == 'Signs of Rodents') %>%
         ggplot(aes(x=month(Created.Date))) + 
         geom_bar(fill='brown', colour='black') +
         facet_wrap(vars(year(Created.Date)))

data %>% ggplot(aes(x=Location.Type)) + geom_bar(col='black', fill='red') + coord_flip()

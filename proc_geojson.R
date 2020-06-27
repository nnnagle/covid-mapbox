library(sf)
library(geojsonsf)
library(ggplot2)
library(tidyverse)

dat <- geojson_sf('data/counties-cases.geojson')
ggplot(data=dat) +
  geom_sf(aes(fill=`11.06.2020`))


counties_sf <- geojson_sf('data/gz_2010_us_050_00_20m.json')
counties_sf <- counties_sf %>% select(NAME, COUNTY, STATE, geometry)

nyc_counties <- c('36061','36081','36005','36085','36047')
counties_sf <- counties_sf %>%
  unite('geoid', STATE, COUNTY, sep='') %>%
  mutate(geoid = ifelse(geoid %in% nyc_counties,
                        '36NYC', geoid)) %>%
  mutate(NAME = ifelse(geoid=='36NYC', 'New York City', NAME)) %>%
  group_by(geoid, NAME) %>%
  summarize() %>%
  ungroup()

model.results <- readRDS('data//results.RDS') %>%
  mutate(geoid = as.character(geoid)) %>%
  mutate(lambda_q50 = ifelse(is.na(total_cases), NA, lambda_q50))

mr_wide <- model.results %>% select(geoid, date, lambda=lambda_q50) %>%
  mutate(lambda = round(as.numeric(lambda/1e8*10000),digits=1)) %>%
  pivot_wider(id_cols=geoid, names_from=date, values_from=lambda) 

county_data <- counties_sf %>%
  left_join(mr_wide,
            by = 'geoid')


#write_sf(county_data, 'counties_data.geojson')
q <- sf_geojson(county_data, digits=NULL,factors_as_string=FALSE)
write_file(x=q, path='counties_data.geojson')


library(sf)
library(geojsonsf)
library(ggplot2)
library(tidyverse)

##################
load('~/Dropbox/covid-model/results/results_2020-07-01.RData')
county_dat <- data_out
rm(data_out)



counties_sf <- geojson_sf('data/gz_2010_us_050_00_20m.json')
counties_sf <- counties_sf %>% select(NAME, COUNTY, STATE, geometry)

nyc_counties <- c('36061','36081','36005','36085','36047')
counties_sf <- counties_sf %>%
  unite('geoid', STATE, COUNTY, sep='', remove=FALSE) %>%
  mutate(geoid = ifelse(geoid %in% nyc_counties,
                        '36NYC', geoid)) %>%
  mutate(NAME = ifelse(geoid=='36NYC', 'New York City', NAME)) %>%
  group_by(STATE, geoid, NAME) %>%
  summarize() %>%
  ungroup()

# reduce data
model_results <- county_dat %>%
  select(geoid, date,
         NAME=county_name,
         lambda=lambda_q50, 
            lambda_lo = lambda_q05, lambda_hi = lambda_q95, 
            pop=pop,
            new_cases=new_cases) %>%
  mutate(geoid = as.character(geoid)) 
# find first observation
first_obs <- model_results %>%
  filter(!is.na(new_cases)) %>%
  group_by(geoid) %>%
  summarize(first_date = min(date))
# set preds before first obs to missing
model_results <- model_results %>%
  left_join(first_obs, by='geoid') %>%
  mutate(lambda = ifelse(date<first_date, NA, lambda)) %>%
  select(-first_date)


mr_wide <- model_results %>% select(geoid, date, lambda) %>%
  mutate(lambda = round(10000*lambda, digits=2)) %>%
  pivot_wider(id_cols=geoid, names_from=date, values_from=lambda)

county_data <- counties_sf %>%
  left_join(mr_wide,
            by = 'geoid')

#write_sf(county_data, 'counties_data.geojson')
q <- sf_geojson(county_data, digits=NULL,factors_as_string=FALSE)
write_file(x=q, path='www/counties_data.geojson')


# create Re value
model_results <- model_results %>%
  group_by(geoid) %>%
  arrange(date) %>%
  mutate(Re = round(lambda / lag(lambda, n=4),digits = 3)) %>%
  ungroup()

# Create a 3x3 bivariate map:
model_results <- model_results %>%
  mutate(Re_cat = cut(Re, breaks=c(-Inf, 1.1, 1.5, Inf), labels=c('1','2','3'))) %>%
  mutate(lam_cat = cut(lambda*10000,breaks=c(-Inf, .5, 2, Inf), labels=c('1','2','3'))) %>%
  mutate(lam_re = as.numeric(paste0(as.character(lam_cat), as.character(Re_cat)))) %>%
  mutate(lam_re = ifelse(str_detect(lam_re, 'NA'), NA, lam_re))
  

mr_wide <- model_results %>% 
  select(geoid, date, lam_re) %>%
  pivot_wider(id_cols=geoid, names_from=date, values_from=lam_re)

county_data <- counties_sf %>%
  left_join(mr_wide,
            by = 'geoid')
q <- sf_geojson(county_data, digits=NULL,factors_as_string=FALSE)
write_file(x=q, path='www/counties_data_biv.geojson')



# write aspatial data to json
model_results %>%
  mutate(
         mu = round(lambda*pop, digits=2),
         mu_lo = round(lambda_lo*pop,digits=2),
         mu_hi = round(lambda_hi*pop,digits=2),
         lambda = round(lambda*10000, digits=3),
         state = substr(geoid, 1,2)) %>%
  select(geoid, state, date, NAME, new_cases, lambda, mu, mu_lo, mu_hi,pop) %>%
  write_csv(path='www/county_data.csv')
  
#model_results %>%
#  mutate(lambda = round(lambda*10000,digits=3),
#         lambda_lo = round(lambda_lo*10000,digits=3),
#         lambda_hi = round(lambda_hi*10000,digits=3)) %>%
#  jsonlite::write_json(path='www/counties_data.json')
    
  
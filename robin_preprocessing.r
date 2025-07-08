source('source/main.R')
library(dplyr)

runoff_robin <- list.files(path="/storage/brno2/home/curceac/data/stations/robin/raw", pattern = "\\.csv$", full.names = TRUE) %>% 
  lapply(fread) %>% 
  rbindlist()

runoff_robin_meta <- fread("C:\\Users\\curceac\\Robin raw data\\metadata\\robin_station_metadata_public_v1-1.csv")

runoff_robin_day <- merge(runoff_robin, runoff_robin_meta[, .(robin_id = ROBIN_ID, area = AREA, lat = LATITUDE, lon = LONGITUDE)])

runoff_robin_day[, flow_mm := round((flow_cumecs * SEC_IN_DAY / (area * 10^6)) * 1000, 2)][, area := NULL][, flow_cumecs := NULL]





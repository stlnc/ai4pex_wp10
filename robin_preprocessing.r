source('source/main.R')
library(dplyr)

runoff_robin <- list.files(path="~/data/stations/robin/raw", pattern = "\\.csv$", full.names = TRUE) %>% 
  lapply(fread) %>% 
  rbindlist()

runoff_robin_meta <- fread("~/data/stations/robin/metadata/robin_station_metadata_public_v1-1.csv")

runoff_robin_day <- merge(runoff_robin, runoff_robin_meta[, .(robin_id = ROBIN_ID, area = AREA, lat = LATITUDE, lon = LONGITUDE)])

runoff_robin_day[, flow_mm := round((flow_cumecs * SEC_IN_DAY / (area * 10^6)) * 1000, 2)][, area := NULL][, flow_cumecs := NULL]

setnames(runoff_robin_day, 'flow_mm', 'flow')

saveRDS(runoff_robin_day, '~/data/stations/robin/processed/robin-v1_q_mm_land_18630101_20221231_station_daily.rds')

runoff_robin_day[, year := as.integer(format(date, "%Y"))]
runoff_robin_day[, month := as.integer(format(date, "%m"))]

runoff_robin_month <- runoff_robin_day[
  , .(flow = sum(flow, na.rm = TRUE)), 
  by = .(robin_id, year, month)
]

runoff_robin_year <- runoff_robin_day[
  , .(flow = sum(flow, na.rm = TRUE)), 
  by = .(robin_id, year)
]

saveRDS(runoff_robin_month, '~/data/stations/robin/processed/robin-v1_q_mm_land_18630101_20221231_station_monthly.rds')
saveRDS(runoff_robin_year, '~/data/stations/robin/processed/robin-v1_q_mm_land_18630101_20221231_station_yearly.rds')



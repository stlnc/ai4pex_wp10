## --- Packages ---
suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(raster)
  library(ncdf4)
  library(sp)
  library(sf)
  library(stars)
  library(parallel)
  library(terra)
  library(ggplot2)
})

## --- Paths ---
PATH_ROOT <- normalizePath("/storage/projects-du-praha/ai4pex-czu", mustWork = FALSE)
PATH_DATA <- file.path(PATH_ROOT, "data")

PATH_PREC <- file.path(PATH_DATA, "precip")
PATH_EVAP <- file.path(PATH_DATA, "evap")
PATH_TEMP <- file.path(PATH_DATA, "temp")
PATH_LCC <- file.path(PATH_DATA, "land_cover_change")
PATH_LAI <- file.path(PATH_DATA, "leaf_area_index")
PATH_SM <- file.path(PATH_DATA, "sm")
PATH_RUNOFF <- file.path(PATH_DATA, "stations")
PATH_WS <- file.path(PATH_DATA, "waterstorage")
PATH_FLOODS <- file.path(PATH_DATA, "floods")

## --- Variable names ---
PREC_NAME <- "prec"
PREC_NAME_SHORT <- "tp"
EVAP_NAME <- "evap"
EVAP_NAME_SHORT <- "e"

## --- Time Constants ---
DAYS_IN_YEAR <- 365.25
SEC_IN_DAY   <- 60*60*24

## --- Spatial Constants ---
GLOBAL_AREA <- 1.345883e+14 

## --- Unit Conversions ---
M2_TO_KM2 <- 1e-6
MM_TO_M   <- 1e-3
MM_TO_KM  <- 1e-6

## --- Parallelisation ---
N_CORES <- detectCores()

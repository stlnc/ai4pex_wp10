## --- Packages ---
suppressPackageStartupMessages({
  if (!requireNamespace("data.table", quietly = TRUE)) {
    install.packages("data.table")
  }
  library(data.table)
  if (!requireNamespace("lubridate", quietly = TRUE)) {
    install.packages("lubridate")
  }
  library(lubridate)
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    install.packages("ggplot2")
  }
  library(ggplot2)
  if (!requireNamespace("raster", quietly = TRUE)) {
    install.packages("raster")
  }
  library(raster)
  if (!requireNamespace("ncdf4", quietly = TRUE)) {
    install.packages("ncdf4")
  }
  library(ncdf4)
  if (!requireNamespace("sp", quietly = TRUE)) {
    install.packages("sp")
  }
  library(sp)
  if (!requireNamespace("sf", quietly = TRUE)) {
    install.packages("sf")
  }
  library(sf)
  if (!requireNamespace("stars", quietly = TRUE)) {
    install.packages("stars")
  } 
  library(stars)
})

## --- Base Paths ---
PATH_ROOT <- normalizePath("~/storage/brno2/home/curceac", mustWork = FALSE)
PATH_DATA <- file.path(PATH_ROOT, "data")
PATH_SAVE <- file.path(PATH_ROOT, "data_project")

# --- Time Constants ---
DAYS_IN_YEAR <- 365.25
SEC_IN_DAY   <- 60*60*24

# --- Spatial Constants ---
GLOBAL_AREA <- 1.345883e+14 

# --- Unit Conversions ---
M2_TO_KM2 <- 1e-6
MM_TO_M   <- 1e-3
MM_TO_KM  <- 1e-6
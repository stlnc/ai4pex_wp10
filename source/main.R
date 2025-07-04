## --- Packages ---
suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(ggplot2)
  library(raster)
  library(ncdf4)
  library(sp)
  library(sf)
  library(stars)
})

## --- Base Paths ---
PATH_ROOT <- normalizePath("~/storage/brno2/home/curceac", mustWork = FALSE)
PATH_DATA <- file.path(PATH_ROOT, "data")
PATH_SAVE <- file.path(PATH_ROOT, "data_project")

PATH_PREC_SIM <- file.path(PATH_DATA, "sim/precip/raw")
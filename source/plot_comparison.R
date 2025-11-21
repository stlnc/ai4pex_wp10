source('source/main.R')

if (!requireNamespace("cowplot", quietly = TRUE)) {
  install.packages("cowplot")
} 
library(cowplot)
if (!requireNamespace("maps", quietly = TRUE)) {
  install.packages("maps")
} 
library(maps)
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite")
} 
library(jsonlite)

dir.create(PATH_FLOODS)
dir.create(PATH_PREC)

set.seed(Sys.time())

zip_files <- list.files(PATH_FLOODS, pattern = "\\.zip$", recursive = TRUE, full.names = TRUE)
if (length(zip_files) == 0) stop("No zip files found in ", PATH_FLOODS)

selected_zip <- sample(zip_files, 1)
temp_dir <- tempfile(pattern = "flood_extract_")
dir.create(temp_dir)
unzip(selected_zip, exdir = temp_dir)

tiff_file <- list.files(temp_dir, pattern = "\\.tif$", recursive = TRUE, full.names = TRUE)[1]
json_file <- list.files(temp_dir, pattern = "properties\\.json$", recursive = TRUE, full.names = TRUE)[1]

if (is.na(tiff_file) || is.na(json_file)) stop("Could not find TIFF or properties.json file")

flood_metadata <- fromJSON(json_file)

filename <- basename(selected_zip)
filename_parts <- strsplit(gsub("\\.zip$", "", filename), "_")[[1]]
dfo_id_from_file <- filename_parts[2]
start_date_from_file <- as.Date(filename_parts[4], format = "%Y%m%d")
end_date_from_file <- as.Date(filename_parts[6], format = "%Y%m%d")

if (is.null(flood_metadata$dfo_id) || flood_metadata$dfo_id == "") {
  flood_metadata$dfo_id <- dfo_id_from_file
}
if (is.null(flood_metadata$dfo_began) || flood_metadata$dfo_began == "") {
  flood_metadata$dfo_began <- as.character(start_date_from_file)
}
if (is.null(flood_metadata$dfo_ended) || flood_metadata$dfo_ended == "") {
  flood_metadata$dfo_ended <- as.character(end_date_from_file)
}

tiff_data <- rast(tiff_file)
tiff_extent <- ext(tiff_data)
tiff_extent <- as.vector(tiff_extent)

start_date <- as.Date(flood_metadata$dfo_began)
end_date <- as.Date(flood_metadata$dfo_ended)

PATH_MSWEP <- paste0(PATH_PREC, "/mswep-v2-8_tp_mm_land_197901_202012_025_daily.nc")
nc <- nc_open(PATH_MSWEP)
time_var <- ncvar_get(nc, "time")
time_units <- ncatt_get(nc, "time", "units")$value

origin_str <- sub("days since ", "", time_units)
origin_str <- trimws(gsub(" .*", "", origin_str))
date_parts <- strsplit(origin_str, "-")[[1]]
year <- as.integer(date_parts[1])
month <- as.integer(date_parts[2])
day <- as.integer(date_parts[3])
origin_date <- as.Date(sprintf("%04d-%02d-%02d", year, month, day))
nc_dates <- origin_date + time_var

time_indices <- which(nc_dates >= start_date & nc_dates <= end_date)

if (length(time_indices) == 0) {
  nc_close(nc)
  stop("No data found for the date range ", start_date, " to ", end_date)
}

nc_close(nc)

suppressWarnings(mswep_subset <- rast(PATH_MSWEP, subds = "mask", lyrs = time_indices))

crs(mswep_subset) <- "EPSG:4326"
ext(mswep_subset) <- c(-180, 180, -90, 90)
mswep_subset <- flip(mswep_subset, direction = "vertical")

mswep_subset[mswep_subset == -9999] <- NA

mswep_cropped <- crop(mswep_subset, tiff_extent)

if (nlyr(mswep_cropped) > 1) {
  total_precip <- app(mswep_cropped, sum, na.rm = TRUE)
} else {
  total_precip <- mswep_cropped
}

tiff_df <- as.data.frame(tiff_data, xy = TRUE)
colnames(tiff_df) <- c("lon", "lat", "value")
tiff_df <- as.data.frame(lapply(tiff_df, as.numeric))

unlink(temp_dir, recursive = TRUE)

world_map <- map_data("world")

precip_df <- as.data.frame(total_precip, xy = TRUE)
colnames(precip_df) <- c("lon", "lat", "value")

p1 <- ggplot() +
  geom_raster(data = tiff_df, aes(x = lon, y = lat, fill = value)) +
  geom_path(data = world_map, aes(x = long, y = lat, group = group), 
            color = "black", linewidth = 0.3) +
  scale_fill_gradient(low = "white", high = "blue", 
                      name = "Flood\nExposure",
                      na.value = "transparent") +
  coord_fixed(xlim = c(tiff_extent[1], tiff_extent[2]),
              ylim = c(tiff_extent[3], tiff_extent[4]),
              expand = FALSE) +
  labs(title = paste0("Flood Exposure - DFO ", flood_metadata$dfo_id, 
                      "\n", flood_metadata$dfo_main_cause, " (", 
                      flood_metadata$dfo_country, ")"), 
       x = "Longitude", y = "Latitude") +
  theme_minimal() +
  theme(panel.grid.major = element_line(color = "gray90", linewidth = 0.2),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA))

p2 <- ggplot() +
  geom_raster(data = precip_df, aes(x = lon, y = lat, fill = value)) +
  geom_path(data = world_map, aes(x = long, y = lat, group = group), 
            color = "black", linewidth = 0.3) +
  scale_fill_gradientn(colors = c("#FFFFFF", "#EDF8B1", "#C7E9B4", 
                                   "#7FCDBB", "#41B6C4", "#1D91C0", 
                                   "#225EA8", "#253494", "#081D58"),
                       name = "Total Precip.\n(mm, land only)",
                       na.value = "transparent",
                       limits = c(0, NA)) +
  coord_fixed(xlim = c(tiff_extent[1], tiff_extent[2]),
              ylim = c(tiff_extent[3], tiff_extent[4]),
              expand = FALSE) +
  labs(title = paste0("Total Precipitation\n(", 
                      format(start_date, "%d %b %Y"), " - ", 
                      format(end_date, "%d %b %Y"), ")"), 
       x = "Longitude", y = "Latitude") +
  theme_minimal() +
  theme(panel.grid.major = element_line(color = "gray90", linewidth = 0.2),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA))

combined_plot <- plot_grid(p1, p2, ncol = 2, nrow = 1)

print(combined_plot)

p1 <- ggplot2::ggplot() +
  ggplot2::geom_raster(data = tiff_df, ggplot2::aes(x = lon, y = lat, fill = value)) +
  ggplot2::geom_path(data = world_map, ggplot2::aes(x = long, y = lat, group = group), 
                     color = "black", linewidth = 0.3) +
  ggplot2::scale_fill_gradient(low = "white", high = "blue", 
                               name = "Flood\nExposure",
                               na.value = "transparent") +
  ggplot2::coord_fixed(xlim = c(tiff_extent[1], tiff_extent[2]),
                       ylim = c(tiff_extent[3], tiff_extent[4]),
                       expand = FALSE) +
  ggplot2::labs(title = paste0("Flood Exposure - DFO ", flood_metadata$dfo_id, 
                               "\n", flood_metadata$dfo_main_cause, " (", 
                               flood_metadata$dfo_country, ")"), 
                x = "Longitude", y = "Latitude") +
  ggplot2::theme_minimal() +
  ggplot2::theme(panel.grid.major = ggplot2::element_line(color = "gray90", linewidth = 0.2),
                 panel.grid.minor = ggplot2::element_blank(),
                 panel.background = ggplot2::element_rect(fill = "white", color = NA),
                 plot.background = ggplot2::element_rect(fill = "white", color = NA))


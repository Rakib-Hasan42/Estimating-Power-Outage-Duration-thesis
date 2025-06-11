#Load necessary libraries
library(ncdf4)     # For handling NetCDF files
library(terra)     # For raster operations
library(sf)        # For spatial operations
library(dplyr)     # For data manipulation
library(tigris)    # For Florida county boundaries
library(ggplot2)   # For visualization
library(readr)     # For saving CSV files
library(openxlsx)  # For saving Excel files

#Set NetCDF file path (Replace with your file path)
nc_file <- "C:/Users/raoab/Downloads/VIIRS-Land_v001_NPP13C1_S-NPP_20221123_c20240127020027.nc"
#step 1: Extract Time Information from NetCDF
nc_data <- nc_open(nc_file)

if ("time" %in% names(nc_data$dim)) {
  time_vals <- ncvar_get(nc_data, "time")
  time_units <- ncatt_get(nc_data, "time", "units")$value
  
  # Extract reference date
  reference_date <- as.Date(gsub("days since ", "", time_units))
  
  # Convert time values to actual dates
  real_dates <- as.Date(time_vals, origin = reference_date)
  
  #automatically select the first available date
  detected_date <- real_dates[1]
  print(paste("sing detected date:", detected_date))
} else {
  stop("error: No time variable found in the NetCDF file.")
}

# Close NetCDF file
nc_close(nc_data)

#step 2: Load NDVI Raster Data
ndvi_raster <- rast(nc_file, subds = "NDVI")

#step 3: Load Florida County Boundaries
florida_counties <- counties(state = "FL", class = "sf")

# Transform CRS to match NDVI raster
florida_counties <- st_transform(florida_counties, crs(ndvi_raster))

#step 4: Extract NDVI for the Detected Date
date_index <- which(real_dates == detected_date)

if (length(date_index) == 0) {
  stop(paste("error: The detected date (", detected_date, ") is not available in the dataset."))
} else {
  print(paste("extracting NDVI for", detected_date))
}

# Extract NDVI for the detected date
ndvi_selected <- ndvi_raster[[date_index]]

#step 5: Crop NDVI to Florida Boundaries
ndvi_florida <- crop(ndvi_selected, ext(florida_counties))
ndvi_florida <- mask(ndvi_florida, vect(florida_counties))

# Convert NDVI raster to DataFrame
ndvi_df <- as.data.frame(ndvi_florida, xy = TRUE)

#step 6: Assign Counties and Compute One NDVI Value per County
# Convert NDVI data to spatial format
ndvi_sf <- st_as_sf(ndvi_df, coords = c("x", "y"), crs = st_crs(ndvi_florida))

# Perform a spatial join to assign each NDVI point to a county
ndvi_with_counties <- st_join(ndvi_sf, florida_counties["NAME"], left = TRUE)

# Convert back to DataFrame
ndvi_with_counties_df <- as.data.frame(ndvi_with_counties)

#extract Longitude & Latitude from the Geometry Column
coords <- st_coordinates(ndvi_sf)  # Extract X (Longitude) & Y (Latitude)
ndvi_with_counties_df$Longitude <- coords[,1]
ndvi_with_counties_df$Latitude <- coords[,2]

#remove geometry column & rename columns
ndvi_with_counties_df <- ndvi_with_counties_df %>%
  select(Longitude, Latitude, NDVI, NAME)

colnames(ndvi_with_counties_df) <- c("Longitude", "Latitude", "NDVI", "County")

#aggregate NDVI: Get One NDVI Value per County (Mean & Min NDVI)
florida_ndvi_summary <- ndvi_with_counties_df %>%
  group_by(County) %>%
  summarise(Mean_NDVI = mean(NDVI, na.rm = TRUE), 
            Min_NDVI = min(NDVI, na.rm = TRUE)) %>%
  ungroup()

#add Date Column
florida_ndvi_summary$Date <- detected_date

#step 7: Save the Results
csv_filename <- paste0("C:/Users/raoab/Downloads/Florida_NDVI_Per_County_", detected_date, ".csv")
write_csv(florida_ndvi_summary, csv_filename)

print(paste("NDVI summary saved to:", csv_filename))

#step 8: Save as Excel File
excel_filename <- paste0("C:/Users/raoab/Downloads/Florida_NDVI_Per_County_", detected_date, ".xlsx")
write.xlsx(florida_ndvi_summary, excel_filename)

print(paste("NDVI summary saved to Excel:", excel_filename))

#step 9: Plot NDVI Map (Mean NDVI Per County)
ggplot() +
  geom_sf(data = merge(florida_counties, florida_ndvi_summary, by.x = "NAME", by.y = "County", all.x = TRUE),
          aes(fill = Mean_NDVI), color = "black") +
  scale_fill_gradientn(colors = c("brown", "yellow", "green"),
                       limits = c(-1, 1),
                       name = "Mean NDVI") +
  labs(title = paste("Mean NDVI Per County in Florida (", detected_date, ")", sep = ""),
       x = "Longitude",
       y = "Latitude") +
  theme_minimal()

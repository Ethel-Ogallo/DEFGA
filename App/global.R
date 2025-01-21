# 1. Load packages----
pacman::p_load(sf,
               ggplot2,
               shiny,
               plotly,
               dplyr,
               tidyr,
               tidyverse,
               httr,
               ows4R,
               gganimate,
               lubridate,
               shinydashboard,
               shinyjs,
               shinythemes,
               shinyWidgets,
               shinycssloaders,
               gridGraphics,
               ggiraph,
               gghighlight,
               shinyjs,
               leaflet,
               bslib,
               curl,
               shinydashboardPlus,
               dashboardthemes,
               httr)

# 2. Load data from WFS ----

# Request data from WFS (using Geoserver)
# wfs_url <- "https://geoserver22s.zgis.at/geoserver/IPSDI_WT24/wfs"
# 
# wfs_request <- paste0(
#   wfs_url,
#   "?service=WFS",
#   "&version=1.0.0",
#   "&request=GetFeature",
#   "&typeName=IPSDI_WT24:austria_employment_data_DEFGA",
#   "&outputFormat=application/json"
# )
# 
# # Read the Data from WFS
# employment_data <- st_read(dsn = wfs_request, quiet = TRUE)

# Define WFS URL and parameters
# Define the WFS URL and parameters
wfs_url <- "https://zgis216.geo.sbg.ac.at/server/services/Hosted/austria_employment_data/MapServer/WFSServer?"
layer_name <- "austria_employment_data:austria_employment_data"
# Parameters for GetFeature request
params <- list(
  service = "WFS",
  version = "2.0.0",
  request = "GetFeature",
  typeName = layer_name,                # Use the correct layer name here
  outputFormat = "GeoJSON"              # Request GeoJSON format
)

# Send GET request to WFS
response <- GET(wfs_url, query = params)

# Parse the GeoJSON response into an sf object
geojson <- content(response, as = "text")
employment_data <- st_read(geojson, quiet = TRUE)

# 3. Data manipulation ----
# Reproject to a projected CRS - EPSG:3857 is commonly used
employment_data <- st_transform(employment_data, crs = 3857)

# Preprocess the employment data: converting year to integer and gender to factor
employment_data <- employment_data |> 
  mutate(
    year = as.integer(Year),
    gender = factor(Gender, levels = c("Male", "Female", "total")),
    region = factor(region, levels = c("Rural", "Urban"))
  ) |> 
  filter(gender %in% c("Male", "Female")) |>   # Remove NAs and filter
  rename(nuts_name = NUTS_NAME, num_employed = num_employ)

region_map <- employment_data |>
  group_by(year, region, nuts_name) |>
  summarise(
    total_employed = sum(num_employed, na.rm = TRUE),
    geometry = st_union(geometry),  # Combine geometries by region and year
    .groups = "drop"  # Ensure ungrouping after summarisation
  ) |>
  st_as_sf()


gender_map <- employment_data |>
  group_by(year, nuts_name, gender, region) |>
  summarise(
    total_employed = sum(num_employed, na.rm = TRUE),
    geometry = st_union(geometry)  # Combine geometries by region and year
  ) |>
  ungroup() |>
  st_as_sf() 






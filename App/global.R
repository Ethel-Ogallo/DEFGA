# 1. Load packages----
pacman::p_load(sf,
               ggplot2,
               shiny,
               plotly,
               dplyr,
               tidyr,
               gganimate,
               lubridate,
               shinydashboard,
               shinyjs,
               shinythemes,
               shinyWidgets,
               shinycssloaders,
               RColorBrewer,
               gridGraphics,
               ggiraph,
               gghighlight,
               shinyjs,
               viridis)

# 2. Load data from WFS ----

## Request data from WFS ----
wfs_url <- "https://geoserver22s.zgis.at/geoserver/IPSDI_WT24/wfs?"

wfs_request <- paste0(
  wfs_url,
  "?service=WFS",
  "&version=1.0.0",
  "&request=GetFeature",
  "&typeName=IPSDI_WT24:austria_employment_data_DEFGA",
  "&outputFormat=application/json"
)

# Read the Data from WFS
employment_data <- st_read(dsn = wfs_request, quiet = FALSE)

# 3. Data manipulation ----
# Preprocess the employment data: converting year to integer and gender to factor
employment_data <- employment_data |> 
  mutate(year = as.integer(year), 
         gender = factor(gender, levels = c("Male", "Female", "total")),
         region = factor(region, levels = c("Rural","Urban")),
         year_date = as.Date(year_date))

region_map <- employment_data |>
  group_by(year, region, nuts_name) |>
  summarise(
    total_employed = sum(num_employed, na.rm = TRUE),
    geometry = st_union(geometry) # Combine geometries by region and year
  ) |>
  ungroup() |>
  st_as_sf()

gender_map <- employment_data |>
  group_by(year, nuts_name, gender, region) |>
  summarise(
    total_employed = sum(num_employed, na.rm = TRUE),
    geometry = st_union(geometry) # Combine geometries by region and year
  ) |>
  ungroup() |>
  st_as_sf()


# breaks
breaks_manual <- c(0, 100000, 200000, 350000, 500000, 600000,1500000)
breaks_manual2 <- c(0, 70000, 150000, 200000, 250000, 350000,700000)

# colors
colors <- c("#9ebcda", "#BC2C1A")



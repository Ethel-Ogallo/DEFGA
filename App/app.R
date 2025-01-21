##'Development of Employment Figures by gender Austria 2013-2022
##'Date: 11-01-2025
##'Authors: Adana Mirzoyan, Ethel Ogallo 
##'University of Salzburg
##'Interactive dashboard that visualizes the trend in employment and disparity by gender and region

source('global.R')

# UI ----
ui <- navbarPage(
  title = "DEFGA",  # App title
  id = "main_tabs",  # Assign an ID for controlling navigation
  theme = bslib::bs_theme(),  # Optional: Apply a theme
  
  # Home Page ----
  tabPanel(
    "Home", 
    useShinyjs(),  # Enable shinyjs for interactivity
    
    # Head for custom styling
    tags$head(
      tags$style(HTML("
        body, html {
          margin: 0;
          padding: 0;
          height: 100%;
          width: 100%;
          #overflow: hidden;
          font-family: Arial, sans-serif;
        }
        
        .navbar {
          background-color: grey; /* Navbar color */
          padding: 10px 20px;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .navbar a {
          text-decoration: none;
          color: #337ab7;
          padding: 0 15px;
          font-weight: bold;
        }

        .navbar a:hover {
          color: #337ab7;
        }

        .hero {
          position: absolute;
          background-image: url('job-5382501_1280.jpg'); 
          background-size: cover;
          background-position: center;
          background-repeat: no-repeat;
          height: 90vh; /* Full viewport height */
          width: 100vw; /* Full viewport width */
          display: flex;
          justify-content: center;
          align-items: center;
          color: white;
          text-align: center;
          filter: brightness(80%); /* Slight transparency effect */
        }
        
        .hero::before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background-color: rgba(0, 0, 0, 0.5); /* Additional transparency overlay */
          z-index: -1;
        }

        .hero h1 {
          font-size: 4rem;
          margin: 0;
          text-shadow: 0 2px 5px rgba(0, 0, 0, 0.5);
        }

        .hero p {
          font-size: 2rem;
          margin-top: 20px;
          text-shadow: 0 2px 5px rgba(0, 0, 0, 0.5);
        }

        .hero button {
          margin-top: 20px;
          padding: 10px 20px;
          font-size: 1.25rem;
          background-color: #007bff;
          color: white;
          border: none;
          border-radius: 5px;
          cursor: pointer;
        }

        .hero button:hover {
          background-color: #0056b3;
        }
        
        /* Make the body scrollable while keeping the full-screen hero section */
        .content {
          overflow-y: auto;
          height: calc(100vh - 100px); /* Adjust this if needed for your header height */
        }
      
        /* Ensure the charts don't get cut off */
        .chart-container {
          overflow-y: scroll;
          max-height: 100vh; /* Keep the charts inside the viewport */
        }
      "))
    ),
    
    # Hero Section for Home Page
    div(class = "hero",
        div(
          h1("DEFGA"),
          p("Development of Employment Figures by Gender Austria 2013-2022"),
          actionButton("get_started", "Get started »")
        )
    )
  ),
  
  # About Page ----
  tabPanel(
    "About",
    div(
      style = "margin: 40px; max-width: 800px; margin-left: auto; margin-right: auto;",
      h3("About"),
      p(
        style = "font-size: 18px; line-height: 1.6;",
        "Welcome to the Development of Employment Figures by Gender in Austria platform!"
      ),
      p(
        style = "font-size: 18px; line-height: 1.6;",
        "This platform provides insights into employment trends across Austria from 2013 to 2022, with a focus on 
        gender and urban-rural dynamics. The dashboard is part of a broader Spatial Data Infrastructure (SDI) that 
        integrates open-source tools to support data storage , analysis and shairing. The SDI combines a 
        geodatabase (PostGIS) for storing standardized data, interoperable web services (Geoserver), and this 
        interactive dashboard(Shiny)."
      ),
      p(
        style = "font-size: 18px; line-height: 1.6;",
        "By visualizing employment trends, this platform aims to assist policymakers, educators, and researchers 
        in addressing gender employment gaps, and supporting informed decision-making."
      ),
      h4("Acknowledgment"),
      p(
        style = "font-size: 18px; line-height: 1.6; margin-top: 20px;",
        "This project was collaboratively developed by:"
      ),
      tags$ul(
        style = "font-size: 18px; line-height: 1.6; text-align: left; margin-left: left; margin-right: auto;",
        tags$li("Adana Mirzoyan"),
        tags$li("Ethel Ogallo")
      ),
      h4("Data Sources"),
      p(
        style = "font-size: 18px; line-height: 1.6; margin-top: 20px;",
        "The platform uses data from the following sources:"
      ),
      tags$ul(
        style = "text-align: left; margin-left: left; margin-right: auto; font-size: 18px;",
        tags$li(tags$a(href = "https://www.statistik.at/", target = "_blank", "Statistics Austria")),
        tags$li(tags$a(href = "https://ec.europa.eu/eurostat", target = "_blank", "Eurostat"))
      ),
      h4("Last Updated"),
      p(
        style = "text-align: left; font-size: 18px; line-height: 1.6; margin-top: 20px;",
        paste("This dashboard was last updated on: ", Sys.Date())
      )
    )
  ),
  
  # Gender-Employment Page ----
  tabPanel(
    "Employment trend",
    fluidRow(
      column(
        5,
        br(),
        uiOutput("map_title"),  # Title for the map
        withSpinner(
          leafletOutput(
            'map',
            width = '100%',
            height = '500px'
          )
        ),
        type = 3,
        color.background = 'white'
      ),
      column(
        2,
        br(),
        selectInput(
          inputId = 'comparison',
          label = 'Select Comparison:',
          choices = c('Region', 'Gender'),
          selected = 'Region'
        ),
        br(),
        conditionalPanel(
          condition = "input.comparison == 'Gender'",
          selectInput(
            inputId = 'gender',
            label = 'Select Gender:',
            choices = c('Male', 'Female'),
            selected = 'Male'
          )
        ),
        br(),
        sliderInput(
          inputId = "map_time",
          label = "Year:",
          min = 2013,               
          max = 2022,               
          value = 2013,             
          step = 1,                 
          animate = TRUE,           
          sep = ""
        )
      ),
      column(
        5,
        withSpinner(
          girafeOutput(
            'pie_chart',
            width = '100%',
            height = '500px'
          ),
          type = '3',
          color.background = 'white'
        )
      )
    ),
    fluidRow(
        girafeOutput('line_chart', 
                     width = '100%', 
                     height = '500px')
 
    )
    
  )
)


# SERVER ----
server <- function(input, output, session) {
  # Navigate to "About" page when "Get started" is clicked
  observeEvent(input$get_started, {
    updateNavbarPage(session, inputId = "main_tabs", selected = "About")
  })
  
  #Employment map----
  observeEvent(c(input$comparison, input$gender, input$map_time), {
    selected_comparison <- input$comparison
    selected_gender <- input$gender
    selected_maptime <- input$map_time
    
    # Update the dynamic title based on the selected inputs for the map
    output$map_title <- renderUI({
      title_text <- paste("Employment figures by", selected_comparison)
      if (selected_comparison == "Gender") {
        title_text <- paste(title_text, " ", selected_gender)
      }
      title_text <- paste(title_text, " ", selected_maptime)
      
      tags$div(
        style = "font-size: 24px; font-weight: bold; text-align: center; margin-bottom: 10px;",
        title_text
      )
    })
    
    # Filter the data based on the selected year
    data1 <- region_map |> 
      filter(year == selected_maptime)  # Filter based on selected year
    
    # Transform the CRS to WGS84 (EPSG:4326) if necessary
    data1 <- st_transform(data1, crs = 4326)  # Transform to WGS84 (long-lat)
    
    # Check the selected comparison (Region or Gender) and filter accordingly
    if (selected_comparison == "Region") {
      
      # Render the region map with click to get information and highlight in gray on hover
      output$map <- renderLeaflet({
        pal <- colorNumeric(
          palette = c("#ffeda0", "#feb24c", "#f03b20", "#bd0026", "#800026"),
          domain = data1$total_employed
        )
        
        leaflet(data1) %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addPolygons(
            fillColor = ~pal(total_employed),
            color = "#BDBDBD",  # Default border color
            weight = 0.5,
            opacity = 1,
            fillOpacity = 0.7,
            # Popup with all data details
            popup = ~paste0(
              "<b>NUTS3: </b>", nuts_name, "<br>",
              "<b>Type: </b>", region, "<br>",
              "<b>Employed: </b>", total_employed, "<br>",
              "<b>Year: </b>", year
            ),
            highlight = highlightOptions(
              weight = 0.5,  # Keep the border thin
              color = "#BDBDBD",  # Keep border color unchanged
              fillColor = "gray",  # Highlight the polygon with gray fill on hover
              fillOpacity = 0.7,
              bringToFront = TRUE
            )
          ) %>%
          addLegend(
            position = "bottomright",
            pal = pal,
            values = data1$total_employed,
            title = "Employment",
            opacity = 0.7,
            labels = c("0-150k", "150k-300k", "300k-500k", "500k-1M", ">1M")
          ) %>%
          # Set the initial view to Austria with appropriate zoom
          setView(lng = 13.333, lat = 47.516, zoom = 6) %>%  # Coordinates of Austria
          # Set the map bounds to Austria to restrict panning
          setMaxBounds(
            lng1 = 9.5, lat1 = 46.5,  # Southwest corner
            lng2 = 17.0, lat2 = 49.0   # Northeast corner
          )
      })
      
    } else if (selected_comparison == "Gender") {
      
      # Filter the data by gender and year
      gender_data <- gender_map |> 
        filter(gender == selected_gender, year == selected_maptime)  # Filter by gender and year
      
      # Transform the CRS to WGS84 (EPSG:4326) if necessary
      gender_data <- st_transform(gender_data, crs = 4326)  # Transform to WGS84 (long-lat)
      
      # Render the gender map with click to get information and highlight in gray on hover
      output$map <- renderLeaflet({
        pal <- colorNumeric(
          palette = c("#ffeda0", "#feb24c", "#f03b20", "#bd0026", "#800026"),
          domain = gender_data$total_employed
        )
        
        leaflet(gender_data) %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addPolygons(
            fillColor = ~pal(total_employed),
            color = "#BDBDBD",  # Default border color
            weight = 0.5,
            opacity = 1,
            fillOpacity = 0.7,
            # Popup with all data details
            popup = ~paste0(
              "<b>NUTS3: </b>", nuts_name, "<br>",
              "<b>Type: </b>", region, "<br>",
              "<b>Gender: </b>", gender, "<br>",
              "<b>Employed: </b>", total_employed, "<br>",
              "<b>Year: </b>", year
            ),
            highlight = highlightOptions(
              weight = 0.5,  # Keep the border thin
              color = "#BDBDBD",  # Keep border color unchanged
              fillColor = "gray",  # Highlight the polygon with gray fill on hover
              fillOpacity = 0.7,
              bringToFront = TRUE
            )
          ) %>%
          addLegend(
            position = "bottomright",
            pal = pal,
            values = gender_data$total_employed,
            title = "Employment",
            opacity = 0.7,
            labels <- c("0-70k", "70k-150k", "150k-200k", "200k-250k", ">250k")
          ) %>%
          # Set the initial view to Austria with appropriate zoom
          setView(lng = 13.333, lat = 47.516, zoom = 6) %>%  # Coordinates of Austria
          # Set the map bounds to Austria to restrict panning
          setMaxBounds(
            lng1 = 9.5, lat1 = 46.5,  # Southwest corner
            lng2 = 17.0, lat2 = 49.0   # Northeast corner
          )
      })
    }
  })
  
  # Employment pie chart ---- 
  observeEvent(c(input$comparison, input$gender, input$map_time), {
    selected_comparison <- input$comparison
    selected_gender <- input$gender
    selected_maptime <- input$map_time
    
    # Filter the data based on the selected year
    data1 <- employment_data |>  
      filter(region %in% c("Rural", "Urban")) |>
      group_by(region, year) |>
      summarise(total_employed = sum(num_employed, na.rm = TRUE)) |>
      ungroup() |>
      filter(year == selected_maptime)
    
    if (selected_comparison == "Region") {
      # Render the region map with interactive hover
      output$pie_chart <- renderGirafe({
        pie_chart1 <- ggplot(data1) +
          geom_bar_interactive(
            aes(
              x = "", 
              y = total_employed, 
              fill = region,
              tooltip = paste0(region, ": ", total_employed),
              data_id = region
            ), 
            stat = "identity", 
            width = 1
          ) +
          coord_polar("y") +
          scale_fill_manual(values = c("#feb24c", "#bd0026")) +
          labs(title = paste("Employment by", selected_comparison, selected_maptime)) +
          theme_void() +
          theme(
            plot.title = element_text(hjust = 0.5),
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            panel.grid = element_blank()
          )
        
        girafe(
          ggobj = pie_chart1,
          width_svg = 7,
          height_svg = 6,
          options = list(
            opts_hover(css = "stroke-width: 3; cursor: pointer; fill:grey;"),
            opts_selection(type = "single", css = "opacity: 0.4;"),
            opts_tooltip(css = "background-color: white; color: black; font-size: 14px; padding: 5px;")
          )
        )
      })
      
    } else if (selected_comparison == "Gender") {
      # Filter the data by gender and year
      data2 <- employment_data |> 
        filter(gender %in% c("Male", "Female")) |>
        group_by(gender, year) |>
        summarise(total_employed = sum(num_employed, na.rm = TRUE)) |>
        ungroup() |>
        filter(year == selected_maptime)
      
      # Render the gender map with interactive hover
      output$pie_chart <- renderGirafe({
        pie_chart2 <- ggplot(data2) +
          geom_bar_interactive(
            aes(
              x = "", 
              y = total_employed, 
              fill = gender,
              tooltip = paste0(gender, ": ", total_employed),
              data_id = gender
            ), 
            stat = "identity", 
            width = 1
          ) +
          coord_polar("y") +
          scale_fill_manual(values = c("#feb24c", "#bd0026")) +
          labs(title = paste("Employment by", selected_comparison, selected_maptime)) +
          theme_void() +
          theme(
            plot.title = element_text(hjust = 0.5),
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            panel.grid = element_blank()
          )
        
        girafe(
          ggobj = pie_chart2,
          width_svg = 7,
          height_svg = 6,
          options = list(
            opts_hover(css = "stroke-width: 3; cursor: pointer; fill:grey;"),
            opts_selection(type = "single", css = "opacity: 0.4;"),
            opts_tooltip(css = "background-color: white; color: black; font-size: 14px; padding: 5px;")
          )
        )
      })
    }
  })
  
  # Employment line chart----
  output$line_chart <- renderGirafe({
    line_chart <- employment_data |>
      filter(gender %in% c("Male", "Female")) |>
      group_by(year, gender) |>
      summarise(total_employed = sum(num_employed, na.rm = TRUE)) |>
      ungroup() |>
      ggplot(aes(
        x = year, 
        y = total_employed, 
        color = gender, 
        group = gender
      )) +
      geom_line() +  # Basic ggplot line
      geom_point() +  # Basic ggplot points
      scale_color_manual(values = c("Male" = "#feb24c", "Female" = "#bd0026"))+
      scale_x_continuous(breaks = seq(min(employment_data$year), max(employment_data$year), by = 1)) +
      ggtitle("Gender Employment Over Time") +
      theme_classic()+
      theme(plot.title = element_text(hjust = 0.5))
    
      girafe(
        ggobj = line_chart,
        width_svg = 9, 
        height_svg = 5,
        options = list(
          opts_hover(css = "stroke-width: 3; cursor: pointer; fill:grey;"),
          opts_selection(type = "single", css = "opacity: 0.4;"),
          opts_tooltip(css = "background-color: white; color: black; font-size: 14px; padding: 5px;")
        )
      )
  })
  
}

# Run App ----
shinyApp(ui, server)
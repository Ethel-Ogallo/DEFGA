# UI-----
ui <- navbarPage(
  title = "DEFGA",
  id = "tabs", # For programmatic navigation
  
  # Home Tab -----
  tabPanel(
    title = "Home",
    # Initial narrow image section with title and "Get Started" button
    tags$div(
      style = "
      position: relative; 
      background-image: url('job-5382501_1280.jpg'); 
      background-size: cover;
      background-position: center;
      height: 50vh; /* Reduced height for the initial banner */
      width: 100vw; 
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
      color: white;
    ",
      # Add a semi-transparent overlay
      tags$div(
        style = "
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.6); /* Dark overlay */
        z-index: 1;
      "
      ),
      # Main content (title and Get Started button)
      tags$div(
        style = "
        position: relative;
        z-index: 2;
      ",
        h1("Development of Employment Figures", style = "font-size: 40px; margin-bottom: 20px;"),
      )
    ),
    tags$div(
      id = "overview_section", 
      style = "
      background-color: #f0f0f0; 
      padding: 40px;
      max-width: 80%;
      margin: 40px auto;
      border-radius: 10px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
      color: black;
      font-family: 'Arial', sans-serif;
    ",
      # Overview content
      h3("Overview", style = "font-size: 32px; font-weight: bold; color: #333; margin-bottom: 20px;"),
      p("This platform provides insights into employment trends across Austria from 2013 to 2022, with a focus on gender and urban-rural dynamics. The visualizations aim to help policymakers, educators, and researchers in identifying and addressing gender employment gaps."),
      p("By exploring the trends, the platform supports informed decision-making and contributes to bridging gender-related employment disparities."),
      h4("Acknowledgment", style = "font-size: 20px; font-weight: bold; margin-top: 20px;"),
      tags$ul(
        tags$li("Adana Mirzoyan"),
        tags$li("Ethel Ogallo")
      ),
      h4("Data Sources", style = "font-size: 20px; font-weight: bold; margin-top: 20px;"),
      tags$ul(
        tags$li(tags$a(href = "https://www.statistik.at/", target = "_blank", "Statistics Austria")),
        tags$li(tags$a(href = "https://ec.europa.eu/eurostat", target = "_blank", "Eurostat"))
      ),
      p(style = "font-size: 18px; line-height: 1.6;", paste("Last updated on:", Sys.Date())),
      
      # Continue button at the bottom of the overview
      br(),
      actionButton(
        inputId = "continue_to_employment", 
        label = "Continue to Visualization", 
        style = "
        background-color: #fce2c9; /* Same lighter color */
        color: black; 
        padding: 10px 20px; 
        font-size: 16px; 
        border-radius: 5px; 
        border: none;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
        cursor: pointer;
        "
      )
    )
  ),
  
  # Employment Trend Tab -----
  tabPanel(
    title = "Employment Trend",
    dashboardPage(
      dashboardHeader(disable = TRUE), # No header for the dashboard layout
      dashboardSidebar( disable = TRUE
      ),
      dashboardBody(
        fluidRow(
          column(
            4, 
            # Value boxes inside card with same background as Overview
            tags$div(
              class = "box-card",
              style = "background-color: #f0f0f0; padding: 20px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);",
              valueBoxOutput("total_employed"),
              valueBoxOutput("male_employed"),
              valueBoxOutput("female_employed")
            )
          ),
          column(
            4, 
            # Map in its own card with the same background as Overview
            tags$div(
              class = "map-card",
              style = "background-color: #f0f0f0; padding: 20px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);",
              uiOutput("map_title"),
              withSpinner(
                leafletOutput('map', width = '100%', height = '500px'),
                # spinner.type = 3
              )
            )
          ),
          column(
            4, 
            # Line chart in its own card with the same background as Overview
            tags$div(
              class = "chart-card",
              style = "background-color: #f0f0f0; padding: 20px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);",
              withSpinner(
                girafeOutput('line_chart', width = '100%', height = '500px')
              )
            )
          )
        ),
        fluidRow(
          column(
            3, 
            selectInput(
              inputId = 'comparison',
              label = 'Select Comparison:',
              choices = c('Region', 'Gender'),
              selected = 'Region'
            )
          ),
          column(
            3, 
            conditionalPanel(
              condition = "input.comparison == 'Gender'",
              selectInput(
                inputId = 'gender',
                label = 'Select Gender:',
                choices = c('Male', 'Female'),
                selected = 'Male'
              )
            )
          ),
          column(
            3, 
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
          )
        )
      )
    )
  )
)

# Define server logic 
server <- function(input, output, session) {
  # Scroll to the overview section when "Get Started" is clicked
  observeEvent(input$get_started, {
    shinyjs::runjs('$("html, body").animate({ scrollTop: $("#overview_section").offset().top }, 1000);')
  })
  
  # Navigate to Employment Trends page when "Continue to Employment Trends" is clicked
  observeEvent(input$continue_to_employment, {
    updateNavbarPage(session, "tabs", "Employment Trend")
  })
  
  # value boxes ----
  output$total_employed <- renderValueBox({
    total_employed <- sum(employment_data$num_employed[employment_data$year == input$map_time], na.rm = TRUE)
    total_employed_formatted <- prettyNum(total_employed, big.mark = ",")  # Adding commas
    valueBox(
      total_employed_formatted, "Total Employed", icon = icon("briefcase"), color = "purple"
    )
  })
  
  output$male_employed <- renderValueBox({
    male_employed <- sum(employment_data$num_employed[employment_data$gender == "Male" & employment_data$year == input$map_time], na.rm = TRUE)
    male_employed_formatted <- prettyNum(male_employed, big.mark = ",")  # Adding commas
    valueBox(
      male_employed_formatted, "Male Employed", icon = icon("male"), color = "aqua"
    )
  })
  
  output$female_employed <- renderValueBox({
    female_employed <- sum(employment_data$num_employed[employment_data$gender == "Female" & employment_data$year == input$map_time], na.rm = TRUE)
    female_employed_formatted <- prettyNum(female_employed, big.mark = ",")  # Adding commas
    valueBox(
      female_employed_formatted, "Female Employed", icon = icon("female"), color = "fuchsia"
    )
  })
  
  #Employment map----
  observeEvent(c(input$comparison, input$gender, input$map_time), {
    selected_comparison <- input$comparison
    selected_gender <- input$gender
    selected_maptime <- input$map_time
    
    # Filter the data based on the selected year
    data1 <- region_map |> 
      filter(year == selected_maptime)  # Filter based on selected year
    
    # Transform the CRS to WGS84 (EPSG:4326) if necessary
    data1 <- st_transform(data1, crs = 4326)  # Transform to WGS84 (long-lat)
    
    # Define global min and max for consistency across years
    global_min <- min(region_map$total_employed, na.rm = TRUE)
    global_max <- max(region_map$total_employed, na.rm = TRUE)
    
    # Define breaks and labels for the legend
    breaks <- c(0, 70000, 150000, 200000, 250000, global_max)
    labels <- c("0-70k", "70k-150k", "150k-200k", "200k-250k", paste0("> ", format(global_max, big.mark = ",")))
    
    # Define color palette using a consistent domain
    pal <- colorBin(
      palette = c("#ffeda0", "#feb24c", "#f03b20", "#bd0026", "#800026"),
      bins = breaks,
      domain = c(global_min, global_max),
      na.color = "transparent"
    )
    
    # Check the selected comparison (Region or Gender) and render the map accordingly
    if (selected_comparison == "Region") {
      output$map <- renderLeaflet({
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
              weight = 0.5,
              color = "#BDBDBD",
              fillColor = "gray",
              fillOpacity = 0.7,
              bringToFront = TRUE
            )
          ) %>%
          addLegend(
            position = "bottomright",
            pal = pal,
            values = c(global_min, global_max),
            title = "Employment",
            opacity = 0.7,
            labFormat = function(type, cuts, p) {
              labels
            }
          ) %>%
          setView(lng = 13.333, lat = 47.516, zoom = 6) %>%  # Coordinates of Austria
          setMaxBounds(lng1 = 9.5, lat1 = 46.5, lng2 = 17.0, lat2 = 49.0)  # Map bounds
      })
    } else if (selected_comparison == "Gender") {
      # Filter gender data
      gender_data <- gender_map |> 
        filter(gender == selected_gender, year == selected_maptime)
      
      # Transform CRS
      gender_data <- st_transform(gender_data, crs = 4326)
      
      output$map <- renderLeaflet({
        leaflet(gender_data) %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addPolygons(
            fillColor = ~pal(total_employed),
            color = "#BDBDBD",
            weight = 0.5,
            opacity = 1,
            fillOpacity = 0.7,
            popup = ~paste0(
              "<b>NUTS3: </b>", nuts_name, "<br>",
              "<b>Type: </b>", region, "<br>",
              "<b>Gender: </b>", gender, "<br>",
              "<b>Employed: </b>", total_employed, "<br>",
              "<b>Year: </b>", year
            ),
            highlight = highlightOptions(
              weight = 0.5,
              color = "#BDBDBD",
              fillColor = "gray",
              fillOpacity = 0.7,
              bringToFront = TRUE
            )
          ) %>%
          addLegend(
            position = "bottomright",
            pal = pal,
            values = c(global_min, global_max),
            title = "Employment",
            opacity = 0.7,
            labFormat = function(type, cuts, p) {
              labels
            }
          ) %>%
          setView(lng = 13.333, lat = 47.516, zoom = 6) %>%  # Coordinates of Austria
          setMaxBounds(lng1 = 9.5, lat1 = 46.5, lng2 = 17.0, lat2 = 49.0)
      })
    }
  })
  
  # Employment line chart----
  output$line_chart <- renderGirafe({
    # Filter the data based on gender and year input
    filtered_data <- employment_data |>
      filter(gender %in% c(input$gender), year == input$map_time)
    
    # Create the line chart with bar chart overlay
    line_chart <- ggplot(filtered_data) + 
      # Add the line chart
      geom_line(aes(x = year, y = total_employed, color = gender, group = gender), size = 1) +
      geom_point(aes(x = year, y = total_employed, color = gender), size = 3) +
      # Add the bar chart
      geom_bar(aes(x = year, y = total_employed, fill = gender), stat = 'identity', alpha = 0.5) +
      labs(title = paste(input$gender, "Employment Trend"), x = "Year", y = "Number of Employed") +
      theme_minimal() +
      theme(legend.position = "top") +
      scale_color_manual(values = c("Male" = "blue", "Female" = "pink")) +
      scale_fill_manual(values = c("Male" = "blue", "Female" = "pink"))
    
    ggplotly(line_chart)
  })
}

# Run the app ----
shinyApp(ui, server)

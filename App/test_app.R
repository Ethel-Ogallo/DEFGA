source('global.R')
# UI-----
ui <- navbarPage(
  title = "DEFGA",
  id = "tabs", # For programmatic navigation
  
  # Home Tab -----
  tabPanel(
    title = "Home",
    # Initial narrow image section with title 
    tags$div(
      style = "
      position: relative; 
      background-image: url('job-5382501_1280.jpg'); 
      background-size: cover;
      background-position: center;
      height: 70vh; /* Reduced height for the initial banner */
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
        h1("Development of Employment Figures by Gender, Austria", style = "font-size: 40px;color: #FFDEC7; margin-bottom: 20px;"),
      )
    ),
    tags$div(
      id = "overview_section", 
      style = "
      background-color: #2F2D2C ; 
      padding: 50px;
      max-width: 100vw; 
      margin: 0 auto; /* Minimal space */
      border-radius: 0; /* Remove border radius for continuation */
      box-shadow: none; /* Remove shadow for seamless look */
      color: #ffd8be;
      font-family: 'Arial', sans-serif;
    ",
      # Overview content
      h3("Overview", style = "font-size: 32px; font-weight: bold; color: #ffd8be; margin-bottom: 20px;"),
      p("This platform provides insights into employment trends across Austria from 2013 to 2022, with a focus on gender and urban-rural dynamics. The visualizations aim to help policymakers, educators, and researchers in identifying and addressing gender employment gaps."),
      p("By exploring the trends, the platform supports informed decision-making and contributes to bridging gender-related employment disparities."),
      h4("Acknowledgment", style = "font-size: 20px; font-weight: bold; margin-top: 20px;color: #ffd8be;"),
      tags$ul(
        tags$li("Adana Mirzoyan"),
        tags$li("Ethel Ogallo")
      ),
      h4("Data Sources", style = "font-size: 20px; font-weight: bold;color: #ffd8be; margin-top: 20px;"),
      tags$ul(
        tags$li(tags$a(href = "https://www.statistik.at/", target = "_blank", "Statistics Austria")),
        tags$li(tags$a(href = "https://ec.europa.eu/eurostat", target = "_blank", "Eurostat"))
      ),
      p(style = "font-size: 18px; line-height: 1.6;", paste("Last updated on:", Sys.Date())),
      
      # Continue button at the bottom of the overview
      br(),
      actionButton(
        inputId = "continue_to_employment", 
        label = "Continue to Dashboard >>", 
        style = "
        background-color: #9ecae1; /* Same lighter color */
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
        shinyDashboardThemes(theme = "flat_red"),
        fluidRow(
          column(12,
                 div(
                   style = "display: flex; justify-content: center; align-items: center; gap: 20px;",
                   valueBoxOutput("total_employed", width = 3),
                   valueBoxOutput("male_employed", width = 3),
                   valueBoxOutput("female_employed", width = 3)
                 )
          )
        ),
        fluidRow(
          column(
            5,
            br(),
            uiOutput("map_title"),
            withSpinner(
              leafletOutput(
                'map',
                width = '100%',
                height = '600px'
              ),
              # spinner.type = 3
            )
          ),
          column(
            2,
            selectInput(
              inputId = 'comparison',
              label = '1. Select Comparison:',
              choices = c('Region', 'Gender'),
              selected = 'Region'
            ),
            br(),
            conditionalPanel(
              condition = "input.comparison == 'Gender'",
              selectInput(
                inputId = 'gender',
                label = '2. Select Gender:',
                choices = c('Male', 'Female'),
                selected = 'Male'
              )
            ),
            br(),
            sliderInput(
              inputId = "map_time",
              label = "3. Select Year:",
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
                'line_chart',
                width = '100%',
                height = '700px'
              )
            )
          )
        )
      )
    )
  )
)

# Define server logic ----
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
    total_employed <- sum(employment_data$num_employ[employment_data$year == input$map_time], na.rm = TRUE)
    total_employed_formatted <- prettyNum(total_employed, big.mark = ",")  # Adding commas
    valueBox(
      total_employed_formatted, "Total Employed", icon = icon("briefcase"), color = "purple"
    )
  })
  
  output$male_employed <- renderValueBox({
    male_employed <- sum(employment_data$num_employ[employment_data$gender == "Male" & employment_data$year == input$map_time], na.rm = TRUE)
    male_employed_formatted <- prettyNum(male_employed, big.mark = ",")  # Adding commas
    valueBox(
      male_employed_formatted, "Male Employed", icon = icon("male"), color = "aqua"
    )
  })
  
  output$female_employed <- renderValueBox({
    female_employed <- sum(employment_data$num_employ[employment_data$gender == "Female" & employment_data$year == input$map_time], na.rm = TRUE)
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
      filter(year == selected_maptime)
    
    # Transform the CRS to WGS84 (EPSG:4326) if necessary
    data1 <- st_transform(data1, crs = 4326)
    
    # Define global min and max for consistency across years
    global_min1 <- min(region_map$total_employed, na.rm = TRUE)
    global_max1 <- max(region_map$total_employed, na.rm = TRUE)
    
    breaks1 <- c(0, 70000, 150000, 200000, 250000, global_max1)
    labels1 <- c("0-70k", "70k-150k", "150k-200k", "200k-250k", paste0("> ", format(global_max1, big.mark = ","))) 
    
    # Define color palettes for Male, Female, and Region
    male_palette <- c("#e0f7fa", "#b3e5fc", "#81d4fa", "#4fc3f7", "#0288d1")
    female_palette <- c("#fce4ec", "#f8bbd0", "#f48fb1", "#f06292", "#d81b60")
    region_palette <- c("#f3e5f5", "#e1bee7", "#ce93d8", "#ba68c8", "#8e24aa")
    
    # Select the palette dynamically based on the comparison type
    pal <- colorBin(
      palette = if (selected_comparison == "Region") region_palette else if (selected_gender == "Male") male_palette else female_palette,
      bins = breaks1,
      domain = c(global_min1, global_max1),
      na.color = "transparent"
    )
    
    # Check the selected comparison (Region or Gender) and render the map accordingly
    if (selected_comparison == "Region") {
      output$map <- renderLeaflet({
        leaflet(data1) %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addPolygons(
            fillColor = ~pal(total_employed),
            color = "#BDBDBD",
            weight = 0.5,
            opacity = 1,
            fillOpacity = 0.7,
            popup = ~paste0(
              "<b>NUTS3: </b>", NUTS_NAME, "<br>",
              "<b>Type: </b>", region, "<br>",
              "<b>Employed: </b>", total_employed, "<br>",
              "<b>Year: </b>", year
            ),
            highlight = highlightOptions(
              weight = 0.5,
              color = "#BDBDBD",
              fillColor = "#f03b20",
              fillOpacity = 0.7,
              bringToFront = TRUE
            )
          ) %>%
          addLegend(
            position = "bottomright",
            pal = pal,
            values = c(global_min1, global_max1),
            title = "No. employed",
            opacity = 0.7,
            labFormat = function(type, cuts, p) {
              labels1
            }
          ) %>%
          setView(lng = 13.333, lat = 47.516, zoom = 7) %>%
          setMaxBounds(lng1 = 9.5, lat1 = 46.5, lng2 = 17.0, lat2 = 49.0)
      })
    } else if (selected_comparison == "Gender") {
      # Filter gender data
      gender_data <- gender_map |> 
        filter(gender == selected_gender, year == selected_maptime)
      
      # Transform CRS
      gender_data <- st_transform(gender_data, crs = 4326)
      
      global_min2 <- min(gender_map$total_employed, na.rm = TRUE)
      global_max2 <- max(gender_map$total_employed, na.rm = TRUE)
      
      breaks2 <- c(0, 20000, 50000, 80000, 130000, global_max2)
      labels2 <- c("0-20k", "20k-50k", "50k-80k","80k-130k",paste0("> ", format(global_max2, big.mark = ",")))
      
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
              "<b>NUTS3: </b>", NUTS_NAME, "<br>",
              "<b>Type: </b>", region, "<br>",
              "<b>Gender: </b>", gender, "<br>",
              "<b>Employed: </b>", total_employed, "<br>",
              "<b>Year: </b>", year
            ),
            highlight = highlightOptions(
              weight = 0.5,
              color = "#BDBDBD",
              fillColor = "#f03b20",
              fillOpacity = 0.7,
              bringToFront = TRUE
            )
          ) %>%
          addLegend(
            position = "bottomright",
            pal = pal,
            values = c(global_min2, global_max2),
            title = "No. employed",
            opacity = 0.7,
            labFormat = function(type, cuts, p) {
              labels2
            }
          ) %>%
          setView(lng = 13.333, lat = 47.516, zoom = 7) %>%
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
      geom_line(aes(x = year, y = num_employ, color = gender, group = gender), size = 1) +
      geom_point(aes(x = year, y = num_employ, color = gender), size = 3) +
      # Add the bar chart
      geom_bar(aes(x = year, y = num_employ, fill = gender, 
                   text = paste0("gender: ", gender, "<br>Year: ", year, "<br>Total Employed: ", num_employ)),
               stat = "identity", width = 0.5, alpha = 0.5, position = "dodge") +
      scale_color_manual(values = c("Male" = "#4fc3f7", "Female" = "#f06292")) +
      scale_fill_manual(values = c("Male" = "#4fc3f7", "Female" = "#f06292")) +
      scale_x_continuous(breaks = seq(min(employment_data$year), max(employment_data$year), by = 1)) +
      ggtitle("Gender Employment Over Time") +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0.5))
    
    # Create an interactive plot using girafe
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

# Run the application 
shinyApp(ui = ui, server = server)

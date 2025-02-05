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
      padding: 80px 20px; /* Space around the content */
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
        h1("Development of Employment Figures by Gender, Austria", style = "font-size: 40px;color: #F0f0f0; margin-bottom: 20px;"),
      )
    ),
    tags$div(
      id = "overview_section", 
      style = "
      display: flex;
      position: relative;
      justify-content: center;
      align-items: center;
      background-color: #f5f5f5; /* Light grey background */
      padding: 80px 20px; /* Space around the content */
      height: 90vh; /* Center vertically within the viewport */
      color: #333;
      font-family: 'Arial', sans-serif;
      z-index: 2;
    ",
      tags$div(
        style = "
        max-width: 800px; /* Restrict content width */
        line-height: 1.8; /* Improved readability */
        padding: 20px 30px; /* Breathing space */
        border-radius: 10px; /* Rounded corners */
        background-color: transparent; /* No obvious card background */
      ",
        # Overview content
        h3("Overview", style = "font-size:26px; font-weight: bold; color: #333; margin-bottom: 20px;"),
        p("This platform provides insights into employment trends across Austria from 2013 to 2022, with a focus on 
          gender and urban-rural dynamics. The visualizations aim to help policymakers, educators, and researchers in 
          identifying and addressing gender employment gaps.",
          style = "font-size: 20px;"),
        p("Acknowledgment", style = "font-size: 20px; font-weight: bold; margin-top: 20px; color: #333;"),
        tags$ul(
          style = "font-size: 20px; padding-left: 20px;", # Ensure bullets align correctly
          tags$li("Adana Mirzoyan"),
          tags$li("Ethel Ogallo")
        ),
        p("Data Sources", style = "font-size: 20px; font-weight: bold; color: #333; margin-top: 20px;"),
        tags$ul(
          style = "font-size: 20px; padding-left: 20px;", # Ensure bullets align correctly
          tags$li(tags$a(href = "https://www.statistik.at/", target = "_blank", "Statistics Austria")),
          tags$li(tags$a(href = "https://ec.europa.eu/eurostat", target = "_blank", "Eurostat"))
        ),
        p(style = "font-size: 18px;", paste("Last updated on: 24-01-2025")),
        # Continue button at the bottom of the overview
        br(),
        actionButton(
          inputId = "continue_to_employment", 
          label = "Continue to Dashboard >>", 
          style = "
          background-color: #9ecae1; /* Same lighter color */
          color: black; 
          padding: 12px 24px; /* Slightly larger button */
          font-size: 18px; 
          border-radius: 5px; 
          border: none;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
          cursor: pointer;
        "
        )
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
            h3("Employment Distribution Across Austria",style = "color: black; text-align: center;"),
            br(),
            uiOutput("map_description"),
            br(),
            withSpinner(
              leafletOutput(
                'map',
                width = '100%',
                height = '500px'
              )
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
            br(),
            h3("Employment Trends by Gender Over Time", style = "color: black; text-align: center;"),
            uiOutput("bar_chart_description"),
            br(),
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


# SERVER LOGIC ----
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
    
    output$map_description <- renderText({
      if (input$comparison == "Region") {
        HTML('<p style="color: black;">This map shows the percentage of total employed per NUTS3 region, calculated as the total employed in that NUTS3 region for the selected year divided by the total employed in Austria that year. Click on a region to read more.</p>')
      } else {
        HTML(paste0('<p style="color: black;">This map shows the percentage of ', input$gender, 
                    ' employment in each NUTS3 region, calculated as the total ', input$gender, 
                    ' employed in that NUTS3 region for the selected year divided by the total employed in that NUTS3 region that year.</p>'))
      }
    })
    
    # Filter the data based on the selected year
    data1 <- region_map |> 
      filter(year == selected_maptime)
    
    # Transform the CRS to WGS84 (EPSG:4326) if necessary
    data1 <- st_transform(data1, crs = 4326)
    
    # Define breaks and labels dynamically based on relative percentages
    breaks1 <- c(0, 1, 3, 5, max(region_map$perc_total_employed_nuts, na.rm = TRUE))
    labels1 <- c("< 1%", "1-3%" ,"3-5%", "> 5%")
    
    # Define color palettes for Male, Female, and Region
    male_palette <- c("#e0f7fa", "#b3e5fc", "#81d4fa", "#4fc3f7", "#0288d1")
    female_palette <- c("#fce4ec", "#f8bbd0", "#f48fb1", "#f06292", "#d81b60")
    region_palette <- c("#f3e5f5", "#e1bee7", "#ce93d8", "#ba68c8", "#8e24aa")
    
    # Select the palette dynamically based on the comparison type
    pal <- colorBin(
      palette = if (selected_comparison == "Region") region_palette else if (selected_gender == "Male") male_palette else female_palette,
      bins = breaks1,
      domain = c(0, max(region_map$perc_total_employed_nuts, na.rm = TRUE)),
      na.color = "transparent"
    )
    
    if (selected_comparison == "Region") {
      output$map <- renderLeaflet({
        leaflet(data1) %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addPolygons(
            fillColor = ~pal(perc_total_employed_nuts),
            color = "#BDBDBD",
            weight = 0.5,
            opacity = 1,
            fillOpacity = 0.7,
            popup = ~paste0(
              "<b>NUTS3: </b>", nuts_name, "<br>",
              "<b>Type: </b>", region, "<br>",
              "<b>Num employed: </b>", scales::comma(total_employed_nuts), "<br>",
              "<b>Percent Employed: </b>", round(perc_total_employed_nuts, 2), "%<br>",
              "<b>Year: </b>", year
            ),
            highlight = highlightOptions(
              weight = 0.5,
              color = "#BDBDBD",
              fillColor = "#feb24c",
              fillOpacity = 0.7,
              bringToFront = TRUE
            )
          ) %>%
          addLegend(
            position = "bottomright",
            pal = pal,
            values = region_map$perc_total_employed_nuts,
            title = "% Employed",
            opacity = 0.7,
            labFormat = function(type, cuts, p) {
              labels1
            }
          ) %>%
          setView(lng = 13.333, lat = 47.516, zoom = 7) %>%
          setMaxBounds(lng1 = 9.5, lat1 = 46.5, lng2 = 17.0, lat2 = 49.0)
      })
    } else if (selected_comparison == "Gender") {
      gender_data <- gender_map |> 
        filter(gender == selected_gender, year == selected_maptime)
      
      gender_data <- st_transform(gender_data, crs = 4326)
      
      # Adjust breaks dynamically based on selected gender
      if (selected_gender == "Male") {
        breaks2 <- c(0, 50, 52, 54, max(gender_map$perc_total_employed_nuts_gender, na.rm = TRUE))
        labels2 <- c("≤ 50%", "50-52%","52-54%", paste0("> ", format(max(gender_map$perc_total_employed_nuts_gender, na.rm = TRUE), digits = 2), "%"))
      } else {
        breaks2 <- c(0, 44, 46, 48, 50)
        labels2 <- c("≤ 44%", "44-46%", "46-48%","48-50%")
      }
   
      pal_gender <- colorBin(
        palette = if (selected_gender == "Male") male_palette else female_palette,
        bins = breaks2,
        domain = c(0, max(gender_map$perc_total_employed_nuts_gender, na.rm = TRUE)),
        na.color = "transparent"
      )
      
      output$map <- renderLeaflet({
        leaflet(gender_data) %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addPolygons(
            fillColor = ~pal_gender(perc_total_employed_nuts_gender),
            color = "#BDBDBD",
            weight = 0.5,
            opacity = 1,
            fillOpacity = 0.7,
            popup = ~paste0(
              "<b>NUTS3: </b>", nuts_name, "<br>",
              "<b>Type: </b>", region, "<br>",
              "<b>Gender: </b>", gender, "<br>",
              "<b>Num employed: </b>", scales::comma(total_employed_nuts_gender), "<br>",
              "<b>Percent Employed: </b>", round(perc_total_employed_nuts_gender, 2), "%<br>",
              "<b>Year: </b>", year
            ),
            highlight = highlightOptions(
              weight = 0.5,
              color = "#BDBDBD",
              fillColor = "#feb24c",
              fillOpacity = 0.7,
              bringToFront = TRUE
            )
          ) %>%
          addLegend(
            position = "bottomright",
            pal = pal_gender,
            values = gender_map$perc_total_employed_nuts_gender,
            title = "% Employed",
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
  observeEvent(c(input$comparison, input$gender, input$map_time), {
    selected_comparison <- input$comparison
    selected_gender <- ifelse(is.null(input$gender), "Male", input$gender)
    selected_maptime <- input$map_time
    
    output$bar_chart_description <- renderText({
      if (input$comparison == "Region") {
        HTML('<p style="color: black;">This bar chart shows the overall employment distribution over time, allowing for a comparison of employment trends across different years. Bars will be the default color when year is selected.</p>')
      } else {
        HTML(paste0('<p style="color: black;">This bar chart highlights the employment trends of ', input$gender, 
               ' individuals over the years. Bars corresponding to the selected gender will be highlighted in a darker color to emphasize their representation.Bars will be the default color when year is selected</p>'))
      }
    })

    
    output$line_chart <- renderGirafe({
      # Define a function to darken the color
      darken_color <- function(color, factor = 0.9) {
        col <- col2rgb(color) / 255
        col <- col * factor  # Darken the color by a factor
        rgb(col[1], col[2], col[3], maxColorValue = 1)
      }
      
      # Define base colors for gender
      base_colors <- c(
        "Male" = "#81d4fa",  # Light blue for Male
        "Female" = "#f48fb1"  # Light pink for Female
      )
      
      # Apply highlighting logic based on selected year or gender
      employment_data2 <- employment_data2 %>%
        mutate(
          highlight_color = case_when(
            year == selected_maptime & gender == selected_gender ~ "highlight",  # Both selected
            #year == selected_maptime ~ "year_selected",  # Only year selected
            gender == selected_gender ~ "gender_selected",  # Only gender selected
            TRUE ~ "default"  # No selection
          ),
          # Apply darkened color for highlighting, or use default color
          bar_color = case_when(
            #highlight_color == "highlight" ~ darken_color(base_colors[gender], factor = 1),  # Darken the color for both gender and year
            highlight_color == "year_selected" & gender == "Male" ~ darken_color(base_colors["Male"], factor = 0.7),  # Darken male bars for year
            highlight_color == "year_selected" & gender == "Female" ~ darken_color(base_colors["Female"], factor = 0.7),  # Darken female bars for year
            highlight_color == "gender_selected" & gender == "Male" ~ darken_color(base_colors["Male"], factor = 0.7),  # Darken male bars for gender
            highlight_color == "gender_selected" & gender == "Female" ~ darken_color(base_colors["Female"], factor = 0.7),  # Darken female bars for gender
            TRUE ~ base_colors[gender]  # Default to gender's color
          )
        )
      
      # Create the main plot without the legend
      line_chart <- ggplot(employment_data2) +
        geom_col_interactive(
          aes(
            x = year,
            y = perc_total_employed_gender,
            fill = bar_color,  # Use dynamically calculated bar color
            tooltip = paste0(
              "Gender: ", gender,
              "<br>Year: ", year,
              "<br>Number employed: ", scales::comma(total_employed_gender),  # Format with commas
              "<br>Percentage: ", round(perc_total_employed_gender, 2), "%"
            ),
            data_id = paste0(year, "_", gender)
          ),
          stat = "identity",
          position = "dodge",
          width = 0.5,
          alpha = 0.8  # Slightly increase opacity for the bars
        ) +
        scale_x_continuous(
          breaks = seq(min(employment_data2$year), max(employment_data2$year), by = 1),
          name = "Year"
        ) +
        scale_y_continuous(
          breaks = seq(40, 60, by = 1),  # Adjusted for better visibility
          name = "Percentage of Total Employed"
        ) +
        coord_cartesian(ylim = c(45, 55)) +
        scale_fill_identity() +  # Use the dynamically calculated fill colors for the bars
        theme_classic() +
        theme(
          plot.title = element_text(hjust = 0.5, face = "bold"),
          axis.title.x = element_text(size = 14),  # Adjust x-axis title size
          axis.title.y = element_text(size = 14),   # Adjust y-axis title size
          legend.position = "none",  # Remove the legend from the main plot
          legend.title = element_text(face = "bold"),
          legend.text = element_text(size = 12)
        )
      
      # Create a separate legend
      legend <- ggplot(data.frame(gender = c("Male", "Female"), fill = base_colors)) +
        geom_point(aes(x = gender, y = 1, color = gender), size = 5) +  # Larger points (size 5)
        geom_text(aes(x = gender, y = 1, label = gender), size = 4, color = "black", hjust = -0.3) +  # Adjust label to the left
        scale_color_manual(values = base_colors) +  # Apply base colors
        theme_void() +
        theme(
          legend.position = "none"  # Remove the legend
        )

      
      # Combine the chart and the legend
      combined_plot <- plot_grid(line_chart, legend, ncol = 1, rel_heights = c(1, 0.2))
      
      # Return the combined plot as a girafe object
      girafe(
        ggobj = combined_plot,
        width_svg = 10,
        height_svg = 9,
        options = list(
          opts_hover(css = "stroke-width: 3; cursor: pointer; fill: grey;"),
          opts_selection(
            type = "single",  # Single selection mode
            css = "stroke: darkblue; stroke-width: 2;",
            only_shiny = TRUE
          ),
          opts_tooltip(css = "background-color: white; color: black; font-size: 14px; padding: 5px;")
        )
      )
    })
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

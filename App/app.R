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
          overflow: hidden;
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
          height: 100vh; /* Full viewport height */
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
        "Welcome!"
        ),
      p(  
        style = "font-size: 18px; line-height: 1.6;",
        "The Development of Employment Figures by Gender in Austria platform explores gender-based employment 
        trends across regions in Austria from 2013 to 2022, with a specific focus on disparities in gender and 
        urban-rural dynamics. The data used is merged employment data by gender and region from Statistics Austria and NUTS3 region data from Eurostat. 
        The objective is to provide policymakers and educators with insights to address employment gaps and promote gender equity."
      ),
      h4("Acknowledgment"),
      p(
        style = "font-size: 18px; line-height: 1.6; margin-top: 20px;",
        "Authors:"
      ),
      tags$ul(
        style = "font-size: 18px; line-height: 1.6; text-align: left; margin-left: left; margin-right: auto;",
        tags$li("Adana Mirzoyan"),
        tags$li("Ethel Ogallo")
      ),
      p(
        style = "font-size: 18px; line-height: 1.6; margin-top: 20px;",
        "Data sources:"
      ),
      tags$ul(
        style = "text-align: left; margin-left: left; margin-right: auto; font-size: 18px;",
        tags$li(tags$a(href = "https://www.statistik.at/", target = "_blank", "Statistics Austria")),
        tags$li(tags$a(href = "https://ec.europa.eu/eurostat", target = "_blank", "Eurostat"))
      ),
      p(
        style = "text-align: left; font-size: 18px; line-height: 1.6; margin-top: 20px;",
        paste("Last Updated: ", Sys.Date())
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
        withSpinner(
          girafeOutput(
            'line_chart',
            width = '100%',
            height = '1000px'
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
            choices = c('total', 'Male', 'Female'),
            selected = 'total'
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
            'map',
            width = '100%',
            height = '700px'
          ),
          type = '3',
          color.background = 'white'
        )
      )
    ),
    # fluidRow(
    #   #column(7),
    #   column(12,
    #          sliderInput(
    #            inputId = "year",
    #            label = "Year:",
    #            min = 2013,               # Start year
    #            max = 2022,               # End year
    #            value = 2013,             # Default selected year
    #            step = 1,                 # Increment in years
    #            animate = TRUE            # Optional: Add animation controls
    #          )
    #   )
    #   
    # )
  )
)


# SERVER ----
server <- function(input, output, session) {
  # Navigate to "About" page when "Get started" is clicked
  observeEvent(input$get_started, {
    updateNavbarPage(session, inputId = "main_tabs", selected = "About")
  })
  
  # Employment line chart----
  output$line_chart <- renderGirafe({
    # Create the line chart using ggplot2
    line_chart <- employment_data |>
      filter(gender %in% c("Male", "Female")) |> # Filter for male and female genders only
      group_by(year, gender) |>
      summarise(total_employed = sum(num_employed, na.rm = TRUE)) |>
      ungroup() |>
      ggplot(aes(
        x = year, 
        y = total_employed, 
        color = gender, 
        group = gender,
        tooltip = paste("Gender:", gender, "<br>Year:", year, "<br>Total Employed:", total_employed),
        data_id = gender # Unique ID for interactive selection
      )) +
      geom_line_interactive() + # Interactive lines
      geom_point_interactive() + # Interactive points
      scale_x_continuous(breaks = seq(min(employment_data$year), max(employment_data$year), by = 1)) + # Show all years
      ggtitle("Gender employment through time") +
      theme_classic() +
      theme(legend.position = "bottom",)
    
    # Render the interactive plot
    girafe_plot1 <- girafe(
      ggobj = line_chart,
      width_svg = 7, 
      height_svg = 6,
      options = list(
        opts_hover(css = "stroke-width: 3; cursor: pointer;"), # Highlight hovered elements
        opts_selection(type = "single", css = "opacity: 0.4;"), # Single selection with unselected dimming
        opts_tooltip(css = "background-color: white; color: black; font-size: 14px; padding: 5px;") # Tooltip styling
      )
    )
    # Display the interactive plot
    girafe_plot1
  })
  
  # Employment map ----
  observeEvent(c(input$comparison, input$gender, input$map_time), {
    selected_comparison <- input$comparison
    selected_gender <- input$gender
    selected_maptime <- input$map_time
    
    # Filter the data based on the selected year
    data1 <- region_map %>%
      filter(year == selected_maptime)
    
    # Check the selected comparison (Region or Gender) and filter accordingly
    if (selected_comparison == "Region") {
      
      # Render the region map with interactive hover
      output$map <- renderGirafe({
        gg <- ggplot(data1) +
          geom_sf_interactive(aes(fill = total_employed, geometry = geometry,
                                  tooltip = paste("<br>NUTS3: ",nuts_name,
                                                  "<br>Type: ", region, 
                                                  "<br>Employed: ", total_employed,
                                                  "<br>Year: ", year))) +
          scale_fill_gradient(
            low = "#F7EF99",  # Color for the minimum value
            high = "#BC2C1A", # Color for the maximum value
            name = "Employed" # Legend title
          )  + 
          labs(title = paste("Employment by Region in", selected_maptime)) +
          theme_void() +
          theme(legend.position = "right", 
                plot.title = element_text(hjust = 0.5))  # Center title
        
        # Make it interactive using girafe
        girafe_plot2 <- girafe(
          ggobj = gg,
          width_svg = 7, 
          height_svg = 6,
          options = list(
            opts_hover(css = "stroke-width: 3; cursor: pointer;"),  # Highlight hovered elements
            opts_selection(type = "single", css = "opacity: 0.4;"),  # Single selection with unselected dimming
            opts_tooltip(css = "background-color: white; color: black; font-size: 14px; padding: 5px;")  # Tooltip styling
          )
        )
        
        girafe_plot2
      })
      
    } else if (selected_comparison == "Gender") {
      
      # Filter the data by gender and year
      gender_data <- gender_map %>%
        filter(gender == selected_gender, year == selected_maptime)
      
      # Render the gender map with interactive hover
      output$map <- renderGirafe({
        gg <- ggplot(gender_data) +
          geom_sf_interactive(aes(fill = total_employed, geometry = geometry,
                                  tooltip = paste("NUTS3:", nuts_name,
                                                  "<br>Type: ", region,
                                                  "<br>Gender: ", gender,
                                                  "<br>Employed: ", total_employed,
                                                  "<br>Year: ", year))) +
          scale_fill_gradient(
            low = "#F7EF99",  # Color for the minimum value
            high = "#BC2C1A", # Color for the maximum value
            name = "Employed" # Legend title
          )  +
          labs(title = paste("Employment by Gender in", selected_maptime)) +
          theme_void() +
          theme(legend.position = "right",
                plot.title = element_text(hjust = 0.5))
        
        # Make it interactive using girafe
        girafe_plot3 <- girafe(
          ggobj = gg,
          width_svg = 7, 
          height_svg = 6,
          options = list(
            opts_hover(css = "stroke-width: 3; cursor: pointer;"), # Highlight hovered elements
            opts_selection(type = "single", css = "opacity: 0.4;"), # Single selection with unselected dimming
            opts_tooltip(css = "background-color: white; color: black; font-size: 14px; padding: 5px;") # Tooltip styling
          )
        )
      })
    }
  })
  
  
}

# Run App ----
shinyApp(ui, server)



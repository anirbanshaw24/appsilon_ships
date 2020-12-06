# Initialize a Semantic page
semanticPage(
  # Assign webpage title
  title = "Ship Routes",
  
  # Suppress bootstrap
  suppress_bootstrap = TRUE,
  
  # Loading screen
  use_waiter(),
  waiter_show_on_load(html = spin_fading_circles()),
  
  # Header segment with Title of the app and a short Description
  segment(
    class = 'basic',
    h1(class = "ui header", "Longest Consecutive Mesurements in Vessel Routes"),
    div(
      style = "font-size: 18px; line-height: 1.5",
      'This app calculates the longest distance between consecutive gps coordinates and plots the same.
                       To begin, please select the Vessel Type followed by Vessel Name and optionally the trip destination.'
    )
  ),
  
  # A fluidrow container to house all the drop down inputs and information cards
  fluidRow(
    # Column with half width in the fluidrow
    column(
      5,
      class = 'ui raised segment',
      style = "text-align: center; border-top: 5px solid LightSeaGreen; display: inline-block;  margin: 10px; vertical-align:top",
      
      # Drop down for selecting ship type
      div(
        style = "margin: 10px; display: inline-block",
        drop_down_input(
          id = "ship_type",
          label = 'Vessel Type',
          choices = str_sort(as.character(unique(
            processed_data$ship_type
          )))
        )
      ),
      '->',
      
      # Drop down for selecting ship name
      div(
        style = "margin: 10px; display: inline-block",
        drop_down_input(
          id = "ship_name",
          label = 'Vessel Name',
          choices = c()
        )
      )
    ),
    
    # Column with half width in the fluidrow
    column(
      6,
      style = "  display: inline-block;",
      fluidRow(
        
        # Info Card with total number of observations for the selected Vessel
        column(
          2,
          class = 'ui raised segment',
          style = "text-align: center; border-top: 5px solid DarkSeaGreen;  display: inline-block; margin: 10px;  font-family: Arial; ",
          div(style = "font-size: 18px;  color: DimGray; font-weight: bold",
              textOutput('num_observations')),
          div(style = "font-size: 16px;  margin: 8px; color: DimGray",
              'Total Observations')
        ),
        
        # Info Card with average speed for the selected Vessel
        column(
          2,
          class = 'ui raised segment',
          style = "text-align: center; border-top: 5px solid DarkSeaGreen;  display: inline-block;  margin: 10px; font-family: Arial; vertical-align:top",
          div(style = "font-size: 18px;  color: DimGray; font-weight: bold",
              textOutput('avg_speed')),
          div(style = "font-size: 16px;  margin: 8px;  color: DimGray;",
              'Average Speed')
        ),
        
        # Info Card with the average distance between consecutive observations for the selected Vessel
        column(
          2,
          class = 'ui raised segment',
          style = "text-align: center; border-top: 5px solid DarkSeaGreen;  display: inline-block;  margin: 10px; font-family: Arial; vertical-align:top",
          div(style = "font-size: 18px;  color: DimGray; font-weight: bold",
              textOutput('avg_dist'),),
          div(style = "font-size: 16px;  margin: 8px;  color: DimGray; ",
              'Avg. Dist. bet. Obs.')
        ),
        
        # Info Card with the Vessel length for the selected Vessel
        column(
          2,
          class = 'ui raised segment',
          style = "text-align: center; border-top: 5px solid DarkSeaGreen;  display: inline-block;  margin: 10px; font-family: Arial; vertical-align:top",
          div(style = "font-size: 18px;  color: DimGray; font-weight: bold",
              textOutput('ship_length')),
          div(style = "font-size: 16px;  margin: 8px;  color: DimGray;",
              'Ship Length')
        ),
        
        # Info Card with the Vessel width for the selected Vessel
        column(
          2,
          class = 'ui raised segment',
          style = "text-align: center; border-top: 5px solid DarkSeaGreen;  display: inline-block;  margin: 10px; font-family: Arial; vertical-align:top",
          div(style = "font-size: 18px;  color: DimGray; font-weight: bold",
              textOutput('ship_width')),
          div(style = "font-size: 16px;  margin: 8px;  color: DimGray; ",
              'Ship Width')
        ),
        
        # Info Card with the average dead weight for the selected Vessel
        column(
          2,
          class = 'ui raised segment',
          style = "text-align: center; border-top: 5px solid DarkSeaGreen;  display: inline-block;  margin: 10px; font-family: Arial; vertical-align:top",
          div(style = "font-size: 18px;  color: DimGray; font-weight: bold",
              textOutput('ship_weight')),
          div(style = "font-size: 16px;  margin: 8px;  color: DimGray;",
              'Avg. Deadweight')
        )
      )
    )
  ),
  p(),
  
  # Segment with the leaflet output initialized with 100% width and 600 pixels height
  segment(style = "text-align: center; border-top: 5px solid forestgreen",
          
          # This segment contains the leaflet map taking 100% width and height fixed at 700px
          leafletOutput(
            "map", width = "100%", height = 600
          ))
  
)
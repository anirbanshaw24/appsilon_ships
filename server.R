function(input, output, session) {
  
  # Hide the initial loading screen
  waiter_hide()
  
observe( {
  # Validate that the reactive data frame is filtered by selected Vessel Type and is not empty
  validate(
    need(selected_ship_type(), 'Select Vessel Type')
  )
  
  # Remove duplicates from all the Vessel Names according to the selected Vessel type, then sort alphabetically and then isolate it as it is a reactive data frame
  temp <- isolate(str_sort(as.character(unique(selected_ship_type()$SHIPNAME))))
  
  # Call the above initialized module to update the drop down menu
  drop_down_server( id = 'ship_name',
                   choices = temp)
})

  observe({
    
    # Validate that the reactive data frame is filtered by selected Vessel Name and is not empty
    validate(
      need(selected_ship(), 'Select Vessel')
    )
    
    # Remove duplicates from all the Vessel Destinations according to the selected Vessel Name, then sort alphabetically and then isolate it as it is a reactive data frame
    temp <- isolate(str_sort(as.character(unique(selected_ship()$DESTINATION[selected_ship()$DESTINATION != "" & !is.na(selected_ship()$DESTINATION)]))))

    # Call the above initialized module to update the drop down menu
    drop_down_server( id = 'ship_destination',
                     choices = c('All Journeys', temp))
    })
  
  # Reactive data frame based on the selected vessel type
  selected_ship_type <- reactive({
    temp <- processed_data %>%
      filter(ship_type == input$'ship_type-dropdown')
    temp
  })
  
  # Reactive Ship ID from the selected vessel name. Multiple vessel names are there for the same vessel ID.
  selected_ship_id <- reactive({
    ship_id <- selected_ship_type()[selected_ship_type()$SHIPNAME == input$'ship_name-dropdown', 'SHIP_ID'][1,1]
    ship_id$SHIP_ID
  })
  
  # Reactive data frame based on the selected vessel name
  selected_ship <- reactive({
    
    # Filter the data based on selected vessel name.
      temp <- selected_ship_type() %>%
        filter(SHIP_ID == selected_ship_id())
    temp
  })
  
  # Reactive data frame with the observation with longest distance and most recent trip and the preceding observation.
  selected_ship_longest_recent_trip <- reactive( {
    
    # Filter the observation with longest and recent trip and the observation before that. If the first observation is longest then take the first row twice so that mid point calculations are valid later on.
      if (tail(which(selected_ship()$distance == max(selected_ship()$distance)), 1) == 1) {
        temp <- selected_ship()[c(tail(which(selected_ship()$distance == max(selected_ship()$distance)), 1), tail(which(selected_ship()$distance == max(selected_ship()$distance)), 1)), ]
      } else {
        temp <- selected_ship()[c(tail(which(selected_ship()$distance == max(selected_ship()$distance)), 1) - 1, tail(which(selected_ship()$distance == max(selected_ship()$distance)), 1)), ]
      }
    temp
  })

  # # Info Card with total number of observations for the selected Vessel
  output$num_observations <- renderText({
    
    # Validate that vessel name is selected
    validate(
      need(input$'ship_name-dropdown', 'Select Vessel')
    )
    paste( prettyNum(dim(selected_ship())[1], big.mark = ',') )
    })
  
  # Info Card with average speed for the selected Vessel
  output$avg_speed <- renderText({
    # Validate that vessel name is selected
    validate(
      need(input$'ship_name-dropdown', 'Select Vessel')
    )
    paste( prettyNum(round(mean(selected_ship()$SPEED), 0), big.mark = ',') , 'knots')
  })
  
  # Info Card with the average distance between consecutive observations for the selected Vessel
  output$avg_dist <- renderText({
    
    # Validate that vessel name is selected
    validate(
      need(input$'ship_name-dropdown', 'Select Vessel')
    )
    paste( prettyNum(round(mean(selected_ship()$distance), 0), big.mark = ',') , 'meters')
  })
  
  # Info Card with the Vessel length for the selected Vessel
  output$ship_length <- renderText({
    
    # Validate that vessel name is selected
    validate(
      need(input$'ship_name-dropdown', 'Select Vessel')
    )
    paste( prettyNum(round(mean(selected_ship()$LENGTH), 0), big.mark = ',') , 'meters')
  })
  
  # Info Card with the Vessel width for the selected Vessel
  output$ship_width <- renderText({
    
    # Validate that vessel name is selected
    validate(
      need(input$'ship_name-dropdown', 'Select Vessel')
    )
    paste( prettyNum(round(mean(selected_ship()$WIDTH), 0), big.mark = ',') , 'meters')
  })
  
  # Info Card with the average dead weight for the selected Vessel
  output$ship_weight <- renderText({
    
    # Validate that vessel name is selected
    validate(
      need(input$'ship_name-dropdown', 'Select Vessel')
    )
    paste( prettyNum(round(mean(selected_ship()$DWT), 0), big.mark = ',') , 'tons')
  })
  
  # Construct the base map on leaflet with the unique ports in the data set plotted on the map.
  output$map <- renderLeaflet({
    map_temp <-
      leaflet(data = parked_ships) %>%
      
      # Set the view
      setView(lng = 20,
              lat = 57,
              zoom = 6) %>%
      
      # Add base layer of world map
      addProviderTiles(group = 'provider_tile',
                       provider = providers$CartoDB.Positron) %>%
      
      # Add minimap for reference
      addMiniMap(
        zoomAnimation = T,
        tiles = providers$Esri,
        width = 150,
        height = 150,
        zoomLevelOffset = -6,
        autoToggleDisplay = T
      ) %>%
      
      # Add markers of all the unique ports in the dataset
      addAwesomeMarkers(
        group = 'ports',
        ~ LON,
        ~ LAT,
        icon = makeAwesomeIcon(
          icon = "anchor",
          markerColor = "green",
          library = "fa",
          iconColor = "#FFFFFF"
        ),
        label = paste( str_to_title(parked_ships$port)),
        labelOptions = labelOptions(
          direction = 'bottom',
          # style = "background-color: red",
          noHide = T,
          textsize = "16px",
          # offset = c(0, 15),
          style = list(
            "background-color" = "rgba(73, 161, 38, 0.1)",
            "font-family" = "ariel",
            "font-style" = "italic",
            "box-shadow" = "1px 1px rgba(0,0,0,0.15)",
            "font-size" = "16px",
            "border-color" = "rgba(0,0,0,0.05)"
          )
        )
      )
    map_temp
  })
  
  # Reactively update ship route and longest ship distance based on user selections.
  observe( {

    # Validate that ship is selected
    validate(need(
      input$'ship_name-dropdown',
      'Select ship type and ship name. Then Click on "Calculate"'
    ))

    # Filter the last observation with longest trip
    temp <- isolate(selected_ship_longest_recent_trip())

    # Isolate the reactive data frame of all the observations of the selected ship
    temp2 <- isolate(selected_ship())

    # Calculate the mid point between the 2 coordinates with the longest distance
    mid_pt <-
      midPoint(
        p1 = c(temp$LON[1], temp$LAT[1]),
        p2 = c(temp$LON[2], temp$LAT[2]),
        a = 6378137,
        f = 1 / 298.257223563
      )

    # Create bounding box of all the coordinates from a selected ship. This will be used for setting the view of leaflet.
    view_box <- make_bbox(temp2$LON, temp2$LAT, f = -0.04)

    # Create labels for the longest consecutive distances
    labs <- lapply(seq(nrow(temp)), function(i) {
      paste0(
        '<b>',
        'Max Consecutive Distance',
        '</b><br>',
        'Vessel: ',
        '<i>',
        temp[2, "SHIPNAME"],
        ' (',
        temp[2, "ship_type"],
        ')',
        '</i>',
        '<br>',
        'Date: ',
        '<i>',
        format(as.Date.character(temp[2, "date"], format = "%Y-%m-%d"),
               "%d %B, %Y"),
        '</i>',
        '<br>',
        'Max Dist.: ',
        '<i>',
        prettyNum(round(temp[2, "distance"], 0), big.mark = ','),
        ' meters',
        '</i>',
        '<br>',
        'Dest.: ',
        '<i>',
        temp[2, "DESTINATION"],
        '</i>'
      )
    })

    # Add polylines of all the trips by the ship and highlight the line with the longest distance.
    map_temp <- leafletProxy("map",
                 data = temp2) %>%

      # Clear the previous vessel routes from the map
      clearGroup(c(
        'all_ship_routes',
        'longest_trip',
        'longest_coordinates',
        'mid_point'
      )) %>%

      # Fly to new map view according to the selected vessel
      flyToBounds(view_box[[1]], view_box[[2]] , view_box[[3]] , view_box[[4]]) %>%
      addPolylines(
        group = 'all_ship_routes',
        lng = ~LON,
        lat = ~LAT,
        color = wes_pal[5],
        dashArray = "10, 5",
        stroke = T,
        weight = 2,
        opacity = 0.75
      ) %>%

      # Add a line between then longest consecutive observations
      addPolylines(
        group = 'longest_trip',
        lng = temp$LON,
        lat = temp$LAT,
        color = wes_pal_longest[2],
        stroke = T,
        opacity = 0.75,
        weight = 4
      ) %>%

      # Add markers on the longest consecutive observations
      addAwesomeMarkers(
        group = 'longest_coordinates',
        lng = temp$LON,
        lat = temp$LAT,
        icon = makeAwesomeIcon(
          icon = "ship",
          markerColor = "darkblue",
          library = "fa",
          iconColor = "#FFFFFF"
        )
      ) %>%

      # Add label to the midpoint between the 2 longest consecutive coordinates with the trip details.
      addMarkers(
        group = 'mid_point',
        lng = mid_pt[1],
        lat = mid_pt[2],
        label = lapply(labs, htmltools::HTML),
        # label = paste0('Ship: ', temp$SHIPNAME[2], ' (', temp$ship_type[2] , ')', ' | Max Dist.: ', prettyNum(round(temp$distance[2], 1), big.mark = ','), ' meters'),
        icon = list(iconUrl = 'http://icons.iconarchive.com/icons/artua/star-wars/128/Master-Joda-icon.png',
                    iconSize = c(1, 1)),
        # icon = makeAwesomeIcon(icon = "maxcdn", markerColor = "orange", library = "fa", iconColor = "#FFFFFF"),
        labelOptions = labelOptions(
          direction = 'auto',
          noHide = T,
          textsize = "15px",
          style = list(
            "background-color" = "rgba(255, 255, 255, 0.1)",
            "font-family" = "ariel",
            "font-style" = "bold",
            "box-shadow" = "1px 1px rgba(0,0,0,0.02)",
            "font-size" = "16px",
            "border-color" = "rgba(0,0,0,0.00)",
            "border-top" = "2px solid darkblue",
            "text-align" = "left"
          )
        )
      )
  })
}
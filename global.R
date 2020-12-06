# Clear memory
rm(list = ls())

# Import Libraries
library(shinyjs)
library(magrittr)
library(highlighter)
library(formatR)
library(httr)
library(rjson)
library(purrrlyr)
library(shiny)
library(shiny.semantic)
library(semantic.dashboard)
library(ggplot2)
library(plotly)
library(DT)
library(leaflet)
library(stringr)
library(dplyr)
library(geosphere)
library(ggmap)
library(fst)
library(wesanderson)
library(waiter)

processed_data <- read.fst('data/processed_data.fst', as.data.table = T)
parked_ships <- read.fst('data/parked_ships.fst', as.data.table = T)

# # Import data from path
# master_data <- read.csv('data/ships.csv')
# 
# # Correctly format the date time feature
# master_data$DATETIME <- str_replace(master_data$DATETIME, 'T', ' ')
# master_data$DATETIME <- str_replace(master_data$DATETIME, 'Z', '')
# master_data$DATETIME <- as.POSIXct(master_data$DATETIME, tz = 'UTC')
# 
# # Group by SHIP ID and Calculate distance between consecutive observations
# # Impute NA values
# # Select the required variables
# processed_data <- master_data %>%
#   group_by(SHIP_ID) %>%
#   mutate(LAT_prev = lag(LAT),
#          LON_prev = lag(LON)) %>%
#   mutate(distance = distHaversine(matrix(c(LON_prev, LAT_prev), ncol = 2), matrix(c(LON, LAT),   ncol = 2))) %>%
#   ungroup() %>%
#   mutate_at(vars(distance), ~replace(., is.na(.), -1)) %>%
#   group_by(SHIP_ID) %>%
#   mutate(max_dist = ifelse(distance == max(distance),1, 0)) %>%
#   mutate(max_dist_count = lag(cumsum(max_dist))) %>%
#   mutate_at(vars(max_dist_count), ~replace(., is.na(.), -1)) %>%
#   ungroup() %>%
#   select(LAT, LON, SPEED, DESTINATION, LENGTH, WIDTH, DWT, SHIPNAME, SHIPTYPE, PORT, SHIP_ID, date, ship_type, port, is_parked, LAT_prev, LON_prev, distance, max_dist, max_dist_count)
# write_fst(processed_data, 'data/processed_data.fst', compress = 50, uniform_encoding = FALSE)
# 
# Generate a data frame of unique ports in the data set
# parked_ships <- processed_data %>%
#   filter(is_parked == 1) %>%
#   filter(SPEED == 0) %>%
#   group_by(SHIP_ID) %>%
#   slice(n()) %>%
#   ungroup() %>%
#   distinct(port, .keep_all = T)
# write_fst(parked_ships, 'data/parked_ships.fst', compress = 50, uniform_encoding = FALSE)

# Initialize palettes from Wes Anderson
wes_pal <- wes_palette("Darjeeling1")
wes_pal_longest <- wes_palette("Darjeeling2")

# Initialize UI drop down module
drop_down_input <-
  function(id, label = "Select", choices) {
    ns <- NS(id)
    tagList(
      dropdown_input(
        input_id = ns('dropdown'),
        choices = choices,
        type = "selection single",
        default_text = label
      )
    )
  }

# Initialize Server drop down module
drop_down_server <- function( id, choices) {
  moduleServer(
    id,
    function(input, output, session) {
      observe({
        ns <-session$ns
        update_dropdown_input(
          session = session,
          input_id = 'dropdown',
          choices = choices
        )
      })
    }
  )
}



# R Shiny App to calculate and plot the longest consecutive observations for a given Vessel
This app is built on a AIS dataset that logs the ships GPS coordinates and various journey variables like deadweight, heading, course etc. The dataset has the following variables:

- LAT - ship’s latitude
- LON - ship’s longitude
- SPEED - ship’s speed in knots
- COURSE - ship’s course as angle
- HEADING - ship’s compass direction
- DESTINATION - ship’s destination (reported by the crew)
- FLAG - ship’s flag
- LENGTH - ship’s length in meters
- SHIPNAME - ship’s name
- SHIPTYPE - ship’s type
- SHIP_ID - ship’s unique identifier
- WIDTH - ship’s width in meters
- DWT - ship’s deadweight in tones
- DATETIME - date and time of the observation
- PORT - current port reported by the vessel
- -Date - date extracted from DATETIME
- Week_nb - week number extracted from date
- Ship_type - ship’s type from SHIPTYPE
- Port - current port assigned based on the ship’s location
- Is_parked - indicator whether the ship is moving or not 

[Live App](https://anirbanshaw24.shinyapps.io/appsilon_ships/)

## Usage
- As soon as the app loads, the leaflet map object displays all the unique ports and their names present in the dataset. 
- To begin, please select a Vessel Type.
- Next the Vessel Name dropdown gets updated for the selected Vessel Type. The first vessel gets selected by default.
- If required, change the Vessel Name selection as required.
- The app then displays details like total obsevations, average speed, average distance between consecutive events and the ship length, width & average deadweight.
- The app also plots all the ship journeys on a leaflet map object. The longest consecutive observations are highlighted in deep blue and some details of that trip are displayed on the map.

### Notes
- Shiny semantic is used wherever suitable. In some places, fluidrow have been used as it easily adjusts to various devices like mobile, tablets and desktops.
- Certain preprocessing have been performed on the raw dataset and the rdata image has been saved. When the app loads, this rData image is read and objects loaded to the memory. This achives much faster load times compared to reading the raw data and preprocessing it from scratch.
- Waiter is used for loading screen.
## ------------------------------------------------------------------------
library(RSocrata)

# for geo support
library(leaflet)
library(geojsonio)

## ------------------------------------------------------------------------
earthquakesDataFrame <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.csv")
nrow(earthquakesDataFrame) # 1007 (two "pages")
class(earthquakesDataFrame$Datetime[1]) # POSIXlt

## ------------------------------------------------------------------------
earthquakesDataFrame <- read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquakes-for-2012-11-01-API-School-Demo/4334-bgaj")
nrow(earthquakesDataFrame) # 1007 (two "pages")
class(earthquakesDataFrame$Datetime[1]) # POSIXlt

## ------------------------------------------------------------------------
token <- "ew2rEMuESuzWPqMkyPfOSGJgE"
earthquakesDataFrame <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.csv", app_token = token)
nrow(earthquakesDataFrame)

## ------------------------------------------------------------------------
allSitesDataFrame <- ls.socrata("https://soda.demo.socrata.com")
nrow(allSitesDataFrame) # Number of datasets
allSitesDataFrame$title # Names of each dataset

## ------------------------------------------------------------------------

asdsadas <- geojson_read("https://data.cityofchicago.org/resource/6zsd-86xi.geojson", method = "local", parse = FALSE, what = "list")

m <- leaflet() %>%
  addGeoJSON(asdsadas) %>%
  setView(-87.6, 41.8, zoom = 10) %>% 
  addTiles()
m



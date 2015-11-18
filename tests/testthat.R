library(testthat)
library(RSocrata)
<<<<<<< Updated upstream

test_check("RSocrata")
=======
library(profvis)
library(jsonlite)

test_check("RSocrata")

df<-jsonlite::fromJSON("https://data.cityofchicago.org/resource/ydr8-5enu.json")
df1<-jsonlite::fromJSON("https://data.cityofchicago.org/resource/kn9c-c2s2.json")
df1<-jsonlite::fromJSON("https://data.cityofchicago.org/resource/4ijn-s7e5.json")
dfs1<-jsonlite::fromJSON("http://data.undp.org/resource/wxub-qc5k.json")

profvis({
  g <- read.socrata(url = "https://data.cityofchicago.org/Health-Human-Services/Food-Inspections/4ijn-s7e5")
  print(g)
})

profvis({
  b <- read.socrata(url = "https://data.cityofchicago.org/Buildings/Building-Permits/ydr8-5enu")
  print(b)
})
>>>>>>> Stashed changes

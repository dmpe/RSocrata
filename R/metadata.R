# http://data.cityofchicago.org/api/views/xzkq-xp2w/rows.json
# Source: http://stackoverflow.com/a/29782941
# @examples
# getMetadata(url = "http://data.cityofchicago.org/resource/y93d-d9e3.csv")
# getMetadata(urltest = "https://data.cityofchicago.org/resource/6zsd-86xi.json")
getMetadata <- function(url = "") {
  
  parsedUrl <- httr::parse_url(urltest)
  fourByFour <- substr(basename(parsedUrl$path), 1, 9)
  parsedUrl$path <- paste0("api/views/", fourByFour, "/rows.json")
  
  buildURL <- build_url(parsedUrl)
  
  
}
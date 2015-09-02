# An interface to data hosted online in Socrata data repositories
# This is the main file which uses other functions to download data from a Socrata repositories
#
# Author: Hugh J. Devlin, Ph. D. 2013-08-28
###############################################################################

# library("httr")       # for access to the HTTP header
# library("jsonlite")   # for parsing data types from Socrata
# library("mime")       # for guessing mime type
# library("geojsonio")  # for geospatial json

#' Content parsers
#'
#' Return a data frame for csv or json
#'
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
#' @importFrom httr content
#' @importFrom geojsonio geojson_read
#' @param response - an httr response object
#' @param geo_parse - parse, see \link{geojson_read}
#' @param geo_what - what, see \link{geojson_read}
#' @return data frame, possibly empty
#' @noRd
getContentAsDataFrame <- function(response) {
  
  mimeType <- response$header$'content-type'
  
  # skip optional parameters
  sep <- regexpr(';', mimeType)[1]
  
  if (sep != -1) {
    mimeType <- substr(mimeType, 0, sep[1] - 1)
  }
  
  switch(mimeType,
         "text/csv" = 
           httr::content(response), # automatic parsing
         "application/json" = 
           if (httr::content(response, as = "text") == "[ ]") { # empty json?
             data.frame() # empty data frame
           } else {
             data.frame(t(sapply(httr::content(response), unlist)), stringsAsFactors = FALSE)
           }
  ) 
  
}


#' Get a full Socrata data set as an R data frame
#'
#' @description Manages throttling and POSIX date-time conversions.
#'
#' @param url - A Socrata resource URL, or a Socrata "human-friendly" URL, 
#' or Socrata Open Data Application Program Interface (SODA) query 
#' requesting a comma-separated download format (.csv suffix), 
#' May include SoQL parameters, and it is now assumed to include SODA \code{limit} 
#' & \code{offset} parameters.
#' Either use a compelete URL or use parameters below to construct your URL. 
#' @param app_token - a (non-required) string; SODA API token can be used to query the data 
#' portal \url{http://dev.socrata.com/consumers/getting-started.html}
#' @param query - Based on query language called the "Socrata Query Language" ("SoQL"), see 
#' \url{http://dev.socrata.com/docs/queries.html}.
#' @param limit - defaults to the max of 50000. See \url{http://dev.socrata.com/docs/paging.html}.
#' @param offset - defaults to the max of 0. See \url{http://dev.socrata.com/docs/paging.html}.
#' @param output - defaults to csv; one of \code{"csv" or "json"}. 
#' @param domain - A Socrata domain, e.g \url{http://data.cityofchicago.org} 
#' @param fourByFour - a unique 4x4 identifier, e.g. "ydr8-5enu". See more \code{\link{isFourByFour}}

#' @section TODO: \url{https://github.com/Chicago/RSocrata/issues/14}
#' @section Issue: If you get something like \code{Error in rbind(deparse.level, ...) : 
#' numbers of columns of arguments do not match} when using "json" output, this is a known bug 
#' \url{https://github.com/Chicago/RSocrata/issues/19}! Use instead csv output for time being. 
#'
#' @return a data frame with POSIX dates if csv or json. 
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' 
#' @examples
#' df_csv <- read.socrata(url = "http://soda.demo.socrata.com/resource/4334-bgaj.csv")
#' df_manual <- read.socrata(domain = "http://data.cityofchicago.org/", fourByFour = "ydr8-5enu")
#' df_manual2 <- read.socrata(domain = "http://data.cityofchicago.org/", fourByFour = "ydr8-5enu")
#' df_manual3 <- read.socrata(domain = "http://data.cityofchicago.org/", fourByFour = "ydr8-5enu", 
#' output = "csv")
#' 
#' @importFrom httr parse_url build_url
#' @importFrom mime guess_type
#' @importFrom plyr rbind.fill
#' 
#' @export
read.socrata <- function(url = NULL, app_token = NULL, limit = 50000, domain = NULL, fourByFour = NULL, 
                         query = NULL, offset = 0, output = "csv") {
  
  if (is.null(url) == TRUE) {
    buildUrl <- paste0(domain, "resource/", fourByFour, ".", output)
    url <- httr::parse_url(buildUrl)
  }
  
  # check url syntax, allow human-readable Socrata url
  validUrl <- validateUrl(url, app_token) 
  parsedUrl <- httr::parse_url(paste0(validUrl, "&$limit=", limit))
  
  mimeType <- mime::guess_type(clearnParams2(parsedUrl$path))
  
  if (!(mimeType %in% c("text/csv","application/json", "text/plain"))) {
    stop(mimeType, " not a supported data format. Try JSON or CSV. For GeoJSON use: read.socrataGEO")
  }
  
  response <- errorHandling(validUrl)
  results <- getContentAsDataFrame(response)
  dataTypes <- getSodaTypes(response)
  
  rowCount <- as.numeric(getMetadata(clearnParams(validUrl))[1])
  
  ## More to come? Loop over pages implicitly
  while (nrow(results) < rowCount) { 
    query_url <- paste0(validUrl, ifelse(is.null(parsedUrl$query), "?", "&"), "$offset=", nrow(results), "&$limit=", limit)
    response <- errorHandling(query_url)
    page <- getContentAsDataFrame(response)
    results <- plyr::rbind.fill(results, page) # accumulate data
  }	
  
  # Convert Socrata calendar dates to POSIX format
  # Check for column names that are not NA and which dataType is a "calendar_date". If there are some, 
  # then convert them to POSIX format
  for (columnName in colnames(results)[!is.na(dataTypes[fieldName(colnames(results))]) 
                                       & dataTypes[fieldName(colnames(results))] == "calendar_date"]) {
    results[[columnName]] <- posixify(results[[columnName]])
  }
  
  return(results)
}

#' Download GeoJSON data using geojsonio package
#' 
#' @param what - What to return format is choosen. One of list or \code{\link{sp}}. Default: list.
#' @param parse - Parse geojson to data.frame like structures if possible or not. Default: FALSE (not)
#' \link{geojsonio}
#' 
#' @importFrom geojsonio geojson_read
#' @importFrom httr build_url parse_url
#' @importFrom mime guess_type
#' 
#' @return Returns a \code{\link{sp}}, which is the default option here. 
#' 
#' @examples 
#' df_geo <- read.socrataGEO(url = "https://data.cityofchicago.org/resource/6zsd-86xi.geojson")
#' 
#' @export
read.socrataGEO <- function(url = NULL, limit = 50000, offset = 0, method = "local", what = "sp", parse = FALSE, ...) {
  
  validUrl <- httr::parse_url(url)
  mimeType <- mime::guess_type(validUrl$path)
  
  if (mimeType == "application/vnd.geo+json") {
    results <- geojsonio::geojson_read(url, method = method, parse = parse, what = what, ...)
  } 
  
  return(results)
  
}

#' Get the SoDA 2 data types
#'
#' Get the Socrata Open Data Application Program Interface data types from the http response header. 
#' Used only for CSV and JSON, not GeoJSON
#' 
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @param response - headers attribute from an httr response object
#' @return a named vector mapping field names to data types
#' @importFrom jsonlite fromJSON
#' @noRd
getSodaTypes <- function(response) {
  result <- jsonlite::fromJSON(response$headers[['x-soda2-types']])
  names(result) <- jsonlite::fromJSON(response$headers[['x-soda2-fields']])
  return(result)
}


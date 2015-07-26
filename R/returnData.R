# An interface to data hosted online in Socrata data repositories
# This is the main file which uses other functions to download data from a Socrata repositories
#
# Author: Hugh J. Devlin, Ph. D. 2013-08-28
###############################################################################

# library("httr")       # for access to the HTTP header
# library("jsonlite")   # for parsing data types from Socrata
# library("mime")       # for guessing mime type
# library("geojsonio") # for geospatial json

#' Wrap httr GET in some diagnostics
#' 
#' In case of failure, report error details from Socrata.
#' 
#' @param url - Socrata Open Data Application Program Interface (SODA) query, a URL
#' @return httr a response object
#' @importFrom httr GET
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' 
#' @noRd
checkResponse <- function(url = "") {
  response <- httr::GET(url)
  
  errorHandling(response)
  
  return(response)
}

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
getContentAsDataFrame <- function(response, geo_parse = NULL, geo_what = NULL) {
  
  mimeType <- response$header$'content-type'
  
  # skip optional parameters
  sep <- regexpr(';', mimeType)[1]
  
  if(sep != -1) {
    mimeType <- substr(mimeType, 0, sep[1] - 1)
  }
  
  switch(mimeType,
         "text/csv" = 
           httr::content(response), # automatic parsing
         "application/json" = 
           if(httr::content(response, as = "text") == "[ ]") { # empty json?
             data.frame() # empty data frame
           } else {
             data.frame(t(sapply(httr::content(response), unlist)), stringsAsFactors = FALSE)
           }, 
         "application/vnd.geo+json" =  # use geojson_read directly through its response link
           geojsonio::geojson_read(response$url, method = "local", parse = geo_parse, what = geo_what)
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
#' Either use a compelete URL, e.g. \code{} or use parameters below to construct your URL. 
#' But don't combine them.
#' @param app_token - a (non-required) string; SODA API token can be used to query the data 
#' portal \url{http://dev.socrata.com/consumers/getting-started.html}
#' @param query - Based on query language called the "Socrata Query Language" ("SoQL"), see 
#' \url{http://dev.socrata.com/docs/queries.html}.
#' @param limit - defaults to the max of 50000. See \url{http://dev.socrata.com/docs/paging.html}.
#' @param offset - defaults to the max of 0. See \url{http://dev.socrata.com/docs/paging.html}.
#' @param output - defaults to csv; one of \code{c("csv", "json", "geojson")}. 
#' In the case of GeoJSON, it can be either a data frame or 
#' @param domain - A Socrata domain, e.g \url{http://data.cityofchicago.org} 
#' @param fourByFour - a unique 4x4 identifier, e.g. "ydr8-5enu". See more \code{\link{isFourByFour}}
#' @param geo_what - What to return if geojson is choosen. One of list or \code{\link{sp}}. Default: list.
#' @param geo_parse - (logical) To parse geojson to data.frame like structures if possible or not. Default: FALSE (not)
#' 
#' @section TODO: \url{https://github.com/Chicago/RSocrata/issues/14}
#' @section Issue: If you get something like \code{Error in rbind(deparse.level, ...) : 
#' numbers of columns of arguments do not match} when using "json" output, this is a known bug 
#' \url{https://github.com/Chicago/RSocrata/issues/19}! Use instead csv output for time being. 
#'
#' @return a data frame with POSIX dates if csv or json. Return a list (default) if geojson.
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' 
#' @examples
#' df_csv <- read.socrata(url = "http://soda.demo.socrata.com/resource/4334-bgaj.csv")
#' df_geo <- read.socrata(url = "https://data.cityofchicago.org/resource/6zsd-86xi.geojson")
#' df_manual <- read.socrata(domain = "http://data.cityofchicago.org/", fourByFour = "ydr8-5enu")
#' df_manual2 <- read.socrata(domain = "http://data.cityofchicago.org/", fourByFour = "ydr8-5enu")
#' df_manual3 <- read.socrata(domain = "http://data.cityofchicago.org/", fourByFour = "ydr8-5enu", output = "csv")
#' df_manual4 <- read.socrata(domain = "https://data.cityofchicago.org/", fourByFour = "6zsd-86xi", output = "geojson", geo_what = "list", geo_parse = TRUE)
#' 
#' @importFrom httr parse_url build_url
#' @importFrom mime guess_type
#' @importFrom plyr rbind.fill
#' 
#' @export
read.socrata <- function(url = NULL, app_token = NULL, domain = NULL, fourByFour = NULL, 
                         query = NULL, limit = 50000, offset = 0, 
                         output = "csv", geo_what = "sp", geo_parse = FALSE) {
  
  if(is.null(url) == TRUE) {
    buildUrl <- paste0(domain, "resource/", fourByFour, ".", output)
    url <- httr::parse_url(buildUrl)
  }
  
  # check url syntax, allow human-readable Socrata url
  validUrl <- validateUrl(url, app_token, output = output) 
  parsedUrl <- httr::parse_url(validUrl)
  
  mimeType <- mime::guess_type(parsedUrl$path)
  if(!(mimeType %in% c("text/csv","application/json", "application/vnd.geo+json"))) {
    stop(mimeType, " not a supported data format. Try JSON, CSV or GeoJSON.")
  }
  
  if(mimeType == "application/vnd.geo+json") {   # if geojson
    response <- checkResponse(validUrl)
    page <- getContentAsDataFrame(response, geo_what = geo_what, geo_parse = geo_parse)
    results <- page
    
  } else {   # if csv or json
    response <- checkResponse(validUrl)
    page <- getContentAsDataFrame(response)
    results <- page
    dataTypes <- getSodaTypes(response)
    
    rowCount <- getQueryRowCount(parsedUrl, mimeType)
    
    ## More to come? Loop over pages implicitly
    while(nrow(results) != rowCount) { 
      query_url <- paste0(validUrl, ifelse(is.null(parsedUrl$query), "?", "&"), "$offset=", nrow(results), "&$limit=", limit)
      response <- checkResponse(query_url)
      page <- getContentAsDataFrame(response)
      results <- plyr::rbind.fill(results, page) # accumulate
    }	
    
    # Convert Socrata calendar dates to POSIX format
    # Check for column names that are not NA and which dataType is a "calendar_date". If there are some, 
    # then convert them to POSIX format
    for(columnName in colnames(page)[!is.na(dataTypes[fieldName(colnames(page))]) & dataTypes[fieldName(colnames(page))] == "calendar_date"]) {
      results[[columnName]] <- posixify(results[[columnName]])
    }
    
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


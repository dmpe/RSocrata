#' Convert, if necessary, URL to valid REST API URL supported by Socrata.
#'
#' @description Will convert a human-readable URL to a valid REST API call
#' supported by Socrata. It will accept a valid API URL if provided
#' by users and will also convert a human-readable URL to a valid API
#' URL. Will accept queries with optional API token as a separate
#' argument or will also accept API token in the URL query. Will
#' resolve conflicting API token by deferring to original URL.
#'
#' @param url - a string; character vector of length one
#' @param app_token - a string; SODA API token used to query the data
#' portal \url{http://dev.socrata.com/consumers/getting-started.html}
#' 
#' @return a valid URL
#' 
#' @importFrom httr parse_url build_url
#' 
#' @author Tom Schenk Jr \email{tom.schenk@@cityofchicago.org}
#' 
#' @examples
#' \dontrun{
#' validateUrl(url = "a.fake.url.being.tested", app_token = "ew2rEMuESuzWPqMkyPfOSGJgE")
#' }
# validateUrl(url = "https://soda.demo.socrata.com/resource/4334-bgaj.json", app_token="ew2rEMuESuzWPqMkyPfOSGJgE")
# validateUrl(url = "https://soda.demo.socrata.com/resource/4334-bgaj.json?$limit=5&$offset=0", app_token="ew2rEMuESuzWPqMkyPfOSGJgE") # wrong
# validateUrl(url = "https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj.csv?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE&$limit=5&$offset=0") # too
#'
#' @export
validateUrl <- function(url = "", app_token = NULL) {
  parsedUrl <- httr::parse_url(url)
  
  if (is.null(parsedUrl$scheme) | is.null(parsedUrl$hostname) | is.null(parsedUrl$path)) {
    stop(url, " does not appear to be a valid URL.")
  }
  
  if (!is.null(app_token)) {
    # Handles the addition of API token and resolves invalid uses
    
    if ( is.null(parsedUrl$query["$$app_token"][[1]]) ) {
      token_inclusion <- "valid_use"
    } else {
      token_inclusion <- "already_included"
    }
    
    switch(token_inclusion,
           "already_included" = {
             # Token already included in url argument
             warning(url, " already contains an API token in url. Ignoring user-defined token.")
           },
           "valid_use" = {
             # app_token argument is used, not duplicative.
             parsedUrl$query[["app_token"]] <- paste0("%24%24app_token=", app_token)
           })
    
  }
  
  if (substr(parsedUrl$path, 1, 9) == "resource/") {
    return(httr::build_url(parsedUrl)) # resource url already
  }
  
  fourByFour <- basename(parsedUrl$path)
  if (!isFourByFour(fourByFour)) {
    stop(fourByFour, " is not a valid Socrata dataset unique identifier.")
  } else {
    parsedUrl$path <- paste0("resource/", fourByFour)
    httr::build_url(parsedUrl)
  }
  
}



# Validate URL with a SODA query (their special one ? $)
#
# @source Taken from \link{https://github.com/Chicago/RSocrata/blob/sprint7/R/validateUrlQuery.R}
# @author Gene Leynes \email{gleynes@@gmail.com}
# @examples
# validateURLQuery(httr::parse_url("https://soda.demo.socrata.com/resource/4334-bgaj.csv?$limit=5&$offset=0"), apptoken = "ew2rEMuESuzWPqMkyPfOSGJgE")
# 
#' @importFrom httr GET build_url content
validateURLQuery <- function(urlParsed, apptoken, keyfield = "id") {
  
  ## Insert token into query part of url
  # urlParsed[["query"]] <- insertToken(urlParsed = urlParsed, apptoken = apptoken)
  
  ## Extract the key field (aka order) from the parsedUrl, if it exists
  ## And remove $order from query
  orderArg <- grep(pattern = "\\$order", x = names(urlParsed[["query"]]), ignore.case = TRUE)
  
  if (length(orderArg) > 0) {
    if (is.null(keyfield)) {
      ## Use the order argument for keyfield
      keyfield <- urlParsed[["query"]][[orderArg]]
    } else {
      if (keyfield != urlParsed[["query"]][[orderArg]]) {
        warning(paste0(
          "The keyfield provided does not match the keyfield ",
          "implied by the URL argument / arguments\n", "KEYFIELD SUPPLIED: ", keyfield, "\n",
          "ORDER ARGUMENT IN URL: ", urlParsed[["query"]][[orderArg]], "\n", "Defaulting to ",
          keyfield
        ))
      }
    }
    ## remove $order from parsed url
    urlParsed[["query"]][[orderArg]] <- NULL
  }
  
  ## Rely on constructed limit argument, so remove any previous limit
  ## specification from query (it's interger(0) if no limit arg present)
  limitArg <- grep(pattern = "\\$limit", x = names(urlParsed[["query"]]), ignore.case = TRUE)
  
  if (length(limitArg) > 0) {
    rowLimit <- urlParsed[["query"]][[limitArg]]
    urlParsed[["query"]][[limitArg]] <- NULL
    
  } else {
    rowLimit <- NULL
  }
  
  ## If there is nothing left in the query then remove it
  if (length(urlParsed[["query"]]) == 0) {
    urlParsed[["query"]] <- NULL
  }
  
  return(list(
    query = urlParsed$query,
    keyfield = keyfield,
    rowLimit = rowLimit
  ))
}

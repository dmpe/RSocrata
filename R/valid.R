

getQuery <- function(query){
  if(is.list(query)){
    result <- query
  } else if (is.null(query)){
    result <- NULL
  } else {
    if(substr(query, 1,1) != "?") {
      query <- paste0("?", query)
    }
    result <- httr::parse_url(query)$query
  }
  return(result)
}

getResourcePath <- function(resourcePath,  defaultDataType = "csv",  validDataTypes = c("csv", "json")) {
  ## Extract 4x4
  fourByFour <- substr(basename(as.character(resourcePath)), 1, 9)
  ## Test validity of fourByFour
  if(!isFourByFour(fourByFour)){
    stop(paste(fourByFour, "is not a valid Socrata 4x4"))
  }
  ## Extract mime type
  mimeType <- gsub(".+\\.", "", resourcePath)
  ## Test validity of mimeType
  if(!mimeType %in% validDataTypes) {
    mimeType <- defaultDataType
  }
  ## Construct valid resource path
  result <- file.path("resource", paste0(fourByFour, ".", mimeType))
  return(list(resourcePath = result,
              fourByFour = fourByFour,
              mimeType = mimeType))
  
}

validateUrlQuery <- function(urlParsed,apptoken,keyfield) {
  
  ## Insert token into query part of url
  urlParsed[["query"]] <- insertToken(urlParsed = urlParsed, apptoken = apptoken)
  
  ## Extract the key field (aka order) from the parsedUrl, if it exists
  ## And remove $order from query
  orderArg <- grep(pattern = "\\$order", 
                   x = names(urlParsed[["query"]]), 
                   ignore.case = TRUE)
  if(length(orderArg) > 0){
    if(is.null(keyfield)){
      ## Use the order argument for keyfield
      keyfield <- urlParsed[["query"]][[orderArg]]
    } else {
      if(keyfield != urlParsed[["query"]][[orderArg]]) {
        warning(paste0("The keyfield provided does not match the keyfield ",
                       "implied by the URL argument / arguments\n",
                       "KEYFIELD SUPPLIED: ", keyfield, "\n",
                       "ORDER ARGUMENT IN URL: ", 
                       urlParsed[["query"]][[orderArg]], "\n",
                       "Defaulting to ", keyfield))
      }
    }
    ## remove $order from parsed url
    urlParsed[["query"]][[orderArg]] <- NULL
  }
  
  ## Rely on constructed limit argument, so remove any previous limit
  ## specification from query (it's interger(0) if no limit arg present)
  limitArg <- grep(pattern = "\\$limit",  x = names(urlParsed[["query"]]),   ignore.case = TRUE)
  if(length(limitArg) > 0){
    rowLimit <- urlParsed[["query"]][[limitArg]]
    urlParsed[["query"]][[limitArg]] <- NULL
  } else {
    rowLimit <- NULL
  }
  
  ## If there is nothing left in the query then remove it
  if(length(urlParsed[["query"]]) == 0){
    urlParsed[["query"]] <- NULL
  }
  
  return(list(query = urlParsed$query,
              keyfield = keyfield,
              rowLimit = rowLimit))
}


insertToken <- function(urlParsed, apptoken = NULL) {
  
  ## Extract just the query from the URL
  query <- urlParsed[["query"]]
  
  if(!is.null(apptoken)){
    ## If there is no query at all, create a base
    if(is.null(query)){
      query  <- list()
    }
    ## Convert to character, just in case
    apptoken <- as.character(apptoken)
    ## If the user supplied apptoken as an argument, and there was already 
    ## one in the query, and they don't match, then warn
    queryHasAppToken <- !is.null(query["$$app_token"][[1]])
    if(queryHasAppToken && query[["$$app_token"]] != apptoken){
      msg <- paste0("url = ", httr::build_url(urlParsed), "\n",
                    "The supplied url has an API token embedded in ",
                    "it, and the embedded token (",
                    query[['$$app_token']], ") does not match the ",
                    "supplied apptoken (", apptoken ,").\n",
                    "Using apptoken.")
      warning(msg)
    }
    
    ## Insert apptoken into the query (even if it already exists)
    query[["$$app_token"]] <- apptoken
  }
  return(query)
}
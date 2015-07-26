#' Return number of row as specified in the metadata of the data set
#'
#' @importFrom httr GET build_url content
#' @seealso Taken from \link{https://github.com/Chicago/RSocrata/blob/sprint7/R/getQueryRowCount.R}
#' @author Gene Leynes \email{gleynes@@gmail.com}
#' @noRd
getQueryRowCount <- function(urlParsed, mimeType){
  
  ## Construct the count query based on the URL, 
  if(is.null(urlParsed[['query']])){
    ## If there is no query at all, create a simple count
    cntQueryText <- "?$SELECT=COUNT(*)"
  } else {
    ## Otherwise, construct the query text with a COUNT command at the 
    ## beginning of any other limiting commands
    ## Reconstitute the httr url into a string
    cntQueryText <- httr::build_url(structure(list(query=urlParsed[['query']]), 
                                              class = "url"))
    ## Add the COUNT command to the beginning of the query
    cntQueryText <- gsub(pattern = ".+\\?",
                         replacement = "?$SELECT=COUNT(*)&",
                         cntQueryText)
  }
  
  ## Combine the count query with the rest of the URL
  cntUrl <- paste0(urlParsed[[c('scheme')]], "://", 
                   urlParsed[[c('hostname')]], "/", 
                   urlParsed[[c('path')]], 
                   cntQueryText)
  ## Execute the query to count the rows
  totalRowsResult <- httr::GET(cntUrl)
  
  ## Parsing the result depends on the mime type
  if(mimeType == "application/json"){
    totalRows <- as.numeric(httr::content(totalRowsResult)[[1]]$count)
  } else {
    totalRows <- as.numeric(httr::content(totalRowsResult)$count)
  }
  
  ## Limit the row count to $limit (if the $limit existed). Always return maximum
  # totalRows <- min(totalRows, as.numeric(rowLimit))
  
  return(totalRows)
}
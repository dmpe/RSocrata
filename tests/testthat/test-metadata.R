library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)

context("Checks metadata")

test_that("it returns some number of rows", {
  nr <- getMetadata(url = "http://data.cityofchicago.org/resource/y93d-d9e3.csv")
  expect_output(nr[[1]], "143")
  nr2 <- getMetadata(url = "https://data.cityofchicago.org/resource/6zsd-86xi.json")
  expect_output(nr2[[1]], "5877581")
})




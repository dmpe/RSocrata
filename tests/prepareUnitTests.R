library("RUnit")


if("tests" %in% list.files()){
  path = "tests/unitTests"
  source(file.path(getwd(), "R/RSocrata.R"))
} else {
  path = "unitTests"
    
  source("../../RSocrata/R/RSocrata.R")
}


#test.suite <- defineTestSuite("test Socrata SODA interface",
#                               dirs = file.path("tests/unitTests"),
#                                testFileRegexp = 'testRSocrata.R')
test.suite <- defineTestSuite("test Socrata SODA interface",
                               dirs = file.path(path),
                               testFileRegexp = 'testRSocrata.R')

test.result <- runTestSuite(test.suite)

print(path)

test.errors <- getErrors(test.result)

printTextProtocol(test.result)
if(test.errors$nErr > 0 | test.errors$nFail >0) stop("TEST HAD ERRORS!")

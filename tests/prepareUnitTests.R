library("RUnit")

runAllTests <- function(){
    if(length(grep("Rcheck", getwd())) > 0){
      path = file.path(getwd(), "unitTests")
      pkgPath <- file.path(getwd(), "..", "00_pkg_src", "RSocrata", "R")
    } else {
      if(length(grep("tests", getwd())) > 0){
        path = "unitTests"
        pkgPath <- file.path(getwd(), "..", "R")
      } else {
        path = "tests/unitTests"
        pkgPath <- file.path(getwd(), "R")
      }
    }
    source(file.path(pkgPath, "RSocrata.R"))
        
    test.suite <- defineTestSuite("test Socrata SODA interface",
                                  dirs = file.path(path),
                                  testFileRegexp = 'testRSocrata.R')
        
    test.result <- runTestSuite(test.suite)
    
    test.errors <- getErrors(test.result)
    
    printTextProtocol(test.result)
    if(test.errors$nErr > 0 | test.errors$nFail >0) stop("TEST HAD ERRORS!")
}

runAllTests()
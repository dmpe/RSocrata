library("RUnit")


runAllTests <- function(){
    if("tests" %in% list.files()){
      path = "tests/unitTests"
      pkgPath <- file.path(getwd(), "R")
      } else { # Set paths during R CMD check
      path = file.path(getwd(), "unitTests")
      pkgPath <- file.path(getwd(), "..", "00_pkg_src", "RSocrata", "R")
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
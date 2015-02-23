# CONTRIBUTING GUIDELINES

The main objective of the RSocrata package is to let users download and interact with data from Socrata data portals in a way that is most familiar with R programmers. This includes using POSIX dates, transforming objects into data frames, and making it easier to interact with web services without knowing particulars of the SoDA API.

Before submitting a pull request, please follow these items:

* Please review the project's release plan.
* Change the `Date` field in the `DESCRIPTION` file to the date of your build
* Change the `Version` field in the `DESCRIPTION` file to the appropriate build or version number
* If adding a new feature, please add appropriate unit tests in `R/tests/testRSocrata.R`
* Test your build before submitting a pull request by running all unit tests and `R CMD check --as-cran`. These must pass before being accepted.
* If your solving an existing [issue](https://github.com/Chicago/RSocrata/issues), please note it in the commit message, e.g., "Fixes #12".
* Submit your pull request to the `dev` branch.
* Sign the [contributor license agreement](http://en.wikipedia.org/wiki/Contributor_License_Agreement).

Additional explanation behind these steps are explained below.

## Changing DESCRIPTION file

You should modify two fields in the `DESCRIPTION` file: the `Date` and `Version`.

This project follow's [semantic versioning](www.semver.org) and we follow an X.Y.Z-B format. Please review and modify the version number appropriately. Development builds follow X.Y.Z-B, where B is the build number. For instance, 1.6.0-1 is the first developmental build for version 1.6.0. Please iterate new a build number. Depending on the severity of your build, we may queue your contribution to CRAN based on how major the new implementation is.

Likewise, please modify the `Date` to match the date of your build using the `YYYY-MM-DD` format.

## Unit testing

If you add any new features or functions, please add a corresponding unit test in `R/tests/testRSocrata.R`. This uses the `RUnit` library.

Likewise, if there there is a condition not being tested, please feel free to add additional tests. 

## Testing before submission

Submissions need to pass continuous integration tests before being placed on the master branch. Namely, all modifications must pass CRAN package build tests and must also pass unit testing. Both of these tests are automatically tested on [Travis CI](https://travis-ci.org/Chicago/RSocrata).

Run these tests locally before creating a pull request by executing these commands in your terminal or command prompt in the RSocrata directory:

> Rscript -e 'source("R/tests/testRSocrata.R"); runAllTests()'
> R CMD check --as-cran

If you have any questions, please do not hestiate to reach out on the [GitHub issues page](https://github.com/Chicago/RSocrata/issues).

## Creating a pull request

Please submit any pull request to the project's `dev` branch. 

## Contributor License Agreement

All contributors must sign a [contributor license agreement](http://en.wikipedia.org/wiki/Contributor_License_Agreement). This is designed to ensure the City of Chicago does not use any code that may be protected by proprietary intellectual property. Pull requests and contributions must have an electronically signed CLA. You can view and sign the electronic CLA [here](https://www.clahub.com/agreements/Chicago/RSocrata).

If this causes a problem, please feel free to email [developers@cityofchicago.org](developers@cityofchicago.org).
# So, you want to contribute?

This project is about making it easier for R programmers to interact with Socrata data portals. Your contributions can help keep this library useful to the thousands of R programmers who work with open data. There are a few guidelines that are needed to make sure everything runs smoothly.

## User functionality
The purpose of this project is to let R users make calls to any Socrata portal, regardless of the source URL.

- Return data from a Socrata portal in R-friendly formats and data types
- Allow users to be brief and use "human-friendly" interaction instead of strict compliance with SoDA requirements, which should be handled on the backend.
- When appropriate, dates and times should be converted to handle appropriately as corresponding data types in R (e.g., use posixify() function) and convert names to human readable names (e.g., use fieldName() function). Other such improvements to these are welcomed.
- Should not require highly structured arguments, though, optional arguments providing more structure are encouraged

## Project Organization
The latest production release of RSocrata will be available on the CRAN repository while the GitHub repository is in various stages of development. Namely:

- CRAN repository is *production* code (but may not be latest release).
- Copies of stable releases will be available on the GitHub [releases page](https://github.com/Chicago/RSocrata/releases) (will always have the latest release, even if it's not on CRAN, yet).
- The master branch of the repo should be considered *Beta*, generally stable but could contain errors
- The dev branch of the repo should be considered *Alpha* and use at your own risk (see continuous integration)
- Any other branches are experimental or pre-alpha stage.

### Branching

The core development team has a practice of opening issues on the portal and naming branches corresponding to those issues (e.g., iss4 for Issue #4). You can participate in the development on these branches if you would like. Please be active in the corresponding issue page so everyone can coordinate.

### Issue tracking

As noted above, the core development team has a practice of opening issues on the portal and naming branches after those issues. This helps us document progress liberally using GitHub issues that correspond to changes in the code. 

Each issue and pull request is assigned one of the following labels:

* enhancement - adding new features and capabilities 
* documentation - adding or revising documentation 
* bug - a bug fix, patch, or revision that does not add new features, but corrects existing features or handles exceptions or special cases in a better manner
* duplicate - an issue or pull request that has already been noted or fixed and when a new feature is suggested but already capable in the platform.
* invalid - harsher in words than reality, this is used when we cannot replicate an issue
* wontfix - a dreaded label that the issue or request won't be accepted in the future. Rarely used, there are probably a lot of issues if this is used.

### Continuous integration

This project uses Travis-CI to conduct tests using ```R CMD check``` and runs unit tests. Be wary if you are cloining a repo that has "build failing" unless you aim to fix the issue. We aim to always have the master branch pass integration tests, where as the dev branch will be more unstable.

### Format

- Tabs should be set at four spaces
- New functions should be verbs (e.g., read.socrata)
- Use functions whenever possible

### Versioning
This project follows the guidelines of [semantic versioning](www.semver.org). Please keep this in mind when submitting new features. If the modification would break existing codebase, this would be considered a full version upgrade (e.g., 1.0.0 to 2.0.0). Such changes are likely to be queued before releasing on CRAN. For instance, if ```read.socrata(url)``` would return a different result after implementing the new code (besides changes as a result of a patch or a bug fix).

Minor (1.0.0 to 1.1.0) and patch (1.0.1 to 1.0.1) changes will be submitted to CRAN on a regular basis. CRAN usually does not accept more than one release a month.

Builds are separated at the end with a "-", such as 1.0.0-8 to indicate the eigth development build. Build numbers should iterate when submitted to the dev branch. Release versions should eschew "-" before submission to CRAN.

When submitting a pull request, revise the DESCRIPTION file with a proposed version number. We will likely ask you to revise it after we finish our code review.

## Submitting a pull request

Before submitting a pull request, please check the following items:

* If applicable, create a new unit test in ```R/tests/testRSocrata.R```.
* Run the ```runAllTests()``` function in ```R/tests/testRSocrata.R``` and ensure there are not any errors.
* Run ```R CMD check --as-cran RSocrata``` and ensure it passes with no warnings or errors (see Continuous integration)
* Check that you've updated DESCRIPTION with a proposed version number (see Versioning).

If this passes, then:

* Open a pull request on GitHub
* Write a easily understandable description of the change
* Please write at least a paragraph (it's just four sentences!) or more describing the changes.

After you submit the request, the team will:

* Keep an open dialog on the pull request page
* Check if continuous integration fails (see Continuous integration), if so, we'll ask you to re-review before we look further.
* Conduct code review to check for (1) consistent user functionality (see User functionality), (2) code format (see Formatting), and (3) if it's relevant/useful. We may ask you to revise the pull request.
* Depending on the changes, we may hold your pull request until a later date (see Versioning)

Questions? Feel free to open a GitHub issue or email developers@cityofchicago.org.

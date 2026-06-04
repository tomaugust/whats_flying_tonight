library(testthat)

test_check_app <- function() {
  testthat::test_dir(
    file.path(getwd(), "tests", "testthat"),
    reporter = testthat::SummaryReporter$new()
  )
}

test_check_app()

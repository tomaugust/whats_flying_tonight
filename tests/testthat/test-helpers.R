test_that("monthsdays returns expected month lengths", {
  with_app_dir({
    source("scripts/internal/monthdays.R")
  })

  expect_equal(monthsdays("Jan"), 31)
  expect_equal(monthsdays("Feb"), 29)
  expect_equal(monthsdays("apr"), 30)
})

test_that("gatherData returns records for a known populated hectad and date", {
  with_app_dir({
    source_scripts <- list.files("scripts/internal", full.names = TRUE)
    for (script in source_scripts) {
      source(script)
    }
    result <- gatherData(hectad = "SU58", jDay = 140, radius = 1, dayBuffer = 4)
  })

  expect_s3_class(result, "data.frame")
  expect_named(result, c("species", "nrec"))
  expect_true(nrow(result) > 0)
  expect_true(all(result$nrec > 0))
})

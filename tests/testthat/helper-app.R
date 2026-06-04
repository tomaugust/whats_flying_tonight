app_dir <- normalizePath(file.path("..", ".."), winslash = "/", mustWork = TRUE)

Sys.setenv(NOT_CRAN = "true")

chrome_candidates <- c(
  file.path(Sys.getenv("LOCALAPPDATA"), "Google", "Chrome", "Application", "chrome.exe"),
  file.path(Sys.getenv("PROGRAMFILES"), "Google", "Chrome", "Application", "chrome.exe"),
  file.path(Sys.getenv("ProgramFiles(x86)"), "Google", "Chrome", "Application", "chrome.exe"),
  file.path(Sys.getenv("PROGRAMFILES"), "Microsoft", "Edge", "Application", "msedge.exe"),
  file.path(Sys.getenv("ProgramFiles(x86)"), "Microsoft", "Edge", "Application", "msedge.exe")
)

chrome_path <- chrome_candidates[file.exists(chrome_candidates)][1]
if (!is.na(chrome_path) && !nzchar(Sys.getenv("CHROMOTE_CHROME"))) {
  Sys.setenv(CHROMOTE_CHROME = chrome_path)
}

with_app_dir <- function(expr) {
  old_dir <- setwd(app_dir)
  on.exit(setwd(old_dir), add = TRUE)
  force(expr)
}

source_app <- function() {
  with_app_dir({
    source_env <- new.env(parent = globalenv())
    source("app.R", local = source_env)
    source_env$app_env
  })
}

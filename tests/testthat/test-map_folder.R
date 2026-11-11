make_folder <- function() {
  d <- file.path(tempfile("fm"), "project")
  dir.create(file.path(d, "data", "raw"), recursive = TRUE)
  dir.create(file.path(d, "node_modules", "pkg"), recursive = TRUE)
  dir.create(file.path(d, "empty"))
  writeLines("x,y\n1,2", file.path(d, "data", "raw", "a.csv"))
  writeLines("print(1)", file.path(d, "analysis.R"))
  writeLines("{}", file.path(d, "node_modules", "pkg", "index.js"))
  writeLines("hidden", file.path(d, "foo_cache"))
  d
}

# The map as a static page, returned as one string
static_map <- function(d, ...) {
  f <- suppressMessages(map_folder(
    d, server = FALSE, open = FALSE, file = tempfile(fileext = ".html"), ...
  ))
  paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
}

# scan_folder ---------------------------------------------------------------

test_that("scan_folder finds files and folders and skips the ignored", {
  s <- scan_folder(make_folder())
  expect_setequal(
    s$path,
    c("data", "data/raw", "data/raw/a.csv", "analysis.R", "empty")
  )
  expect_true(all(s$dir[s$path %in% c("data", "data/raw", "empty")]))
  expect_true(s$size[s$path == "analysis.R"] > 0)
  expect_s3_class(s$mtime, "POSIXct")
})

test_that("ignore takes wildcards and ignores case", {
  s <- scan_folder(make_folder(), ignore = c("DATA", "*.R"))
  expect_false(any(grepl("^data", s$path)))
  expect_false("analysis.R" %in% s$path)
  expect_true("node_modules" %in% s$path)
})

test_that("special characters in ignore are taken literally", {
  rx <- pathr:::.fm_glob_regex(c(".git", "a+b", "x[1]", "*_cache"))
  hit <- function(x) grepl(rx, x, ignore.case = TRUE)
  expect_true(all(hit(c(".git", "a+b", "x[1]", "foo_cache"))))
  expect_false(any(hit(c("xgit", "aab", "x1"))))
})

test_that("a folder that does not exist is an error", {
  expect_error(scan_folder("does/not/exist"), "does not exist")
  expect_error(map_folder("does/not/exist"), "does not exist")
})

test_that("gitignore = TRUE skips what git ignores", {
  skip_if(Sys.which("git") == "", "git is not installed")
  d <- make_folder()
  writeLines(c("data/raw/", "*.log"), file.path(d, ".gitignore"))
  writeLines("x", file.path(d, "run.log"))
  system2("git", c("-C", shQuote(d), "init", "-q"), stdout = FALSE,
          stderr = FALSE)
  plain <- scan_folder(d)$path
  expect_true(all(c("data/raw", "run.log") %in% plain))
  s <- scan_folder(d, gitignore = TRUE)$path
  expect_false(any(c("data/raw", "data/raw/a.csv", "run.log") %in% s))
  # data/ holds nothing but ignored files, yet is not itself ignored
  expect_true(all(c("data", "analysis.R", ".gitignore") %in% s))
})

test_that("gitignore = TRUE outside a repository warns and scans anyway", {
  skip_if(Sys.which("git") == "", "git is not installed")
  d <- make_folder()
  expect_warning(s <- scan_folder(d, gitignore = TRUE), "had no effect")
  expect_true("analysis.R" %in% s$path)
})

# suggested relations -------------------------------------------------------

test_that("paths used in scripts become suggested relations", {
  d <- make_folder()
  dir.create(file.path(d, "R"))
  dir.create(file.path(d, "output"))
  writeLines("x", file.path(d, "output", "result.csv"))
  writeLines("x", file.path(d, "output", "plot.png"))
  writeLines("f <- function() 1", file.path(d, "R", "helpers.R"))
  writeLines(c(
    'source("R/helpers.R")',
    'raw <- readr::read_csv("data/raw/a.csv")',
    "write.csv(raw, file.path('output', 'result.csv'))",
    'ggplot2::ggsave(here::here("output", "plot.png"), width = 5)',
    'both <- lapply(c("data\\\\raw\\\\a.csv"), read.csv)',
    'label <- "analysis"; missing <- read.csv("data/not-there.csv")',
    'dir <- "data/raw"'
  ), file.path(d, "analysis.R"))
  writeLines('x <- readLines("../analysis.R")', file.path(d, "R", "peek.R"))

  found <- pathr:::.fm_detect(d, scan_folder(d))
  rel <- paste(found$from, found$label, found$to)
  expect_setequal(rel, c(
    "R/helpers.R sourced by analysis.R",
    "data/raw/a.csv input to analysis.R",
    "analysis.R writes output/result.csv",
    "analysis.R writes output/plot.png",
    "data/raw used by analysis.R",
    "analysis.R input to R/peek.R"
  ))
})

test_that("the call a path belongs to is the innermost one that is not a wrapper", {
  call <- pathr:::.fm_open_call
  expect_equal(call('x <- readr::read_csv('), "readr::read_csv")
  expect_equal(call('write_csv(clean(x), '), "write_csv")
  expect_equal(call('lapply(c('), "lapply")
  expect_equal(call('p <- '), "")
})

test_that("detected relations reach the page, and detect = FALSE leaves them out", {
  skip_if_not_installed("jsonlite")
  d <- make_folder()
  writeLines('x <- read.csv("data/raw/a.csv")', file.path(d, "analysis.R"))
  expect_true(grepl('"detected":[["data/raw/a.csv","analysis.R","input to"]]',
                    static_map(d), fixed = TRUE))
  expect_true(grepl('"detected":null', static_map(d, detect = FALSE),
                    fixed = TRUE))
})

# map_folder ----------------------------------------------------------------

test_that("missing sizes do not break the summary", {
  d <- list(root = "p",
            entries = data.frame(size = c(10, NA), dir = c(FALSE, FALSE)))
  expect_no_error(suppressMessages(pathr:::.fm_summarise(d)))
  expect_message(pathr:::.fm_summarise(d), "2 files in 0 folders")
})

test_that("the page gets the data and vis-network inlined", {
  skip_if_not_installed("jsonlite")
  html <- static_map(make_folder())
  expect_false(grepl("__FOLDER_MAP_DATA__", html, fixed = TRUE))
  expect_false(grepl("cdn.jsdelivr.net", html, fixed = TRUE))
  expect_true(grepl('"root":"project"', html, fixed = TRUE))
  expect_true(grepl('"data/raw/a.csv"', html, fixed = TRUE))
})

test_that("show_files decides whether files are drawn from the start", {
  skip_if_not_installed("jsonlite")
  d <- make_folder()
  expect_true(grepl('"showFiles":true', static_map(d), fixed = TRUE))
  expect_true(grepl('"showFiles":false', static_map(d, show_files = FALSE),
                    fixed = TRUE))
})

test_that("the notes file is not part of the map", {
  skip_if_not_installed("jsonlite")
  d <- make_folder()
  writeLines("{}", file.path(d, ".foldermap.json"))
  expect_false(grepl('".foldermap.json"', static_map(d), fixed = TRUE))
})

test_that("a file name with </script> cannot break the page", {
  skip_if_not_installed("jsonlite")
  skip_on_os("windows") # '<' and '>' are not allowed in file names there
  d <- make_folder()
  file.create(file.path(d, "</script>x"))
  expect_true(grepl("<\\/script>x", static_map(d), fixed = TRUE))
})

# folder_notes --------------------------------------------------------------

test_that("folder_notes returns relative paths", {
  skip_if_not_installed("jsonlite")
  d <- make_folder()
  writeLines('{"foldermap":1,"root":"project",
    "nodes":{"project/data":{"tag":"core","note":"all input"},"project":{"note":"the root"}},
    "relations":[{"id":"a","from":"project/analysis.R","to":"project/data/raw/a.csv","label":"input to"},
                 {"id":"b","from":"project/analysis.R","to":"project/gone.csv","label":"output from"}]}',
             file.path(d, ".foldermap.json"), useBytes = TRUE)
  n <- folder_notes(d)
  expect_equal(n$nodes$path, c("data", ""))
  expect_equal(n$nodes$tag, c("core", NA))
  expect_equal(n$relations$to, c("data/raw/a.csv", "gone.csv"))
  expect_equal(n$relations$exists, c(TRUE, FALSE))
})

test_that("no notes give empty data frames", {
  skip_if_not_installed("jsonlite")
  n <- folder_notes(make_folder())
  expect_equal(nrow(n$nodes), 0)
  expect_equal(nrow(n$relations), 0)
})

test_that("notes written by mappegraf are still read", {
  skip_if_not_installed("jsonlite")
  d <- make_folder()
  writeLines('{"mappegraf":1,"root":"project",
    "nodes":{"project/data":{"tag":"kerne"},"project/empty":{"tag":"gammel"}},
    "relations":[]}', file.path(d, ".mappegraf.json"))
  n <- folder_notes(d)
  expect_equal(n$nodes$tag, c("core", "outdated"))
  expect_false(grepl('".mappegraf.json"', static_map(d), fixed = TRUE))
  expect_true(grepl('"tag":"kerne"', static_map(d), fixed = TRUE))

  # once .foldermap.json exists, it wins
  writeLines('{"nodes":{},"relations":[]}', file.path(d, ".foldermap.json"))
  expect_equal(nrow(folder_notes(d)$nodes), 0)
})

test_that("a broken notes file is an error naming the file", {
  skip_if_not_installed("jsonlite")
  d <- make_folder()
  writeLines("not json", file.path(d, ".foldermap.json"))
  expect_error(folder_notes(d), "Could not read")
})

# folder_guide --------------------------------------------------------------

test_that("folder_guide writes tags, notes and relations as Markdown", {
  skip_if_not_installed("jsonlite")
  d <- make_folder()
  writeLines('{"nodes":{"project/data":{"tag":"core","note":"all input\\nlives here"},
      "project/analysis.R":{"note":"run this first"},"project/empty":{"tag":"outdated"}},
    "relations":[{"id":"a","from":"project/data/raw/a.csv","to":"project/analysis.R","label":"input to","note":"monthly"},
                 {"id":"b","from":"project/analysis.R","to":"project/gone.csv","label":""}]}',
             file.path(d, ".foldermap.json"))
  out <- tempfile(fileext = ".md")
  md <- suppressMessages(folder_guide(d, file = out))
  expect_equal(readLines(out), md)
  expect_equal(md[[1]], "# Guide to project")
  expect_true(all(c(
    "## Core", "- `data`: all input lives here",
    "## Outdated", "- `empty`",
    "## Other notes", "- `analysis.R`: run this first",
    "## Relations", "- `data/raw/a.csv` input to `analysis.R`: monthly",
    "- `analysis.R` related to `gone.csv` (one end no longer exists)"
  ) %in% md))
  expect_false("## Important" %in% md)
  expect_output(folder_guide(d), "## Core")
})

test_that("folder_guide says so when there is nothing to write", {
  skip_if_not_installed("jsonlite")
  expect_output(folder_guide(make_folder()), "Nothing is tagged")
})

# the view ------------------------------------------------------------------

test_that("the view is saved outside the folder and read back", {
  skip_if_not_installed("jsonlite")
  d <- make_folder()
  withr::local_options(pathr.folder_map_view_dir = tempfile("view"))
  expect_null(pathr:::.fm_read_view(d))
  pathr:::.fm_save_view(d, charToRaw('{"expanded":["project"],"pos":{}}'))
  expect_equal(pathr:::.fm_read_view(d)$expanded, list("project"))
  expect_equal(as.character(pathr:::.fm_json(pathr:::.fm_read_view(d))),
               '{"expanded":["project"],"pos":{}}')
  expect_length(list.files(d, pattern = "view", recursive = TRUE,
                           all.files = TRUE), 0)
  expect_error(pathr:::.fm_save_view(d, charToRaw("not json")), "Invalid")
  expect_false(pathr:::.fm_view_file(d) == pathr:::.fm_view_file(dirname(d)))
})

# the server ----------------------------------------------------------------

test_that("the token neither moves the user's seed nor follows it", {
  token <- function() {
    pathr:::.fm_without_seed(paste(sample(letters, 24, TRUE), collapse = ""))
  }
  set.seed(1); expected <- runif(1)
  set.seed(1); a <- token(); actual <- runif(1)
  set.seed(1); b <- token()
  expect_equal(actual, expected)
  expect_false(identical(a, b))
})

test_that(".fm_open refuses paths outside the folder", {
  d <- make_folder()
  expect_error(pathr:::.fm_open(d, "../"), "outside the folder")
  expect_error(pathr:::.fm_open(d, "not-there.txt"), "Does not exist")
})

test_that(".fm_query decodes values", {
  skip_if_not_installed("httpuv")
  p <- pathr:::.fm_query("?t=abc&what=open&path=data%2Fr%C3%A5%20fil.csv")
  expect_equal(p$t, "abc")
  expect_equal(p$what, "open")
  expect_equal(p$path, "data/rå fil.csv")
})

test_that("the server saves notes and refuses a wrong token", {
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("httpuv")
  skip_if_not_installed("curl")
  d <- make_folder()
  withr::local_options(pathr.folder_map_view_dir = tempfile("view"))
  url <- suppressMessages(map_folder(d, open = FALSE))
  withr::defer(suppressMessages(stop_folder_map()))
  base <- sub("/\\?t=.*", "", url)
  token <- sub(".*\\?t=", "", url)
  fetch <- function(u, ...) {
    h <- curl::new_handle(...)
    res <- NULL
    curl::curl_fetch_multi(u, done = function(r) res <<- r,
                           fail = function(e) stop(e), handle = h)
    while (is.null(res)) {
      curl::multi_run(timeout = 0.05, poll = TRUE)
      httpuv::service(10)
    }
    res
  }
  expect_equal(fetch(paste0(base, "/?t=wrong"))$status_code, 403)
  page <- fetch(url)
  expect_equal(page$status_code, 200)
  expect_true(grepl('"saveUrl":"save?t=', rawToChar(page$content),
                    fixed = TRUE))

  body <- '{"nodes":{"project/data":{"tag":"important"}},"relations":[]}'
  r <- fetch(paste0(base, "/save?t=", token), postfields = body)
  expect_equal(r$status_code, 200)
  expect_equal(folder_notes(d)$nodes$tag, "important")
  bad <- suppressMessages(
    fetch(paste0(base, "/save?t=", token), postfields = "not json")
  )
  expect_equal(bad$status_code, 500)

  # the view is saved through its own route and comes with the next page
  v <- fetch(paste0(base, "/view?t=", token),
             postfields = '{"expanded":["project/data"]}')
  expect_equal(v$status_code, 200)
  expect_true(grepl('"view":{"expanded":["project/data"]}',
                    rawToChar(fetch(url)$content), fixed = TRUE))
  notes <- jsonlite::fromJSON(file.path(d, ".foldermap.json"))
  expect_false("expanded" %in% names(notes))

  # a new call for the same folder replaces the old server
  url2 <- suppressMessages(map_folder(d, open = FALSE))
  expect_length(pathr:::.fm$servers, 1)
  expect_false(identical(url, url2))
})

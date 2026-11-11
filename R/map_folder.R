# An interactive network graph of a folder: scan it in R, show it in the
# browser, and keep the tags, notes and relations the user adds in a JSON
# file inside the folder. The page (inst/www/folder-map.html) does the
# drawing; R scans, serves and saves. Internals carry the prefix .fm_.

.fm <- new.env(parent = emptyenv())
.fm$servers <- list()

`%||%` <- function(a, b) if (is.null(a)) b else a

# jsonlite and httpuv are Suggests, so that pathr stays light for those who
# only want the addins. Both come along with shiny.
.fm_need <- function(pkg, why) {
  if (requireNamespace(pkg, quietly = TRUE)) return(invisible(TRUE))
  cli::cli_abort(c(
    "{why} needs the {.pkg {pkg}} package.",
    i = "Install it with {.code install.packages(\"{pkg}\")}."
  ))
}

# ---- scanning --------------------------------------------------------------

#' Names skipped when a folder is scanned
#'
#' Folders and files that rarely say anything about how a project is put
#' together, but can hold tens of thousands of files (`node_modules`, `.git`,
#' the renv library). They are skipped *during* the scan, so they cost no
#' time.
#'
#' @return A character vector. `*` is a wildcard, and matching ignores case.
#' @seealso [map_folder()], [scan_folder()]
#' @export
#' @examples
#' folder_ignore()
#' c(folder_ignore(), "output", "*.tmp")
folder_ignore <- function() {
  c("node_modules", ".git", ".svn", "__pycache__", ".Rproj.user", ".venv",
    "venv", ".ipynb_checkpoints", ".DS_Store", "Thumbs.db", "desktop.ini",
    ".quarto", "*_cache", "renv", ".foldermap.json", ".mappegraf.json")
}

#' Scan a folder
#'
#' Walks the folder recursively and returns one row per file and folder.
#' This is the data [map_folder()] draws its graph from.
#'
#' @param path The folder to scan.
#' @param ignore Names to skip, see [folder_ignore()].
#' @param max_depth How deep to go at most. Guards against loops through
#'   junctions on Windows.
#'
#' @return A data frame with the columns `path` (relative, with `/`), `size`
#'   (bytes, 0 for folders), `mtime` (POSIXct) and `dir` (logical).
#' @export
#' @examples
#' scan_folder(R.home("doc"))
scan_folder <- function(path = ".", ignore = folder_ignore(), max_depth = 60) {
  if (!dir.exists(path)) {
    cli::cli_abort("The folder {.path {path}} does not exist.")
  }
  rx <- .fm_glob_regex(ignore)
  paths <- list(); sizes <- list(); times <- list(); is_dir <- list()
  i <- 0L
  stack <- ""
  depth <- 0L
  while (length(stack)) {
    rel <- stack[[length(stack)]]
    d <- depth[[length(depth)]]
    stack <- stack[-length(stack)]
    depth <- depth[-length(depth)]
    full <- if (nzchar(rel)) file.path(path, rel) else path
    names <- list.files(full, all.files = TRUE, no.. = TRUE)
    names <- names[!grepl(rx, names, ignore.case = TRUE)]
    if (!length(names)) next
    rels <- if (nzchar(rel)) paste(rel, names, sep = "/") else names
    info <- file.info(file.path(path, rels), extra_cols = FALSE)
    dir <- info$isdir %in% TRUE
    i <- i + 1L
    paths[[i]] <- rels
    sizes[[i]] <- ifelse(dir, 0, info$size)
    times[[i]] <- as.numeric(info$mtime)
    is_dir[[i]] <- dir
    if (d < max_depth) {
      stack <- c(stack, rels[dir])
      depth <- c(depth, rep(d + 1L, sum(dir)))
    }
  }
  data.frame(
    path = as.character(unlist(paths)),
    size = as.numeric(unlist(sizes)),
    mtime = as.POSIXct(as.numeric(unlist(times)), origin = "1970-01-01"),
    dir = as.logical(unlist(is_dir)),
    stringsAsFactors = FALSE
  )
}

# Turn glob patterns ("*_cache") into one regular expression.
.fm_glob_regex <- function(ignore) {
  ignore <- ignore[nzchar(ignore)]
  if (!length(ignore)) return("^$")
  # perl = TRUE: without it TRE does not read "\\]" as an escape inside
  # [...], and then no special character is escaped (".git" would match
  # "xgit").
  rx <- gsub("([.+?^${}()|\\[\\]\\\\])", "\\\\\\1", ignore, perl = TRUE)
  rx <- gsub("*", ".*", rx, fixed = TRUE)
  paste0("^(", paste(rx, collapse = "|"), ")$")
}

# ---- the map ---------------------------------------------------------------

#' Show a folder as an interactive map
#'
#' Scans `path` and opens it as a network graph in the browser. A big project
#' folder with many levels is hard to take in through the file explorer: you
#' see one level at a time and have nowhere to write down what matters. The
#' map shows the whole structure at once, sized by bytes or number of files,
#' and lets you add what you know: tags (Core, Important, Unclear, Outdated),
#' notes, and your own relations between folders and files, such as "input
#' to" or "depends on".
#'
#' Double-click a folder to unfold it. Select a node to see its size, file
#' types, and largest and most recently changed files, and to give it a tag,
#' a note or a relation to another node.
#'
#' @section Where the notes are kept:
#' In `.foldermap.json` inside the scanned folder. That is deliberate, rather
#' than the browser's own storage: the file follows the project, can be
#' shared with colleagues and put under version control. It only changes when
#' you change a tag, a note or a relation. What is unfolded, the layout and
#' where the nodes sit is personal and changes with every click, so that is
#' remembered per folder in your own cache
#' (`tools::R_user_dir("pathr", "cache")`) instead.
#'
#' Writing the file takes a small local server, which needs \pkg{httpuv}. It
#' listens on `127.0.0.1`, reachable only from your own machine, and every
#' request must carry a random token, so other web pages in your browser
#' cannot read the folder or overwrite the notes. The server also lets the
#' ↻ button rescan the folder and the "Open" and "Show in explorer" buttons
#' reach the file on disk. It runs until the R session ends or
#' [stop_folder_map()] is called.
#'
#' Without \pkg{httpuv} (`server = FALSE`) a single self-contained HTML file
#' is written. Existing notes are shown, but new ones are kept in the browser
#' only; use "Export" and save the file as `.foldermap.json` in the folder.
#'
#' @section Does anything go online?:
#' No. The scan happens in R, the page is served from your own machine, and
#' the graph's JavaScript library (vis-network) ships with the package.
#' Nothing is fetched from outside and nothing is sent anywhere.
#'
#' @param path The folder to show.
#' @param ignore Names to skip, see [folder_ignore()].
#' @param notes The file holding tags, notes and relations. Defaults to
#'   `.foldermap.json` inside the folder, so it follows the project.
#' @param show_files Show the files from the start, not just the folders?
#'   Can be switched in the map too. At most 40 files per folder are drawn at
#'   a time; the rest are gathered in one node you can click.
#' @param server Start a local server that saves the notes to `notes`?
#'   Needs \pkg{httpuv}.
#' @param open Open the map in the browser?
#' @param file Without a server only: where the HTML file is written.
#'   Defaults to a temporary file.
#'
#' @return Invisibly, the address (with a server) or the path to the HTML
#'   file.
#' @seealso [folder_notes()] reads the notes back into R; [scan_folder()]
#'   gives the file listing the map is built from.
#' @export
#' @examples
#' \dontrun{
#' map_folder("C:/projects/big-project")
#'
#' # without a server, as a file you can pass on
#' map_folder(".", server = FALSE, file = "folder-map.html")
#' }
map_folder <- function(path = ".",
                       ignore = folder_ignore(),
                       notes = file.path(path, ".foldermap.json"),
                       show_files = TRUE,
                       server = requireNamespace("httpuv", quietly = TRUE),
                       open = interactive(),
                       file = NULL) {
  if (!dir.exists(path)) {
    cli::cli_abort("The folder {.path {path}} does not exist.")
  }
  .fm_need("jsonlite", "{.fn map_folder}")
  path <- normalizePath(path, winslash = "/")
  # Full path, so that a later setwd() does not move where the server saves
  notes <- file.path(
    normalizePath(dirname(notes), winslash = "/", mustWork = FALSE),
    basename(notes)
  )
  ignore <- unique(c(ignore, basename(notes)))

  if (isTRUE(server)) {
    .fm_need("httpuv", "{.code server = TRUE}")
    url <- .fm_start_server(path, ignore, notes, show_files)
    if (open) utils::browseURL(url)
    return(invisible(url))
  }

  d <- .fm_data(path, ignore, notes, show_files)
  file <- file %||% tempfile("folder-map-", fileext = ".html")
  writeLines(enc2utf8(.fm_html(d)), file, useBytes = TRUE)
  .fm_summarise(d)
  cli::cli_alert_info("The map is written to {.path {file}}.")
  if (open) utils::browseURL(file)
  invisible(file)
}

.fm_summarise <- function(d) {
  e <- d$entries
  n_files <- sum(!e$dir)
  n_dirs <- sum(e$dir)
  # na.rm: a file can lack a size (broken shortcut, deleted during the scan)
  size <- .bf_size(sum(e$size, na.rm = TRUE))
  cli::cli_alert_success(paste0(
    "{.strong {d$root}}: {n_files} file{?s} in ",
    "{cli::qty(n_dirs)}{n_dirs} folder{?s}, {size}."
  ))
}

# The data object the page reads (EMBED in folder-map.html).
.fm_data <- function(path, ignore, notes, show_files = TRUE,
                     save_url = NULL, data_url = NULL, open_url = NULL,
                     view_url = NULL) {
  scan <- scan_folder(path, ignore)
  list(
    root = basename(normalizePath(path, winslash = "/")),
    basePath = normalizePath(path, winslash = "\\"),
    entries = data.frame(
      path = scan$path,
      size = scan$size,
      mtime = round(as.numeric(scan$mtime) * 1000),
      dir = scan$dir,
      stringsAsFactors = FALSE
    ),
    ann = .fm_read_notes(notes),
    showFiles = isTRUE(show_files),
    view = if (!is.null(view_url)) .fm_read_view(path),
    saveUrl = save_url,
    dataUrl = data_url,
    openUrl = open_url,
    viewUrl = view_url
  )
}

.fm_json <- function(d) {
  jsonlite::toJSON(d, dataframe = "values", auto_unbox = TRUE, digits = NA,
                   null = "null", na = "null")
}

# The template with vis-network inlined, so the map works offline. The
# library is about 700 KB, so the result is kept for the session and only
# read again if the files have changed.
.fm_template <- function() {
  template <- system.file("www", "folder-map.html", package = "pathr",
                          mustWork = TRUE)
  lib <- system.file("www", "vis-network.min.js", package = "pathr")
  key <- paste(template, lib,
               paste(file.mtime(c(template, lib)), collapse = "|"))
  if (identical(.fm$template_key, key)) return(.fm$template)

  html <- paste(readLines(template, encoding = "UTF-8", warn = FALSE),
                collapse = "\n")
  if (nzchar(lib)) {
    js <- paste(readLines(lib, encoding = "UTF-8", warn = FALSE),
                collapse = "\n")
    html <- .fm_replace_once(
      html,
      '<script src="https://cdn.jsdelivr.net/npm/vis-network@9.1.9/standalone/umd/vis-network.min.js"></script>',
      paste0("<script>", js, "</script>")
    )
  }
  .fm$template <- html
  .fm$template_key <- key
  html
}

# Put the data into the template and return the whole page as text.
.fm_html <- function(d) {
  # "</" is escaped, so a file name can never close the <script> block
  json <- gsub("</", "<\\/", .fm_json(d), fixed = TRUE)
  .fm_replace_once(.fm_template(), "/*__FOLDER_MAP_DATA__*/null", json)
}

# Replace the first occurrence of `from` literally (sub() interprets \\ in
# the replacement).
.fm_replace_once <- function(x, from, to) {
  pos <- regexpr(from, x, fixed = TRUE)
  if (pos < 0) {
    cli::cli_abort("Internal error: the template lacks {.code {from}}.")
  }
  paste0(substr(x, 1, pos - 1), to,
         substr(x, pos + attr(pos, "match.length"), nchar(x)))
}

# ---- notes -----------------------------------------------------------------

#' Read tags, notes and relations back into R
#'
#' What you write in [map_folder()] is saved in `.foldermap.json`. This
#' function turns it into two data frames, for instance to list a project's
#' core files or to check that the relations still point at something that
#' exists.
#'
#' Paths are relative to the folder and use `/`. The root folder itself is
#' `""`.
#'
#' @inheritParams map_folder
#'
#' @return A list with
#'   * `nodes`: `path`, `tag` (`core`, `important`, `unclear`, `outdated` or
#'     `NA`) and `note`.
#'   * `relations`: `from`, `to`, `label`, `note` and `exists` (whether both
#'     ends are still there in the folder).
#' @export
#' @examples
#' \dontrun{
#' n <- folder_notes("C:/projects/big-project")
#' subset(n$nodes, tag == "core")
#' subset(n$relations, !exists)
#' }
folder_notes <- function(path = ".",
                         notes = file.path(path, ".foldermap.json")) {
  .fm_need("jsonlite", "{.fn folder_notes}")
  raw <- .fm_read_notes(notes)
  drop_root <- function(x) sub("^[^/]*/?", "", x)
  field <- function(l, name) {
    vapply(l, function(x) as.character(x[[name]] %||% NA_character_), "")
  }

  nodes <- raw$nodes %||% list()
  nodes <- data.frame(
    path = drop_root(names(nodes)),
    tag = .fm_tag(field(nodes, "tag")),
    note = field(nodes, "note"),
    stringsAsFactors = FALSE, row.names = NULL
  )

  rel <- raw$relations %||% list()
  from <- drop_root(field(rel, "from"))
  to <- drop_root(field(rel, "to"))
  there <- function(p) file.exists(file.path(path, p))
  relations <- data.frame(
    from = from, to = to,
    label = field(rel, "label"),
    note = field(rel, "note"),
    exists = if (length(rel)) there(from) & there(to) else logical(),
    stringsAsFactors = FALSE, row.names = NULL
  )
  list(nodes = nodes, relations = relations)
}

# Notes written before the map moved into pathr (the mappegraf package) use
# Danish tag names. The page translates them the same way.
.fm_tag <- function(tag) {
  old <- c(kerne = "core", vigtig = "important", uklar = "unclear",
           gammel = "outdated")
  hit <- tag %in% names(old)
  tag[hit] <- unname(old[tag[hit]])
  tag
}

# The raw notes as a list. A folder mapped with mappegraf has its notes in
# .mappegraf.json; they are read from there until the first save writes
# .foldermap.json.
.fm_read_notes <- function(notes) {
  if (!file.exists(notes)) {
    old <- file.path(dirname(notes), ".mappegraf.json")
    if (basename(notes) == ".foldermap.json" && file.exists(old)) {
      notes <- old
    } else {
      return(list(nodes = structure(list(), names = character()),
                  relations = list()))
    }
  }
  tryCatch(
    jsonlite::fromJSON(notes, simplifyVector = FALSE),
    error = function(e) {
      cli::cli_abort(c("Could not read {.path {notes}}.",
                       x = conditionMessage(e)))
    }
  )
}

# ---- the view --------------------------------------------------------------

# The view (what is unfolded, the layout and where the nodes sit) is
# personal and changes with every click. So it is not kept in
# .foldermap.json, which is shared and version-controlled, but in the user's
# cache directory. The browser's localStorage cannot be used with a server,
# because the port (and so the browser's "origin") is new in every R session.
.fm_view_file <- function(path) {
  # The same folder must give the same file however the path is written
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  dir <- getOption(
    "pathr.folder_map_view_dir",
    file.path(tools::R_user_dir("pathr", "cache"), "folder-map")
  )
  name <- gsub("[^A-Za-z0-9]+", "-", basename(path))
  file.path(dir, paste0(name, "-", .fm_hash(path), ".json"))
}

# A small text hash, so two folders with the same name get a file each.
.fm_hash <- function(x) {
  h <- 7
  for (k in utf8ToInt(enc2utf8(x))) h <- (h * 31 + k) %% 2147483647
  sprintf("%08x", as.integer(h))
}

# The view as a list, or NULL if there is none. A broken file is not an
# error: the map just starts over.
.fm_read_view <- function(path) {
  f <- .fm_view_file(path)
  if (!file.exists(f)) return(NULL)
  tryCatch(jsonlite::fromJSON(f, simplifyVector = FALSE),
           error = function(e) NULL)
}

.fm_save_view <- function(path, raw) {
  if (length(raw) > 5e6) stop("The view is too large")
  if (!jsonlite::validate(rawToChar(raw))) stop("Invalid JSON")
  f <- .fm_view_file(path)
  dir.create(dirname(f), recursive = TRUE, showWarnings = FALSE)
  writeBin(raw, f)
  invisible(f)
}

# ---- the server ------------------------------------------------------------

# Run `expr` without touching the user's random number generator. The token
# must neither move the seed of an analysis in progress nor be predictable
# from a set.seed() the user has called.
.fm_without_seed <- function(expr) {
  gl <- globalenv()
  old <- get0(".Random.seed", envir = gl, inherits = FALSE)
  on.exit(
    if (is.null(old)) suppressWarnings(rm(".Random.seed", envir = gl))
    else assign(".Random.seed", old, envir = gl)
  )
  set.seed(NULL)
  expr
}

# Stop an older server for the same folder, so two tabs do not overwrite
# each other's notes and the servers do not pile up.
.fm_stop_for <- function(path) {
  for (u in names(.fm$servers)) {
    if (identical(.fm$servers[[u]]$path, path)) {
      try(httpuv::stopServer(.fm$servers[[u]]$server), silent = TRUE)
      .fm$servers[[u]] <- NULL
    }
  }
}

# Start a server for one folder. The routes:
#   GET  /       the page with the data embedded
#   GET  /data   a new scan (the ↻ button)
#   POST /save   writes the notes to `notes`
#   POST /view   saves the view (unfolded, layout, positions)
#   POST /open   opens a file or folder (what=open) or shows it in the
#                file explorer (what=explorer)
# Every route requires a random token, so other web pages in the browser
# cannot read the folder, overwrite the notes or open files.
.fm_start_server <- function(path, ignore, notes, show_files = TRUE) {
  .fm_stop_for(path)
  token <- .fm_without_seed(
    paste(sample(c(letters, 0:9), 32, TRUE), collapse = "")
  )
  q <- paste0("?t=", token)

  page_data <- function() {
    .fm_data(path, ignore, notes, show_files,
             save_url = paste0("save", q), data_url = paste0("data", q),
             open_url = paste0("open", q), view_url = paste0("view", q))
  }
  # The scan behind the summary is reused for the first page view, so the
  # folder is not scanned twice at start
  first <- page_data()
  scanned <- Sys.time()

  reply <- function(body, type = "application/json; charset=utf-8",
                    status = 200L) {
    list(status = status,
         headers = list(`Content-Type` = type, `Cache-Control` = "no-store"),
         body = charToRaw(enc2utf8(body)))
  }
  text <- "text/plain; charset=utf-8"

  app <- list(call = function(req) {
    if (!identical(sub(".*[?&]t=([^&]*).*", "\\1", req$QUERY_STRING), token)) {
      return(reply("Wrong or missing token", text, 403L))
    }
    route <- req$PATH_INFO
    method <- req$REQUEST_METHOD
    tryCatch({
      if (method == "GET" && route == "/") {
        fresh <- !is.null(first) &&
          difftime(Sys.time(), scanned, units = "secs") < 30
        d <- if (fresh) first else page_data()
        first <<- NULL
        reply(.fm_html(d), "text/html; charset=utf-8")
      } else if (method == "GET" && route == "/data") {
        reply(.fm_json(.fm_data(path, ignore, notes)))
      } else if (method == "POST" && route == "/open") {
        p <- .fm_query(req$QUERY_STRING)
        .fm_open(path, p$path %||% "", p$what %||% "open")
        reply('{"ok":true}')
      } else if (method == "POST" && route == "/save") {
        raw <- req$rook.input$read()
        if (!jsonlite::validate(rawToChar(raw))) stop("Invalid JSON")
        writeBin(raw, notes)
        reply('{"ok":true}')
      } else if (method == "POST" && route == "/view") {
        .fm_save_view(path, req$rook.input$read())
        reply('{"ok":true}')
      } else {
        reply("Not found", text, 404L)
      }
    }, error = function(e) {
      cli::cli_alert_warning("map_folder: {conditionMessage(e)}")
      reply(conditionMessage(e), text, 500L)
    })
  })

  port <- .fm_without_seed(httpuv::randomPort())
  s <- httpuv::startServer("127.0.0.1", port, app)
  url <- sprintf("http://127.0.0.1:%d/%s", port, q)
  .fm$servers[[url]] <- list(server = s, path = path)

  .fm_summarise(first)
  cli::cli_alert_info(
    "The map runs at {.url {url}}. Notes are saved in {.path {notes}}."
  )
  cli::cli_alert_info("Stop it with {.run pathr::stop_folder_map()}.")
  url
}

.fm_query <- function(qs) {
  par <- strsplit(strsplit(sub("^\\?", "", qs), "&", fixed = TRUE)[[1]],
                  "=", fixed = TRUE)
  value <- vapply(par, function(x) {
    httpuv::decodeURIComponent(if (length(x) > 1) x[[2]] else "")
  }, "")
  structure(as.list(value), names = vapply(par, `[[`, "", 1))
}

# Open a path relative to the root. The path must lie inside the root, so a
# tampered request ("../../") cannot open anything else on the disk.
.fm_open <- function(root, rel, what = c("open", "explorer")) {
  what <- match.arg(what)
  root <- normalizePath(root, winslash = "/")
  full <- normalizePath(file.path(root, rel), winslash = "/", mustWork = FALSE)
  if (!file.exists(full)) stop("Does not exist: ", rel)
  if (full != root && !startsWith(full, paste0(root, "/"))) {
    stop("The path is outside the folder: ", rel)
  }
  if (what == "open") .bf_open_file(full) else .open_in_explorer(full)
  invisible(full)
}

#' Stop the folder map's local servers
#'
#' Stops the servers [map_folder()] has started in this R session. Other
#' \pkg{httpuv} servers, such as Shiny apps, are left alone.
#'
#' @return Invisibly, the number of servers stopped.
#' @export
#' @examples
#' stop_folder_map()
stop_folder_map <- function() {
  n <- length(.fm$servers)
  for (s in .fm$servers) try(httpuv::stopServer(s$server), silent = TRUE)
  .fm$servers <- list()
  if (n) cli::cli_alert_success("Stopped {n} server{?s}.")
  invisible(n)
}

# Show a folder as an interactive map

Scans `path` and opens it as a network graph in the browser. A big
project folder with many levels is hard to take in through the file
explorer: you see one level at a time and have nowhere to write down
what matters. The map shows the whole structure at once, sized by bytes
or number of files, and lets you add what you know: tags (Core,
Important, Unclear, Outdated), notes, and your own relations between
folders and files, such as "input to" or "depends on".

## Usage

``` r
map_folder(
  path = ".",
  ignore = folder_ignore(),
  notes = file.path(path, ".foldermap.json"),
  show_files = TRUE,
  server = requireNamespace("httpuv", quietly = TRUE),
  open = interactive(),
  file = NULL,
  gitignore = FALSE,
  detect = TRUE
)
```

## Arguments

- path:

  The folder to show.

- ignore:

  Names to skip, see
  [`folder_ignore()`](https://dataniel.github.io/pathr/reference/folder_ignore.md).

- notes:

  The file holding tags, notes and relations. Defaults to
  `.foldermap.json` inside the folder, so it follows the project.

- show_files:

  Show the files from the start, not just the folders? Can be switched
  in the map too. At most 40 files per folder are drawn at a time; the
  rest are gathered in one node you can click.

- server:

  Start a local server that saves the notes to `notes`? Needs httpuv.

- open:

  Open the map in the browser?

- file:

  Without a server only: where the HTML file is written. Defaults to a
  temporary file.

- gitignore:

  Also skip what git ignores? See
  [`scan_folder()`](https://dataniel.github.io/pathr/reference/scan_folder.md).

- detect:

  Read the scripts in the folder and suggest relations from the paths
  they use? See the section on suggestions.

## Value

Invisibly, the address (with a server) or the path to the HTML file.

## Details

Double-click a folder to unfold it. Select a node to see its size, file
types, and largest and most recently changed files, and to give it a
tag, a note or a relation to another node.

## Relations the map suggests

Drawing every relation by hand is the slow part, so the map proposes
some. With `detect = TRUE` the R, R Markdown and Quarto scripts in the
folder are read for quoted paths that point at something else in the
folder, and the call around the path decides the label: a file handed to
`read_csv()` or [`readRDS()`](https://rdrr.io/r/base/readRDS.html) is
"input to" the script, one handed to `write_csv()` or `ggsave()` is one
the script "writes", and a
[`source()`](https://rdrr.io/r/base/source.html)d file is "sourced by"
it. Files with the same name and size are proposed as "copy of" each
other.

These are suggestions only. They are drawn dotted, listed in the panel,
and become relations when you add them; a dismissed suggestion is
remembered in the notes file and not proposed again. The scripts are
read as text, never run, so a path built at run time
(`paste0(dir, name)`) is not found.
[`file.path()`](https://rdrr.io/r/base/file.path.html) and `here()`
calls made of plain strings are.

## Where the notes are kept

In `.foldermap.json` inside the scanned folder. That is deliberate,
rather than the browser's own storage: the file follows the project, can
be shared with colleagues and put under version control. It only changes
when you change a tag, a note or a relation. What is unfolded, the
layout and where the nodes sit is personal and changes with every click,
so that is remembered per folder in your own cache
(`tools::R_user_dir("pathr", "cache")`) instead.

Writing the file takes a small local server, which needs httpuv. It
listens on `127.0.0.1`, reachable only from your own machine, and every
request must carry a random token, so other web pages in your browser
cannot read the folder or overwrite the notes. The server also lets the
↻ button rescan the folder and the "Open" and "Show in explorer" buttons
reach the file on disk. It runs until the R session ends or
[`stop_folder_map()`](https://dataniel.github.io/pathr/reference/stop_folder_map.md)
is called.

Without httpuv (`server = FALSE`) a single self-contained HTML file is
written. Existing notes are shown, but new ones are kept in the browser
only; use "Export" and save the file as `.foldermap.json` in the folder.

## Does anything go online?

No. The scan happens in R, the page is served from your own machine, and
the graph's JavaScript library (vis-network) ships with the package.
Nothing is fetched from outside and nothing is sent anywhere.

## See also

[`folder_notes()`](https://dataniel.github.io/pathr/reference/folder_notes.md)
reads the notes back into R and
[`folder_guide()`](https://dataniel.github.io/pathr/reference/folder_guide.md)
writes them up;
[`scan_folder()`](https://dataniel.github.io/pathr/reference/scan_folder.md)
gives the file listing the map is built from.

## Examples

``` r
if (FALSE) { # \dontrun{
map_folder("C:/projects/big-project")

# without a server, as a file you can pass on
map_folder(".", server = FALSE, file = "folder-map.html")
} # }
```

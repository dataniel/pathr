# Less fiddling with file paths

Working with files in R means dealing with paths, and on Windows that is
a small but constant annoyance. Nothing here is hard – it is just
friction: backslashes that R will not accept, a file explorer you keep
switching to and from, and the same little chores repeated every time
you point at a new file.

This is not a style guide. It is just a few small attempts to make
working with Windows paths a bit less tedious, collected as functions in
**pathr**. Take whatever you find useful and ignore the rest.

## The annoyances

Three small things cause most of it:

1.  **Pasted Windows paths have backslashes**, which R reads as escape
    characters, so every path needs `\` turned into `/` before it is a
    valid string.
2.  **Finding a file means leaving R** for the file explorer, copying
    the path, and pasting it back.
3.  **It repeats.** A handful of files in one script means doing all of
    the above a handful of times.

The functions below each take one of these off your plate.

## Grab a path without typing it: `browse_files()`

[`browse_files()`](https://dataniel.github.io/pathr/reference/browse_files.md)
is a small file explorer that lives inside R. It opens a three-column,
keyboard-driven browser – parent folder, current folder, and a preview –
that you move through with `h`/`j`/`k`/`l` or the arrow keys.

``` r
p <- browse_files()    # navigate, mark with Space, press Q
```

Mark one or more files or folders with `Space`, then `Q` hands the paths
back to R – a single string for one, a `c("a", "b")` vector for several
– already with forward slashes, so there is nothing to fix. `y` copies
the same expression to the clipboard, and `o` opens the item under the
cursor in the system explorer. No second window, no clipboard
round-trip.

Pass `root` to cap how far up you can climb – the browser never goes
above that directory, so you can scope it to a project folder:

``` r
browse_files("data", root = "data")   # cannot navigate above data/
```

`p` toggles the content preview – the text peek and Excel cell peek –
while the preview column itself stays put.

Press `r` to toggle *reader mode*: instead of the bare path, `Enter` and
`y` insert a call that reads the target with the native reader for its
type – `arrow::read_parquet()` for `.parquet`,
[`readxl::read_xlsx()`](https://readxl.tidyverse.org/reference/read_excel.html)
for `.xlsx`, `readr::read_csv2()` for `.csv`, and so on. A single file
is read inline –

``` r
arrow::read_parquet("data/x.parquet")
```

while several files of the same type are bound to a `my_paths` object
and the reader is mapped over them, so the vector is named and left
around to reuse:

``` r
my_paths <- c(
  "data/a.parquet",
  "data/b.parquet"
)

lapply(my_paths, arrow::read_parquet)
```

Pass `map = "purrr"` to
[`browse_files()`](https://dataniel.github.io/pathr/reference/browse_files.md)
to get [`purrr::map()`](https://purrr.tidyverse.org/reference/map.html)
instead of [`lapply()`](https://rdrr.io/r/base/lapply.html), or toggle
it live in the app with `m`. A mix of types can’t share one reader, so
each file gets its own named read instead. The inserted code is
self-contained – it carries the reader it needs and runs without `pathr`
attached.

Press `b` (or set `base_dir = TRUE`) to factor a shared directory out
into a `base_dir` variable, so a long common path lives in one place:

``` r
base_dir <- "C:/Users/you/demo"

my_paths <- c(
  paste0(base_dir, "/a.parquet"),
  paste0(base_dir, "/b.parquet")
)

lapply(my_paths, arrow::read_parquet)
```

## See the whole folder at once: `map_folder()`

A file browser shows one level at a time. A big project folder with many
levels is hard to take in that way, and there is nowhere to write down
what you learn about it.
[`map_folder()`](https://dataniel.github.io/pathr/reference/map_folder.md)
draws the whole structure as a graph in the browser:

``` r
map_folder("C:/projects/big-project")
```

| To | Do |
|----|----|
| Unfold or collapse a folder | double-click |
| See size, file types, largest and newest files | click |
| Tag as ★ Core, ◆ Important, ? Unclear or ⌛ Outdated | the buttons in the panel, or the keys `1`–`4` |
| Write a note | the field in the panel |
| Draw a relation, such as “input to” | `R` or “Connect to…”, then click the target |
| Search names, notes and tags | `/` |
| Copy a path as an R string, forward slashes and all | “Copy for R” |
| Find the dead corners | “Color”: age |
| See what takes up the room | “Layout”: treemap |
| See only what you have tagged, noted or related | “tagged only” |

A relation to something inside a collapsed folder is drawn dashed at the
nearest visible folder, so relations do not vanish when you collapse.

Drawing every relation by hand is the slow part, so the map suggests
some. It reads the R, R Markdown and Quarto scripts in the folder for
quoted paths that point at something else in the folder, and labels them
by the call around the path: a file given to `read_csv()` is “input to”
the script, one given to `write_csv()` or `ggsave()` is one the script
“writes”, a [`source()`](https://rdrr.io/r/base/source.html)d file is
“sourced by” it. Files with the same name and size are suggested as
copies. Suggestions are drawn dotted and listed in the panel; they
become relations when you add them, and a dismissed one is not suggested
again. The scripts are only read, never run, so a path put together at
run time is not found. From RStudio, the **Map folder** addin opens the
map for the project.

What you add is saved in `.foldermap.json` inside the folder. The file
follows the project, can be shared with colleagues and put under version
control, and it only changes when you change a tag, a note or a
relation. What is unfolded and where the nodes sit is remembered per
folder in your own cache instead, so the map looks the same next time
without adding noise to version control.

Saving takes a small local server, which needs the **httpuv** package
(it comes along with shiny). It listens on `127.0.0.1` only and is
protected by a random token. Nothing is fetched from or sent to the
internet: the graph library ships with pathr.
[`stop_folder_map()`](https://dataniel.github.io/pathr/reference/stop_folder_map.md)
stops the server; otherwise it runs until the R session ends.

[`folder_notes()`](https://dataniel.github.io/pathr/reference/folder_notes.md)
reads it all back as data frames – to list the core files of a project,
say, or to find relations whose ends have moved:

``` r
n <- folder_notes("C:/projects/big-project")
subset(n$nodes, tag == "core")
subset(n$relations, !exists)
```

[`folder_guide()`](https://dataniel.github.io/pathr/reference/folder_guide.md)
writes the same thing as prose: a short Markdown document with the
tagged folders and files, their notes, and the relations – for a README,
or for whoever takes the project over.

``` r
folder_guide("C:/projects/big-project", file = "FOLDERS.md")
```

Pass `gitignore = TRUE` to leave out whatever git ignores. It is off by
default, because the data and output folders a project keeps out of git
are often exactly what you want to see on the map.

Without a server you get a single self-contained HTML file to pass on:

``` r
map_folder(".", server = FALSE, file = "folder-map.html")
```

## Jump to a file you already have in code: `open_in_explorer()`

The other direction: you have a path in your script and want to see it
on disk.
[`open_in_explorer()`](https://dataniel.github.io/pathr/reference/open_in_explorer.md)
does it from the console, and the **Open in file explorer** addin does
it from wherever the cursor is.

``` r
open_in_explorer("C:/data/2026")
open_in_explorer(my_dir)   # a variable holding a path works too
```

The addin figures out its target on its own: the selected text, or the
path-like word under the cursor (so you can just rest the cursor on a
path or an object holding one), or the working directory if there is
nothing. A literal path opens directly; anything else is evaluated as R
code; a file is revealed (selected) inside its folder rather than
opened.

## Fix the backslashes

When a path does arrive over the clipboard, three addins turn it into
valid R, depending on how it came in:

- **[`addin_paste_path()`](https://dataniel.github.io/pathr/reference/addin_paste_path.md)**
  reads the clipboard, flips the backslashes, and inserts the result as
  a quoted string – the one-step “I just copied a path” move. Copy
  several paths and it inserts a `c(...)` vector instead.
- **[`addin_fix_path()`](https://dataniel.github.io/pathr/reference/addin_fix_path.md)**
  repairs paths already in your file: the selection, or the whole file
  if nothing is selected (the cursor stays where it was). It only
  touches real Windows paths and leaves `\(x)` lambdas and `\n` escapes
  alone.
- **[`addin_flip_backslash()`](https://dataniel.github.io/pathr/reference/addin_flip_backslash.md)**
  is the blunt version: every `\` in the selection becomes `/`, for when
  that is all you want.

These are RStudio addins, like the explorer one above. I prefer to call
them from the command palette (`Ctrl+Shift+P`, then type the addin
name), but you can also bind whichever you use most to a keyboard
shortcut under *Tools -\> Modify Keyboard Shortcuts*.

## Turn a list of paths into a vector

Paths often arrive as a list. Mark several files in the file explorer
and press `Ctrl+Shift+C` (*Copy as path*), and you get one per line,
each wrapped in quotes:

    "C:\data\2026\jan.csv"
    "C:\data\2026\feb.csv"
    "C:\data\2026\mar.csv"

Pasted into a script and selected,
[`addin_text_to_vector()`](https://dataniel.github.io/pathr/reference/addin_text_to_vector.md)
turns it into

``` r
c(
  "C:/data/2026/jan.csv",
  "C:/data/2026/feb.csv",
  "C:/data/2026/mar.csv"
)
```

– the explorer’s quotes dropped, the backslashes flipped. It works on
any line-delimited list, not just paths: file names from an email, CVR
numbers from a spreadsheet column, variable names. Lines without quotes
or backslashes are simply quoted, so you never hand-quote a list again.

## Then read them

Once the paths are in hand, read them with whatever you prefer. In
[`browse_files()`](https://dataniel.github.io/pathr/reference/browse_files.md),
reader mode writes the read for you. For a whole set of files at once,
`daos::read_files()` expands `glue`-style patterns, checks the files
exist, detects the format, and names the results:

``` r
daos::read_files("C:/data/2026_q{1:4}.parquet", names = 1:4)
```

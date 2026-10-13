[![R-CMD-check](https://github.com/dataniel/pathr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dataniel/pathr/actions/workflows/R-CMD-check.yaml)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![pkgdown](https://img.shields.io/badge/docs-pkgdown-blue.svg)](https://dataniel.github.io/pathr)

Frictionless file paths in R and RStudio. On Windows, every path is a
small chore: backslashes R will not accept, a file explorer you keep
switching to, and the same steps repeated for every file. pathr is a
handful of tools, mostly RStudio addins, that take those chores away.

It grew out of [daos](https://github.com/dataniel/daos) and stands
alone: it depends on neither daos nor the data-wrangling stack daos
brings along, so it installs light enough to have in every session.

## Installation

``` r
pak::pak("dataniel/pathr")
```

## What it looks like

**Copy several files in the explorer** (`Ctrl+Shift+C`, *Copy as path*),
paste, select, and run the *Text to vector* addin:

    "C:\data\2026\jan.csv"            c(
    "C:\data\2026\feb.csv"     ->       "C:/data/2026/jan.csv",
                                        "C:/data/2026/feb.csv"
                                      )

**Or never leave R.**
[`browse_files()`](https://dataniel.github.io/pathr/reference/browse_files.md)
is a keyboard-driven file browser: mark files with `Space`, press
`Enter`, and the paths, or a call that reads them, land in your script.

``` r
p <- browse_files()    # navigate, mark with Space, press Q
```

## Functions

| Function                                                                                           | Description                                                                                                                              |
|----------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| [`browse_files()`](https://dataniel.github.io/pathr/reference/browse_files.md)                     | Yazi-style Shiny file browser: mark files/folders and copy paths, or a call that reads them, to R                                        |
| [`open_in_explorer()`](https://dataniel.github.io/pathr/reference/open_in_explorer.md)             | Open a folder, or reveal a file, in the system file explorer                                                                             |
| [`addin_open_in_explorer()`](https://dataniel.github.io/pathr/reference/addin_open_in_explorer.md) | RStudio addin: open the selected path, the path under the cursor, or [`getwd()`](https://rdrr.io/r/base/getwd.html) in the file explorer |
| [`addin_paste_path()`](https://dataniel.github.io/pathr/reference/addin_paste_path.md)             | RStudio addin: paste Windows paths from the clipboard as a quoted R string or a `c(...)` vector                                          |
| [`addin_fix_path()`](https://dataniel.github.io/pathr/reference/addin_fix_path.md)                 | RStudio addin: replace backslashes with forward slashes in Windows paths                                                                 |
| [`addin_flip_backslash()`](https://dataniel.github.io/pathr/reference/addin_flip_backslash.md)     | RStudio addin: replace all backslashes with forward slashes in the selection                                                             |
| [`addin_text_to_vector()`](https://dataniel.github.io/pathr/reference/addin_text_to_vector.md)     | RStudio addin: convert selected lines, such as *Copy as path* output, to an R character vector                                           |

Call the addins from the *Addins* menu or the command palette
(`Ctrl+Shift+P`), or bind them to a shortcut under *Tools -\> Modify
Keyboard Shortcuts*.
[`vignette("pathr")`](https://dataniel.github.io/pathr/articles/pathr.md)
walks through all of it.

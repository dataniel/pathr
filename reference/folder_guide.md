# Write the map's notes up as a guide to the folder

Turns the tags, notes and relations from
[`map_folder()`](https://dataniel.github.io/pathr/reference/map_folder.md)
into a short Markdown document: the tagged folders and files with their
notes, then the relations. It is the map as something to read – for a
README, or for the colleague who takes the project over.

## Usage

``` r
folder_guide(
  path = ".",
  notes = file.path(path, ".foldermap.json"),
  file = NULL
)
```

## Arguments

- path:

  The folder to show.

- notes:

  The file holding tags, notes and relations. Defaults to
  `.foldermap.json` inside the folder, so it follows the project.

- file:

  Where to write the guide. With `NULL`, the default, it is printed
  instead.

## Value

The Markdown lines, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
folder_guide("C:/projects/big-project")
folder_guide("C:/projects/big-project", file = "FOLDERS.md")
} # }
```

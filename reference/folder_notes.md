# Read tags, notes and relations back into R

What you write in
[`map_folder()`](https://dataniel.github.io/pathr/reference/map_folder.md)
is saved in `.foldermap.json`. This function turns it into two data
frames, for instance to list a project's core files or to check that the
relations still point at something that exists.

## Usage

``` r
folder_notes(path = ".", notes = file.path(path, ".foldermap.json"))
```

## Arguments

- path:

  The folder to show.

- notes:

  The file holding tags, notes and relations. Defaults to
  `.foldermap.json` inside the folder, so it follows the project.

## Value

A list with

- `nodes`: `path`, `tag` (`core`, `important`, `unclear`, `outdated` or
  `NA`) and `note`.

- `relations`: `from`, `to`, `label`, `note` and `exists` (whether both
  ends are still there in the folder).

## Details

Paths are relative to the folder and use `/`. The root folder itself is
`""`.

## Examples

``` r
if (FALSE) { # \dontrun{
n <- folder_notes("C:/projects/big-project")
subset(n$nodes, tag == "core")
subset(n$relations, !exists)
} # }
```

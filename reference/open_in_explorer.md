# Open a path in the system file explorer

Opens a directory directly, or reveals a file (selected) inside its
containing folder. The console counterpart of
[`addin_open_in_explorer()`](https://dataniel.github.io/pathr/reference/addin_open_in_explorer.md).
On Windows the explorer window comes to the foreground; opened through
`shell.exec()` it tends to land behind RStudio.

## Usage

``` r
open_in_explorer(path = getwd())
```

## Arguments

- path:

  A file or directory path. Defaults to the working directory.

## Value

`path`, invisibly.

## Details

Being exported, it can also be the target of a clickable link in a cli
message, `{.run pathr::open_in_explorer('C:/data')}`: RStudio only runs
link code of the form `pkg::fun(args)`.

## Examples

``` r
if (FALSE) { # \dontrun{
open_in_explorer("C:/data/2026")
open_in_explorer(my_dir)   # a variable holding a path works too
} # }
```

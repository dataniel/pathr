# Names skipped when a folder is scanned

Folders and files that rarely say anything about how a project is put
together, but can hold tens of thousands of files (`node_modules`,
`.git`, the renv library). They are skipped *during* the scan, so they
cost no time.

## Usage

``` r
folder_ignore()
```

## Value

A character vector. `*` is a wildcard, and matching ignores case.

## See also

[`map_folder()`](https://dataniel.github.io/pathr/reference/map_folder.md),
[`scan_folder()`](https://dataniel.github.io/pathr/reference/scan_folder.md)

## Examples

``` r
folder_ignore()
#>  [1] "node_modules"       ".git"               ".svn"              
#>  [4] "__pycache__"        ".Rproj.user"        ".venv"             
#>  [7] "venv"               ".ipynb_checkpoints" ".DS_Store"         
#> [10] "Thumbs.db"          "desktop.ini"        ".quarto"           
#> [13] "*_cache"            "renv"               ".foldermap.json"   
#> [16] ".mappegraf.json"   
c(folder_ignore(), "output", "*.tmp")
#>  [1] "node_modules"       ".git"               ".svn"              
#>  [4] "__pycache__"        ".Rproj.user"        ".venv"             
#>  [7] "venv"               ".ipynb_checkpoints" ".DS_Store"         
#> [10] "Thumbs.db"          "desktop.ini"        ".quarto"           
#> [13] "*_cache"            "renv"               ".foldermap.json"   
#> [16] ".mappegraf.json"    "output"             "*.tmp"             
```

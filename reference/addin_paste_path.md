# RStudio addin: paste paths from the clipboard

Reads Windows paths from the clipboard, replaces backslashes with
forward slashes, and inserts them at the cursor: one path as a quoted R
string, several (one per line, as *Copy as path* gives them for several
files) as a `c(...)` vector. Quotes around a copied path are dropped, so
the explorer's *Copy as path* pastes as `"C:/data/jan.csv"`, not
`""C:/data/jan.csv""`.

## Usage

``` r
addin_paste_path()
```

## See also

[`addin_text_to_vector()`](https://dataniel.github.io/pathr/reference/addin_text_to_vector.md)
for a list already in the file.

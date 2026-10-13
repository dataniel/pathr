# RStudio addin: convert lines to an R character vector

Converts the selected text (one item per line) to an R character vector
expression, e.g. `c("a", "b", "c")`. Empty lines are ignored.

## Usage

``` r
addin_text_to_vector()
```

## Details

It is made for lists of paths: select the lines the file explorer's
*Copy as path* (`Ctrl+Shift+C` on several files) pastes, and the quotes
around each path are dropped and the backslashes flipped, so
`"C:\data\jan.csv"` becomes `"C:/data/jan.csv"` rather than invalid R.
Any other list – CVR numbers, variable names, a column copied from Excel
– is quoted as it stands.

## See also

[`addin_paste_path()`](https://dataniel.github.io/pathr/reference/addin_paste_path.md),
which does the same straight from the clipboard.

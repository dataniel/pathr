# Stop the folder map's local servers

Stops the servers
[`map_folder()`](https://dataniel.github.io/pathr/reference/map_folder.md)
has started in this R session. Other httpuv servers, such as Shiny apps,
are left alone.

## Usage

``` r
stop_folder_map()
```

## Value

Invisibly, the number of servers stopped.

## Examples

``` r
stop_folder_map()
```

# Scan a folder

Walks the folder recursively and returns one row per file and folder.
This is the data
[`map_folder()`](https://dataniel.github.io/pathr/reference/map_folder.md)
draws its graph from.

## Usage

``` r
scan_folder(
  path = ".",
  ignore = folder_ignore(),
  max_depth = 60,
  gitignore = FALSE
)
```

## Arguments

- path:

  The folder to scan.

- ignore:

  Names to skip, see
  [`folder_ignore()`](https://dataniel.github.io/pathr/reference/folder_ignore.md).

- max_depth:

  How deep to go at most. Guards against loops through junctions on
  Windows.

- gitignore:

  Also skip what git ignores in this folder? The question is put to git
  itself, so nested `.gitignore` files, negations and your global
  excludes all count. Off by default: the data and output folders a
  project keeps out of git are often exactly what you want on the map.

## Value

A data frame with the columns `path` (relative, with `/`), `size`
(bytes, 0 for folders), `mtime` (POSIXct) and `dir` (logical).

## Examples

``` r
scan_folder(R.home("doc"))
#>                                                 path    size
#> 1                                            AUTHORS    1063
#> 2                                   BioC_mirrors.csv    3283
#> 3                                            COPYING   18011
#> 4                                         COPYRIGHTS   33077
#> 5                                   CRAN_mirrors.csv   15454
#> 6                                                FAQ  118850
#> 7                                           KEYWORDS    2530
#> 8                                        KEYWORDS.db    3047
#> 9                                               NEWS  276166
#> 10                                            NEWS.0   93568
#> 11                                            NEWS.1  294093
#> 12                                            NEWS.2  641793
#> 13                                        NEWS.2.rds  407663
#> 14                                            NEWS.3  325036
#> 15                                        NEWS.3.rds  528694
#> 16                                          NEWS.pdf  444056
#> 17                                          NEWS.rds  477455
#> 18                                         RESOURCES    1268
#> 19                                            THANKS    3913
#> 20                                              html       0
#> 21                                            manual       0
#> 22                                 manual/R-FAQ.html  250032
#> 23                               manual/R-admin.html  449753
#> 24                                manual/R-data.html  207571
#> 25                                manual/R-exts.html 1711795
#> 26                               manual/R-intro.html  563453
#> 27                                manual/R-ints.html  448042
#> 28                                manual/R-lang.html  380427
#> 29                                     manual/images       0
#> 30                              manual/images/QQ.png    7185
#> 31                            manual/images/ecdf.png    5570
#> 32                           manual/images/fig11.png    3884
#> 33                           manual/images/fig12.png    3853
#> 34                            manual/images/hist.png    9376
#> 35                             manual/images/ice.png    2728
#> 36                                  html/NEWS.2.html  349537
#> 37                                  html/NEWS.3.html  449931
#> 38                                    html/NEWS.html  391988
#> 39                                    html/R-nav.css    3550
#> 40                                        html/R.css    2133
#> 41                                    html/Rlogo.pdf    6755
#> 42                                    html/Rlogo.svg    2693
#> 43                                  html/Search.html     707
#> 44                                html/SearchOn.html    7917
#> 45                                   html/about.html     911
#> 46                                  html/favicon.ico    5430
#> 47                                   html/index.html    2483
#> 48                                        html/katex       0
#> 49                               html/katex-check.js     327
#> 50                              html/katex-config.js     341
#> 51                                     html/left.jpg    1013
#> 52                                     html/logo.jpg   15985
#> 53                            html/mathjax-config.js     620
#> 54                                    html/orcid.svg     983
#> 55                      html/packages-head-utf8.html     516
#> 56                                html/packages.html    6693
#> 57                                    html/prism.css    5147
#> 58                                     html/prism.js   44516
#> 59                               html/resources.html    5463
#> 60                                    html/right.jpg    1022
#> 61                                      html/ror.svg    3712
#> 62                                       html/up.jpg    1021
#> 63                                html/katex/LICENSE    1160
#> 64                              html/katex/README.md    7119
#> 65                                  html/katex/fonts       0
#> 66                              html/katex/katex.css   26718
#> 67                               html/katex/katex.js  618576
#> 68            html/katex/fonts/KaTeX_AMS-Regular.ttf   63632
#> 69           html/katex/fonts/KaTeX_AMS-Regular.woff   33516
#> 70          html/katex/fonts/KaTeX_AMS-Regular.woff2   28076
#> 71       html/katex/fonts/KaTeX_Caligraphic-Bold.ttf   12368
#> 72      html/katex/fonts/KaTeX_Caligraphic-Bold.woff    7716
#> 73     html/katex/fonts/KaTeX_Caligraphic-Bold.woff2    6912
#> 74    html/katex/fonts/KaTeX_Caligraphic-Regular.ttf   12344
#> 75   html/katex/fonts/KaTeX_Caligraphic-Regular.woff    7656
#> 76  html/katex/fonts/KaTeX_Caligraphic-Regular.woff2    6908
#> 77           html/katex/fonts/KaTeX_Fraktur-Bold.ttf   19584
#> 78          html/katex/fonts/KaTeX_Fraktur-Bold.woff   13296
#> 79         html/katex/fonts/KaTeX_Fraktur-Bold.woff2   11348
#> 80        html/katex/fonts/KaTeX_Fraktur-Regular.ttf   19572
#> 81       html/katex/fonts/KaTeX_Fraktur-Regular.woff   13208
#> 82      html/katex/fonts/KaTeX_Fraktur-Regular.woff2   11316
#> 83              html/katex/fonts/KaTeX_Main-Bold.ttf   51336
#> 84             html/katex/fonts/KaTeX_Main-Bold.woff   29912
#> 85            html/katex/fonts/KaTeX_Main-Bold.woff2   25324
#> 86        html/katex/fonts/KaTeX_Main-BoldItalic.ttf   32968
#> 87       html/katex/fonts/KaTeX_Main-BoldItalic.woff   19412
#> 88      html/katex/fonts/KaTeX_Main-BoldItalic.woff2   16780
#> 89            html/katex/fonts/KaTeX_Main-Italic.ttf   33580
#> 90           html/katex/fonts/KaTeX_Main-Italic.woff   19676
#> 91          html/katex/fonts/KaTeX_Main-Italic.woff2   16988
#> 92           html/katex/fonts/KaTeX_Main-Regular.ttf   53580
#> 93          html/katex/fonts/KaTeX_Main-Regular.woff   30772
#> 94         html/katex/fonts/KaTeX_Main-Regular.woff2   26272
#> 95        html/katex/fonts/KaTeX_Math-BoldItalic.ttf   31196
#> 96       html/katex/fonts/KaTeX_Math-BoldItalic.woff   18668
#> 97      html/katex/fonts/KaTeX_Math-BoldItalic.woff2   16400
#> 98            html/katex/fonts/KaTeX_Math-Italic.ttf   31308
#> 99           html/katex/fonts/KaTeX_Math-Italic.woff   18748
#> 100         html/katex/fonts/KaTeX_Math-Italic.woff2   16440
#> 101        html/katex/fonts/KaTeX_SansSerif-Bold.ttf   24504
#> 102       html/katex/fonts/KaTeX_SansSerif-Bold.woff   14408
#> 103      html/katex/fonts/KaTeX_SansSerif-Bold.woff2   12216
#> 104      html/katex/fonts/KaTeX_SansSerif-Italic.ttf   22364
#> 105     html/katex/fonts/KaTeX_SansSerif-Italic.woff   14112
#> 106    html/katex/fonts/KaTeX_SansSerif-Italic.woff2   12028
#> 107     html/katex/fonts/KaTeX_SansSerif-Regular.ttf   19436
#> 108    html/katex/fonts/KaTeX_SansSerif-Regular.woff   12316
#> 109   html/katex/fonts/KaTeX_SansSerif-Regular.woff2   10344
#> 110        html/katex/fonts/KaTeX_Script-Regular.ttf   16648
#> 111       html/katex/fonts/KaTeX_Script-Regular.woff   10588
#> 112      html/katex/fonts/KaTeX_Script-Regular.woff2    9644
#> 113         html/katex/fonts/KaTeX_Size1-Regular.ttf   12228
#> 114        html/katex/fonts/KaTeX_Size1-Regular.woff    6496
#> 115       html/katex/fonts/KaTeX_Size1-Regular.woff2    5468
#> 116         html/katex/fonts/KaTeX_Size2-Regular.ttf   11508
#> 117        html/katex/fonts/KaTeX_Size2-Regular.woff    6188
#> 118       html/katex/fonts/KaTeX_Size2-Regular.woff2    5208
#> 119         html/katex/fonts/KaTeX_Size3-Regular.ttf    7588
#> 120        html/katex/fonts/KaTeX_Size3-Regular.woff    4420
#> 121       html/katex/fonts/KaTeX_Size3-Regular.woff2    3624
#> 122         html/katex/fonts/KaTeX_Size4-Regular.ttf   10364
#> 123        html/katex/fonts/KaTeX_Size4-Regular.woff    5980
#> 124       html/katex/fonts/KaTeX_Size4-Regular.woff2    4928
#> 125    html/katex/fonts/KaTeX_Typewriter-Regular.ttf   27556
#> 126   html/katex/fonts/KaTeX_Typewriter-Regular.woff   16028
#> 127  html/katex/fonts/KaTeX_Typewriter-Regular.woff2   13568
#>                   mtime   dir
#> 1   2026-10-29 18:39:52 FALSE
#> 2   2026-10-29 18:39:52 FALSE
#> 3   2026-10-29 18:39:52 FALSE
#> 4   2026-10-29 18:39:52 FALSE
#> 5   2026-10-29 18:39:52 FALSE
#> 6   2026-10-29 18:39:52 FALSE
#> 7   2026-10-29 18:39:52 FALSE
#> 8   2026-10-29 18:39:52 FALSE
#> 9   2026-10-29 18:39:52 FALSE
#> 10  2026-10-29 18:39:52 FALSE
#> 11  2026-10-29 18:39:52 FALSE
#> 12  2026-10-29 18:39:52 FALSE
#> 13  2026-10-29 18:39:52 FALSE
#> 14  2026-10-29 18:39:52 FALSE
#> 15  2026-10-29 18:39:52 FALSE
#> 16  2026-10-29 18:39:52 FALSE
#> 17  2026-10-29 18:39:52 FALSE
#> 18  2026-10-29 18:39:52 FALSE
#> 19  2026-10-29 18:39:52 FALSE
#> 20  2026-11-11 22:01:10  TRUE
#> 21  2026-11-11 22:01:10  TRUE
#> 22  2026-10-29 18:39:52 FALSE
#> 23  2026-10-29 18:39:52 FALSE
#> 24  2026-10-29 18:39:52 FALSE
#> 25  2026-10-29 18:39:52 FALSE
#> 26  2026-10-29 18:39:52 FALSE
#> 27  2026-10-29 18:39:52 FALSE
#> 28  2026-10-29 18:39:52 FALSE
#> 29  2026-11-11 22:01:10  TRUE
#> 30  2026-10-29 18:39:52 FALSE
#> 31  2026-10-29 18:39:52 FALSE
#> 32  2026-10-29 18:39:52 FALSE
#> 33  2026-10-29 18:39:52 FALSE
#> 34  2026-10-29 18:39:52 FALSE
#> 35  2026-10-29 18:39:52 FALSE
#> 36  2026-10-29 18:39:52 FALSE
#> 37  2026-10-29 18:39:52 FALSE
#> 38  2026-10-29 18:39:52 FALSE
#> 39  2026-10-29 18:39:52 FALSE
#> 40  2026-10-29 18:39:52 FALSE
#> 41  2026-10-29 18:39:52 FALSE
#> 42  2026-10-29 18:39:52 FALSE
#> 43  2026-10-29 18:39:52 FALSE
#> 44  2026-10-29 18:39:52 FALSE
#> 45  2026-10-29 18:39:52 FALSE
#> 46  2026-10-29 18:39:52 FALSE
#> 47  2026-10-29 18:39:52 FALSE
#> 48  2026-11-11 22:01:10  TRUE
#> 49  2026-10-29 18:39:52 FALSE
#> 50  2026-10-29 18:39:52 FALSE
#> 51  2026-10-29 18:39:52 FALSE
#> 52  2026-10-29 18:39:52 FALSE
#> 53  2026-10-29 18:39:52 FALSE
#> 54  2026-10-29 18:39:52 FALSE
#> 55  2026-10-29 18:39:52 FALSE
#> 56  2026-10-29 18:39:53 FALSE
#> 57  2026-10-29 18:39:52 FALSE
#> 58  2026-10-29 18:39:52 FALSE
#> 59  2026-10-29 18:39:52 FALSE
#> 60  2026-10-29 18:39:52 FALSE
#> 61  2026-10-29 18:39:52 FALSE
#> 62  2026-10-29 18:39:52 FALSE
#> 63  2024-12-04 14:08:10 FALSE
#> 64  2024-12-04 14:08:10 FALSE
#> 65  2026-11-11 22:01:10  TRUE
#> 66  2024-12-04 14:08:10 FALSE
#> 67  2024-12-04 14:08:11 FALSE
#> 68  2024-12-04 14:08:10 FALSE
#> 69  2024-12-04 14:08:10 FALSE
#> 70  2024-12-04 14:08:10 FALSE
#> 71  2024-12-04 14:08:10 FALSE
#> 72  2024-12-04 14:08:10 FALSE
#> 73  2024-12-04 14:08:10 FALSE
#> 74  2024-12-04 14:08:10 FALSE
#> 75  2024-12-04 14:08:10 FALSE
#> 76  2024-12-04 14:08:10 FALSE
#> 77  2024-12-04 14:08:10 FALSE
#> 78  2024-12-04 14:08:10 FALSE
#> 79  2024-12-04 14:08:10 FALSE
#> 80  2024-12-04 14:08:10 FALSE
#> 81  2024-12-04 14:08:10 FALSE
#> 82  2024-12-04 14:08:10 FALSE
#> 83  2024-12-04 14:08:10 FALSE
#> 84  2024-12-04 14:08:10 FALSE
#> 85  2024-12-04 14:08:10 FALSE
#> 86  2024-12-04 14:08:10 FALSE
#> 87  2024-12-04 14:08:10 FALSE
#> 88  2024-12-04 14:08:10 FALSE
#> 89  2024-12-04 14:08:10 FALSE
#> 90  2024-12-04 14:08:10 FALSE
#> 91  2024-12-04 14:08:10 FALSE
#> 92  2024-12-04 14:08:10 FALSE
#> 93  2024-12-04 14:08:10 FALSE
#> 94  2024-12-04 14:08:10 FALSE
#> 95  2024-12-04 14:08:10 FALSE
#> 96  2024-12-04 14:08:10 FALSE
#> 97  2024-12-04 14:08:10 FALSE
#> 98  2024-12-04 14:08:10 FALSE
#> 99  2024-12-04 14:08:10 FALSE
#> 100 2024-12-04 14:08:10 FALSE
#> 101 2024-12-04 14:08:10 FALSE
#> 102 2024-12-04 14:08:10 FALSE
#> 103 2024-12-04 14:08:10 FALSE
#> 104 2024-12-04 14:08:10 FALSE
#> 105 2024-12-04 14:08:10 FALSE
#> 106 2024-12-04 14:08:10 FALSE
#> 107 2024-12-04 14:08:10 FALSE
#> 108 2024-12-04 14:08:10 FALSE
#> 109 2024-12-04 14:08:10 FALSE
#> 110 2024-12-04 14:08:10 FALSE
#> 111 2024-12-04 14:08:10 FALSE
#> 112 2024-12-04 14:08:10 FALSE
#> 113 2024-12-04 14:08:10 FALSE
#> 114 2024-12-04 14:08:10 FALSE
#> 115 2024-12-04 14:08:10 FALSE
#> 116 2024-12-04 14:08:10 FALSE
#> 117 2024-12-04 14:08:10 FALSE
#> 118 2024-12-04 14:08:10 FALSE
#> 119 2024-12-04 14:08:10 FALSE
#> 120 2024-12-04 14:08:10 FALSE
#> 121 2024-12-04 14:08:10 FALSE
#> 122 2024-12-04 14:08:10 FALSE
#> 123 2024-12-04 14:08:10 FALSE
#> 124 2024-12-04 14:08:10 FALSE
#> 125 2024-12-04 14:08:10 FALSE
#> 126 2024-12-04 14:08:10 FALSE
#> 127 2024-12-04 14:08:10 FALSE
```

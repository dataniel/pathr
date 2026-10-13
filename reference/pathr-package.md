# pathr: frictionless file paths

Working with files in R on Windows means a small but constant friction:
backslashes R will not accept, a file explorer you keep switching to and
from, and the same chores repeated for every new file. Each function
here takes one of those off your plate.

## The functions

- **Grab a path without typing it:**
  [`browse_files()`](https://dataniel.github.io/pathr/reference/browse_files.md),
  a keyboard-driven file browser that hands the marked paths back to R –
  or a call that reads them

- **See a path on disk:**
  [`open_in_explorer()`](https://dataniel.github.io/pathr/reference/open_in_explorer.md)
  from the console, and
  [`addin_open_in_explorer()`](https://dataniel.github.io/pathr/reference/addin_open_in_explorer.md)
  from wherever the cursor is

- **Turn pasted Windows paths into valid R:**
  [`addin_paste_path()`](https://dataniel.github.io/pathr/reference/addin_paste_path.md),
  [`addin_fix_path()`](https://dataniel.github.io/pathr/reference/addin_fix_path.md),
  [`addin_flip_backslash()`](https://dataniel.github.io/pathr/reference/addin_flip_backslash.md),
  and
  [`addin_text_to_vector()`](https://dataniel.github.io/pathr/reference/addin_text_to_vector.md)
  for a list of them

The `addin_*()` functions are RStudio addins: call them from the
*Addins* menu or the command palette (`Ctrl+Shift+P`), or bind them to a
keyboard shortcut under *Tools -\> Modify Keyboard Shortcuts*.
[`vignette("pathr")`](https://dataniel.github.io/pathr/articles/pathr.md)
walks through all of it.

## Why a package of its own

The addins were born in `daos`, a general toolbox. They moved out
because they are used in every RStudio session regardless of project, so
they should install without the data-wrangling stack `daos` brings
along.

## See also

Useful links:

- <https://dataniel.github.io/pathr>

- <https://github.com/dataniel/pathr>

- Report bugs at <https://github.com/dataniel/pathr/issues>

## Author

**Maintainer**: Daniel Madsen <danielmadsen@live.dk>

Authors:

- Daniel Madsen <danielmadsen@live.dk>

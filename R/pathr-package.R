#' pathr: frictionless file paths
#'
#' Working with files in R on Windows means a small but constant friction:
#' backslashes R will not accept, a file explorer you keep switching to and
#' from, and the same chores repeated for every new file. Each function here
#' takes one of those off your plate.
#'
#' @section The functions:
#' * **Grab a path without typing it:** [browse_files()], a keyboard-driven
#'   file browser that hands the marked paths back to R -- or a call that
#'   reads them
#' * **See a path on disk:** [open_in_explorer()] from the console, and
#'   [addin_open_in_explorer()] from wherever the cursor is
#' * **Turn pasted Windows paths into valid R:** [addin_paste_path()],
#'   [addin_fix_path()], [addin_flip_backslash()], and
#'   [addin_text_to_vector()] for a list of them
#'
#' The `addin_*()` functions are RStudio addins: call them from the *Addins*
#' menu or the command palette (`Ctrl+Shift+P`), or bind them to a keyboard
#' shortcut under *Tools -> Modify Keyboard Shortcuts*. `vignette("pathr")`
#' walks through all of it.
#'
#' @section Why a package of its own:
#' The addins were born in `daos`, a general toolbox. They moved out because
#' they are used in every RStudio session regardless of project, so they
#' should install without the data-wrangling stack `daos` brings along.
#'
#' @keywords internal
"_PACKAGE"

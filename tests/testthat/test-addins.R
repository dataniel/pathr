flip <- function(x) gsub("\\\\", "/", x)

# .fix_windows_paths -------------------------------------------------------

test_that(".fix_windows_paths converts drive paths", {
  expect_equal(
    pathr:::.fix_windows_paths("C:\\Users\\danie\\Documents"),
    "C:/Users/danie/Documents"
  )
})

test_that(".fix_windows_paths converts UNC paths", {
  expect_equal(
    pathr:::.fix_windows_paths("\\\\server\\share\\file.txt"),
    "//server/share/file.txt"
  )
})

test_that(".fix_windows_paths handles path at end of string (no char doubling)", {
  expect_equal(
    pathr:::.fix_windows_paths("C:\\Users\\danie\\Documents\\arkiv\\cv"),
    "C:/Users/danie/Documents/arkiv/cv"
  )
})

test_that(".fix_windows_paths only touches paths, not other backslashes", {
  input <- "use \\n for newline, but C:\\Users\\foo gets fixed"
  expect_equal(
    pathr:::.fix_windows_paths(input),
    "use \\n for newline, but C:/Users/foo gets fixed"
  )
})

test_that(".fix_windows_paths handles multiple paths in one string", {
  input <- "C:\\foo\\bar and C:\\baz\\qux"
  expect_equal(
    pathr:::.fix_windows_paths(input),
    "C:/foo/bar and C:/baz/qux"
  )
})

test_that(".fix_windows_paths leaves non-path text unchanged", {
  expect_equal(pathr:::.fix_windows_paths("no paths here"), "no paths here")
})

# .path_lines and .r_vector (addin_paste_path, addin_text_to_vector) -------

test_that(".path_lines flips backslashes", {
  expect_equal(pathr:::.path_lines("C:\\Users\\danie\\Documents"),
               "C:/Users/danie/Documents")
  expect_equal(pathr:::.path_lines("data\\jan.csv"), "data/jan.csv")
})

test_that(".path_lines leaves a path with no backslashes alone", {
  expect_equal(pathr:::.path_lines("C:/already/fixed"), "C:/already/fixed")
})

test_that(".path_lines drops the quotes Copy as path puts around each path", {
  copied <- '"C:\\data\\jan.csv"\r\n"C:\\data\\feb.csv"'
  expect_equal(pathr:::.path_lines(copied), c("C:/data/jan.csv", "C:/data/feb.csv"))
  expect_equal(pathr:::.path_lines("'C:\\data'"), "C:/data")
})

test_that(".path_lines keeps quotes that do not wrap the whole line", {
  expect_equal(pathr:::.path_lines('say "hi" now'), 'say "hi" now')
  expect_equal(pathr:::.path_lines('"open'), '"open')
})

test_that(".path_lines splits lines, trims them, and drops blank ones", {
  expect_equal(pathr:::.path_lines("  a  \n\n  b  \n"), c("a", "b"))
  expect_equal(pathr:::.path_lines(""), character())
  expect_equal(pathr:::.path_lines('""'), character())
})

test_that(".path_lines quotes an ordinary list as it stands", {
  expect_equal(pathr:::.path_lines("12345678\n87654321"), c("12345678", "87654321"))
})

test_that(".r_vector writes one element per line", {
  expect_equal(pathr:::.r_vector(c("a", "b", "c")), 'c(\n  "a",\n  "b",\n  "c"\n)')
  expect_equal(pathr:::.r_vector("a"), 'c(\n  "a"\n)')
})

test_that("the output of .path_lines and .r_vector parses as R", {
  out <- pathr:::.r_vector(pathr:::.path_lines('"C:\\a\\b.csv"\n"\\\\srv\\x"'))
  expect_equal(eval(parse(text = out)), c("C:/a/b.csv", "//srv/x"))
})

# addin_flip_backslash core logic ------------------------------------------

test_that("flip() replaces all backslashes with forward slashes", {
  expect_equal(flip("C:\\Users\\danie"), "C:/Users/danie")
})

test_that("flip() handles text with no backslashes", {
  expect_equal(flip("C:/Users/danie"), "C:/Users/danie")
})

test_that("flip() replaces backslashes outside of Windows paths", {
  expect_equal(flip("foo\\bar\\baz"), "foo/bar/baz")
})

# .resolve_path_text core logic --------------------------------------------

test_that(".resolve_path_text returns an existing literal path as-is", {
  f <- withr::local_tempfile()
  writeLines("x", f)
  expect_equal(pathr:::.resolve_path_text(f), f)
})

test_that(".resolve_path_text strips surrounding quotes from a literal path", {
  f <- withr::local_tempfile()
  writeLines("x", f)
  expect_equal(pathr:::.resolve_path_text(paste0('"', f, '"')), f)
  expect_equal(pathr:::.resolve_path_text(paste0("'", f, "'")), f)
})

test_that(".resolve_path_text evaluates an object holding a path", {
  f <- withr::local_tempfile()
  writeLines("x", f)
  e <- new.env()
  assign("p", f, envir = e)
  expect_equal(pathr:::.resolve_path_text("p", envir = e), f)
})

test_that(".resolve_path_text evaluates a call returning a path", {
  d <- withr::local_tempdir()
  e <- new.env()
  assign("d", d, envir = e)
  expect_equal(
    pathr:::.resolve_path_text('file.path(d, "a")', envir = e),
    file.path(d, "a")
  )
})

test_that(".resolve_path_text falls back to the unquoted literal", {
  expect_equal(pathr:::.resolve_path_text("no_such_thing"), "no_such_thing")
})

test_that(".resolve_path_text returns NULL for blank text", {
  expect_null(pathr:::.resolve_path_text("   "))
  expect_null(pathr:::.resolve_path_text(""))
})

# .token_at_cursor core logic ----------------------------------------------

test_that(".token_at_cursor grabs the object name under the cursor", {
  line <- "x <- my_path"
  # cursor anywhere inside 'my_path' (cols 7..13)
  expect_equal(pathr:::.token_at_cursor(line, 9), "my_path")
  # cursor just after the token
  expect_equal(pathr:::.token_at_cursor(line, 13), "my_path")
})

test_that(".token_at_cursor captures an unquoted path including slashes", {
  line <- "C:/Users/danie/data.csv"
  expect_equal(pathr:::.token_at_cursor(line, 5), "C:/Users/danie/data.csv")
})

test_that(".token_at_cursor stops the token at whitespace", {
  line <- "open  my_path  now"
  expect_equal(pathr:::.token_at_cursor(line, 8), "my_path")
})

test_that(".token_at_cursor returns empty when the cursor is on whitespace", {
  expect_equal(pathr:::.token_at_cursor("a   b", 3), "")
})

test_that(".token_at_cursor returns empty for an empty line", {
  expect_equal(pathr:::.token_at_cursor("", 1), "")
})

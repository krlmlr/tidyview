#' @import rlang
NULL

#' View an object
#'
#' Queries the view handler by calling [get_view_handler()], and calls it
#' (if non-`NULL`).
#'
#' @return `x`, invisibly.
#'
#' @param x The object to display.
#' @param title The title to use for the display, by default
#'   the deparsed expression is used.
#' @param ... Passed on to the view handler.
#'
#' @export
view <- function(x, title = NULL, ...) {
  if (is.null(title)) {
    title <- expr_name(enexpr(x))
  }

  view_handler <- get_view_handler(x)
  if (!is.null(view_handler)) {
    view_handler(x = x, title = title, ...)
  }

  invisible(x)
}

#' Define how to view an object
#'
#' Called by [view()] to determine how to display an object.
#' The default implementation returns `[utils::View]`.
#' The RStudio IDE overrides this function, this is picked up
#' correctly.
#'
#' @return A function with at least two arguments, `x` and `title`.
#'
#' @param ... Unused, for extensibility.
#' @export
get_view_handler <- function(x, ...) UseMethod("get_view_handler")

#' @export
get_view_handler.default <- function(x, ...) {
  get("View", envir = as.environment("package:utils"))
}

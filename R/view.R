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

view_handler_factory_env <- new_environment(list(f = list()))

#' Define how to view an object
#'
#' `get_view_handler()` is called by [view()] to determine
#' how to display an object.
#'
#' @return A function with at least two arguments, `x` and `title`.
#'
#' @param x The object to display.
#' @export
get_view_handler <- function(x) {
  for (factory in view_handler_factory_env$f) {
    view_handler <- factory(x)
    if (!is.null(view_handler)) {
      args <- formals(view_handler)
      if (length(args) < 2) {
        warn("View handler must have at least two arguments `x` and `title`.")
      } else if (any(names(args)[1:2] != c("x", "title"))) {
        warn("View handler must have arguments `x` and `title` in the beginning.")
      } else {
        return(view_handler)
      }
    }
  }

  default_view_handler
}

#' @description
#' `default_view_handler()` is the view handler returned by default.
#' It calls `[utils::View]`; the RStudio IDE overrides this function,
#' this is picked up correctly.
#'
#' @export
#' @rdname get_view_handler
default_view_handler <- function(x, title) {
  View <- get("View", envir = as.environment("package:utils"))
  View(x, title)
}


#' @description
#' `register_view_handler_factory()` and `unregister_view_handler_factory()`
#' allow users and packages to override the default view handler.
#' See the section "View handler factories" for details.
#'
#' @section View handler factories:
#' When a factory is registered with `register_view_handler_factory()`,
#' each time `view()` is called, that factory will be consulted.
#' The function in the `factory` argument will be
#' called with the object to display; if it returns a handler, i.e. a
#' function with a signature similar to `default_view_handler`,
#' the handler will be called with the object.
#' If the factory returns `NULL` the next factory will be consulted.
#' If no factory returns a handler, the default view handler is called.
#'
#' Factories are consulted in the reverse order of registration,
#' the factory registered last will be called first.
#' Re-registering a factory moves it to the top of the chain.
#' Unregistering a factory makes sure it won't be called again.
#'
#' @param factory A function with exactly one argument, `x`.
#'
#' @export
#' @rdname get_view_handler
register_view_handler_factory <- function(factory) {
  stopifnot(is_function(factory), identical(names(formals(factory)), "x"))

  view_handler_factory_env$f <- unique(c(list(factory), view_handler_factory_env$f))
  invisible(factory)
}

#' @export
unregister_view_handler_factory <- function(factory) {
  view_handler_factory_env$f <- setdiff(view_handler_factory_env$f, c(list(factory)))
  invisible(factory)
}

#' @description
#' `suppress_view()` basically turns off `view()`, it registers a view handler factory
#' that always returns a function that does nothing.
#' @export
#' @rdname get_view_handler
suppress_view <- function() {
  register_view_handler_factory(void_view_handler_factory)
}

#' @description
#' `permit_view()` removes the void view handler factory registered by `suppress_view()`.
#' @export
#' @rdname get_view_handler
permit_view <- function() {
  unregister_view_handler_factory(void_view_handler_factory)
}

void_view_handler_factory <- function(x) {
  void_view_handler
}

void_view_handler <- function(x, title) {
  inform(paste0("Suppressed viewing of ", title))
}

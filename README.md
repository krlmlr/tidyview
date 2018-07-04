
<!-- README.md is generated from README.Rmd. Please edit that file -->
tidyview
========

The goal of tidyview is to provide an extensible replacement for `utils::View()`.

Installation
------------

You can install the released version of tidyview from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("tidyview")
```

Example
-------

By default, `view()` forwards to `utils::View()`. This isn't useful for rendering an *rmarkdown* document, so the first code shown here will be how to turn it off.

``` r
library(tidyview)
suppress_view()
```

Now we're safe to use `view()`:

``` r
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────────────────── tidyverse 1.2.1 ──
#> ✔ ggplot2 2.2.1          ✔ purrr   0.2.5     
#> ✔ tibble  1.4.2.9002     ✔ dplyr   0.7.6     
#> ✔ tidyr   0.8.1          ✔ stringr 1.3.1     
#> ✔ readr   1.1.1          ✔ forcats 0.3.0
#> ── Conflicts ────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()

view(mtcars)
#> Suppressed viewing of mtcars

mtcars %>%
  view() %>%
  nrow()
#> Suppressed viewing of .
#> [1] 32
```

Note the pipe-friendlyness -- the input is passed through, invisibly, and can be processed later on. In an interactive session, the code above would have opened two data viewers, via the `default_view_handler()` function:

``` r
default_view_handler
#> function(x, title) {
#>   View <- get("View", envir = as.environment("package:utils"))
#>   View(x, title)
#> }
#> <bytecode: 0x56424bdec790>
#> <environment: namespace:tidyview>
```

Custom view handlers can be made available through *factories*. The factory is a design pattern, see the [Wikipedia article](https://en.wikipedia.org/wiki/Factory_(object-oriented_programming)) if you're not familiar with it.

1.  A factory is registered via `register_view_handler_factory()`.

2.  Each time `view()` is called, all registered factories are consulted.

3.  The first factory that returns a valid handler, i.e. a function similar to the `default_view_handler()` seen above, wins. The handler is called with the object.

4.  If no factory takes responsibility, the default view handler is used.

The factory must be a pure function without (user-visible) side effects!

We register a view handler factory that outputs the title and the dimensions of the object for 2D objects, and does nothing for all other objects.

``` r
my_view_handler_factory <- function(x) {
  if (length(dim(x)) != 2) return (NULL)
  
  my_view_handler
}

my_view_handler <- function(x, title) {
  cat("Title: ", title, "\n", sep = "")
  cat("Dimensions: ", paste(dim(x), collapse = " x "), "\n", sep = "")
}

register_view_handler_factory(my_view_handler_factory)
```

Now, when we `view()` a data frame, we get console output:

``` r
view(mtcars)
#> Title: mtcars
#> Dimensions: 32 x 11

mtcars %>%
  view() %>%
  nrow()
#> Title: .
#> Dimensions: 32 x 11
#> [1] 32

mtcars %>%
  view("my title")
#> Title: my title
#> Dimensions: 32 x 11
```

(The dot `.` in the title is created by the pipe. If you need to distinguish views in a pipe-based workflow, use the `title` argument to `view()`.)

Viewing a vector still doesn't do anything, this is how we designed our view handler factory:

``` r
view(1:10)
#> Suppressed viewing of 1:10
```

The implementation of `suppress_view()` shouldn't be surprising:

``` r
suppress_view
#> function() {
#>   register_view_handler_factory(void_view_handler_factory)
#> }
#> <bytecode: 0x56424a2c1020>
#> <environment: namespace:tidyview>
```

Factories are consulted in reverse registration order, calling `suppress_view()` again moves the void handler factory to the top.

``` r
suppress_view()
view(mtcars)
#> Suppressed viewing of mtcars
```

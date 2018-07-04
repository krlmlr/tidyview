# tidyview 0.0.0.9001

Initial release.

- `view()` acts as a drop-in replacement for `utils::View()`.
- `get_view_handler()` is called by `view()` to determine how an object is to be displayed, by default via `default_view_handler()` which forwards to `utils::View()`.
- `suppress_view()` and `permit_view()` make `view()` turn off forwarding to `utils::View()`.
- `register_view_handler_factory()` and `unregister_view_handler_factory()` allow full customization of `view()`.

# Lua Filters

[![Build status][GitHub Actions badge]][GitHub Actions]

[GitHub Actions badge]: https://img.shields.io/github/workflow/status/pandoc/lua-filters/CI?logo=github
[GitHub Actions]: https://github.com/pandoc/lua-filters/actions

This repository collects Lua filters for pandoc.

To learn about Lua filters, see the
[documentation](http://pandoc.org/lua-filters.html).

Structure
---------

Each filter goes in its own subdirectory.  Each subdirectory contains:

- the filter itself (e.g. `wordcount.lua`)
- a `README.md` describing the use of the filter
- a `Makefile` with a `test` target to test the filter
- some data files used for the tests, which may also serve
  as examples

Requirements
------------

Filters are tested against the pandoc version in the latest
pandoc/ubuntu Docker image, i.e. usually the latest release. There
is no guarantee that filters will work with older versions, but
many do.

Some filters depend on external programs, which must be installed
separately.  Refer to the filters' README for detailed
requirements.

Contributing
------------

PRs for improvements, bug fixes, or new filters are welcome.
Please see CONTRIBUTING.md for additional information.

License
-------

All filters are published under the MIT license by their
respective authors. See LICENSE for details.

[Lua style guide]: https://github.com/hslua/lua-style-guide

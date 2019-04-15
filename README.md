[![travis build
status](https://img.shields.io/travis/pandoc/lua-filters/master.svg?label=travis+build)](https://travis-ci.org/pandoc/lua-filters)

# Lua Filters

This repository collects Lua filters for pandoc.

To learn about Lua filters, see the
[documentation](http://pandoc.org/lua-filters.html).

Each filter goes in its own subdirectory.  Each subdirectory contains:

- the filter itself (e.g. `wordcount.lua`)
- a `README.md` describing the use of the filter
- a `Makefile` with a `test` target to test the filter
- some data files used for the tests, which may also serve
  as examples

PRs for new filters are welcome, provided they conform to
these guidelines.


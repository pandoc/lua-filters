# lua-filters

This repository collects lua filters for pandoc.
To learn about lua filters, see the
[documentation](http://pandoc.org/lua-filters.html).

Each filter goes in its own subdirectory of the `filters`
directory.  Each subdirectory contains:

- the filter itself (e.g. `wordcount.lua`)
- a `README.md` describing the use of the filter
- a `Makefile` with a `test` target to test the filter
- some data files used for the tests, which may also serve
  as examples

PRs for new filters are welcome, provided they conform to
these guidelines.


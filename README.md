# Lua Filters

[![Travis build status][Travis badge]](https://travis-ci.org/pandoc/lua-filters)
[![Circle CI build status][Circle CI badge]](https://circleci.com/gh/pandoc/lua-filters)

[Travis badge]: https://img.shields.io/travis/pandoc/lua-filters.svg?logo=travis
[Circle CI badge]: https://img.shields.io/circleci/build/gh/pandoc/lua-filters?logo=circleci

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

Filters are tested against the latest pandoc version.  There is
no guarantee that filters will work with older versions, but
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

[Lua style guide]: https://github.com/Olivine-Labs/lua-style-guide

# Lua Filters

[![Build status][GitHub Actions badge]][GitHub Actions]

[GitHub Actions badge]: https://img.shields.io/github/workflow/status/pandoc/lua-filters/CI?logo=github
[GitHub Actions]: https://github.com/pandoc/lua-filters/actions

A collection of Lua filters for pandoc.

To learn about Lua filters, see the [documentation].

[documentation]: http://pandoc.org/lua-filters.html

Requirements
------------

Filters are tested against the pandoc version in the latest
pandoc/ubuntu Docker image, i.e. usually the latest release. There
is no guarantee that filters will work with older versions, but
many do.

Some filters depend on external programs, which must be installed
separately. Refer to the filters' README for detailed
requirements; the filter READMEs are not included in the release
archives, but available online at
<https://github.com/pandoc/lua-filters>.

Contributing
------------

PRs for improvements, bug fixes, or new filters are welcome.
Please see CONTRIBUTING.md for additional information.

License
-------

All filters are published under the MIT license by their
respective authors. See LICENSE for details.

[Lua style guide]: https://github.com/hslua/lua-style-guide

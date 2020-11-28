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
separately. Refer to the filters' documentations for detailed
requirements.

Installation
------------

All filters can be used without special installation, just by
passing the respective `.lua` file path to pandoc via
`--lua-filter`/`-L`.

User-global installation is possible by placing a filter in within
the `filters` directory of pandoc's user data directory. This
allows to use the filters just by using the filename, without
having to specify the full file path.

On mac and Linux, the filters can be installed by extracting the
archive with

    RELEASE_URL=https://github.com/pandoc/lua-filters/releases/latest
    curl -LSs $RELEASE_URL/download/lua-filters.tar.gz | \
        tar --strip-components=1 --one-top-level=$PANDOC_DIR -zvxf -

where `$PANDOC_DIR` is a user directory as listed in the output of
`pandoc -v`.

Contributing
------------

PRs for improvements, bug fixes, or new filters are welcome.
Please see CONTRIBUTING.md for additional information.

License
-------

All filters are published under the MIT license by their
respective authors. See LICENSE for details.

[Lua style guide]: https://github.com/hslua/lua-style-guide

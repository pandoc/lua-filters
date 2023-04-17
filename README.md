# Lua Filters

[![Build status][CI badge]][GitHub Actions]

[CI badge]: https://img.shields.io/github/actions/workflow/status/pandoc/lua-filters/ci.yml?branch=master&logo=github
[GitHub Actions]: https://github.com/pandoc/lua-filters/actions

A collection of Lua filters for pandoc.

To learn about Lua filters, see the [documentation].

[documentation]: http://pandoc.org/lua-filters.html

> **Warning**
>
> This repository is in the process of **being retired**. Please
> see the next section for details.

## Status of this repository

We no longer accept new filter submissions and will only apply
small patches to the existing filters.

The most popular filters have been or will be transferred to the
[pandoc-ext] organization. Please raise an issue in the
[info][pandoc-ext/info] repository if your favorite filter has not
been re-published yet.

### List of extensions

A list of extensions is available in the [pandoc-ext/info]
repository. See also the [pandoc][topic-pandoc] and
[pandoc-filter][topic-pandoc-filter] GitHub topics.

### New filters

We want the ecosystem to be distributed, but also try to make it
easy to discover new software. That's why we ask filter authors to
add the [pandoc][topic-pandoc] and
[pandoc-filter][topic-pandoc-filter] to the GitHub repositories,
as enables others to explore filters through GitHub's interface.

Additionally, please add a link to your filter to the
[pandoc-ext/info] repository.

[topic-pandoc]: https://github.com/topics/pandoc-filter
[topic-pandoc-filter]: https://github.com/topics/pandoc-filter
[pandoc-ext/info]: https://github.com/pandoc-ext/info

### Why is this repository being retired?

There are multiple reasons why this repository is discontinued:

- *Maintenance* – supporting all filters in this repository became
  unsustainable. As put by John MacFarlane in [issue #207]:

  > One drawback of the current structure is that people submit
  > code here but then don't monitor the repository, and issues
  > are neglected.

  This put a lot of work on not enough shoulders, with the result
  that code wasn't properly maintained.

- *Credit and ownership* – authors should get proper credit for
  their work, but putting all filters in one repository makes
  their contributions less visible. Repositories owned by the
  original authors makes it obvious who put in all the work and
  who is responsible.

- *Interoperability* – many filters are useful for [Quarto] users;
  having one repository per filter makes it possible to support
  Quarto's extension mechanism, enabling users to install the
  filters with the `quarto install extension` command.

[issue #207]: https://github.com/pandoc/lua-filters/issues/207
[Quarto]: https://quarto.org/

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

PRs for improvements or bug fixes are welcome. However, we do not
accept new filters at this time. However, we *do* encourage
submissions of external repositories to be included as a link in
the collection.

Please see CONTRIBUTING.md for information on code contributions.

License
-------

All filters are published under the MIT license by their
respective authors. See LICENSE for details.

[Lua style guide]: https://github.com/hslua/lua-style-guide

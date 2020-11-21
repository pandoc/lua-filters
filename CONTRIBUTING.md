Contributing to lua-filters
===========================

Happy to have you here! Below you can find guidance on the
best way to contribute to this collection of Lua filters.
All contributions are welcome!

Bugs reports and feature requests
---------------------------------

We are happy to receive feature request or bug reports on the
GitHub [issue tracker].

Please note that all filters *usually* target the latest pandoc
version, although we may lag behind sometimes. It is considered a
bug if a filter produces wrong results for the latest pandoc
version; older pandoc versions are not necessarily supported,
although we usually strive to do so.

A bug report is most useful if it gives detailed, *reproducible*
instructions. Additionally, it should include

  * the pandoc version,
  * the exact command line used,
  * the exact input used,
  * the output received, and
  * the output you expected instead.

This will allow us to help you more quickly.

Pull requests
-------------

Whether a small patch or a full new filters, we love getting pull
requests. Consistency is important, especially for a project with
multiple parts written by many contributors. That's why PRs should
follow the filter structure outlined below.

Filter Structure
----------------

The filters come with these components:

- `README.md` describing the filter; if the filter depends on
  additional programs, the document should list those requirements
  and describe how they can be installed.

  Please keep in mind that a key design goal of Markdown was
  readability. The README should be pleasant to read even as plain
  text. This includes keeping lines below 80 chars or, better yet,
  below 66 chars.

- The main Lua filter script; besides the code, it should also
  contain a small header with author, copyright, and licensing
  information. All filters must be licensed under the MIT license.

  Lua code should follow the HsLua [Lua style guide]. The
  tl;dr is: use snake_case for most names and keep lines below 80
  chars.

- `Makefile` to run the tests. The only hard requirement is the
  existence of a `.PHONY` target named `test` which can be used to
  test correctness.

- `sample.md` or a similar file demonstrating how the filter can
  be used. The sample file doubles as test input.

- A file containing the expected output when using the filter on
  the sample input. Multiple such files can be provided if
  different filter configurations are to be tested.

All components should be bundled in a single directory.

Text and source files should always be terminated by a final
newline character. The repository comes with a `.editorconfig`
file which helps to adhere to this and similar conventions. Please
consider installing [editorconfig](https://editorconfig.org) if
you editor supports it.

### Configuration

Filters are expected to be readily usable by a wide range of
users. It should not be necessary to edit any source files, so it
often makes sense to keep a filter configurable.

There are two main methods to configure a filter: environment
variables and special metadata values. The `diagram-generator`
filter supports both and can serve as a good reference.

Tests
-----

We currently test filters under two aspects on different CI
systems:

- *Travis CI*: filters are tested against the latest pandoc
  version as available from pandoc's download page. The build is
  configured via `.travis.yml`.
- *Circle CI*: tests are run in the latest pandoc/ubuntu Docker
  image. The config is in `.circleci/config.yml`.

Both systems contain all software necessary to run the tests. Some
filters require additional software to be installed. Please make
sure that all requirements are satisfied in both build
environments and that the builds finish successfully.

Commits
-------

Please follow the usual guidelines for git commits: keep commits
atomic, self-contained, and add a brief but clear commit message.
This [guide](https://chris.beams.io/posts/git-commit/) by Chris
Beams is a good resource if you'd like to learn more.

However, don't fret over this too much. You can also just
accumulate commits without much thought for this rule. We can
squash all commits in a PR into a single commit upon merging. But
we still appreciate it if we don't have to rewrite the commit
message.


[issue tracker]: https://github.com/pandoc/lua-filters/issues
[Lua style guide]: https://github.com/hslua/lua-style-guide

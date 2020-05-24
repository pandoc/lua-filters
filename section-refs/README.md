# section-refs

This filter allows the user to put bibliographies at the end of
each section, containing only those references in the section. It
works by splitting the document up into sections, and then
treating each section as a separate document for pandoc-citeproc
to process.

## Usage

This filter interferes with the default operation of
pandoc-citeproc. The `pandoc-citeproc` filter must either be run
*before* this filter, or not at all. The `section-refs.lua`
filter calls `pandoc-citeproc` as necessary. For example:

    pandoc input.md -F pandoc-citeproc --lua-filter section-refs.lua

or

    pandoc input.md --lua-filter section-refs.lua

### Configuration

The filter allows customization through these metadata fields:

`section-refs-level`
:   This variable controls what level the biblography will occur
    at the end of. The header of the generated references section
    will be one level lower than the section that it appears on
    (so if it occurs at the end of a level-1 section, it will
    receive a level-2 header, and so on).

`section-refs-bibliography`
:   Behaves like `bibliography` in the context of this filter.
    This variable exists because pandoc automatically invokes
    `pandoc-citeproc` as the final filter if it is called with
    either `--bibliography`, or if the `bibliography` metadata is
    given via a command line option. Using
    `section-refs-bibliography` on the command line avoids this
    unwanted invocation.

## Dependencies

This filter requires

  * pandoc version 2.8 or later, and
  * pandoc-citeproc version 0.14.5 or later.

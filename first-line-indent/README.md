---
title: "First Line Indent - First-line idented paragraphs
 in Pandoc's markdown"
author: "Julien Dutant"
---

First Line Indent
=======

First-line idented paragraphs in Pandoc's markdown.

This Lua filter for Pandoc improves Pandoc's first-line ident
paragraph separation style by removing first-line idents after
blockquotes, lists and code blocks unless specified otherwise.

v1.0. Copyright: © 2021 Julien Dutant <julien.dutant@kcl.ac.uk>
License:  MIT - see LICENSE file for details.

Introduction
------------

In typography paragraphs can be distinguished in two ways: by vertical
whitespace (a style common on the web) or by indenting their first
line (a style common in books). For the latter conventions vary across
typographic traditions: some (*e.g.* French) indent the first line of
every paragraph while others (*e.g.* English) don't indent paragraphs
after section headings and most indented material such as blockquotes
or lists.

In Pandoc the default output uses the vertical whitespace style but
can be switched in some formats (PDF via `LaTeX`, though not in `docx`
or `html`) to the  first-line indent style by setting the metadata
variable `indent` to `true` and the `lang` variable is used to decide
which convention to follow (the default is the English one).

However the default first-line indent style output still adds first-line indents to every paragraph that starts after a blockquote, list, code
block, etc. These are typically (though not always) unwanted, namely when
the text after the blockquote or list is a continuation of the same
paragraph.

This filter improves the handling of first-line indent following
indented material such as blockquotes and provides first-line indent
style for html outputs:

1) The filter activates Pandoc's first-line indent style by setting
  the metadata variable `indent` to true, unless otherwise specified.
2) The filter generates HTML outputs with first-line indent style. That
  is done by inserting CSS code in the document's metadata
  `header-includes` field. (Note that this still works if the document
  has its own `header-includes` material, but not if a
  `header-includes` value  is given to Pandoc via the command line.)
  This default behaviour can be deactivated if the user wants to handle
  first-line indent formatting with a custom pandoc template.
3) If the user manually specifies `\indent` (resp., `\noindent`) at the start
  of a paragraph (in markdown source), the paragraphs are typeset with
  (resp., without) first-line indentation in HTML output as well as
  LaTeX output.
4) The filter removes (typically unwanted) first-line indents after
  blockquotes, lists, code blocks and the like. The user can
  override this by inserting  `\indent` at the beginning of a paragraph
  that does require a first-line indent. By default first-line indent
  is removed after the block of the following types, though this can
  be customized by the user: block quotes, lists (of all types:
  unordered, ordered, numbered examples, definition lists),
  horizontal rules.
5) A custom size for the first-line indentation in HTML and LaTeX output
  can be specified.

Usage
-----

### Basic usage

Copy `first-line-indent.lua` in your document folder or in your pandoc
data directory (details in [Pandoc's manual](https://pandoc.org/MANUAL.html#option--lua-filter)). Run it on your document with a
command line option:

```bash
pandoc --luafilter first-line-indent.lua SOURCE.md -o OUTPUT.html

pandoc -L first-line-indent.lua SOURCE.md -o OUTPUT.pdf
```

or specify it in a defaults file (details in [Pandoc's manual](https://pandoc.org/MANUAL.html#option--defaults)).

This will generate HTML and PDF outputs in first-line indent paragraph
separation style with the indent automatically removed after headings,
blockquotes, lists of all kinds and horizontal rules.

If you want to keep the first-line indent of a certain paragraph after
a list or blockquote, this must be done in markdown (convert your
source to markdown first with pandoc). You simply add `\indent` at the
beginning of the paragraph:

```markdown
> This is a blockquote

\indent This paragraph will have an indent even though it follows a
blockquote.
```

### Advanced usage

The filter has options that can be specified in a [pandoc default
file](https://pandoc.org/MANUAL.html#option--defaults) or, if the
source is markdown, in the source document's metadata block.
Either way they are specified as sub-fields of a `first-line-indent`
field. In the source's metadata block, they are specified as
follows (these are the default values):

```yaml
first-line-indent:
  size: 1em
  auto-remove: true
  set-metadata-variable: true
  set-header-includes: true
  remove-after:
    - BlockQuote
    - BulletList
    - CodeBlock
    - DefinitionList
    - HorizontalRule
    - OrderedList
  dont-remove-after: Table
```

And as follows in a default file:

```yaml
metadata:
  first-line-indent:
    size: 1em
    auto-remove: true
    set-metadata-variable: true
    set-header-includes: true
    remove-after:
      - BlockQuote
      - BulletList
      - CodeBlock
      - DefinitionList
      - HorizontalRule
      - OrderedList
    dont-remove-after: Table
```

The options are described below.

* `size`: string specificing size of the first-line indent. Must be in a
  format suitable for all desired outputs. `1.5em`, `2ex`, `.5pc`, `10pt`,
  `25mm`, `2.5cm`, `0.3in`, all work in LaTeX and HTML. `25px` only works
  in HTML. LaTeX commands (`\textheight`) are not supported.
* `auto-remove`: whether the filter automatically removes first-line
  indent from paragraphs that follow blockquotes and the like, unless
  they start with the `\indent` string. (Default: true)
* `set-metadata-variable`: whether the filter should tell Pandoc to use
  first-line-indent paragraph separation style by setting the metadata
  variable `indent` to `true`. (Default: true)
* `set-header-includes`: whether the filter should add formatting code
  to the document's `header-includes` metadata field. Set it to false if
  you use a custom template instead.
* `remove-after`, `dont-remove-after`: use these options to customize
  the automatic removal of first-line indent on paragraphs following
  blocks of a certain type. These options can be a single string or
  an list of strings. The strings are case-sensitive and should be
  those corresponding to [block types in Lua
  filters](https://pandoc.org/lua-filters.html#type-block): BlockQuote,
  BulletList, CodeBlock, DefinitionList, Div, Header, HorizontalRule,
  LineBlock, Null, OrderedList, Para, Plain, RawBlock, Table.

To illustrate the last option, suppose you don't want to filter to remove
first-line indent after definition lists. You can add the following
lines in the document's metadata block (if the source is markdown):

```yaml
first-line-indent:
  dont-remove-after: DefinitionList
```

### Styling the outputs

In LaTeX output the filters adds `\noindent` commands at beginning of
paragraphs that shouldn't be indented. These can be controlled in
LaTeX as usual.

In HTML output paragraphs that are explicitly marked to have no first-line
indent are preceded by an empty `div` with class `no-first-line-indent-after`
and those that are explictly marked (with `\indent` in the markdown
source) to have a first-line indent are preceded by an empty `div` with class
`first-line-indent-after`, as follows:

```html
<ul>
  <li>A bullet</li>
  <li>list</li>
</ul>
<div class="no-first-line-indent-after"></div>
<p>This paragraph should not have first-line indent.</p>
...
<div class="first-line-indent-after"></div>
<p>This paragraph should have first-line indent.</p>
```

These can be styled in CSS as follows:

```css
p {
  text-indent: 1em;
  margin: 0;
}
:is(h1, h2, h3, h4, h5, h6) + p {
  text-indent: 0em;
}
:is(div.no-first-line-indent-after) + p {
  text-indent: 0em;
}
:is(div.first-line-indent-after) + p {
  text-indent: 1em;
}
```

The `p` rule adds a first-line identation to every paragraph (and `margin: 0` removes the default vertical space between paragraphs). The
`is(h1, h2, h3, h4, h5, h6) + p` rule removes first-line indentation from
every paragraph that follows a heading. The
`:is(div.no-first-line-indent-after) + p` and
`:is(div.first-line-indent-after) + p` rules remove/add first-line indentation
from every paragraph that follows `div`s of the classes `no-first-line-indent-after` and `first-line-indent-after`, respectively.

Contributing
------------

PRs welcome.


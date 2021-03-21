---
title: "First Line Indent - First-line idented paragraphs
 in Pandoc's markdown"
author: "Julien Dutant"
---

Indentation
=======

Paragraph indentation control in pandoc's markdown.

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
  This default behaviour can be deactivated in case the user prefers
  relying on a custom HTML template to handle first-line indent
  formatting.
3) The filter removes (typically unwanted) first-line indents after
  blockquotes, lists, code blocks and the like. The user can
  override this by inserting  `\indent` at the beginning of a paragraph
  that does require a first-line indent. By default first-line indent
  is removed after the block of the following types, though this can
  be customized by the user: block quotes, lists (of all types:
  unordered, ordered, numbered examples, definition lists),
  horizontal rules.

Usage
-----


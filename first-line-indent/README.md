---
title: "First Line Indent - First-line idented paragraphs
 in Pandoc's markdown"
author: "Julien Dutant"
---

Indentation
=======

Paragraph indentation control in pandoc's markdown.

This Lua filter for Pandoc prepares document for separating
paragraphs with a first-line indentation rather than vertical
whitespace.

v1.0. Copyright: © 2021 Julien Dutant <julien.dutant@kcl.ac.uk>
License:  MIT - see LICENSE file for details.

Introduction
------------

Pandoc's default output templates separate paragraphs
with vertical whitespace rather than an idented first line (a style
that is common on the web but uncommon in books). This filter prepares
documents for outputs with the first-line ident style instead.

1) In some typographic traditions (*e.g.* English) when the first-line
indent style is used paragraphs are *not* indented after headings,
blockquotes, code blocks and lists. By default the filter follows this
convention and removes (typically unwanted) indent from paragraphs
that follow blockquotes, code blocks, lists. The user can override
this by inserting  `\indent` at the beginning of a paragraph that does
require a first-line indent even though it is after a list, quote or
code-block. 2) Other typographic traditions (*e.g.* French) indent all
paragraphs, even after headings, blockquotes, code blocks and lists.
The filter offers that option. (TO DO: and tries to make a sensible
guess based on language specification?) 3) the filter generates
default LaTeX / HTML outputs with first-line indent style. That
default behaviour can be deactivated in case the user prefers to
provide their own templates that handle first-line indent formatting.
The filter does this by inserting code in the document's metadata
`header-includes` field. It will still work if a document has its own
`header-includes` field, but not if a `header-includes` value is given
to Pandoc via the command line.

Other outputs (docx, ...) are not covered.

Usage
-----


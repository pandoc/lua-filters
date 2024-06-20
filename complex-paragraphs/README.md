# Compose complex paragraphs

## Definition

Complex paragraphs are paragraphs composed of different blocks:
normal text, quotations, tables,...

This concept makes sense only if you want to indent all paragraphs
by default, including paragraphs beginning after a quotation block
or a table, for instance. In that case, unindenting a text block means
that it is not to be seen as a new paragraph, but as a the
continuation of the previous text block that has been interrupted by
another block. If you want to prevent the indentation of all
paragraphs following certain types of blocks, please consider using
the [first-line-indent] filter instead.

[first-line-indent]: https://github.com/pandoc/lua-filters/tree/master/first-line-indent

## How to use this filter

To create a complex paragraph in your MD file, simply wrap its
components in a Div with class `.complex-paragraph`. Some
examples are given in `sample.md`.

## What it does

For the moment, it only prevents the indentation of text blocks
other than the first one. More features can be requested.

The Div itself is not removed from the AST, so that you can
pass it through other filters.

## Output formats

The following output formats are supported:

  * context
  * docx
  * latex

Other formats can be added. PRs are welcome. If you prefer to
submit an issue instead, please specify what code should be
used in the targeted format in order to achieve what this filter
does.

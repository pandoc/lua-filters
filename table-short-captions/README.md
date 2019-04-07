---
title: "table-short-captions.lua"
---

# Short captions in \LaTeX\ tables output

For LaTeX output, this filter enables use of the attribute
`short-caption` for tables. The attribute value will appear in the List
of Tables.

This filter also enables the class `.unlisted` for tables. This will
prevent the table caption from appearing in the List of Tables.

# Usage

In Pandoc Markdown, you can add a caption to a table with

    Table: This is the *italicised long caption* of my table, which has
    a very long caption.

If the document metadata includes `lot:true`, then the List of Tables
will be inserted at the beginning of the document.

The [pandoc-crossref](http://lierdakil.github.io/pandoc-crossref/)
filter extends this, and enables you to specify a custom label for the
table.

    Table: This is the *italicised long caption* of my table, which has
    a very long caption.  {#tbl:full-of-juicy-data}

This filter, when run _before_ pandoc-crossref, allows you to add short
captions to the table as a `short-caption` attribute. What is between
the quotes will be parsed as Markdown.

**Important!:** You _must_ use empty square brackets before the
attributes tag.

    Table: This is the *italicised long caption* of my table, which has
    a very long caption.
    []{#tbl:full-of-juicy-data short-caption="Short caption for *juicy* data table."}

Alternatively, if you wish to create a table which is unlisted in the
List of Tables, you can use the `.unlisted` class in the attributes tag.

    Table: This is the *italicised long caption* of my table, which will
    not appear in the List of Tables. []{#tbl:full-of-juicy-data .unlisted}

This filter should prove useful for students writing dissertations, who
often have to include a List of Tables in the front matter, but where
table captions themselves can be quite lengthy.

    pandoc --lua-filter=table-short-captions.lua \
           --filter pandoc-crossref \
           article.md -o article.tex

    pandoc --lua-filter=table-short-captions.lua \
           --filter pandoc-crossref \
           article.md -o article.pdf


# Limitations

- The filter will process the `short-caption` attribute value as pandoc
  markdown, regardless of the input format.
- pandoc-crossref should be run after it.
- I have only tested this from a Markdown source.

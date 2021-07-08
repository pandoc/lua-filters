---
title: "Sample first line indent"
# Filter options. These are defaults, you will get the same
# if you don't specify anything. See the README.md for details.
first-line-indent:
  set-metadata-variable: true
  set-header-includes: true
  auto-remove: true
  remove-after: Table
  dont-remove-after:
    - DefinitionList
    - OrderedList
  size: "2em"
# header-includes
header-includes:
- |
  ```{=latex}
  \usepackage{lipsum}
  ```
- |
  ```{=html}
  <style>p {color:blue;}</style>
  ```
---

This sample tests the filter on a document with a metadata header-includes of the MetaList type.

First paragraph. In English-style typography, the first paragraph shouldn't have a first-line indent, nor the paragraphs below headers.

This paragraph should start with a first-line indent. But after this quote:

> Lorem ipsum dolor sit amet, consectetur adipiscing elit.

the paragraph continues, so there should not be a first-line indent.

The quote below ends a paragraph:

> Lorem ipsum dolor sit amet, consectetur adipiscing elit.

\indent This paragraph, then, is genuinely a new paragraph and starts with
a first-line indent.

# Further tests

After a heading (in English typographic style) the paragraph does not have a first-line indent.

In the couple couple of paragraphs that follow the quotes below, we have manually specified `\noindent` and `\indent` respectively. This is to check that the filter doesn't add its own commands to those.

> Lorem ipsum dolor sit amet, consectetur adipiscing elit.

\noindent Manually specified no first line indent.

\indent Manually specified first line ident.

We can also check that indent is removed after lists:

* A bullet
* list

And after code blocks:

```lua
local variable = "value"
```

Or horizontal rules.

---

In this document we added a few custom filter options. The size of first-line
indents is 2em instead of the standard 1em. We also added an option to remove indent after tables:

  Right     Left     Center     Default
-------     ------ ----------   -------
     12     12        12            12
    123     123       123          123
      1     1          1             1

Table:  Demonstration of simple table syntax.

So this paragraph's first line is not indented. And we included custom options
*not* to remove ident after ordered lists and definition lists:

Definition
: This is a definition block.

This paragraph is indented.

1. An ordered
2. list

This paragraph is indented.

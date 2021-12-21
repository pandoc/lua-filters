# list-table

reStructuredText has so-called [list tables], which are not
only easy-to-write but also produce clean diffs since you
don't need to re-align all the whitespace when one cell width
changes. This filter lets you use RST-inspired list tables in
markdown. Any div with the first class `list-table` is
converted, for example the following Markdown:

```
:::list-table
   * - Heading row 1, column 1
     - Heading row 1, column 2
     - Heading row 1, column 3

   * - Row 1, column 1
     -
     - Row 1, column 3

   * - Row 2, column 1
     - Row 2, column 2
:::
```

results in the following table:

| Heading row 1, column 1 | Heading row 1, column 2 | Heading row 1, column 3 |
|-------------------------|-------------------------|-------------------------|
| Row 1, column 1         |                         | Row 1, column 3         |
| Row 2, column 1         | Row 2, column 2         |                         |

Three additional features are supported:

* If the div starts with a paragraph its content is used as the table caption.

* With the `align` attribute you can configure column alignment. When given
  the value must specify an alignment character (`d`, `l`, `r`, or `c` for
  default, left, right or center respectively) for each column. The characters
  must be separated by commas.

* With the `widths` attribute you can configure column widths via
  comma-separated numbers. The column widths will be relative to the numbers
  e.g. for `1,3` the second column will be three times as wide as the first.

For a demonstration of these features see [sample.md](sample.md).

[list tables]: https://docutils.sourceforge.io/docs/ref/rst/directives.html#list-table

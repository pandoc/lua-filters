# List tables for Pandoc

> **Warning**
>
> This filter is now maintained at
> <https://github.com/pandoc-ext/list-table>. The code here will
> no longer be updated.

This is the documentation for `list-table.lua`, a Lua filter
to bring [RST-style list tables] to Pandoc's Markdown.

List tables are not only easy-to-write but also produce clean
diffs since you don't need to re-align all the whitespace when
one cell width changes. This filter lets you use RST-inspired
list tables in markdown. Any div with the first class `list-table`
is converted, for example the following Markdown:

```
:::list-table
   * - row 1, column 1
     - row 1, column 2
     - row 1, column 3

   * - row 2, column 1
     -
     - row 2, column 3

   * - row 3, column 1
     - row 3, column 2
:::
```

results in the following table:

| row 1, column 1 | row 1, column 2 | row 1, column 3 |
|-----------------|-----------------|-----------------|
| row 2, column 1 |                 | row 2, column 3 |
| row 3, column 1 | row 3, column 2 |                 |

The filter also supports more advanced features,
as described in the following sections.

[RST-style list tables]: https://docutils.sourceforge.io/docs/ref/rst/directives.html#list-table

## Table captions

If the div starts with a paragraph its content is used as the table caption.
For example:

```markdown
:::list-table
   Markup languages

   * - Name
     - Initial release

   * - Markdown
     - 2004

   * - reStructuredText
     - 2002
:::
```

results in:

<!-- HTML because GFM does not support table captions -->
<table>
<caption>Markup languages</caption>
<thead>
<tr>
<th>Name</th>
<th>Initial release</th>
</tr>
</thead>
<tbody>
<tr>
<td>Markdown</td>
<td>2004</td>
</tr>
<tr>
<td>reStructuredText</td>
<td>2002</td>
</tr>
</tbody>
</table>

## Column alignments

With the `aligns` attribute you can configure column alignments. When given the
value must specify an alignment character (`d`, `l`, `r`, or `c` for default,
left, right or center respectively) for each column. The characters must be
separated by commas.

```
:::{.list-table aligns=l,c}
   * - Name
     - Initial release

   * - Markdown
     - 2004

   * - reStructuredText
     - 2002
:::
```

results in:

| Name             | Initial release |
|:-----------------|:---------------:|
| Markdown         |      2004       |
| reStructuredText |      2002       |

## Column widths

With the `widths` attribute you can configure column widths via
comma-separated numbers. The column widths will be relative to the numbers.
For example when we change the first line of the previous example to:

```
:::{.list-table widths=1,3}
```

the second column will be three times as wide as the first column.

<!-- no demo because GFM does not support inline CSS -->

## Header rows & columns

You can configure how many rows are part of the table head
with the `header-rows` attribute (which defaults to 1).

```
:::{.list-table header-rows=0}
   * - row 1, column 1
     - row 1, column 2

   * - row 2, column 1
     - row 2, column 2
:::
```

results in:

<table>
<tbody>
<tr>
<td>row 1, column 1</td>
<td>row 1, column 2</td>
</tr>
<tr>
<td>row 2, column 1</td>
<td>row 2, column 2</td>
</tr>
</tbody>
</table>

The same also works for `header-cols` (which however defaults to 0).
For example:

```
:::{.list-table header-cols=1}
   * - Name
     - Initial release

   * - Markdown
     - 2004

   * - reStructuredText
     - 2002
:::
```

results in:

<table>
<thead>
<tr>
<th>Name</th>
<th>Initial release</th>
</tr>
</thead>
<tbody>
<tr>
<th>Markdown</th>
<td>2004</td>
</tr>
<tr>
<th>reStructuredText</th>
<td>2002</td>
</tr>
</tbody>
</table>

## Cell attributes

If the first inline element of a table cell is an empty Span it
is removed and its attributes are transferred to the table cell.
The `colspan` and `rowspan` attributes are supported.

```
:::{.list-table}
   * - Name
     - Italic
     - Code

   * - Markdown
     - []{rowspan=2} `*italic*`
     - `` `code` ``

   * - reStructuredText
     - ` ``code`` `
:::
```

results in:

<table>
<thead>
<tr>
<th>Name</th>
<th>Italic</th>
<th>Code</th>
</tr>
</thead>
<tbody>
<tr>
<td>Markdown</td>
<td rowspan="2"> <code>*italic*</code></td>
<td><code>`code`</code></td>
</tr>
<tr>
<td><p>reStructuredText</p></td>
<td><p><code>``code``</code></p></td>
</tr>
</tbody>
</table>

Individual cell alignment is also supported via the `align` attribute.
Expected values are `l`, `r`, `c` for left, right and center respectively.
(Please mind that contrary to [column alignments](#column-alignments)
this attribute is singular).

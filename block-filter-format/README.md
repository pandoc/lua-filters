# block-filter-format

Filter to include/exclude blocks dependend on the output format.

Specifiying the attribute `include-if-format=<format1>;...;<formatN>`
includes file if the output format matches any format `<format1>` - `<formatN>`.

Specifiying the attribute `exclude-if-format=<format1>;...;<formatN>`
excludes file if the output format matches any format `<format1>` - `<formatN>`.

Multiple replacements are separated by a semicolon `;`.
Both attributes can be combined.

Currently the following blocks support attributes:

- `Meta`
- `Header`
- `Table`
- `Div`
- `Span`
- `CodeBlock`
- `Code`
- `Image`
- `Link`

Make sur ethe extensions are enabled such that attributes
on these blocks get parsed, when using this filter.


## Example

### Exclude

```{exclude-if-format=native;json}
echo "hello" || exit 1
```

### Include

```{include-if-format=native exclude-if-format=json}
ls -al || exit 1
```

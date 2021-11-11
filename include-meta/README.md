# include-meta

This filter adds the meta-data from one or more external YAML files to
the metadata of the document.

This allows defining frequently needed sets of meta-data in external
files and reusing them.

In contrast to the `--metadata-file` option of Pandoc, this filter
allows specifying the set(s) of meta-data in the actual document
header, which is more transparent than e.g. hiding them in a make
script.

## Specifying a YAML File to be included

Simply add the `include-meta` directive to the document header, like
so:

    ---
    title: My document author: Joe Doe include-meta: defaults.yaml
    ...

Multiple files can be specified by using a list:

    ---
    title: My document author: Joe Doe include-meta: 
      - defaults.yaml
      - moredefaults.yaml
    ...

## Priority Rules

The metadata from the external YAML files will be processed in the
order of (1) the statements in the document's YAML header block and
(2) the position of the file in the list.

   ---
    title: My document author: Joe Doe include-meta: 
      - first.yaml
      - second.yaml include-meta: third.yaml include-meta: 
      - fourth.yaml
      - fifth.yaml header-includes:
      - \setbeamertemplate{footline}[page number]
    ...

The **metadata in the YAML header of the document** is processed **at
the very end** (i.e. with the highest priority).

The metadata from all referenced YAML files and the YAML header in the
document **is combined as follows:**

- duplicates are ignored (but only if they are truly identical),
- `title` and `date` are replaced by the value in the source with the
  highest priority (the document or the last YAML file in the list),
- `header-includes` and `bibliography` values are joined
  into a combined list, and
- values from all other properties are taken from the source with the
  highest priority (e.g. set according to the YAML in the document).

**2021-11-11:** `author` entries are no longer joined into a combined list, because it turned out to be cumbersome to remove or modify an author name from defaults set in external files.

For instance, if you specify one bibliography in the the first YAML and
another one in the second, the final meta-data will be a list of
both. The order of the list will represent the order of the
processing (no sorting, see above).

**Note:** The merging rules and code are based on a [Github Issue
  discussion]
  (https://github.com/jgm/pandoc/issues/3115#issuecomment-294506221), but the code has been augmented to handle boolean values in YAML properly.

The exact relationship between metadata from the document and the sum
of the external YAML files is still evolving. I might add a mechanism
for specifying the priority of e.g. the document settings or even individual properties in the future. 

## Recursion and Nesting

The filter does not process `include-meta` directives in the included files, i.e. there is no support for nesting or recursion. This would make the resulting meta-data difficult to predict. 

If you need nested `include-meta` directives in the included files, you should be able to use Pandoc to generate intermediate Markdown files repeatedly for each level of nesting, like so (not tested):

```
pandoc source.md  --lua-filter=include-meta.lua -o temp.md --standalone 
pandoc temp.md  --lua-filter=include-meta.lua -o <final_file.extension>  
```

## Work in Progress

This filter is work in progress. Known limitations are as follows:

1. The joining of properties like `header-includes` and `bibliography` works only for the first two levels of YAML data structures. This should suffice for most cases but could cause problems if the merge mode "extendlist" is applied to additional properties. So there is no recursion in the merge process of two YAML trees.

2. At the moment, only relative or absolute paths can be used, but not such including environment variables, like `$MY_CONFIG/defaults.yaml`.

3. The combination of boolean values that default as true for RevealJS will require that the last statement uses `0` instead of `false`. For more information, [see here](https://pandoc.org/MANUAL.html#variables-for-html-slides).

4. The priority rules and details of merging is not guaranteed to match the behavior of specifying multiple files to Pandoc, like so:

`pandoc defaults.yaml defaults2.yaml sample-document.md -o <final_file.extension>`

This is because (1) the script uses its own code for the merge and (2) the support for individual priority rules.



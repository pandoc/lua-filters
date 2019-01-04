# GraphViz Pandoc filter
GraphViz Pandoc filter to process code blocks with class "graphviz" containing GraphViz notation into images.

* For textual output formats, use --extract-media=DIR
* For HTML formats, you may alternatively use --self-contained

## Example in markdown-file
```graphviz
digraph hierarchy {
a -> b
}
```
## Run pandoc
```
pandoc --self-contained --lua-filter=graphviz.lua readme.md -o output.htm
```

## Prerequisites
Install GraphViz


This script based on the example "Converting ABC code to music notation" from https://pandoc.org/lua-filters.html

This script was only tested with markdown to html on a Linux environment!

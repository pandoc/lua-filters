--[[
# Graphviz Pandoc filter
Graphviz Pandoc filter to process code blocks with class "graphviz" containing Graphviz notation into images.

* For textual output formats, use --extract-media=DIR
* For HTML formats, you may alternatively use --self-contained

## Example in markdown-file
```graphviz
digraph hierarchy {
    a -> b
    }
## Run pandoc
```
pandoc --self-contained --lua-filter=graphviz.lua readme.md -o output.htm
```

## Prerequisites
* install Graphviz

This script based on the example "Converting ABC code to music notation" from https://pandoc.org/lua-filters.html
**This script was only tested with markdown to html on a Linux environment!**
]]

-- SVG has a much better quality
-- local filetype = "png"
-- local mimetype = "image/png"
local filetype = "svg"
local mimetype = "image/svg+xml"

-- call Graphviz
local function make_img(code, filetype)
    local final = pandoc.pipe("dot", {"-T" .. filetype}, code)
    return final
end

-- search for class "graphviz" and replace with image
function CodeBlock(block)
    if block.classes[1] == "graphviz" then
        local img = make_img(block.text, filetype)
        local fname = pandoc.sha1(img) .. "." .. filetype
        pandoc.mediabag.insert(fname, mimetype, img)
        return pandoc.Para{ pandoc.Image({}, fname) }
    end
end

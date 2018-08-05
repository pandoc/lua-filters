--[[
# PlantUML Pandoc filter
PlantUML Pandoc filter to process code blocks with class "plantuml" containing PlantUML notation into images.

* For textual output formats, use --extract-media=DIR
* For HTML formats, you may alternatively use --self-contained

## Example in markdown-file
```plantuml
@startuml
Alice -> Bob: Authentication Request Bob --> Alice: Authentication Response
Alice -> Bob: Another authentication Request Alice <-- Bob: another authentication Response @enduml
```
## Run pandoc
```
pandoc --self-contained --lua-filter=plantuml.lua readme.md -o output.htm
```

## Prerequisites
* install PlantUML from http://plantuml.com (needs JAVA)
* change path to plantuml.jar in plantuml.lua

This script based on the example "Converting ABC code to music notation" from https://pandoc.org/lua-filters.html
**This script was only tested with markdown to html on a windows environment!**
]]

-- Path to PlantUML.jar
local plantumlPath = "c:\\tool\\WBENCH\\lib\\apps\\bench\\plantuml\\plantuml.jar"

-- SVG has a much better quality
-- local filetype = "png"
-- local mimetype = "image/png"
local filetype = "svg"
local mimetype = "image/svg+xml"

-- call plantuml.jar wit some parameters (see plantuml help)
local function plantuml(puml, filetype, plantumlPath)
    local final = pandoc.pipe("java", {"-jar", plantumlPath, "-t" .. filetype, "-pipe", "-charset", "UTF8"}, puml)
    return final
end

-- search for class "plantuml" and replace with image
function CodeBlock(block)
    if block.classes[1] == "plantuml" then
        local img = plantuml(block.text, filetype, plantumlPath)
        local fname = pandoc.sha1(img) .. "." .. filetype
        pandoc.mediabag.insert(fname, mimetype, img)
        return pandoc.Para{ pandoc.Image({pandoc.Str("PlantUML Diagramm")}, fname) }
    end
end
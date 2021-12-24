-- lua filter for RST-like list-tables in Markdown.
-- Copyright (C) 2021 Martin Fischer, released under MIT license

if PANDOC_VERSION and PANDOC_VERSION.must_be_at_least then
    PANDOC_VERSION:must_be_at_least("2.11")
else
    error("pandoc version >=2.11 is required")
end

local function get_colspecs(div_attributes, column_count)
    local aligns = {}
    local widths = {}

    if div_attributes.align then
        local alignments = {
            d = 'AlignDefault',
            l = 'AlignLeft',
            r = 'AlignRight',
            c = 'AlignCenter'
        }
        for a in div_attributes.align:gmatch('[^,]') do
            assert(alignments[a] ~= nil,
                   "unknown column alignment " .. tostring(a))
            table.insert(aligns, alignments[a])
        end
        div_attributes.align = nil
    else
        for i = 1, column_count do
            table.insert(aligns, pandoc.AlignDefault)
        end
    end

    if div_attributes.widths then
        local total = 0
        for w in div_attributes.widths:gmatch('[^,]') do
            table.insert(widths, tonumber(w))
            total = total + tonumber(w)
        end
        for i = 1, column_count do widths[i] = widths[i] / total end
        div_attributes.widths = nil
    else
        for i = 1, column_count do
            table.insert(widths, 0) -- let pandoc determine col widths
        end
    end

    return aligns, widths
end

local function process(div)
    if div.attr.classes[1] ~= "list-table" then return nil end
    table.remove(div.attr.classes, 1)

    local caption = {}

    if div.content[1].t == "Para" then
        caption = table.remove(div.content, 1).content
    end

    assert(div.content[1].t == "BulletList",
           "expected bullet list, found " .. div.content[1].t)
    local list = div.content[1]

    local rows = {}

    for i = 1, #list.content do
        assert(#list.content[i] == 1, "expected item to contain only one block")
        assert(list.content[i][1].t == "BulletList",
               "expected bullet list, found " .. list.content[i][1].t)
        table.insert(rows, list.content[i][1].content)
    end

    local headers = table.remove(rows, 1)
    local aligns, widths = get_colspecs(div.attr.attributes, #headers)

    local table = pandoc.utils.from_simple_table(
                pandoc.SimpleTable(caption, aligns, widths, headers, rows))
    table.attr = div.attr
    return {table}
end

return {{Div = process}}

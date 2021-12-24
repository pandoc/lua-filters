-- lua filter for RST-like list-tables in Markdown.
-- Copyright (C) 2021 Martin Fischer, released under MIT license

if PANDOC_VERSION and PANDOC_VERSION.must_be_at_least then
    PANDOC_VERSION:must_be_at_least("2.11")
else
    error("pandoc version >=2.11 is required")
end

local function get_colspecs(div_attributes, column_count)
    -- list of (align, width) pairs
    local colspecs = {}

    for i = 1, column_count do
        table.insert(colspecs, {pandoc.AlignDefault, nil})
    end

    if div_attributes.aligns then
        local alignments = {
            d = 'AlignDefault',
            l = 'AlignLeft',
            r = 'AlignRight',
            c = 'AlignCenter'
        }
        local i = 1
        for a in div_attributes.aligns:gmatch('[^,]') do
            assert(alignments[a] ~= nil,
                   "unknown column alignment " .. tostring(a))
            colspecs[i][1] = alignments[a]
            i = i + 1
        end
        div_attributes.aligns = nil
    end

    if div_attributes.widths then
        local total = 0
        local widths = {}
        for w in div_attributes.widths:gmatch('[^,]') do
            table.insert(widths, tonumber(w))
            total = total + tonumber(w)
        end
        for i = 1, column_count do
            colspecs[i][2] = widths[i] / total
        end
        div_attributes.widths = nil
    end

    return colspecs
end

local function new_table_head(rows)
    return {{}, rows}
end

local function  new_table_body(rows, header_col_count)
    return {
        attr = {},
        body = rows,
        head = {},
        row_head_columns = header_col_count
    }
end

local function new_row(cells)
    return {{}, cells}
end

local function new_cell(contents)
    return {
        attr = {},
        alignment = pandoc.AlignDefault,
        contents = contents,
        col_span = 1,
        row_span = 1
    }
end

local function process(div)
    if div.attr.classes[1] ~= "list-table" then return nil end
    table.remove(div.attr.classes, 1)

    local caption = {}

    if div.content[1].t == "Para" then
        local para = table.remove(div.content, 1)
        caption = {pandoc.Plain(para.content)}
    end

    assert(div.content[1].t == "BulletList",
           "expected bullet list, found " .. div.content[1].t)
    local list = div.content[1]

    local rows = {}

    for i = 1, #list.content do
        assert(#list.content[i] == 1, "expected item to contain only one block")
        assert(list.content[i][1].t == "BulletList",
               "expected bullet list, found " .. list.content[i][1].t)
        local cells = {}
        for _, cell_content in pairs(list.content[i][1].content) do
            table.insert(cells, new_cell(cell_content))
        end
        local row = new_row(cells)
        table.insert(rows, row)
    end

    local header_row_count = tonumber(div.attr.attributes['header-rows']) or 1
    div.attr.attributes['header-rows'] = nil

    local header_col_count = tonumber(div.attr.attributes['header-cols']) or 0
    div.attr.attributes['header-cols'] = nil

    local colspecs = get_colspecs(div.attr.attributes, #rows[1][2])
    local thead_rows = {}
    for i = 1, header_row_count do
        table.insert(thead_rows, table.remove(rows, 1))
    end

    local table_foot = {{}, {}};
    return pandoc.Table(
        {long = caption, short = {}},
        colspecs,
        new_table_head(thead_rows),
        {new_table_body(rows, header_col_count)},
        table_foot,
        div.attr
    )
end

return {{Div = process}}

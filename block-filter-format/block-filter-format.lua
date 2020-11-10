--- block-filter-format.lua – filter to filter blocks depending on the format
---
--- Copyright: © 2019–2020 Albert Krewinkel
--- License:   MIT – see LICENSE file for details
-- pandoc's List type
local List = require 'pandoc.List'

--- Get global setting if we keep attributes on the block.
--- Default: false
local keep_attrs = false
function get_vars(meta)
    if meta['block-filter-format-attrs'] then keep_attrs = true end
end

--- Include/exclude by attribute
--- `exclude-if-format='formatA;formatB;...'
--- `include-if-format='formatA;formatB;...`
--- Default: true
local function is_included(block, file)
    local include = true
    local exclude = false

    if block.attributes['include-if-format'] then
        include = block.attributes['include-if-format']:match(FORMAT) ~= nil
    end

    if block.attributes['exclude-if-format'] then
        exclude = block.attributes['exclude-if-format']:match(FORMAT) ~= nil
    end

    return include == true and exclude == false
end

--- Filter function for blocks
function filter_block(block)
    -- Filter by includes and excludes
    if is_included(block) then
        if not keep_attrs then
            block.attributes['include-if-format'] = nil
            block.attributes['exclude-if-format'] = nil
        end
        return block
    end
    return List {}
end

return {
    {Meta = get_vars},
    {Header = filter_block},
    {Table = filter_block},
    {Div = filter_block},
    {Span = filter_block},
    {CodeBlock = filter_block},
    {Code = filter_block},
    {Image = filter_block},
    {Link = filter_block},
}

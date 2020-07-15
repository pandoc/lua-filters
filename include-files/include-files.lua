--- include-files.lua – filter to include Markdown files
---
--- Copyright: © 2019–2020 Albert Krewinkel
--- License:   MIT – see LICENSE file for details

-- pandoc's List type
local List = require 'pandoc.List'

--- Shift headings in block list by given number
local function shift_headings(blocks, shift_by)
  if not shift_by then
    return blocks
  end

  local shift_headings_filter = {
    Header = function (header)
      header.level = header.level + shift_by
      return header
    end
  }

  return pandoc.walk_block(pandoc.Div(blocks), shift_headings_filter).content
end

--- Filter function for code blocks
local transclude
function transclude (cb)
  -- ignore code blocks which are not of class "include".
  if not cb.classes:includes 'include' then
    return
  end

  -- Markdown is used if this is nil.
  local format = cb.attributes['format']
  local shift_heading_level_by =
    tonumber(cb.attributes['shift-heading-level-by'])


  local blocks = List:new()
  for line in cb.text:gmatch('[^\n]+') do
    if line:sub(1,2) ~= '//' then
      local fh = io.open(line)
      local contents = pandoc.read(fh:read '*a', format).blocks
      -- recursive transclusion
      contents = pandoc.walk_block(
        pandoc.Div(contents),
        {CodeBlock = transclude}
      ).content
      blocks:extend(shift_headings(contents, shift_heading_level_by))
      fh:close()
    end
  end
  return blocks
end

return {
  {CodeBlock = transclude}
}

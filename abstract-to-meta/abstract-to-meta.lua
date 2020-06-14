--[[
abstract-to-meta – move an "abstract" section into document metadata

Copyright: © 2017–2020 Albert Krewinkel
License:   MIT – see LICENSE file for details
]]
local abstract = {}

--- Extract abstract from a list of blocks.
function abstract_from_blocklist (blocks)
  local body_blocks = {}
  local looking_at_abstract = false

  for _, block in ipairs(blocks) do
    if block.t == 'Header' and block.level == 1 then
      if block.identifier == 'abstract' then
        looking_at_abstract = true
      else
        looking_at_abstract = false
        body_blocks[#body_blocks + 1] = block
      end
    elseif looking_at_abstract then
      abstract[#abstract + 1] = block
    else
      body_blocks[#body_blocks + 1] = block
    end
  end

  return body_blocks
end

if PANDOC_VERSION >= {2,9,2} then
  -- Check all block lists with pandoc 2.9.2 or later
  return {{
      Blocks = abstract_from_blocklist,
      Meta = function (meta)
        if not meta.abstract and #abstract > 0 then
          meta.abstract = pandoc.MetaBlocks(abstract)
        end
        return meta
      end
  }}
else
  -- otherwise, just check the top-level block-list
  return {{
      Pandoc = function (doc)
        local meta = doc.meta
        local other_blocks = abstract_from_blocklist(doc.blocks)
        if not meta.abstract and #abstract > 0 then
          meta.abstract = pandoc.MetaBlocks(abstract)
        end
        return pandoc.Pandoc(other_blocks, meta)
      end,
  }}
end

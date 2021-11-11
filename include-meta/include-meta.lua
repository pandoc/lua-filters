--[[
include-meta - include YAML meta-data from file

Copyright: © 2021 Martin Hepp

Based on 
- abstract-to-meta, copyright: © 2017–2021 Albert Krewinkel
- include-files.lua, copyright: © 2019–2021 Albert Krewinkel
- Merge functions from
- https://github.com/jgm/pandoc/issues/3115#issuecomment-294506221

License:   MIT – see LICENSE file for details
]]

PANDOC_VERSION:must_be_at_least '2.12'

local List = require 'pandoc.List'
local utils = require 'pandoc.utils'
local stringify = utils.stringify

local function len(t)
  local count = 0
  for _ in pairs(t) do 
    count = count + 1 
  end
  return count
end

-- Merge functions taken from
-- https://github.com/jgm/pandoc/issues/3115#issuecomment-294506221
-- Sincere thanks to Albert Krewinkel, @tarleb for this
-- The original version does not handle boolean values properly for replace 
-- and keep methods. Fixed.

local merge_methods = {
  replace = function(v1, v2)
    if v2 == nil then 
      return v1 
    elseif v1 == nil then
      return v2
    else
      return v2 
    end
  end,
  keep = function(v1, v2) 
    if v2 == nil then 
      return v1 
    elseif v1 == nil then
      return v2
    else
      return v1 
    end
  end,
  extendlist = function(v1, v2)
    local res
    if type(v1) == "table" and v1.tag == "MetaList" then
      res = v1
    else
      res = pandoc.MetaList{v1}
    end
    if type(v2) == "table" and v2.tag == "MetaList" then
      for i = 1, #v2 do
        local found = false
        for j = 1, #res do
          if res[j] == v2[i] then
            found = true 
            break 
          end
        end
        if not found then
          res[#res + 1] = v2[i]
        end
      end
    else
      local found = false
      for j = 1, #res do
        if res[j] == v2 then
          found = true 
          break 
        end
      end
      if not found then
        res[#res + 1] = v2
      end
    end
    return res
  end
}

--- Merge second metadata table into the first.
function merge_metadata(md1, md2)
  for k, v in pairs(md2) do
    -- The default method is to replace the current value.
    if stringify(k) == 'header-includes' 
      or stringify(k) == 'bibliography' then
      method = "extendlist"
    elseif false then
      method = "keep"
    else
      method = "replace"
    end
    md1[k] = merge_methods[method](md1[k], md2[k])
  end
  return md1
end


function meta_expand (meta)
  local all_meta = pandoc.MetaList({})
  local yaml_includes = meta['include-meta']
  -- print(len(yaml_includes), "YAML meta file(s) to be included found.")
  if yaml_includes then
    for i, filename in pairs(yaml_includes) do
      yaml_file_path = stringify(filename)  
    --  print('Processing:', yaml_file_path)
      local yaml_fh = io.open(yaml_file_path, "r")
      if not yaml_fh then
        io.stderr:write("Cannot open file: ", yaml_file_path, " - Skipped.\n")
      else
        local doc_from_file = pandoc.read(yaml_fh:read '*a', format)
  --      print(stringify(doc_from_file))
        yaml_fh:close()
        all_meta = merge_metadata(all_meta, doc_from_file.meta)
      end
    end
    -- Remove the includes-meta directive after processing
    meta['include-meta'] = nil     
    return merge_metadata(all_meta, meta, merge_methods)
  else
    return
  end
end

return { {Meta = meta_expand} }

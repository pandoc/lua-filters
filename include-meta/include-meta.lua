--[[
include-meta - include YAML meta-data from file

Copyright: © 2021 Martin Hepp

Based on 
- abstract-to-meta, copyright: © 2017–2021 Albert Krewinkel
- include-files.lua, copyright: © 2019–2021 Albert Krewinkel

License:   MIT – see LICENSE file for details
]]

-- Module pandoc.path is required and was added in version 2.12
PANDOC_VERSION:must_be_at_least '2.12'

local List = require 'pandoc.List'
local utils = require 'pandoc.utils'
local stringify = utils.stringify
-- local path = require 'pandoc.path'
-- local system = require 'pandoc.system'


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
-- and keep. Fixed.

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
        res[#res + 1] = v2[i]
      end
    else
      res[#res + 1] = v2
    end
    return res
  end
}

--- Merge second metadata table into the first.
function merge_metadata(md1, md2, field_methods)
  for k, v in pairs(md2) do
    -- The default method is to replace the current value.
    local method = field_methods[k] or "replace"
    -- print(k, type(k), md1[k], md2[k])
    if stringify(k) == 'header-includes' then
      method = "extendlist"
    end
    md1[k] = merge_methods[method](md1[k], md2[k])
  end
  return md1
end

-- Default priority rules
-- So far no quick solution for 'header-includes' in LUA
local field_methods = {
    testproperty = "extendlist",
    author = "extendlist",
    title = "replace",
    date = "replace",
    classoptions = "keep"
  }


function meta_expand (meta)
  local all_meta = pandoc.MetaList({})
  local yaml_includes = meta['include-meta']
  print(len(yaml_includes), "YAML meta file(s) to be included found.")
  for i, filename in pairs(yaml_includes) do
    yaml_file_path = stringify(filename)  
    print('Processing:', yaml_file_path)
    local yaml_fh = io.open(yaml_file_path, "r")
    if not yaml_fh then
      io.stderr:write("Cannot open file: ", yaml_file_path, " - Skipped.\n")
    else
      local doc_from_file = pandoc.read(yaml_fh:read '*a', format)
--      print(stringify(doc_from_file))
--      table.insert(all_meta, doc_from_file.meta)
      yaml_fh:close()
      all_meta = merge_metadata(all_meta, doc_from_file.meta, field_methods)
    end
  end
  -- Remove the includes-meta directive after processing
  meta['include-meta'] = nil     
  -- TBD: check wrt priority rules
  return merge_metadata(all_meta, meta, merge_methods)
end

return { {Meta = meta_expand} }

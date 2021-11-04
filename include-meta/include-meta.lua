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
local path = require 'pandoc.path'
local system = require 'pandoc.system'

local function include_meta(meta) 
  local yaml_includes = meta['include-meta']
  local new_meta = meta
  -- how many include statements?
  if #yaml_includes > 1 then
    for include_directive in yaml_includes
      if #include_directive > 1 then
        -- list of files to be included
      elseif #include_directive == 1 then
        -- include meta-data from this file
        

  if yaml_files and #yaml_files > 1 then
    -- process each include
    return new_meta
  elseif yaml_files and #yaml_files == 1 then
    -- process single include
    return new_meta
  else
    return nil
  end
end

return {{

      Meta = include_meta (meta)
  }}

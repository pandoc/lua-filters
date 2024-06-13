--- codeblock-var-replace.lua – replace variables in code blocks
---
--- Copyright: © 2019–2020 Gabriel Nützi
--- License:   MIT – see LICENSE file for details

local sys = require 'pandoc.system'
local utils = require 'pandoc.utils'

-- Save env. variables
local env = sys.environment()

-- Save meta table and metadata
local meta
function save_meta (m)
  meta = m
end

--- Replace variable with values from environment
--- and meta data (stringifing).
local function replace(what, var)
  if what == "env" then
    return env[var]
  elseif what == "meta" then
    local v = meta[var]
    if v then
      return utils.stringify(v)
    end
  end
  return nil
end

--- Replace variables in code blocks
function var_replace_codeblocks (cb)
  -- ignore code blocks which are not of class "var-replace".
  if not cb.classes:includes 'var-replace' then
    return
  end

  cb.text = cb.text:gsub("%${(%l+):([^}]+)}", replace)
  return cb
end

return {
  { Meta = save_meta },
  { CodeBlock = var_replace_codeblocks }
}

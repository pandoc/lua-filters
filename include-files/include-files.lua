--- include-files.lua – filter to include Markdown files
---
--- Copyright: © 2019–2021 Albert Krewinkel
--- License:   MIT – see LICENSE file for details

-- Module pandoc.path is required and was added in version 2.12
PANDOC_VERSION:must_be_at_least '2.12'

local List = require 'pandoc.List'
local path = require 'pandoc.path'
local system = require 'pandoc.system'
local cs = PANDOC_STATE

-- This is the codeblock-var-replace
-- filter directly copied, since we
-- cannot run Lua filters inside this filter
-- https://github.com/jgm/pandoc/issues/6830
-- We replace variables in include blocks.

local sys = require 'pandoc.system'
local utils = require 'pandoc.utils'
-- local ut = require "module-lua.utils"

-- Save env. variables
local env = sys.environment()

-- Save meta table and metadata
local meta
function save_meta (m)
  meta = m
end

--- Replace variables in code blocks
local metaMap
local function var_replace_codeblocks (cb)
  --- Replace variable with values from environment
  --- and meta data (stringifing).
  local function replace(what, var)
    local repl = nil
    if what == "env" then
      repl = env[var]
    elseif what == "meta" then
      local v = metaMap[var]
      if v then
        repl = utils.stringify(v)
      end
    end

    if repl == nil then
      io.stderr:write("Could not replace variable in codeblock: '".. var .."'\n")
    end

    return repl
  end

  -- ignore code blocks which are not of class "var-replace".
  if not cb.classes:includes 'var-replace' then
    return
  end

  cb.text = cb.text:gsub("%${(%l+):([^}]+)}", replace)
end

--- Include/exclude by attribute
--- `exclude-if-format='formatA;formatB;...'
--- `include-if-format='formatA;formatB;...`
--- Default: true
local function is_included(cb)
  local include = true
  local exclude = false

  if cb.attributes['include-if-format'] then
    include = cb.attributes['include-if-format']:match(FORMAT) ~= nil
  end

  if cb.attributes['exclude-if-format'] then
    exclude = cb.attributes['exclude-if-format']:match(FORMAT) ~= nil
  end

  return include == true and exclude == false
end

--- Get default settings
local include_auto = false
local default_format = nil
local include_fail_if_read_error = false

function get_vars (meta)
  if meta['include-auto'] then
    include_auto = true
  end

  if meta['include-fail-if-read-error'] then
    include_fail_if_read_error = true
  end

  -- If this is nil, markdown is used as a default format.
  default_format = meta['include-format']

  -- Save meta table for var_replace
  metaMap = meta
end


--- Keep last heading level found
local last_heading_level = 0
function update_last_level(header)
  last_heading_level = header.level
end

--- Update contents of included file
local function update_contents(blocks, shift_by, include_path)
  local update_contents_filter = {
    -- Shift headings in block list by given number
    Header = function (header)
      if shift_by then
        header.level = header.level + shift_by
      end
      return header
    end,
    -- If image paths are relative then prepend include file path
    Image = function (image)
      if path.is_relative(image.src) then
        image.src = path.normalize(path.join({include_path, image.src}))
      end
      return image
    end,
    -- Update path for include-code-files.lua filter style CodeBlocks
    CodeBlock = function (cb)
      if cb.attributes.include and path.is_relative(cb.attributes.include) then
        cb.attributes.include =
          path.normalize(path.join({include_path, cb.attributes.include}))
        end
      return cb
    end
  }

  return pandoc.walk_block(pandoc.Div(blocks), update_contents_filter).content
end

--- Filter function for code blocks
local transclude
function transclude (cb)
  -- ignore code blocks which are not of class "include".
  if not cb.classes:includes 'include' then
    return
  end

  -- Filter by includes and excludes
  if not is_included(cb) then
    return List{} -- remove block
  end

  -- Variable substitution
  var_replace_codeblocks(cb)

  local format = cb.attributes['format']
  if not format then
    -- Markdown is used if this is nil.
    format = default_format
  end

  -- Check if we include the file as raw inline
  local raw = cb.attributes['raw']
  raw = raw == "true"

  -- Attributes shift headings
  local shift_heading_level_by = 0
  local shift_input = cb.attributes['shift-heading-level-by']
  if shift_input then
    shift_heading_level_by = tonumber(shift_input)
  else
    if include_auto then
      -- Auto shift headings
      shift_heading_level_by = last_heading_level
    end
  end

  --- Keep track of level before recursion
  local buffer_last_heading_level = last_heading_level

  local blocks = List:new()
  for line in cb.text:gmatch('[^\n]+') do
    if line:sub(1,2) == '//' then
      goto skip_to_next
    end

    if cs.verbosity == "INFO" then
      io.stderr:write(string.format("Including: [format: %s, raw: %s]\n - '%s'\n",
                      format,
                      tostring(raw), line))
    end

    local fh = io.open(line)
    if not fh then
      local cwd = system.get_working_directory()
      local msg = "Cannot find include file: '" .. line .. "' in working dir: '" .. cwd .. "'"
      if include_fail_if_read_error then
        io.stderr:write(msg .. " | error\n")
        error("Abort due to include failure")
      else
        io.stderr:write(msg .. " | skipping include\n")
        goto skip_to_next
      end
    end

    -- Read the file
    local text = fh:read('*a')
    fh:close()

    if raw then
      -- Include as raw inline element
      blocks:extend({pandoc.RawBlock(format, text)})
    else
      -- Inlcude as parsed AST
      local contents = pandoc.read(text, format).blocks
      last_heading_level = 0
      -- Recursive transclusion
      contents = system.with_working_directory(
          path.directory(line),
          function ()
            return pandoc.walk_block(
          pandoc.Div(contents),
          { Header = update_last_level, CodeBlock = transclude }
            )
          end).content
        --- Reset to level before recursion
        last_heading_level = buffer_last_heading_level
      blocks:extend(update_contents(contents, shift_heading_level_by,
                                    path.directory(line)))
    end

    ::skip_to_next::
  end

  return blocks
end

return {
  { Meta = get_vars },
  { Header = update_last_level, CodeBlock = transclude }
}

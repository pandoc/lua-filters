--[[
LaTeXTableShortCapts – enable .unlisted and short-caption="" properties on conversion to LaTeX

Copyright (c) 2019 Blake Riley

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
]]
local List = require 'pandoc.List'

-- don't do anything unless we target latex
if FORMAT ~= "latex" then
  return {}
end

--- Code for injection into the LaTeX header, to overwrite a macro in longtable captions.
longtable_caption_mod = [[
% -- begin:latex-table-short-captions --
\makeatletter\AtBeginDocument{%
\def\LT@c@ption#1[#2]#3{%                 % Overwrite the workhorse macro used in formatting a longtable caption.
  \LT@makecaption#1\fnum@table{#3}%
  \ifdefined\pandoctableshortcapt         % If pandoctableshortcapt is defined (even if blank), we should override default behaviour.
     \let\@tempa\pandoctableshortcapt%    % (Use let, we don't want to expand pandoctableshortcapt!)
  \else                                   % If not, fall back to default behaviour
     \def\@tempa{#2}%                     % (Use the argument in square brackets)
  \fi
  \ifx\@tempa\@empty\else                 % If @tempa is blank, no lot entry! Otherwise, @tempa becomes the lot title.
     {\let\\\space
     \addcontentsline{lot}{table}{\protect\numberline{\thetable}{\@tempa}}}%
  \fi}
}\makeatother
% -- end:latex-table-short-captions --
]]

--- Creates an (inclusive) slice of a table
-- @param tbl: The table to be sliced
-- @param first: The starting index
-- @param last: The ending index (inclusive)
-- @return (table): The sliced table
function table.slice(tbl, first, last)
  local sliced = {}
  for i = first or 1, last or #tbl do
    sliced[#sliced+1] = tbl[i]
  end
  return sliced
end

--- Creates a def shortcaption block to be placed before the table
-- @param sc: nil or a List of RawInlines
-- @return (Plain): The def shortcaption block
local function defshortcapt(sc)
  local scblock = List:new{}
  scblock:extend {pandoc.RawInline('tex', "\\def\\pandoctableshortcapt{")}
  if sc then
    scblock:extend (sc)
  end
  scblock:extend {pandoc.RawInline('tex', "}")}
  if not sc then
    scblock:extend {pandoc.RawInline('tex', "  % .unlisted")}
  end
  return pandoc.Plain(scblock)
end

--- The undef shortcaption block to be placed after the table
local undefshortcapt = pandoc.RawBlock('tex', "\\undef\\pandoctableshortcapt")

--- Search through a messy list of pandoc-parsed Inlines into what we need to build short-caption
-- @param (List of Inlines): A mess of Inlines containing the table properties
-- @return[1] (nil or string): The first word starting with "#tbl:"
-- @return[2] (nil or List of Inlines): The "short-caption" property if present, as a List of Inlines.
-- @return[3] (bool): Whether ".unlisted" appeared in the properties
function parse_table_properties(props)
  -- Flatten the string, because this will make our job much easier (except for short-caption hunting)
  local flatprops = pandoc.utils.stringify(props)

  -- Find label
  local label = flatprops:match("(#tbl:%g-)%s")

  -- Find classes, particularly look for ".unlisted"
  local unlisted = false
  classes = flatprops:gmatch("(%.[%w%-]-)[%s}]")
  for c in classes do
    if c == ".unlisted" then
      unlisted = true
    end
  end

  -- If not unlisted, then find the index of the property short-caption.
  -- This does not attempt to parse all table properties, we ignore them.
  local short_caption = nil
  if not unlisted then
    -- Try to find that index
    local has_short_caption = function(inl)
      return inl.text and (inl.text:match("short%-caption=\"?"))
    end
    local _, idx_sc = props:find_if(has_short_caption)

    -- We're really interested in the next Inline.
    -- If the next Inline exists, and is a "Quoted" type, this is our short caption, otherwise ignore it.
    if idx_sc and props[idx_sc+1] then
      maybe_sc = props[idx_sc+1]
      if maybe_sc.t == "Quoted" then
        short_caption = maybe_sc.content
      end
    end
  end

  return label, short_caption, unlisted
end

--- Wraps a table with shortcaption code
-- @param tbl (Table): The table with {}-wrapped properties in the caption
-- @return (List of Blocks): The table with {label} in the caption, optionally wrapped in shortcaption code
function rewrite_longtable_caption(tbl)
  -- Escape if there is no caption present.
  if not tbl.caption then
    return nil
  end

  -- Try split the caption into (caption, properties)
  local has_start_bracket = function (inl)
    return inl.text and (inl.text:sub(1, 1) == "{")
  end
  local has_end_bracket = function (inl)
    return inl.text and (inl.text:sub(#inl.text, -1) == "}")
  end

  local _b, idx_left = tbl.caption:find_if(has_start_bracket)
  local _e, idx_right = tbl.caption:find_if(has_end_bracket)

  -- If we couldn't find brackets, escape.
  if not (_b and _e) then
    return nil
  end

  -- Otherwise, bisect the caption
  local long_caption = table.slice(tbl.caption, 1, idx_left-1)
  local props        = table.slice(tbl.caption, idx_left, idx_right)

  -- Tidy up long_caption
  if long_caption[#long_caption] == pandoc.Space() then
    table.remove(long_caption)
  end

  -- Parse it all
  long_caption = List:new(long_caption)
  props = List:new(props)
  local label, short_caption, unlisted = parse_table_properties(props)

  -- Put label back into caption for pandoc-crossref
  
  if label then
    long_caption:extend {pandoc.Space(), pandoc.Str("{"..label.."}")}
  end

  -- Place new table
  local result = List:new{}
  if short_caption or unlisted then
    result:extend {defshortcapt(short_caption)}
  end
  result:extend {pandoc.Table(long_caption, tbl.aligns, tbl.widths, tbl.headers, tbl.rows)}
  if short_caption or unlisted then
    result:extend {undefshortcapt}
  end
  return result
end

--- Inserts longtable_caption_mod into the header_includes
-- @param meta (Meta): The document metadata
-- @return (Meta): The document metadata, with latex function inserted in header_includes
function add_longtable_caption_mod(meta)
  local header_includes
  if meta['header-includes'] and meta['header-includes'].t == 'MetaList' then
    header_includes = meta['header-includes']
  else
    header_includes = pandoc.MetaList{meta['header-includes']}
  end
  header_includes[#header_includes + 1] =
    pandoc.MetaBlocks{pandoc.RawBlock('tex', longtable_caption_mod)}
  meta['header-includes'] = header_includes
  return meta
end

return {
  {
    Meta = add_longtable_caption_mod,
    Table = rewrite_longtable_caption,
  }
}

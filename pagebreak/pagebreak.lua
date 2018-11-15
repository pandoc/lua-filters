--[[
pagebreak – convert raw LaTeX page breaks to other formats

Copyright © 2018 Albert Krewinkel

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]
--- Return a block element causing a page break in the given format.
local function newpage(format)
  if format == 'docx' then
    local pagebreak = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
    return pandoc.RawBlock('openxml', pagebreak)
  elseif format:match 'latex' then
    return pandoc.RawBlock('tex', '\\newpage{}')
  elseif format:match 'html.*' then
    local pagebreak = '<div style="style="page-break-after: always;"></div>'
    return pandoc.RawBlock('html', pagebreak)
  elseif format:match 'epub' then
    local pagebreak = '<p style="page-break-after: always;"> </p>'
    return pandoc.RawBlock('html', pagebreak)
  else
    -- fall back to insert a form feed character
    return pandoc.Para{pandoc.Str '\f'}
  end
end

local function is_newpage_command(command)
  return command:match '^\\newpage%{?%}?$'
end

-- Filter function called on each RawBlock element.
function RawBlock (el)
  -- check that the block is TeX or LaTeX and contains only
  -- \newpage or \newpage{}
  if el.format:match 'tex' and is_newpage_command(el.text) then
    -- use format-specific pagebreak marker. FORMAT is set by pandoc to
    -- the targeted output format.
    return newpage(FORMAT)
  end
  -- otherwise, leave the block unchanged
  return nil
end

-- Turning paragraphs which contain nothing but a form feed
-- characters into line breaks.
function Para (el)
  if #el.content == 1 and el.content[1].text == '\f' then
    return newpage(FORMAT)
  end
end

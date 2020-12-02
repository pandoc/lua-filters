--[[
pandocVlna.lua - Filter to automatically insert non-breakable spaces in specific
locations in text.

Currently supports czech and english languages, with default being set to
english. PRs or suggestions leading to improvement of current features or
to add supported for other languages is highly welcome.
Inspired by simillar tools in TeX toolchain: `luavlna` and `vlna`.

Author: Tomas Krulis (with substantial help from Albert Krewinkel)
License: MIT - more details in LICENSE file in repository root directory
--]]

local utils = require 'pandoc.utils'
local stringify = utils.stringify

--[[
Table of one-letter prefixes, after which should be inserted '\160'.
Verbose, but can be changed per user requirements.
--]]

local prefixes = {}

local prefixesEN = {
  ['I'] = true,
  ['a'] = true,
  ['A'] = true,
  ['the'] = true,
  ['The'] = true
}

local prefixesCZ = {
  ['a'] = true,
  ['i'] = true,
  ['k'] = true,
  ['o'] = true,
  ['s'] = true,
  ['u'] = true,
  ['v'] = true,
  ['z'] = true,
  ['A'] = true,
  ['I'] = true,
  ['K'] = true,
  ['O'] = true,
  ['S'] = true,
  ['U'] = true,
  ['V'] = true,
  ['Z'] = true
}

-- Set `prefixes` according to `lang` metadata value
function Meta(meta)
  if meta.lang then
    langSet = stringify(meta.lang)

    if langSet == 'cs' then
      prefixes = prefixesCZ
    else
      prefixes = prefixesEN --default to english prefixes
    end

  else
    prefixes = prefixesEN --default to english prefixes
  end

end

--[[
Some languages (czech among them) require nonbreakable space *before* long dash
--]]

local dashes = {
  ['--'] = true,
  ['–'] = true
}

--[[
Table of replacement elements
--]]

local nonbreakablespaces = {
  html = '&nbsp;',
  latex = '~',
  context = '~'
}

--[[
Function to determine Space element replacement for non-breakable space
according to output format
--]]

function insert_nonbreakable_space(format)
  if format == 'html' then
    return pandoc.RawInline('html', nonbreakablespaces.html)
  elseif format:match 'latex' then
    return pandoc.RawInline('tex',nonbreakablespaces.latex)
  elseif format:match 'context' then
    return pandoc.RawInline('tex',nonbreakablespaces.latex)
  else
    -- fallback to inserting non-breakable space unicode symbol
    -- pandoc.Str '\xc2\xa0' -- also works
    return pandoc.Str '\u{a0}'
  end
end

--[[
Core filter function:

* It iterates over all inline elements in block
* If it finds Space element, uses previously defined functions to find
`prefixes` or `dashes`
* Replaces Space element with `Str '\u{a0}'`, which is non-breakable space
representation
* Returns modified list of inlines
--]]

function Inlines (inlines)

  -- variable holding replacement value for the non-breakable space
  local nbsp = insert_nonbreakable_space(FORMAT)

  for i = 2, #inlines do -- test from second position, to prevent error if
    -- `Space` element would be first in `Inlines` block

    --assign elements to variables for more readability
    local currentEl = inlines[i]
    local previousEl = inlines[i-1]
    local nextEl = inlines[i+1]

    if currentEl.t == 'Space'
      or currentEl.t == 'SoftBreak' then

      -- Check for one-letter prefixes in Str before Space

      if previousEl.t == 'Str' and prefixes[previousEl.text] then
        -- if elements in table (`prefixes`) are mapped to bolean values,
        -- it is possible to test like `prefixes[argument]` instead of
        -- `if prefixes[argument] == true`
        inlines[i] = nbsp
      end

      -- Check for dashes in Str after Space

      if nextEl.t == 'Str' and dashes[nextEl.text] then
        inlines[i] = nbsp
      end

      -- Check for digit `Str` elements. Those elements might not be fully
      -- parsed (in case there were other filters executed before this one),
      -- so following regex checks for any characters or whitespace wrapping
      -- around `Str` element containing digits

      if nextEl.t == 'Str' and string.match(nextEl.text, '%.*%s*%d+%s*%.*') then
        inlines[i] = nbsp
      end

    end

    --[[
    Check for Str containing sequence " prefix ", which might occur in case of
    preceding filter creates it inside Str element.
    --]]

    if currentEl.t == 'Str' then
      for prefix, _ in pairs(prefixes) do
        if string.match(currentEl.text, '%.*%s+' .. prefix .. '%s+%.*') then
          front, detection, replacement, back = string.match(currentEl.text,
	            '(%.*)(%s+' .. prefix .. ')(%s+)(%.*)')

          inlines[i].text = front .. detection .. nbsp .. back
        end
      end
    end

  end
  return inlines
end

-- This should change the order of running functions: Meta - Inlines - rest ...
return {
  {Meta = Meta},
  {Inlines = Inlines},
}

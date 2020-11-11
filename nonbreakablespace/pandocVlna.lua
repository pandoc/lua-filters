local utils = require 'pandoc.utils'
local stringify = utils.stringify

--[[
Indexed table of one-letter prefixes, after which should be inserted '\160'.
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

  return prefixes
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
--according to output format
--]]

function insert_nonbreakable_space(format)
  if format == 'html' then
    return pandoc.RawInline('html', nonbreakablespaces.html)
  elseif format:match 'latex' then
    return pandoc.RawInline('tex',nonbreakablespaces.latex)
  elseif format:match 'context' then
    return pandoc.RawInline('tex',nonbreakablespaces.latex)
  else
    --fallback to inserting non-breakable space unicode symbol
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

  --variable holding replacement value for the non-breakable space
  local insert = insert_nonbreakable_space(FORMAT)

  for i = 2, #inlines do

    --assign elements to variables for simpler code writing
    local currentEl = inlines[i]
    local previousEl = inlines[i-1]
    local nextEl = inlines[i+1]

    if currentEl.t == 'Space'
      or currentEl.t == 'SoftBreak' then

      -- Check for one-letter prefixes in Str before Space

      if previousEl.t == 'Str' then
        if prefixes[previousEl.text]== true then
--        inlines[i] = pandoc.Str '\xc2\xa0' -- Both work
          inlines[i] = insert
        end
      end

      -- Check for dashes in Str after Space

      if nextEl.t == 'Str' then
        if dashes[nextEl.text] == true then
          inlines[i] = insert
        end
      end

      -- Check for not fully parsed Str elements - Those might be products of
      -- other filters, that were executed before this one

      if nextEl.t == 'Str' then
        if string.match(nextEl.text, '%.*%s*[„]?%d+[“]?%s*%.*') then
          inlines[i] = insert
        end
      end

    end

    --[[
    Check for Str containing sequence " prefix ", which might occur in case of
    preceding filter creates it in one Str element. Also check, if quotation
    mark is present introduced by "quotation.lua" filter
    --]]

    if currentEl.t == 'Str' then
      for index, prefix in ipairs(prefixes) do
        if string.match(currentEl.text, '%.*%s+[„]?' .. prefix .. '[“]?%s+%.*') then
              front, detection, replacement, back = string.match(currentEl.text,
	            '(%.*)(%s+[„]?' .. prefix .. '[“]?)(%s+)(%.*)')

              inlines[i].text = front .. detection .. insert .. back
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

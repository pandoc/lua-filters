--[[
Indexed table of one-letter prefixes, after which should be inserted '\160'.
Verbose, but can be changed per user requirements.
--]]

local prefixes = {
  'a',
  'i',
  'k',
  'o',
  's',
  'u',
  'v',
  'z',
  'A',
  'I',
  'K',
  'O',
  'S',
  'U',
  'V',
  'Z'
}

--[[
Some languages (czech among them) require nonbreakable space *before* long dash
--]]

local dashes = {
  '--',
  '–'
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
Function responsible for searching for one-letter prefixes, after which is
inserted non-breakable space. Function is short-circuited, that means:

* If it finds match with `prefix` in `prefixes` table, then it returns `true`.
* Otherwise, after the iteration is finished, returns `false` (prefix wasnt
found).
--]]

function find_one_letter_prefix(my_string)
  for index, prefix in ipairs(prefixes) do
    if my_string == prefix then
      return true
      end
  end
  return false
end

--[[
Function responsible for searching for dashes, before whose is inserted
non-breakable space. Function is short-circuited, that means:

* If it finds match with `dash` in `dashes` table, then it returns `true`.
* Otherwise, after the iteration is finished, returns `false` (dash wasnt
found).
--]]

function find_dashes(my_dash)
  for index, dash in ipairs(dashes) do
    if my_dash == dash then
      return true
      end
  end
  return false
end

--[[
Function to determine Space element replacement for non-breakable space according to output format
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

  for i = 1, #inlines do
    if inlines[i].t == 'Space' then

      -- Check for one-letter prefixes in Str before Space

      if inlines[i - 1].t == 'Str' then
          local one_letter_prefix = find_one_letter_prefix(inlines[i - 1].text)
            if one_letter_prefix == true then
--            inlines[i] = pandoc.Str '\xc2\xa0' -- Both work
          inlines[i] = insert
        end
        end

      -- Check for dashes in Str after Space

        if inlines[i + 1].t == 'Str' then
          local dash = find_dashes(inlines[i + 1].text)
            if dash == true then
              inlines[i] = insert
            end
        end

        -- Check for not fully parsed Str elements - Those might be products of
        -- other filters, that were executed before this one

        if inlines[i + 1].t == 'Str' then
          if string.match(inlines[i + 1].text, '%.*%s*[„]?%d+[“]?%s*%.*') then
              inlines[i] = insert
            end
        end

    end

      --[[
      Check for Str containing sequence " prefix ", which might occur in case of
      preceding filter creates it in one Str element. Also check, if quotation
      mark is present introduced by "quotation.lua" filter
      --]]

      if inlines[i].t == 'Str' then
        for index, prefix in ipairs(prefixes) do
          if string.match(inlines[i].text, '%.*%s+[„]?' .. prefix .. '[“]?%s+%.*') then
              front, detection, replacement, back = string.match(inlines[i].c, '(%.*)(%s+[„]?' .. prefix .. '[“]?)(%s+)(%.*)')
              inlines[i].text = front .. detection .. insert .. back
            end
        end
      end

  end
  return inlines
end
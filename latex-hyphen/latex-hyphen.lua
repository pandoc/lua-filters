--- Replace intra-word hyphens with LaTeX shorthand "= for better hyphenation.
--
-- PURPOSE
--
-- The regular hyphen - prevents LaTeX from breaking a word at any other
-- position than the explicit hyphen. With long, hyphenated words as they occur
-- in languages like German, this can lead to undesirable visual results. The
-- expression "= outputs a normal hyphen while still allowing LaTeX to break
-- the word at any other position according to its regular hyphenation rules.
--
-- USAGE
--
-- For this to work, babel shorthands have to be activated. With XeLaTeX or
-- LuaTeX as PDF engine, this can be done using the YAML frontmatter:

-- polyglossia-lang:
--     name: german
--     options:
--         - spelling=new,babelshorthands=true
--
-- For pdflatex, a custom template has to be used, as the built-in template
-- explicitly deactivates babel’s shorthands.
--
-- The filter can then be called like this:
--
-- pandoc -o doc.pdf --pdf-engine xelatex --lua-filter latex-hyphen.lua doc.md
--
-- AUTHOR
--
-- Copyright 2020 Frederik Elwert <frederik.elwert@rub.de>
--
-- LICENSE
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.


if FORMAT ~= 'latex' then
  return {}
end

function split_hyphen(inputstr)
  local sep = '-'
  local t = {}
  for str in string.gmatch(inputstr, '([^'..sep..']+)') do
    table.insert(t, str)
  end
  return t
end

function Str(elem)
  local parts = split_hyphen(elem.c)
  -- if not more than one part, string contains no hyphen, return unchanged.
  if #parts <= 1 then
    return nil
  end
  -- otherwise, splice raw latex "= between parts
  local o = {}
  for index, part in ipairs(parts) do
    table.insert(o, pandoc.Str(part))
    if index < #parts then
      table.insert(o, pandoc.RawInline('latex', '"='))
    end
  end
  return o
end

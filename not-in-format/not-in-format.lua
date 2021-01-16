--- not-in-format - keep document parts out of selected output formats.
--
-- This Lua filter for Pandoc that keeps parts of a document out of
-- selected outputs formats.
--
-- v1.0
--
-- @author Julien Dutant <julien.dutant@kcl.ac.uk>
-- @copyright 2021 Julien Dutant
-- @license MIT - see LICENSE file for details.
--

--- Test whether the target format is in a given list
-- @param formats list of formats to be matched
-- @return true if match, false otherwise
local function format_matches(formats)
  for _,format in pairs(formats) do
    if FORMAT:match(format) then
      return true
    end
  end
  return false
end

--- Main Div filter
-- Removes Divs tagged with `not-in-format` if the
-- output format matches one of the Div's attributes
function Div(element)
  if element.classes:includes('not-in-format') and
    format_matches(element.classes) then
      return {}
    else
      return element
    end
end

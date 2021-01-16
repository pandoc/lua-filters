--- # not-in-format - keep document parts out of selected output formats.
--
-- This Lua filter for Pandoc that keeps parts of a document out of
-- selected outputs formats.
--
-- @author Julien Dutant <julien.dutant@kcl.ac.uk>, Albert Krewinkel
-- @copyright 2021 Julien Dutant, Albert Krewinkel
-- @license MIT - see LICENSE file for details.
-- @release 1.0

--- Main Div filter.
-- Removes Divs tagged with `not-in-format` if the
-- output format matches one of the Div's attributes
-- @param element a Div element
-- @return an empty block if the Div classes include `not-in-format`
-- and the target format
function Div(element)

  -- the find_if method returns the first value x in the list
  -- element.classes for which FORMAT:match(x) evaluates as true,
  -- and nil otherwise. Within the if clause that value evaluates
  -- as true and nil evaluates as false.

  if element.classes:includes('not-in-format') and
    element.classes:find_if(function (x) return FORMAT:match(x) end) then
      return {}
    else
      return element
    end
end

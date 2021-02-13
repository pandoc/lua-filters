--- # Bibliography-place: template-controlled bibliography
--    placement in Pandoc.
--
-- This Lua filter for Pandoc allows placement of the bibliography
-- to be controlled in pandoc templates.
--
-- @author Julien Dutant <julien.dutant@kcl.ac.uk>
-- @author Albert Krewinkel
-- @copyright 2021 Julien Dutant, Albert Krewinkel
-- @license MIT - see LICENSE file for details.
-- @release 0.1

local references = nil

--- Div filter for the 'refs' Div.
-- Extract the Div with identifer 'refs' if present and
-- save it in `references`.
-- @param element a Div element
-- @return an empty list if Div has identifier `refs`
function Div(element)
  if element.identifier == 'refs'
    or element.classes:includes('csl-bib-body') then

    references = pandoc.MetaBlocks( { element } )
    return {} -- remove from main body

  end
end

--- Meta filter.
-- Places the references block (as string) in the `references`
-- field of the document's metadata. The template can
-- print it by using `$meta.references$`.
-- @param meta the document's metadata block
-- @return the modified metadata block
function Meta (meta)
  meta.referencesblock = references
  return meta
end

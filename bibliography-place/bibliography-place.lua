--- # not-in-format - keep document parts out of selected output formats.
--
-- This Lua filter for Pandoc allows placement of the bibliography
-- to be controlled in pandoc templates.
--
-- @author Julien Dutant <julien.dutant@kcl.ac.uk>
-- @author Albert Krewinkel
-- @copyright 2021 Julien Dutant, Albert Krewinkel
-- @license MIT - see LICENSE file for details.
-- @release 1.0

local references = pandoc.List:new()

--- Add environment to the references Div if needed
-- takes the body of references (list of blocks)
-- and wraps it in suitable environment commands for
-- each format. id needed for links.
-- @param content content of the bibliography
-- @param id identifier of the bibliography
local function add_environment(content, id)
  if FORMAT:match("latex") then
    content:insert(1,pandoc.RawBlock("latex",
        "\\hypertarget{refs}{" .. id .. "}"))
    content:insert(1,pandoc.RawBlock("latex", "\\begin{CSLReferences}{1}{0}"))
    content:insert(pandoc.RawBlock("latex", "\\end{CSLReferences}"))
  elseif FORMAT:match("html.*") then
    -- wrap the content in an HTML Div
    content:insert(1,pandoc.RawBlock("html", '<div id="refs" class="references csl-bib-body hanging-indent" role="doc-bibliography">'))
    content:insert(pandoc.RawBlock("html", '</div>'))
  end
  return content
end

--- Div filter for the 'refs' Div.
-- Extract the Div with identifer 'refs' if present and
-- save it in `references`.
-- @param element a Div element
-- @return an empty list if Div has identifier `refs`
function Div(element)
  if element.identifier == 'refs'
    or element.classes:includes('csl-bib-body') then
      references = add_environment(element.content, element.identifier)
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

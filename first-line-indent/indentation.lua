--[[-- # First Line Indent - First-line idented paragraphs
 in Pandoc's markdown.
@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Parameters

--- Options map, including defaults.
-- @param header_code boolean whether to include support code in the header (true).
-- @param convert_rules boolean whether to convert horinzontal rules to half length.
local options = {
  header_code = true,
  convert_rules = true,
}

--- list of formats for which we process the filter.
local target_formats = {
  'html.*',
  'latex',
  'jats',
  'native',
  'markdown'
}

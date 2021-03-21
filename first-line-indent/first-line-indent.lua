--[[-- # First-line-indent - First-line idented paragraphs
 in Pandoc's markdown.

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Parameters

--- Options map, including defaults.
-- @param set_metadata_variable boolean whether to set the `indent`
--    metadata variable.
-- @param set_header_includes boolean whether to add formatting code in
--    header-includes to handle first-line indent paragraph style.
-- @param auto_remove_indents boolean whether to automatically remove
--    indents after blockquotes and the like.
-- @param remove_indent_after list of strings, Pandoc AST block types
--    after which first-line indents should be automatically removed.
local options = {
  set_metadata_variable = true,
  set_header_includes = true,
  auto_remove = true,
  remove_indent_after = {
    'BlockQuote',
    'BulletList',
    'CodeBlock',
    'DefinitionList',
    'HorizontalRule',
    'OrderedList',
  }
}

--- Global variables
-- @utils pandoc's module of utilities functions
-- @param block_types: List of block types after which first-line idents
--   should be we automatically removed.
-- @param code_indent Pandoc object for LaTeX indent code
-- @param code_noindent Pandoc object for LaTeX noindent code
local utils = pandoc.utils
local block_types = pandoc.List(options.remove_indent_after)
local code_indent = pandoc.RawInline('tex', '\\indent ')
local code_noindent = pandoc.RawInline('tex', '\\noindent ')

--- process_metadata: filter for the metablock.
-- reads the user options.
-- sets the metadata variable `indent` to `true` unless otherwise specified.
-- adds formatting code to `header-includes` unless otherwise specified.
function process_metadata(meta)

  -- read user options
  if meta['first-line-indent'] then

    local user_options = meta['first-line-indent']

    if not(user_options['set-metadata-variable'] == nil)
      and user_options['set-metadata-variable'] == false then
      options.set_metadata_variable = false

    end

    if not(user_options['set-header-includes'] == nil)
      and user_options['set-header-includes'] == false then
      options.set_header_includes = false
    end

    if not(user_options['auto-remove'] == nil)
      and user_options['auto-remove'] == false then
      options.auto_remove = false
    end

    if (user_options['remove-after']) then
      -- @todo process this option (either single string or list)
    end

    if (user_options['dont-remove-after']) then
      -- @todo process this option (either single string or list)
    end

  end

  -- set the `indent` metadata variable unless otherwise specified or
  -- already set to false
  if options.set_metadata_variable and not(meta.indent == false) then
    meta.indent = true
    return meta
  end

  -- @todo add `header-include` code

end


--- process_body: process the document's body text.
-- unless otherwise specified, automatically adds no-first-line-indent
-- on every paragraph following one of the block types
local function process_body(doc)

  if options.auto_remove then

    local do_not_indent_next_block = false

    for _,elem in pairs(doc.blocks) do

      if elem.t == "Para" and do_not_indent_next_block then

        do_not_indent_next_block = false

        -- check that the paragraph doesn't already explictly specifies
        -- its ident
        if elem.content[1] and not (utils.equals(elem.content[1],
          code_noindent) or utils.equals(elem.content[1],code_indent))
          then

          if FORMAT:match('latex') then
            content = pandoc.List(elem.content)
            content:insert(1, pandoc.RawInline('latex', '\\noindent '))
            elem.content = content
          elseif FORMAT:matches('html*') then
            -- to be handled!
          end

        end

      elseif block_types:includes(elem.t) then

        do_not_indent_next_block = true

      else

        do_not_indent_next_block = false

      end

    end

    return doc

  end

end

--- Main code
-- Returns the filters in the desired order of execution
local metadata_filter = {
  Meta = process_metadata
}
local body_filter = {
  Pandoc = process_body
}
return {
  metadata_filter,
  body_filter
}

--[[-- # First-line-indent - First-line idented paragraphs
 in Pandoc's markdown.

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Options

--- Options map, including defaults.
-- @param set_metadata_variable boolean whether to set the `indent`
--    metadata variable.
-- @param set_header_includes boolean whether to add formatting code in
--    header-includes to handle first-line indent paragraph style.
-- @param auto_remove_indents boolean whether to automatically remove
--    indents after blockquotes and the like.
-- @param remove_indent_after list of strings, Pandoc AST block types
--    after which first-line indents should be automatically removed.
-- @param size string a CSS / LaTeX specification of the first line
--    indent length
local options = {
  set_metadata_variable = true,
  set_header_includes = true,
  auto_remove = true,
  remove_indent_after = pandoc.List({
    'BlockQuote',
    'BulletList',
    'CodeBlock',
    'DefinitionList',
    'HorizontalRule',
    'OrderedList',
  }),
  size = "1em",
}

-- # Filter global variables
-- @utils pandoc's module of utilities functions
-- @param code map of pandoc objects for indent/noindent Raw code
-- @param header_code map of pandoc code to add to header-includes
local utils = pandoc.utils
local code = {
  latex = {
    indent = pandoc.RawInline('tex', '\\indent '),
    noindent = pandoc.RawInline('tex', '\\noindent '),
  },
  html = {
    indent = pandoc.RawBlock('html',
      '<div class="first-line-indent-after"></div>'),
    noindent = pandoc.RawBlock('html',
      '<div class="no-first-line-indent-after"></div>'),
  }
}
local header_code = {
  html = [[
  <style>
    p {
      text-indent: SIZE;
      margin: 0;
    }
    header + p {
      text-indent: ;
    }
    :is(h1, h2, h3, h4, h5, h6) + p {
      text-indent: 0;
    }
    :is(div.no-first-line-indent-after) + p {
      text-indent: 0;
    }
    :is(div.first-line-indent-after) + p {
      text-indent: SIZE;
    }
  </style>
]],
}

--- Add a block to the document's header-includes meta-data field.
-- @param meta the document's metadata block
-- @param blocks list of Pandoc block elements (e.g. RawBlock or Para)
--    to be added to the header-includes of meta
-- @return meta the modified metadata block
local function add_header_includes(meta, blocks)

  local header_includes = pandoc.MetaList( { pandoc.MetaBlocks(blocks) })

  -- add any exisiting meta['header-includes']
  -- it can be MetaInlines, MetaBlocks or MetaList
  if meta['header-includes'] then
    if meta['header-includes'].t == 'MetaList' then
      header_includes:extend(meta['header-includes'])
    else
      header_includes:insert(meta['header-includes'])
    end
  end

  meta['header-includes'] = header_includes

  return meta

end

-- # Filter functions


--- Filter for the metablock.
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

      if user_options['remove-after'].t == 'MetaInlines' or
        user_options['remove-after'].t == 'MetaList' then

          if user_options['remove-after'].t == 'MetaInlines' then

            options.remove_indent_after:insert (
              utils.stringify(user_options['remove-after']))

          else

            for _,item in ipairs(user_options['remove-after']) do

              options.remove_indent_after:insert(utils.stringify(item))

            end

          end

      end
    end

    if (user_options['dont-remove-after']) then

      if user_options['dont-remove-after'].t == 'MetaInlines' or
        user_options['dont-remove-after'].t == 'MetaList' then

          -- list of strings to be removed
          local blacklist = pandoc.List({})

          if user_options['dont-remove-after'].t == 'MetaInlines' then

            blacklist:insert (
              utils.stringify(user_options['dont-remove-after']))

          else

            for _,item in ipairs(user_options['dont-remove-after']) do

              blacklist:insert(utils.stringify(item))

            end

          end

          -- filter the options.remove_indent_after list to only
          -- include items that are not blacklisted
          predicate = function (str)
              return not(blacklist:includes(str))
            end

          options.remove_indent_after =
            options.remove_indent_after:filter(predicate)

      end
    end

   if not(user_options['size'] == nil) then

      -- @todo using stringify means that LaTeX commands in
      -- size are erased. But it ensures that the filter gets
      -- a string. Improvement: check that we have a string
      -- and throw a warning otherwise
      options.size = utils.stringify(user_options['size'])

    end

  end

  -- variable to track whether we've changed `meta`
  changes = false

  -- set the `indent` metadata variable unless otherwise specified or
  -- already set to false
  if options.set_metadata_variable and not(meta.indent == false) then
    meta.indent = true
    changes = true
  end

  -- set the `header-includes` metadata variable
  if options.set_header_includes then

    if FORMAT:match('html*') then

      header_code.html = string.gsub(header_code.html, "SIZE", options.size)
      add_header_includes(meta, { pandoc.RawBlock('html', header_code.html) })

    elseif FORMAT:match('latex') and not(options.size == "1em") then

      add_header_includes(meta, { pandoc.RawBlock('tex',
        '\\setlength{\\parindent}{'.. options.size ..'}') })

    end

  end

  if changes then return meta end

end

--- Add format-specific explicit indent markup to a paragraph.
-- @param type string 'indent' or 'noindent', type of markup to add
-- @param elem pandoc AST paragraph
-- @return a list of blocks (containing a single paragraph element or
-- a rawblock and a paragraph element, depending on output format)
local function indent_markup(type, elem)

  if FORMAT:match('latex') and (type == 'indent' or type == 'noindent') then

    -- in LaTeX, replace any `\indent` or `\noindent` command at
    -- the start of the paragraph with the desired one, add it otherwise

    local content = pandoc.List(elem.content)

    if content[1] and (utils.equals(content[1],
        code.latex.indent) or utils.equals(content[1],
        code.latex.noindent)) then

      content[1] = code.latex[type]

    else

      content:insert(1, code.latex[type])

    end

    elem.content = content
    return({ elem })

  -- in HTML, insert a block (div) before the paragraph

  elseif FORMAT:match('html*') and (type == 'indent' or type == 'noindent') then

    return({ code.html[type], elem })

  else

    return({elem})

  end

end

--- Process indents in the document's body text.
-- Adds output code for explicitly specified first-line indents,
-- automatically removes first-line indents after blocks of the
-- designed types unless otherwise specified.
local function process_body(doc)

  -- result will be the new doc.blocks
  local result = pandoc.List({})
  local do_not_indent_next_block = false

  for _,elem in pairs(doc.blocks) do

    if elem.t == "Para" then

      -- if explicit indentation marking, leave as is and style output
      if elem.content[1] and (utils.equals(elem.content[1],
        code.latex.indent) or utils.equals(elem.content[1],
        code.latex.noindent)) then

        if utils.equals(elem.content[1], code.latex.indent) then
          result:extend(indent_markup('indent', elem))
        else
          result:extend(indent_markup('noindent', elem))
        end

      -- if auto_remove is on remove the first-line indent if needed
      elseif options.auto_remove and do_not_indent_next_block then

        result:extend(indent_markup('noindent', elem))

      else

        result:insert(elem)

      end

      do_not_indent_next_block = false

    elseif options.remove_indent_after:includes(elem.t) then

      do_not_indent_next_block = true
      result:insert(elem)

    else

      do_not_indent_next_block = false
      result:insert(elem)

    end

  end

  doc.blocks = result
  return doc

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

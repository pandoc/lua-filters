--[[
column-div - leverage Pandoc native divs to make balanced and unbalanced column
             and other things based on class name and attirbutes.

Copyright:  © 2021 Christophe Agathon <christophe.agathon@gmail.com>
License:    MIT – see LICENSE file for details

Credits:    Romain Lesur and Yihui Xie for the original column filter
            implementation (output in beamer format).

Output:     latex, pdf, html

Usage:                          classname   attributes
            balanced columns    .columns    column-count
            columns(container)  .columns
            column(each column) .column     width(percent) valign(t|c|b)
            other divs          .<somename> data-latex

            See README.md for details

Note:       You need to include multicol latex package to get balanced columns
            in latex or pdf
            I tried to use well known html or latex parameter.
            Even if lua doen't like hyphens like in column-count.
--]]
local List = require 'pandoc.List'

function Div(div)
  options = ''
  local env = div.classes[1]
  local returned_list
  local begin_env
  local end_env
  local opt

  -- if the div has no class, the object is left unchanged
  if not env then return nil end

  -- if the output is beamer do columns
  if FORMAT:match 'beamer' then
    -- build the returned list of blocks
    begin_env = List:new{pandoc.RawBlock('tex',
                                  '\\begin' .. '{' .. env .. '}' .. options)}
    end_env = List:new{pandoc.RawBlock('tex', '\\end{' .. env .. '}')}
    returned_list = begin_env .. div.content .. end_env

  -- if the format is latex then do minipage and others (like multicol)
  elseif FORMAT:match 'latex' then
    -- build the returned list of blocks
    if env == 'column' then
      --opt = div.attributes['width']
      opt = div.attributes.width
      if opt then
        local width=tonumber(string.match(opt,'(%f[%d]%d[,.%d]*%f[%D])%%'))/100
        options = '{' .. tostring(width) .. '\\columnwidth}'
      end

      opt = div.attributes.valign
      if opt then options = '[' .. opt .. ']' .. options end

      begin_env = List:new{pandoc.RawBlock('tex',
                            '\\begin' .. '{' .. 'minipage' .. '}' .. options)}
      end_env = List:new{pandoc.RawBlock('tex', '\\end{' .. 'minipage' .. '}')}
      returned_list = begin_env .. div.content .. end_env

    elseif env == 'columns' then
      -- merge two consecutives RawBlocks (\end... and \begin...)
      -- to get rid of the unwanted blank line
      local blocks = div.content
      local rbtxt = ''

      for i = #blocks-1, 1, -1 do
        if i > 1 and blocks[i].tag == 'RawBlock' and blocks[i].text:match 'end'
        and blocks[i+1].tag == 'RawBlock' and blocks[i+1].text:match 'begin'
        then
          rbtxt = blocks[i].text .. blocks[i+1].text
          blocks:remove(i+1)
          blocks[i].text = rbtxt
        end
      end
      returned_list=blocks

    else
      -- other environments ex: multicols

      -- process supported options
      opt = div.attributes['column-count']    -- this synthax needed due to '_'
      if opt then options = '{' .. opt .. '}' end

      -- default if no known options
      if options == '' then options = div.attributes.data-latex end

      begin_env = List:new{pandoc.RawBlock('tex',
                                    '\\begin' .. '{' .. env .. '}' .. options)}
      end_env = List:new{pandoc.RawBlock('tex', '\\end{' .. env .. '}')}
      returned_list = begin_env .. div.content .. end_env
    end

  -- if the format is html add support for multi columns
  elseif FORMAT:match 'html' then
    opt = div.attributes['column-count']
    if opt then
      -- add column-count to style if it exists
      if div.attributes.style then
        div.attributes.style = div.attributes.style ..
                                '; column-count: ' .. opt
      else
        div.attributes.style = 'column-count:' .. opt
      end
      div.attributes['column-count'] = nil
      returned_list = List:new{pandoc.Div(div.content, div.attr)}
    end
  end
  return returned_list
end

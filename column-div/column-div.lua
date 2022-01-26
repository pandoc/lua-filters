--[[
column-div - leverage Pandoc native divs to make balanced and unbalanced column
             and other things based on class name and attributes.

Copyright:  © 2021 Christophe Agathon <christophe.agathon@gmail.com>
License:    MIT – see LICENSE file for details

Credits:    Romain Lesur and Yihui Xie for the original column filter
            implementation (output in beamer format).

Output:     latex, pdf, html

Usage:                          classname   attributes
            balanced columns    .columns    column-count
            columns(container)  .columns
            column(each column) .column     width(percent) valign(t|c|b)

            See README.md for details

Note:       You don't need to include multicol latex package to get balanced
            columns in latex or pdf. The filter does it.

            I tried to use well known html or latex parameter.
            Even if lua doen't like hyphens like in column-count.

--]]
local List = require 'pandoc.List'

function Div(div)
  local options = ''
  local env = ''
  local returned_list
  local begin_env
  local end_env
  local opt

  -- if the div has no class, the object is left unchanged
  -- if the div has no class but an id, div.classes ~= nil
  if not div.classes or #div.classes == 0 then return nil end

  -- if the format is latex then do minipage and others (like multicol)
  if FORMAT:match 'latex' then
    -- build the returned list of blocks
    if div.classes:includes('column') then
      env = 'column'
      opt = div.attributes.width
      if opt then
        local width=tonumber(string.match(opt,'(%f[%d]%d[,.%d]*%f[%D])%%'))/100
        options = '{' .. tostring(width)
        if div.attributes['background-color'] then
          -- fix the width for the \colorbox
          options = '{\\dimexpr' .. tostring(width)
                    .. '\\columnwidth-4\\fboxsep\\relax}'
        else
          options = '{' .. tostring(width) .. '\\columnwidth}'
        end
      end

      opt = div.attributes.valign
      if opt then options = '[' .. opt .. ']' .. options end

      begin_env = List:new{pandoc.RawBlock('tex',
                                           '\\begin{minipage}' .. options)}
      end_env = List:new{pandoc.RawBlock('tex', '\\end{minipage}')}

      -- add support for color
      opt = div.attributes.color
      if opt then
        begin_env = begin_env .. List:new{pandoc.RawBlock('tex',
                                                      '\\color{' .. opt .. '}')}
        div.attributes.color = nil    -- consume attribute
      end

      opt = div.attributes['background-color']
      if opt then
        begin_env = List:new{pandoc.RawBlock('tex',
                                             '\\colorbox{' .. opt .. '}{')}
                    .. begin_env
        end_env = end_env .. List:new{pandoc.RawBlock('tex', '}')}
        div.attributes['background-color'] = nil    -- consume attribute
      end

      returned_list = begin_env .. div.content .. end_env

    elseif div.classes:includes('columns') then
      -- it turns-out that asimple Tex \mbox do the job
      begin_env = List:new{pandoc.RawBlock('tex', '\\mbox{')}
      end_env = List:new{pandoc.RawBlock('tex', '}')}
      returned_list = begin_env .. div.content .. end_env

    else
      -- other environments ex: multicols
      if div.classes:includes('multicols') then
        env = 'multicols'
        -- process supported options
        opt = div.attributes['column-count']
        if opt then options = '{' .. opt .. '}' end
      end

      begin_env = List:new{pandoc.RawBlock('tex',
                                    '\\begin{' .. env .. '}' .. options)}
      end_env = List:new{pandoc.RawBlock('tex', '\\end{' .. env .. '}')}
      returned_list = begin_env .. div.content .. end_env
    end

  -- if the format is html add what is not already done by plain pandoc
  elseif FORMAT:match 'html' then
    local style
    -- add support for multi columns
    opt = div.attributes['column-count']
    if opt then
      -- add column-count to style
      style = 'column-count: ' .. opt .. ';' .. (style or '')
      div.attributes['column-count'] = nil
      -- column-count is "consumed" by the filter otherwise it would appear as
      -- data-column-count="…" in the resulting document
    end
    -- add support for color
    opt = div.attributes.color
    if opt then
      -- add color to style
      style = 'color: ' .. opt .. ';' .. (style or '')
      div.attributes.color = nil    -- consume attribute
    end
    opt = div.attributes['background-color']
    if opt then
      -- add color to style
      style = 'background-color: ' .. opt .. ';' .. (style or '')
      div.attributes['background-color'] = nil    -- consume attribute
    end
    -- if we have style then build returned list
    if style then
      -- process width attribute since Pandoc complains about duplicate
      -- style attribute and ignores it.
      opt = div.attributes.width
      if opt then
        style = 'width: ' .. opt .. ';' .. (style or '')
        div.attributes.width = nil    -- consume attribute
      end
      div.attributes.style = style .. (div.attributes.style or '')
      returned_list = List:new{pandoc.Div(div.content, div.attr)}
    end
  end
  return returned_list
end

function Meta(meta)
  -- Include  multicol latex package to get balanced columns in latex or pdf

  includes = [[\usepackage{multicol}]]

  if FORMAT:match 'latex' then
    if meta['header-includes'] then
      table.insert(meta['header-includes'], pandoc.RawBlock('tex', includes))
    else
      meta['header-includes'] = List:new{pandoc.RawBlock('tex', includes)}
    end
  end

  return meta
end

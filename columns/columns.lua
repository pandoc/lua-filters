--[[
columns - multiple columns support.

This Lua filter provides support for multiple columns in
latex and html outputs. For details, see README.md.

v1.0

Copyright: © 2021 Julien Dutant <julien.dutant@kcl.ac.uk>
License:  MIT - see LICENSE file for details.

]]
-- # Internal settings

-- target_formats  filter is triggered when those format are targeted
local target_formats = {
  "html.*",
  "latex",
}

-- # Helper functions

--[[
# format_matches(formats)

Returns true if the current target format is in the list `formats`

]]

local function format_matches(formats)
  for _,format in pairs(formats) do
    if FORMAT:match(format) then
      return true
    end
  end
  return false
end

--[[
# add_header_includes(meta,  block)

add a block to the document's header-includes meta-data field

`meta` (pandoc AST Meta object)
: the document's metadata

`block` (pandoc AST block object, e.g. RawBlock or Para)
: the block to be added

returns `meta` with the block added to the header-includes filed
]]

local function add_header_includes(meta, block)
  
    local header_includes
  
    -- make meta['header-includes'] a list if needed
    if meta['header-includes'] and meta['header-includes'].t == 'MetaList' then
        header_includes = meta['header-includes']
    else
        header_includes = pandoc.MetaList{meta['header-includes']}
    end
    
    -- insert `block` in header-includes and add it to `meta`
    
    header_includes[#header_includes + 1] =
        pandoc.MetaBlocks{block}
        
    meta['header-includes'] = header_includes
    
    return meta
end

--[[
# add_class (element, class)

adds a class to an element

element (pandoc AST element)
: element to which the class is added

class (string)
: class to be added

returns the element with class added
if the element has no classes, returns as is without warning
]]
local function add_class(element, class)

  -- act only if the element has classes
  if element.attr then
    if element.attr.classes then

      -- if the class is absent, add it
      if not element.attr.classes:includes(class) then
        element.attr.classes:insert(class)
      end
    end
  end

  return element
end

--[[
# remove_class (element, class)

removes a class from an element

element (pandoc AST element)
: element from which the class is to be removed

class (string)
: class to be removed

returns the element with class removed
if the element has no classes, returns as is without warning
]]
local function remove_class(element, class)

  -- act only if the element has classes
  if element.attr then
    if element.attr.classes then

      -- if the class is present, remove it
      if element.attr.classes:includes(class) then
        element.attr.classes = element.attr.classes:filter(
          function(x)
            return not (x == class)
          end
          )
      end
    end
  end

  return element
end

--[[
# set_attribute(element, key, value)

sets an element's attribute to a given value

`element` (pandoc AST element)
: element of which the attribute is to be set

`key` (string)
: name of the attribute

`value` (optional, string or number)
: value to be set

sets the element's attribute named `key` to `value`
if `value` is not specified (`nil`) the attribute is removed
if the element has no attributes it is returned as is
]]
local function set_attribute(element,key,value)

  -- act only if the element has attributes
  if element.attr then
    if element.attr.attributes then

      -- if `value` is `nil`, remove the attribute
      if value == nil then 
        if element.attr.attributes[key] then
         element.attr.attributes[key] = nil
       end
      
      -- otherwise set its value
      else
        element.attr.attributes[key] = value
      end
          
    end
  end

  return element
end

--[[
# add_to_html_style (element, style)

adds style markup to an element

element (pandoc AST element with attributes)
: element to which the style markup is added

style (string)
: style markup to be added

returns the element with style added
if the element has no attributes, returns as is without warning
]]
local function add_to_html_style(element, style)

  -- act only if the element has attributes
  if element.attr then
    if element.attr.attributes then
      
      -- if the element has style markup, append
      if element.attr.attributes['style'] then
    
        element.attr.attributes['style'] = 
          element.attr.attributes['style'] .. '; ' .. style .. ' ;'
      
      -- otherwise create
      else
    
        element.attr.attributes['style'] = style .. ' ;'
        
      end
      
    end
  end
  
  return element

end

--[[
# number_by_name(name)

name (string)
: name of the number (e.g. "one")

returns the corresponding number if found, `nil` otherwise
]]
local function number_by_name(name)
  
  local names = {
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
    ten = 10,
    first = 1,
    second = 2,
    third = 3,
    fourth = 4,
    fifth = 5,
    sixth = 6,
    seventh = 7,
    eighth = 8,
    ninth = 9,
    tenth = 10,
  }
  
  result = nil
  
  if name then
    if names[name] then 
      return names[name] 
    end
  end
  
end

--[[
# css_values_to_latex(css_str)

converts CSS values in `string` into LaTeX values

string 
: string specifying CSS values, e.g. "3px solid black"

returns a table with keys `length`, `color` (and `colour`) if found
]]
local function css_values_to_latex(css_str)
    
  -- color conversion table
  --  keys are CSS values, values are LaTeX equivalents
  
  latex_colors = {
    -- xcolor always available
    black = 'black',
    blue = 'blue',
    brown = 'brown',
    cyan = 'cyan',
    darkgray = 'darkgray',
    gray = 'gray',
    green = 'green',
    lightgray = 'lightgray',
    lime = 'lime',
    magenta = 'magenta',
    olive = 'olive',
    orange = 'orange',
    pink = 'pink',
    purple = 'purple',
    red = 'red',
    teal = 'teal',
    violet = 'violet',
    white = 'white',
    yellow = 'yellow',
    -- css1 colors
    silver = 'lightgray',
    fuschia = 'magenta',
    aqua = 'cyan',    
  }
  
  local result = {}
  
  -- look for color values
  --  by color name
  --  rgb, etc.: to be added
  
  local color = ''

  -- space in front simplifies pattern matching
  css_str = ' ' .. css_str

  for text in string.gmatch(css_str, '[%s](%a+)') do
    
    -- if we have LaTeX equivalent of `text`, store it
    if latex_colors[text] then
      result['color'] = latex_colors[text] 
    end
    
  end
  
  -- provide British spelling
  
  if result['color'] then
    result['colour'] = result['color']
  end  
  
  -- look for lengths
  
  --  0 : converted to 0em
  if string.find(css_str, '%s0%s') then
   result['length'] = '0em'
  end
  
  --  px : converted to pt
  for text in string.gmatch(css_str, '(%s%d+)px') do
   result['length'] = text .. 'pt'    
  end
  
  -- lengths units to be kept as is
  --  nb, % must be escaped
  --  nb, if several found, the latest type is preserved
  keep_units = { '%%', 'pt', 'mm', 'cm', 'in', 'ex', 'em' }
  
  for _,unit in pairs(keep_units) do
    
    -- .11em format
    for text in string.gmatch(css_str, '%s%.%d+'.. unit) do
      result['length'] = text
    end

    -- 2em and 1.2em format
    for text in string.gmatch(css_str, '%s%d+%.?%d*'.. unit) do
      result['length'] = text
    end
    
  end

  return result

end

--[[
# ensures_latex_length(text)

Ensures that `text` declares a latex length

returns text if it is or `nil` if it isn't
]]
local function ensures_latex_length(text)
  
  -- LaTeX lengths units
  --  nb, % must be escaped in lua patterns
  units = { '%%', 'pt', 'mm', 'cm', 'in', 'ex', 'em' }
  
  local result = nil
  
  -- ignore spaces, controls and punctuation other than
  -- dot, plus, minus
  text = string.gsub(text, "[%s%c,;%(%)%[%]%*%?%%%^%$]+", "")
  
  for _,unit in pairs(units) do
    
    -- match .11em format and 1.2em format
    if string.match(text, '^%.%d+'.. unit .. '$') or
      string.match(text, '^%d+%.?%d*'.. unit .. '$') then
        
      result = text
        
    end
        
  end
 
  return result
end


-- # Filter-specific functions

--[[
# process_meta(meta)

adds needed material to the document `header-includes` meta-data field
]]
local function process_meta(meta)
  
  -- in LaTeX, require the `multicols` package
  if FORMAT:match('latex') then
    
    return add_header_includes(meta, 
      pandoc.RawBlock('latex', '\\usepackage{multicol}\n'))
    
  end
  
  -- in html, ensure that the first element of `columns` div
  -- has a top margin of zero (otherwise we get white space
  -- on the top of the first column)
  -- idem for the first element after a `column-span` element
  if FORMAT:match('html.*') then
    
    html_header = [[
<style>
/* Styles added by the columns.lua pandoc filter */
  .columns :first-child {margin-top: 0;}
  .column-span + * {margin-top: 0;}
</style>
]]
  
    return add_header_includes(meta, pandoc.RawBlock('html', html_header))
  
  end

  return meta
  
end

--[[
# convert_explicit_columnbreaks(elem)

converts any explicit column markup in the Div `elem`
into a single syntax: Divs with class `columnbreak`

note: if there are `column` divs we keep them in case they 
  harbour further formatting but remove their `column` class
  to avoid double-processing when `columns` are nested
]]
local function convert_explicit_columbreaks(elem)
  
  -- if `elem` ends with a `column` Div, this last Div should
  -- not generate a columnbreak. We tag it to make sure we don't.
  
  if elem.content[#elem.content] then
    if elem.content[#elem.content].classes then
      if elem.content[#elem.content].classes:includes('column') then
        
        elem.content[#elem.content] = 
          add_class(elem.content[#elem.content], 
              'column-div-in-last-position')
          
      end
    end
  end
  
  -- processes `column` Divs and `\columnbreak` LaTeX RawBlocks
  filter = {
    
    Div = function (el)
      
      -- syntactic sugar: `column-break` converted to `columnbreak`
      if el.classes:includes("column-break") then
        
        el = add_class(el,"columnbreak")
        el = remove_class(el,"column-break")
      
      end
      
      if el.classes:includes("column") then
        
        -- with `column` Div, add a break if it's not in last position
        if not el.classes:includes('column-div-in-last-position') then
        
          local breaking_div = pandoc.Div({})
          breaking_div = add_class(breaking_div, "columnbreak")
          
          el.content:insert(breaking_div)
        
        -- if it's in the last position, remove the custom tag
        else 
        
          el = remove_class(el, 'column-div-in-last-position')
        
        end
        
        -- remove `column` classes, but leave the div and other 
        -- attributes the user might have added
        el = remove_class(el, 'column')
      
      end
      
      return el
    end,
    
    RawBlock = function (el)
      if el.format == "tex" and el.text == '\\columnbreak' then
        
        local breaking_div = pandoc.Div({})
        breaking_div = add_class(breaking_div, "columnbreak")
        
        return breaking_div

      else
      
        return el
      
      end
      
    end
    
  }
  
  return pandoc.walk_block(elem, filter)
  
end

--[[
# tag_with_number_of_explicit_columnbreaks(elem)

counts the number of columnbreaks in `elem`

note: tag columnbreaks that are counted
  so we can ignore them when they are nested in
  outermost `columns` divs.
]]
local function tag_with_number_of_explicit_columnbreaks(elem)
  
  local number_columnbreaks = 0
  
  local filter = {
    
    Div = function(el)
      
      if el.classes:includes('columnbreak') and
        not el.classes:includes('columnbreak_already_counted')  then
        
          number_columnbreaks = number_columnbreaks + 1
          el = add_class(el, 'columnbreak_already_counted')
        
      end
      
      return el
    
    end
  }
  
  elem = pandoc.walk_block(elem, filter)
  
  elem = set_attribute(elem, 'number_explicit_columnbreaks', 
      number_columnbreaks)
  
  return elem
  
end

--[[
# consolidate_colattrib_aliases(elem)

Syntactic sugar: unifies various ways of specifying 
column attributes `column-gap`, `column-rule`. 

elem (pandoc AST element)
: a `columns` div with attributes

returns `elem` with the attributes uniquely specified

note: when several specifications conflict, uses the
preferred `column-gap` and `column-rule` specifications. 
]]
local function consolidate_colattrib_aliases(elem)
  
  if elem.attr then
    if elem.attr.attributes then
    
      -- `column-gap` if the preferred syntax is set, erase others
      if elem.attr.attributes["column-gap"] then
        
        elem = set_attribute(elem, "columngap", nil)
        elem = set_attribute(elem, "column-sep", nil)
        elem = set_attribute(elem, "columnsep", nil)
      
      -- otherwise fetch and unset any alias
      else
        
        if elem.attr.attributes["columnsep"] then
          
          elem = set_attribute(elem, "column-gap", 
              elem.attr.attributes["columnsep"])
          elem = set_attribute(elem, "columnsep", nil)
        
        end
        
        if elem.attr.attributes["column-sep"] then
          
          elem = set_attribute(elem, "column-gap", 
              elem.attr.attributes["column-sep"])
          elem = set_attribute(elem, "column-sep", nil)
        
        end
        
        if elem.attr.attributes["columngap"] then
          
          elem = set_attribute(elem, "column-gap", 
              elem.attr.attributes["columngap"])
          elem = set_attribute(elem, "columngap", nil)
        
        end
      
      end 
      
      -- `column-rule` if the preferred syntax is set, erase others
      if elem.attr.attributes["column-rule"] then
        
        elem = set_attribute(elem, "columnrule", nil)
      
      -- otherwise fetch and unset any alias
      else
        
        if elem.attr.attributes["columnrule"] then
          
          elem = set_attribute(elem, "column-rule", 
              elem.attr.attributes["columnrule"])
          elem = set_attribute(elem, "columnrule", nil)
        
        end
        
      end

    end
   
  end

  return elem

end

--[[
# preprocess_columns(elem)

process columns in the Div `elem`

note: when several `columns` Divs are nested `pandoc` applies the
  filter to the innermost ones first. We use this to handle
  nested columns by counting the inner column first, 
  tagging them and ignoring the ones already tagged
]]
local function preprocess_columns(elem)
    
  -- convert any explicit column syntax in a single format:
  -- native Divs with class `columnbreak`
  
  elem = convert_explicit_columbreaks(elem)
  
  -- count explicit columnbreaks
  
  elem = tag_with_number_of_explicit_columnbreaks(elem)

  return elem
end

--[[
# determine_column_count(elem)

determine the number of columns in a `columns` Div

element (pandoc AST element)
: Div of the `columns` class

returns number_columns

looks up two attributes in the Div: 
  `columns-count`, user specified column count
  `number_explicit_columnbreaks`, number of explicit columnbreaks counted by this filter
  
The number of columns will be 2 or the highest between the user
specified `columns-count` or the counted `number_explicit_columnbreaks`.
This ensures that there's enough columns for all columnbreaks.
It provides a single column when user specifies 1 column and
no columnbreak is added.
]]
local function determine_column_count(elem)
  
    -- is there a specified column count?
  local specified_column_count = 0
  if elem.attr.attributes then
    if elem.attr.attributes['column-count'] then
      specified_column_count = tonumber(
        elem.attr.attributes["column-count"])
    end
  end
  
  -- is there an count of explicit columnbreaks?
  local number_explicit_columnbreaks = 0
  if elem.attr.attributes then
    if elem.attr.attributes['number_explicit_columnbreaks'] then
    
      number_explicit_columnbreaks = tonumber(
        elem.attr.attributes['number_explicit_columnbreaks']
        )
    
      set_attribute(elem, 'number_explicit_columnbreaks', nil)
    
    end
  end
    
  -- determines the number of columns
  -- default 2
  -- recall that number of columns = nb columnbreaks + 1
  
  local number_columns = 2
  if specified_column_count > 0 or 
    number_explicit_columnbreaks > 0 then
      
      if (number_explicit_columnbreaks + 1) > 
        specified_column_count then
        
        number_columns = number_explicit_columnbreaks + 1
        
      else
        
        number_columns = specified_column_count
      
      end
      
  end

  return number_columns
  
end

--[[
# format_colspan_latex(elem, number_columns)

Formatting a colspan in LaTeX

elem (pandoc AST element)
: `column-span` div to be formatted

number_columns (number)
: number of columns in the present environment

returns a pandoc RawBlock element in LaTeX format

If the colspan is only one block, turn it into an option
of the next `multicol` environment. Otherwise insert it 
between the two `multicol` environment.

**TODO** process one-block colspan into options
  requires processing headings properly (identifier, link)

]]

--[[
# header_to_latex_and_inlines(header)

Converts a pandoc Header element to a list of inlines
for latex output

header (pandoc AST element)
: a Header element

return a list of inlines

**TODO** check the global environment whether reference links are required?

]]
local function header_to_latex_and_inlines(header)
  
  local latex_header = {
    'section', 
    'subsection', 
    'subsubsection', 
    'paragraph', 
    'subparagraph',
  }

  -- create a list if the header's inlines
  local inlines = pandoc.List:new(header.content)
  
  -- wrap in a latex_header if available 
  
  if header.level then
    if latex_header[header.level] then
    
    inlines:insert(1, pandoc.RawInline('latex', 
        '\\' .. latex_header[header.level] .. '{'))
    inlines:insert(pandoc.RawInline('latex', '}'))
    
    end
  end
  
  -- wrap in a link if available
  if header.identifier then
    
    inlines:insert(1, pandoc.RawInline('latex', 
        '\\hypertarget{' .. header.identifier .. '}{%\n'))
    inlines:insert(pandoc.RawInline('latex', 
        '\\label{' .. header.identifier .. '}}'))
  
  end
  
  return inlines
  
end

local function format_colspan_latex(elem, number_columns)
  
    local result = pandoc.List:new()
    
    -- does the content consists of a single header?
    
    if #elem.content == 1 and elem.content[1].t == 'Header' then
      
      -- create a list of inlines
      inlines = pandoc.List:new()
      inlines:insert(pandoc.RawInline('latex', 
        "\\end{multicols}\n"))
      inlines:insert(pandoc.RawInline('latex', 
        "\\begin{multicols}{".. number_columns .."}["))
      inlines:extend(header_to_latex_and_inlines(elem.content[1]))
--      inlines:extend(elem.content[1].content) -- header inlines
      inlines:insert(pandoc.RawInline('latex',"]\n"))
      
      -- insert as a Plain block
      result:insert(pandoc.Plain(inlines))
      
      return result
      
    else
    
      result:insert(pandoc.RawBlock('latex', 
        "\\end{multicols}\n"))
      result:extend(elem.content)
      result:insert(pandoc.RawBlock('latex', 
        "\\begin{multicols}{".. number_columns .."}")) 
      return result
    
    end

end

--[[
# format_columns_latex(elem)

converts columns into latex markup

element (pandoc AST element)
: Div of the `columns` class

]]
local function format_columns_latex(elem)
  
  -- make content into a List object
  pandoc.List:new(elem.content)
  
  -- how many columns?
  number_columns = determine_column_count(elem)
  
  -- set properties and insert LaTeX environment
  --  we wrap the entire environment in `{...}` to 
  --  ensure properties (gap, rule) don't carry
  --  over to following columns
  
  local latex_begin = '{'
  local latex_end = '}'
  
  if elem.attr.attributes then
    
    if elem.attr.attributes["column-gap"] then
        
      local latex_value = ensures_latex_length(
        elem.attr.attributes["column-gap"])
      
      if latex_value then 
      
        latex_begin = latex_begin .. 
          "\\setlength{\\columnsep}{" .. latex_value .. "}\n"
          
      end
      
      -- remove the `column-gap` attribute
      elem = set_attribute(elem, "column-gap", nil)
      
    end
  
    if elem.attr.attributes["column-rule"] then
              
      -- converts CSS value string to LaTeX values
      local latex_values = css_values_to_latex(
        elem.attr.attributes["column-rule"])
      
      if latex_values["length"] then 
        
        latex_begin = latex_begin .. 
          "\\setlength{\\columnseprule}{" .. 
          latex_values["length"] .. "}\n"
          
      end
      
      if latex_values["color"] then
        
        latex_begin = latex_begin .. 
          "\\renewcommand{\\columnseprulecolor}{\\color{" .. 
          latex_values["color"] .. "}}\n"      
          
      end
      
    
      -- remove the `column-rule` attribute
      elem = set_attribute(elem, "column-rule", nil)
        
    end
    
  end

  latex_begin = latex_begin .. 
    "\\begin{multicols}{" .. number_columns .. "}\n"
  latex_end = "\\end{multicols}\n" .. latex_end
    
  elem.content:insert(1, pandoc.RawBlock('latex', latex_begin))
  elem.content:insert(pandoc.RawBlock('latex', latex_end))
  
  -- process blocks contained in `elem` 
  --  turn any explicit columnbreaks into LaTeX markup
  --  turn `column-span` Divs into LaTeX markup
  
  filter = {
    
    Div = function(el) 
      
      if el.classes:includes("columnbreak") then
        return pandoc.RawBlock('latex', "\\columnbreak\n")
      end
      
      if el.classes:includes("column-span-to-be-processed") then
        return format_colspan_latex(el, number_columns)
      end
            
    end

  }
  
  elem = pandoc.walk_block(elem, filter)
  
  return elem
  
end

--[[
# format_columns_html(elem)

converts columns into html (css3) markup

]]
local function format_columns_html(elem)
 
  -- how many columns?
  number_columns = determine_column_count(elem)

  -- add properties to the `columns` Div
  
  elem = add_to_html_style(elem, 'column-count: ' .. number_columns)
  elem = set_attribute(elem, 'column-count', nil)
  
  if elem.attr.attributes then
    
    if elem.attr.attributes["column-gap"] then
        
      elem = add_to_html_style(elem, 'column-gap: ' .. 
        elem.attr.attributes["column-gap"])
      
      -- remove the `column-gap` attribute
      elem = set_attribute(elem, "column-gap")
      
    end
    
    if elem.attr.attributes["column-rule"] then
              
      elem = add_to_html_style(elem, 'column-rule: ' .. 
        elem.attr.attributes["column-rule"])
    
      -- remove the `column-rule` attribute
      elem = set_attribute(elem, "column-rule", nil)
        
    end
  
  end
    
  -- convert any explicit columnbreaks in CSS markup
  
  filter = {
    
    Div = function(el) 
      
      -- format column-breaks
      if el.classes:includes("columnbreak") then
        
        el = add_to_html_style(el, 'break-after: column')
        
        -- remove columbreaks class to avoid double processing
        -- when nested
        -- clean up already-counted tag
        el = remove_class(el, "columnbreak") 
        el = remove_class(el, "columnbreak_already_counted")
        
      -- format column-spans
      elseif el.classes:includes("column-span-to-be-processed") then
          
        el = add_to_html_style(el, 'column-span: all')
        
        -- remove column-span-to-be-processed class to avoid double processing
        -- add column-span class to allow for styling
        el = add_class(el, "column-span")
        el = remove_class(el, "column-span-to-be-processed")
      
      end
      
      return el
      
    end

  }
  
  elem = pandoc.walk_block(elem, filter)
  
  return elem
  
end


-- # Main filters

--[[
# format_filter

formatting filter

filter to apply column markup in the target formats
]]
format_filter = {
  
  Div = function (element)
    
    -- pick up `columns` Divs for formatting
    if element.classes:includes ("columns") then        
    
      if FORMAT:match('latex') then        
        element = format_columns_latex(element)
      elseif FORMAT:match('html.*') then
        element = format_columns_html(element)
      end
    
    end
  
    return element
    
  end    
}
--[[
# preprocess_filter

preprocessing filters

pick up `columns` Divs for pre-processing
and process the metadata fields

]]
preprocess_filter = {

  Div = function (element)
      
      -- send `columns` Divs to pre-processing
      if element.classes:includes("columns") then     
        return preprocess_columns(element)      
      end
      
    end,
  
  Meta = function (meta)
    
    return process_meta(meta)

  end
}

--[[
# syntactic_sugar_filter

provides multiple syntax

]]
syntactic_sugar_filter = {
  
  Div = function(element)
    
      -- convert "two-columns" into `columns` Divs
      for _,class in pairs(element.classes) do
        
        -- match xxxcolumns, xxx_columns, xxx-columns
        -- if xxx is the name of a number, make
        -- a `columns` div and set its `column-count` attribute
        local number = number_by_name(
          string.match(class,'(%a+)[_%-]?columns$')
          )
        
        if number then
          
          element = set_attribute(element, 
              "column-count", tostring(number))
          element = remove_class(element, class)
          element = add_class(element, "columns")

        end
        
      end
      
      -- allows different ways of specifying `columns` attributes
      if element.classes:includes('columns') then
        
        element = consolidate_colattrib_aliases(element)
      
      end
    
      -- `column-span` syntax
      -- mark up as "to-be-processed" to avoid
      --  double processing when nested
      if element.classes:includes('column-span') or
        element.classes:includes('columnspan') then
        
        element = add_class(element, 'column-span-to-be-processed')
        element = remove_class(element, 'column-span')
        element = remove_class(element, 'columnspan')
      
      end
 
    return element
    
  end
  
}


-- return filters only if the target format matches
--  * `syntatic_sugar_filter` deals with multiple syntax
--  * `preprocessing_filter` converts all explicit 
--    columnbreaks into a common syntax and tags
--    those that are already counted. We must do
--    that for all `columns` environments before
--    turning any break back into LaTeX `\columnbreak` blocks
--    otherwise we mess up the count in nested `columns` Divs.
--  * `format_filter` formats the columns after the counting
--    has been done
if format_matches(target_formats) then
  return {syntactic_sugar_filter,
    preprocess_filter,
    format_filter}
else
  return
end

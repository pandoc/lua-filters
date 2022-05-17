-- shortcodes.lua
-- Copyright (C) 2020 by RStudio, PBC

-- actively prevent running in quarto (as all of this is already included there)
if os.getenv("QUARTO_FILTER_PARAMS") ~= nil then
  io.stderr:write("ERROR: shortcodes.lua should not be used within quarto " .. 
                  "(quarto already includes an identical implementation)")
  os.exit(1)
end


-------- debug helpers --------

-- improved formatting for dumping tables
local function tdump (tbl, indent)
  if not indent then indent = 0 end
  if tbl.t then
    print(string.rep("  ", indent) .. tbl.t)
  end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tdump(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))
    elseif (v ~= nil) then 
      print(formatting .. tostring(v))
    else 
      print(formatting .. 'nil')
    end
  end
end

-- dump an object to stdout
local function dump(o)
  if type(o) == 'table' then
    tdump(o)
  else
    print(tostring(o) .. "\n")
  end
end


-------- table helpers --------

-- slice elements out of a table
local function tslice(t, first, last, step)
  local sliced = {}
  for i = first or 1, last or #t, step or 1 do
    sliced[#sliced+1] = t[i]
  end
  return sliced
end

-- append values to table
local function tappend(t, values)
  for i,value in pairs(values) do
    table.insert(t, value)
  end
end

-- does the table contain a value
local function tcontains(t,value)
  if t and type(t)=="table" and value then
    for _, v in ipairs (t) do
      if v == value then
        return true
      end
    end
    return false
  end
  return false
end

-- is the table a simple array?
-- see: https://web.archive.org/web/20140227143701/http://ericjmritz.name/2014/02/26/lua-is_array/
local function tisarray(t)
  local i = 0
  for _ in pairs(t) do
      i = i + 1
      if t[i] == nil then return false end
  end
  return true
end

local function filter(list, test) 
  local result = {}
  for index, value in ipairs(list) do
      if test(value, index) then
          result[#result + 1] = value
      end
  end
  return result
end


-------- string helpers --------

-- tests whether a string ends with another string
local function endsWith(str, ending) 
  return ending == "" or str:sub(-#ending) == ending
end


local function startsWith(str, starting) 
  return starting == "" or str:sub(1, #starting) == starting
end

-- splits a string on a separator
local function split(str, sep)
  local fields = {}
  
  local sep = sep or " "
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(str, pattern, function(c) fields[#fields + 1] = c end)
  
  return fields
end

local function trimEmpty(contents) 
  local firstNonEmpty = 1
  for i, el in ipairs(contents) do
    if el.t == "Str" and el.text == "" then
      firstNonEmpty = firstNonEmpty + 1
    else
      break
    end
  end
  if firstNonEmpty > 1 then
    contents = tslice(contents, firstNonEmpty, #contents)
  end

  local lastNonEmptyEl = nil
  for i = #contents, 1, -1 do
    el = contents[i]
    if el.t == "Str" and el.text == "" then
      contents = tslice(contents, 1, #contents - 1)
    else
      break
    end
  end
  return contents
end



-------- pandoc helpers --------

-- list of inlines to string
local function inlinesToString(inlines)
  return pandoc.utils.stringify(pandoc.Span(inlines))
end

-- lua string with markdown to pandoc inlines
local function markdownToInlines(str)
  if str then
    local doc = pandoc.read(str)
    return doc.blocks[1].content
  else
    return nil
  end
end

local kBlockTypes = {
  "BlockQuote",
  "BulletList", 
  "CodeBlock ",
  "DefinitionList",
  "Div",
  "Header",
  "HorizontalRule",
  "LineBlock",
  "Null",
  "OrderedList",
  "Para",
  "Plain",
  "RawBlock",
  "Table"
}

local function isBlockEl(el)
  return tcontains(kBlockTypes, el.t)
end

local function isInlineEl(el)
  return not isBlockEl(el)
end

local function trimEmpty(contents) 
  local firstNonEmpty = 1
  for i, el in ipairs(contents) do
    if el.t == "Str" and el.text == "" then
      firstNonEmpty = firstNonEmpty + 1
    else
      break
    end
  end
  if firstNonEmpty > 1 then
    contents = tslice(contents, firstNonEmpty, #contents)
  end

  local lastNonEmptyEl = nil
  for i = #contents, 1, -1 do
    el = contents[i]
    if el.t == "Str" and el.text == "" then
      contents = tslice(contents, 1, #contents - 1)
    else
      break
    end
  end
  return contents
end

-------- option handling --------

local allOptions = {} -- read from Meta during init
local function readMetaOptions(meta) 
  local options = {}
  for key,value in pairs(meta) do
    if type(value) == "table" and value.clone ~= nil then
      options[key] = value:clone()
    else
      options[key] = value
    end 
  end
  return options
end


-- get option value
local function readOption(options, name, default)
  local value = options[name]
  if value == nil then
    value = default
  end

  if type(value) == "table" and value.clone ~= nil then
    return value:clone()
  else
    return value;
  end
end


-- parse option from . delimited name
local function parseOption(name, options, def) 
  local keys = split(name, ".")

  local value = nil
  for i, key in ipairs(keys) do
    if value == nil then
      value = readOption(options, key, nil)
    else
      value = value[key]

      -- the key doesn't match a value, stop indexing
      if value == nil then
        break
      end
    end
  end
  if value == nil then
    return def
  else
    return value
  end
end

-- get option value
local function option(name, def)
  return parseOption(name, allOptions, def)
end

-------- shortcode handlers --------

local function shortcodeMetatable(scriptFile) 
  return {
    -- https://www.lua.org/manual/5.3/manual.html#6.1
    assert = assert,
    collectgarbage = collectgarbage,
    dofile = dofile,
    error = error,
    getmetatable = getmetatable,
    ipairs = ipairs,
    load = load,
    loadfile = loadfile,
    next = next,
    pairs = pairs,
    pcall = pcall,
    print = print,
    rawequal = rawequal,
    rawget = rawget,
    rawlen = rawlen,
    rawset = rawset,
    select = select,
    setmetatable = setmetatable,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    _VERSION = _VERSION,
    xpcall = xpcall,
    coroutine = coroutine,
    require = require,
    package = package,
    string = string,
    utf8 = utf8,
    table = table,
    math = math,
    io = io,
    file = file,
    os = os,
    debug = debug,
    -- https://pandoc.org/lua-filters.html
    FORMAT = FORMAT,
    PANDOC_READER_OPTIONS = PANDOC_READER_OPTIONS,
    PANDOC_WRITER_OPTIONS = PANDOC_WRITER_OPTIONS,
    PANDOC_VERSION = PANDOC_VERSION,
    PANDOC_API_VERSION = PANDOC_API_VERSION,
    PANDOC_SCRIPT_FILE = scriptFile,
    PANDOC_STATE = PANDOC_STATE,
    pandoc = pandoc,
    lpeg = lpeg,
    re = re,
    -- extra helpers
    dump = dump
  }
end

local handlers = {}

local function initShortcodeHandlers(shortcodeFiles)

  -- user provided handlers
  for _,shortcodeFile in ipairs(shortcodeFiles) do
    local file = inlinesToString(shortcodeFile)
    local env = setmetatable({}, {__index = shortcodeMetatable(file)})
    local chunk, err = loadfile(file, "bt", env)
    if not err then
      local result = chunk()
      if result then
        for k,v in pairs(result) do
          handlers[k] = v
        end
      else
        for k,v in pairs(env) do
          handlers[k] = v
        end
      end
    else
      io.stderr:write(err .. "\n")
      os.exit(1)
    end
  end


  -- built in handlers (these override any user handlers)
  handlers['meta'] = handleMeta
  handlers['env'] = handleEnv
  handlers['pagebreak'] = handlePagebreak

end

local function handlerForShortcode(shortCode)
  return handlers[shortCode.name]
end

-- call a handler w/ args & kwargs
local function callShortcodeHandler(handler, shortCode)
  local args = pandoc.List()
  local kwargs = setmetatable({}, { __index = function () return pandoc.Inlines({}) end })
  for _,arg in ipairs(shortCode.args) do
    if arg.name then
      kwargs[arg.name] = arg.value
    else
      args:insert(arg.value)
    end
  end
  local meta = setmetatable({}, { __index = function(t, i) 
    return readMetadata(i)
  end})
  return handler(args, kwargs, meta)
end




-------- shortcode processing --------

-- The open and close shortcode indicators
local kOpenShortcode = "{{<"
local kOpenShortcodeEscape = "/*"
local kCloseShortcode = ">}}"
local kCloseShortcodeEscape = "*/"


-- processes inlines into a shortcode data structure
local function processShortCode(inlines) 

  local kSep = "="
  local shortCode = nil
  local args = pandoc.List()

  -- slice off the open and close tags
  inlines = tslice(inlines, 2, #inlines - 1)

  -- handling for names with accompanying values
  local pendingName = nil
  notePendingName = function(el)
    pendingName = el.text:sub(1, -2)
  end

  -- Adds an argument to the args list (either named or unnamed args)
  insertArg = function(argInlines) 
    if pendingName ~= nil then
      -- there is a pending name, insert this arg
      -- with that name
      args:insert(
        {
          name = pendingName,
          value = argInlines
        })
      pendingName = nil
    else
      -- split the string on equals
      if #argInlines == 1 and argInlines[1].t == "Str" and string.match(argInlines[1].text, kSep) then 
        -- if we can, split the string and assign name / value arg
        -- otherwise just put the whole thing in unnamed
        local parts = split(argInlines[1].text, kSep)
        if #parts == 2 then 
          args:insert(
              { 
                name = parts[1], 
                value = stringToInlines(parts[2])
              })
        else
          args:insert(
            { 
              value = argInlines 
            })
        end
      else
        -- this is an unnamed argument
        args:insert(
          { 
            value = argInlines
          })
      end
    end
  end
  

  -- The core loop
  for i, el in ipairs(inlines) do
    if el.t == "Str" then
      if shortCode == nil then
        -- the first value is a pure text code name
        shortCode = el.text
      else
        -- if we've already captured the code name, proceed to gather args
        if endsWith(el.text, kSep) then 
          -- this is the name of an argument
          notePendingName(el)
        else
          -- this is either an unnamed arg or an arg value
          insertArg({el})
        end
      end
    elseif el.t == "Quoted" then 
      -- this is either an unnamed arg or an arg value
      insertArg(el.content)
    elseif el.t ~= "Space" then
      insertArg({el})
    end
  end

  return {
    args = args,
    name = shortCode
  }
end


-- check if a block is composed of a single shortcode
local function onlyShortcode(contents)
  
  -- trim leading and trailing empty strings
  contents = trimEmpty(contents)

  if #contents < 1 then
    return nil
  end

  -- starts with a shortcode
  local startsWithShortcode = contents[1].t == "Str" and contents[1].text == kOpenShortcode
  if not startsWithShortcode then
    return nil
  end

  -- ends with a shortcode
  local endsWithShortcode = contents[#contents].t == "Str" and contents[#contents].text == kCloseShortcode
  if not endsWithShortcode then  
    return nil
  end

  -- has only one open shortcode
  local openShortcodes = filter(contents, function(el) 
    return el.t == "Str" and el.text == kOpenShortcode  
  end)
  if #openShortcodes ~= 1 then
    return nil
  end

  -- has only one close shortcode 
  local closeShortcodes = filter(contents, function(el) 
    return el.t == "Str" and el.text == kCloseShortcode  
  end) 
  if #closeShortcodes ~= 1 then
    return nil
  end
    
  return contents
end

-- coerce any shortcode result to a list of inlines
local function shortcodeResultAsInlines(result, name)
  local type = pandoc.utils.type(result)
  if type == "Inlines" then
    return result
  elseif type == "Blocks" then
    return pandoc.utils.blocks_to_inlines(result, { pandoc.Space() })
  elseif type == "string" then
    return pandoc.Inlines( { pandoc.Str(result) })
  elseif tisarray(result) then
    local items = pandoc.List(result)
    local inlines = items:filter(isInlineEl)
    if #inlines > 0 then
      return pandoc.Inlines(inlines)
    else
      local blocks = items:filter(isBlockEl)
      return pandoc.utils.blocks_to_inlines(blocks, { pandoc.Space() })
    end
  elseif isInlineEl(result) then
    return pandoc.Inlines( { result })
  elseif isBlockEl(result) then
    return pandoc.utils.blocks_to_inlines( { result }, { pandoc.Space() })
  else
    error("Unexepected result from shortcode " .. name .. "")
    dump(result)
    os.exit(1)
  end
end
  
-- coerce any shortcode result to a list of blocks
local function shortcodeResultAsBlocks(result, name)
  local type = pandoc.utils.type(result)
  if type == "Blocks" then
    return result
  elseif type == "Inlines" then
    return pandoc.Blocks( {pandoc.Para(result) })
  elseif type == "string" then
    return pandoc.Blocks( {pandoc.Para({pandoc.Str(result)})} )
  elseif tisarray(result) then
    local items = pandoc.List(result)
    local blocks = items:filter(isBlockEl)
    if #blocks > 0 then
      return pandoc.Blocks(blocks)
    else
      local inlines = items:filter(isInlineEl)
      return pandoc.Blocks({pandoc.Para(inlines)})
    end
  elseif isBlockEl(result) then
    return pandoc.Blocks( { result } )
  elseif isInlineEl(result) then
    return pandoc.Blocks( {pandoc.Para( {result} ) })
  else
    error("Unexepected result from shortcode " .. name .. "")
    print(result)
    os.exit(1)
  end
end


-- scans through a list of inlines, finds shortcodes, and processes them
local function transformShortcodeInlines(inlines) 
  local transformed = false
  local outputInlines = pandoc.List()
  local shortcodeInlines = pandoc.List()
  local accum = outputInlines
  
  -- iterate through any inlines and process any shortcodes
  for i, el in ipairs(inlines) do

    if el.t == "Str" then 

      -- find escaped shortcodes
      local beginEscapeMatch = el.text:match("^%{%{%{+<")
      local endEscapeMatch = el.text:match(">%}%}%}+$")
     
      -- handle shocrtcode escape -- e.g. {{{< >}}}
      if beginEscapeMatch then
        transformed = true
        accum:insert(pandoc.Str(beginEscapeMatch:sub(2)))
      elseif endEscapeMatch then
        transformed = true
        accum:insert(endEscapeMatch:sub(1, #endEscapeMatch-1))

      -- handle shortcode escape -- e.g. {{</* shortcode_name */>}}
      elseif endsWith(el.text, kOpenShortcode .. kOpenShortcodeEscape) then
        -- This is an escape, so insert the raw shortcode as text (remove the comment chars)
        transformed = true
        accum:insert(pandoc.Str(kOpenShortcode))
        

      elseif startsWith(el.text, kCloseShortcodeEscape .. kCloseShortcode) then 
        -- This is an escape, so insert the raw shortcode as text (remove the comment chars)
        transformed = true
        accum:insert(pandoc.Str(kCloseShortcode))

      elseif endsWith(el.text, kOpenShortcode) then
        -- note that the text might have other text with it (e.g. a case like)
        -- This is my inline ({{< foo bar >}}).
        -- Need to pare off prefix and suffix and preserve them
        local prefix = el.text:sub(1, #el.text - #kOpenShortcode)
        if prefix then
          accum:insert(pandoc.Str(prefix))
        end

        -- the start of a shortcode, start accumulating the shortcode
        accum = shortcodeInlines
        accum:insert(pandoc.Str(kOpenShortcode))
      elseif startsWith(el.text, kCloseShortcode) then

        -- since we closed a shortcode, mark this transformed
        transformed = true

        -- the end of the shortcode, stop accumulating the shortcode
        accum:insert(pandoc.Str(kCloseShortcode))
        accum = outputInlines

        -- process the shortcode
        local shortCode = processShortCode(shortcodeInlines)

        -- find the handler for this shortcode and transform
        local handler = handlerForShortcode(shortCode)
        if handler ~= nil then
          local expanded = callShortcodeHandler(handler, shortCode)
          if expanded ~= nil then
            -- process recursively
            expanded = shortcodeResultAsInlines(expanded, shortCode.name)
            local expandedAgain = transformShortcodeInlines(expanded)
            if (expandedAgain ~= nil) then
              tappend(accum, expandedAgain)
            else
              tappend(accum, expanded)
            end
          end
        else
          tappend(accum, shortcodeInlines)
        end

        local suffix = el.text:sub(#kCloseShortcode + 1)
        if suffix then
          accum:insert(pandoc.Str(suffix))
        end   

        -- clear the accumulated shortcode inlines
        shortcodeInlines = pandoc.List()        
      else 
        -- not a shortcode, accumulate
        accum:insert(el)
      end
    else
      -- not a string, accumulate
      accum:insert(el)
    end
  end
  
  if transformed then
    return outputInlines
  else
    return nil
  end

end

-- transforms shortcodes inside code
local function transformShortcodeCode(el)

  -- don't process shortcodes in code output from engines
  -- (anything in an engine processed code block was actually
  --  proccessed by the engine, so should be printed as is)
  if el.attr and el.attr.classes:includes("cell-code") then
    return
  end

  -- don't process shortcodes if they are explicitly turned off
  if el.attr and el.attr.attributes["shortcodes"] == "false" then
    return
  end
  
  -- process shortcodes
  local text = el.text:gsub("(%{%{%{*<)" ..  "(.-)" .. "(>%}%}%}*)", function(beginCode, code, endCode) 
    if #beginCode > 3 or #endCode > 3 then
      return beginCode:sub(2) .. code .. endCode:sub(1, #endCode-1)
    else
      -- see if any of the shortcode handlers want it (and transform results to plain text)
      local inlines = markdownToInlines(kOpenShortcode .. code .. kCloseShortcode)
      local transformed = transformShortcodeInlines(inlines)
      if transformed ~= nil then
        return inlinesToString(transformed)
      else
        return beginCode .. code .. endCode
      end
    end
  end)

  -- return new element if the text changd
  if text ~= el.text then
    el.text = text
    return el
  end
end

-- finds blocks that only contain a shortcode and processes them
local function transformShortcodeBlocks(blocks) 
  local transformed = false
  local scannedBlocks = pandoc.List()
  
  for i,block in ipairs(blocks) do 
    -- inspect para and plain blocks for shortcodes
    if block.t == "Para" or block.t == "Plain" then

      -- if contents are only a shortcode, process and return
      local onlyShortcode = onlyShortcode(block.content)
      if onlyShortcode ~= nil then
        -- there is a shortcode here, process it and return the blocks
        local shortCode = processShortCode(onlyShortcode)
        local handler = handlerForShortcode(shortCode)
        if handler ~= nil then
          local transformedShortcode = callShortcodeHandler(handler, shortCode)
          if transformedShortcode ~= nil then
            tappend(scannedBlocks, shortcodeResultAsBlocks(transformedShortcode, shortCode.name))
            transformed = true                  
          end
        else
          scannedBlocks:insert(block)
        end
      else 
        scannedBlocks:insert(block)
      end
    else
      scannedBlocks:insert(block)
    end
  end
  
  -- if we didn't transform any shortcodes, just return nil to signal
  -- no changes
  if transformed then
    return scannedBlocks
  else
    return nil
  end
end


-- transforms shortcodes in a string
local function transformString(str)
  if string.find(str, kOpenShortcode) then
    local inlines = markdownToInlines(str)
    if inlines ~= nil then 
      local mutatedTarget = transformShortcodeInlines(inlines)
      if mutatedTarget ~= nil then
        return inlinesToString(mutatedTarget)
      end      
    end
  end  
  return nil
end

-- decode a url
local function urldecode(url)
  if url == nil then
  return
  end
    url = url:gsub("+", " ")
    url = url:gsub("%%(%x%x)", function(x)
      return string.char(tonumber(x, 16))
    end)
  return url
end


-- transforms shortcodes in link targets
local function transformLink(el)
  local target = urldecode(el.target)
  local tranformed = transformString(target);
  if tranformed ~= nil then
    el.target = tranformed
    return el
  end
end

-- transforms shortcodes in img srcs
local function transformImage(el)
  local target = urldecode(el.src)
  local tranformed = transformString(target);
  if tranformed ~= nil then
    el.src = tranformed
    return el
  end
end


-------- meta shortcode --------

-- Implements reading values from document metadata
-- as {{< meta title >}}
-- or {{< meta key.subkey.subkey >}}
-- This only supports emitting simple types (not arrays or maps)

local function processValue(val, name, t)    
  if type(val) == "table" then
    if #val == 0 then
      return { pandoc.Str( "") }
    elseif pandoc.utils.type(val) == "Inlines" then
      return val
    elseif pandoc.utils.type(val) == "Blocks" then
      return pandoc.utils.blocks_to_inlines(val)
    else
      warn("Unsupported type '" .. pandoc.utils.type(val)  .. "' for key " .. name .. " in a " .. t .. " shortcode.")
      return { pandoc.Strong({pandoc.Str("?invalid " .. t .. " type:" .. name)}) }         
    end
  else 
    return { pandoc.Str( tostring(val) ) }  
  end
end

local function handleMeta(args) 
  if #args > 0 then
    -- the args are the var name
    local varName = inlinesToString(args[1])

    -- read the option value
    local optionValue = option(varName, nil)
    if optionValue ~= nil then
      return processValue(optionValue, varName, "meta")
    else 
      warn("Unknown meta key " .. varName .. " specified in a metadata Shortcode.")
      return { pandoc.Strong({pandoc.Str("?meta:" .. varName)}) } 
    end
  else
    -- no args, we can't do anything
    return nil
  end
end

-------- env shortcode --------

-- Implements reading values from envrionment variables
local function handleEnv(args)
  if #args > 0 then
    -- the args are the var name
    local varName = inlinesToString(args[1])

    -- read the environment variable
    local envValue = os.getenv(varName)
    if envValue ~= nil then
      return { pandoc.Str(envValue) }  
    else 
      warn("Unknown variable " .. varName .. " specified in an env Shortcode.")
      return { pandoc.Strong({pandoc.Str("?env:" .. varName)}) } 
    end
  else
    -- no args, we can't do anything
    return nil
  end
end

-------- pagebreak shortcode --------

local function handlePagebreak()
 
  local pagebreak = {
    epub = '<p style="page-break-after: always;"> </p>',
    html = '<div style="page-break-after: always;"></div>',
    latex = '\\newpage{}',
    ooxml = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>',
    odt = '<text:p text:style-name="Pagebreak"/>',
    context = '\\page'
  }

  if FORMAT == 'docx' then
    return pandoc.RawBlock('openxml', pagebreak.ooxml)
  elseif FORMAT:match 'latex' then
    return pandoc.RawBlock('tex', pagebreak.latex)
  elseif FORMAT:match 'odt' then
    return pandoc.RawBlock('opendocument', pagebreak.odt)
  elseif FORMAT:match 'html.*' then
    return pandoc.RawBlock('html', pagebreak.html)
  elseif FORMAT:match 'epub' then
    return pandoc.RawBlock('html', pagebreak.epub)
  elseif FORMAT:match 'context' then
    return pandoc.RawBlock('context', pagebreak.context)
  else
    -- fall back to insert a form feed character
    return pandoc.Para{pandoc.Str '\f'}
  end

end




return {
  -- init
  {
    Meta = function(meta)
      if meta ~= nil then
        -- pre-read metadata
        allOptions = readMetaOptions(meta)
      end
      -- install shortocde handlers
      initShortcodeHandlers(pandoc.List(option("shortcodes", {})))
    end
  },
  
  -- blocks
  {
    Blocks = transformShortcodeBlocks,
    CodeBlock =  transformShortcodeCode,
    RawBlock = transformShortcodeCode
  },

  -- inlines
  {
    Inlines = transformShortcodeInlines,
    Code = transformShortcodeCode,
    RawInline = transformShortcodeCode,
    Link = transformLink,
    Image = transformImage
  }
}


--[[
minted -- enable the minted environment for code listings in beamer and latex.

MIT License

Copyright (c) 2019 Stephen McDowell

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

--------------------------------------------------------------------------------
-- Quick documentation.  See full documentation here:                         --
-- https://github.com/pandoc/lua-filters/blob/master/minted                   --
--------------------------------------------------------------------------------
--[[
Brief overview of metadata keys that you can use in your document:

minted:
  no_default_autogobble:   <boolean>, *DISCOURAGED*
  no_mintinline:           <boolean>
  default_block_language:  <string>
  default_inline_language: <string>
  block_attributes:        <list of strings>
    - attr_1
    - attr_2
    - ...
  inline_attributes:       <list of strings>
    - attr_1
    - attr_2
    - ...

In words, underneath the `minted` metadata key, you have the following options:

### `no_default_autogobble` (boolean)

By default this filter will always use `autogobble` with minted, which will
automatically trim common preceding whitespace.  This is important because
code blocks nested under a list or other block elements _will_ have common
preceding whitespace that you _will_ want trimmed.

### `no_mintinline` (boolean)

Globally prevent this filter from emitting `\mintinline` calls for inline
Code elements, emitting `\texttt` instead.  Possibly useful in saving
compile time for large documents that do not seek to have syntax
highlighting on inline code elements.

### `default_block_language` (string)

The default pygments lexer class to use for code blocks.  By default this
is `"text"`, meaning no syntax highlighting.  This is a fallback value, code
blocks that explicitly specify a lexer will not use it.

### `default_inline_language` (string)

Same as `default_block_language`, only for inline code (typed in single
backticks).  The default is also `"text"`, and changing is discouraged.

### `block_attributes` (list of strings)

Any default attributes to apply to _all_ code blocks.  These may be
overriden on a per-code-block basis.  See section 5.3 of the
[minted documentation][minted_docs] for available options.

### `inline_attributes` (list of strings)

Any default attributes to apply to _all_ inline code.  These may be
overriden on a per-code basis.  See section 5.3 of the
[minted documentation][minted_docs] for available options.

[minted_docs]: http://mirrors.ctan.org/macros/latex/contrib/minted/minted.pdf
]]

local List = require('pandoc.List')

--------------------------------------------------------------------------------
-- Potential metadata elements to override.                                   --
--------------------------------------------------------------------------------
local minted_no_mintinline           = false
local minted_default_block_language  = "text"
local minted_default_inline_language = "text"
local minted_block_attributes        = {}
local minted_inline_attributes       = {}

--------------------------------------------------------------------------------
-- Constants used to differentiate Code and CodeBlock elements.               --
--------------------------------------------------------------------------------
local MintedInline = 0
local MintedBlock  = 1

--------------------------------------------------------------------------------
-- Utility functions.                                                         --
--------------------------------------------------------------------------------
-- Return the string lexer class to be used with minted.  `elem` should be
-- either a Code or CodeBlock element (whose `classes` list will be inspected
-- first).  `kind` is assumed to be either `MintedInline` or `MintedBlock` in
-- order to choose the appropriate fallback lexer when unspecified.
local function minted_language(elem, kind)
  -- If the code [block] attached classes, we assume the first one is the
  -- lexer class to use.
  if #elem.classes > 0 then
    return elem.classes[1]
  end
  -- Allow user-level metadata to override the inline language.
  if kind == MintedInline then
    return minted_default_inline_language
  end
  -- Allow user-level metadata to override the block language.
  if kind == MintedBlock then
    return minted_default_block_language
  end

  -- Failsafe, should not hit here unless function called incorrectly.
  return "text"
end

-- Returns a boolean specifying whether or not the specified string `cls` is an
-- option that is supported by the minted package.
local function is_minted_class(cls)
  -- Section 5.3 Available Options of Minted documentation.  Note that many of
  -- these do not apply to \mintinline (inline Code).  Users are responsible
  -- for supplying valid arguments to minted.  For example, specifying
  -- `autogobble` and `gobble` at the same time is a usage error.
  --
  -- http://mirrors.ctan.org/macros/latex/contrib/minted/minted.pdf
  local all_minted_options = List:new{
    "autogobble", "baselinestretch", "beameroverlays", "breakafter",
    "breakaftergroup", "breakaftersymbolpre", "breakaftersymbolpost",
    "breakanywhere", "breakanywheresymbolpre", "breakanywheresymbolpost",
    "breakautoindent", "breakbefore", "breakbeforegroup",
    "breakbeforesymbolpre", "breakbeforesymbolpost", "breakbytoken",
    "breakbytokenanywhere", "breakindent", "breakindentnchars", "breaklines",
    "breaksymbol", "breaksymbolleft", "breaksymbolright", "breaksymbolindent",
    "breaksymbolindentnchars", "breaksymbolindentleft",
    "breaksymbolindentleftnchars", "breaksymbolindentright",
    "breaksymbolindentrightnchars", "breaksymbolsep", "breaksymbolsepnchars",
    "breaksymbolsepleft", "breaksymbolsepleftnchars", "breaksymbolsepright",
    "breaksymbolseprightnchars", "bgcolor", "codetagify", "curlyquotes",
    "encoding", "escapeinside", "firstline", "firstnumber", "fontfamily",
    "fontseries", "fontsize", "fontshape", "formatcom", "frame", "framerule",
    "framesep", "funcnamehighlighting", "gobble", "highlightcolor",
    "highlightlines", "keywordcase", "label", "labelposition", "lastline",
    "linenos", "numberfirstline", "numbers", "mathescape", "numberblanklines",
    "numbersep", "obeytabs", "outencoding", "python3", "resetmargins",
    "rulecolor", "samepage", "showspaces", "showtabs", "space", "spacecolor",
    "startinline", "style", "stepnumber", "stepnumberfromfirst",
    "stepnumberoffsetvalues", "stripall", "stripnl", "tab", "tabcolor",
    "tabsize", "texcl", "texcomments", "xleftmargin", "xrightmargin"
  }
  return all_minted_options:includes(cls, 0)
end

-- Return a string for the minted attributes `\begin{minted}[attributes]` or
-- `\mintinline[attributes]`.  Attributes are acquired by inspecting the
-- specified element's `classes` and `attr` fields.  Any global attributes
-- provided in the document metadata will be included _only_ if they do not
-- override the element-level attributes.
--
-- `elem` should either be a Code or CodeBlock element, and `kind` is assumed to
-- be either `MintedInline` or `MintedBlock`.  The `kind` determines which
-- global default attribute list to use.
local function minted_attributes(elem, kind)
  -- The full listing of attributes that will be joined and returned.
  local minted_attributes = {}

  -- Book-keeping, track xxx=yyy keys `xxx` that have been added to
  -- `minted_attributes` to make checking optional global defaults via the
  -- `block_attributes` or `inline_attributes` easier.
  local minted_keys = {}

  -- Boolean style options for minted (e.g., ```{.bash .autogobble}) will appear
  -- in the list of classes.
  for _, cls in ipairs(elem.classes) do
    if is_minted_class(cls) then
      table.insert(minted_attributes, cls)
      table.insert(minted_keys, cls)
    end
  end

  -- Value options using key=value (e.g., ```{.bash fontsize=\scriptsize}) show
  -- up in the list of attributes.
  for _, attr in ipairs(elem.attributes) do
    cls, value = attr[1], attr[2]
    if is_minted_class(cls) then
      table.insert(minted_attributes, cls .. "=" .. value)
      table.insert(minted_keys, cls)
    end
  end

  -- Add any global defaults _only_ if they do not conflict.  Note that conflict
  -- is only in the literal sense.  If a user has `autogobble` and `gobble=2`
  -- specified, these do conflict in the minted sense, but this filter makes no
  -- checks on validity ;)
  local global_defaults = nil
  if kind == MintedInline then
    global_defaults = minted_inline_attributes
  elseif kind == MintedBlock then
    global_defaults = minted_block_attributes
  end
  for _, global_attr in ipairs(global_defaults) do
    -- Either use the index of `=` minus one, or -1 if no `=` present.  Fallback
    -- on -1 means that the substring is the original string.
    local end_idx = (string.find(global_attr, "=") or 0) - 1
    local global_key = string.sub(global_attr, 1, end_idx)
    local can_insert_global = true
    for _, existing_key in ipairs(minted_keys) do
      if existing_key == global_key then
        can_insert_global = false
        break
      end
    end

    if can_insert_global then
      table.insert(minted_attributes, global_attr)
    end
  end

  -- Return a comma delimited string for specifying the attributes to minted.
  return table.concat(minted_attributes, ",")
end

-- Return the specified `elem` with any minted data removed from the `classes`
-- and `attr`.  Otherwise writers such as the HTML writer might produce invalid
-- code since latex makes heavy use of the \backslash.
local function remove_minted_attibutes(elem)
  -- Remove any minted items from the classes.
  classes = {}
  for _, cls in ipairs(elem.classes) do
    if not is_minted_class(cls) and cls ~= "no_minted" then
      table.insert(classes, cls)
    end
  end
  elem.classes = classes

  -- Remove any minted items from the attributes.
  extra_attrs = {}
  for _, attr in ipairs(elem.attributes) do
    cls, value = attr[1], attr[2]
    if not is_minted_class(cls) then
      table.insert(extra_attrs, {cls, value})
    end
  end
  elem.attributes = extra_attrs

  -- Return the (potentially modified) element for pandoc to take over.
  return elem
end

-- Return a `start_delim` and `end_delim` that can safely wrap around the
-- specified `text` when used inline. If no special characters occur in `text`,
-- then a pair of braces are returned. Otherwise, if any character of
-- `possible_delims` are not in `text`, then it is returned. If no delimiter
-- could be found, an error is raised.
local function minted_inline_delims(text)
  local start_delim, end_delim
  if text:find('[{}]') then
    -- Try some other delimiter (the alphanumeric digits are in Python's
    -- string.digits + string.ascii_letters order)
    possible_delims = ('|!@#^&*-=+' .. '0123456789' ..
                       'abcdefghijklmnopqrstuvwxyz' ..
                       'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    for char in possible_delims:gmatch('.') do
      if not text:find(char, 1, true) then
        start_delim = char
        end_delim = char
        break
      end
    end
    if not start_delim then
      local msg = 'Unable to determine delimiter to use around inline code %q'
      error(msg:format(text))
    end
  else
    start_delim = '{'
    end_delim = '}'
  end

  return start_delim, end_delim
end

--------------------------------------------------------------------------------
-- Pandoc overrides.                                                          --
--------------------------------------------------------------------------------
-- Override the pandoc Meta function so that we can parse the metadata for the
-- document and store the necessary variables locally to use in other functions
-- such as Code and CodeBlock (helper methods).
function Meta(m)
  -- Grab the `minted` metadata, quit early if not present.
  local minted = m["minted"]
  local found_autogobble = false
  local always_autogobble = true
  if minted ~= nil then
    -- Parse and set the global bypass to turn off all \mintinline calls.
    local no_mintinline = minted["no_mintinline"]
    if no_mintinline ~= nil then
      minted_no_mintinline = no_mintinline
    end

    -- Parse and set the default block language.
    local default_block_language = minted.default_block_language
      and pandoc.utils.stringify(minted.default_block_language)
    if default_block_language ~= nil then
      minted_default_block_language = default_block_language
    end

    -- Parse and set the default inline language.
    local default_inline_language = minted.default_inline_language
      and pandoc.utils.stringify(minted.default_inline_language)
    if default_inline_language ~= nil then
      minted_default_inline_language = default_inline_language
    end

    -- Parse the global default minted attributes to use on every block.
    local block_attributes = minted["block_attributes"]
    if block_attributes ~= nil then
      for _, attr in ipairs(block_attributes) do
        if attr == "autogobble" then
          found_autogobble = true
        end
        table.insert(minted_block_attributes, attr[1].text)
      end
    end

    -- Allow users to turn off autogobble for blocks, but really they should not
    -- ever seek to do this (indented code blocks under list for example).
    local no_default_autogobble = minted["no_default_autogobble"]
    if no_default_autogobble ~= nil then
      always_autogobble = not no_default_autogobble
    end

    -- Parse the global default minted attributes to use on ever inline.
    local inline_attributes = minted["inline_attributes"]
    if inline_attributes ~= nil then
      for _, attr in ipairs(inline_attributes) do
        table.insert(minted_inline_attributes, attr[1].text)
      end
    end
  end

  -- Make sure autogobble is turned on by default if no `minted` meta key is
  -- provided for the document.
  if always_autogobble and not found_autogobble then
    table.insert(minted_block_attributes, "autogobble")
  end

  -- Return the metadata to pandoc (unchanged).
  return m
end

-- Override inline code elements to use \mintinline for beamer / latex writers.
-- Other writers have all minted attributes removed.
function Code(elem)
  if FORMAT == "beamer" or FORMAT == "latex" then
    -- Allow a bypass to turn off \mintinline via adding .no_minted class.
    local found_no_minted_class = false
    for _, cls in ipairs(elem.classes) do
      if cls == "no_minted" then
        found_no_minted_class = true
        break
      end
    end

    -- Check for local or global bypass to turn off \mintinline
    if minted_no_mintinline or found_no_minted_class then
      return nil -- Return `nil` signals to `pandoc` that elem is not changed.
    end

    local start_delim, end_delim = minted_inline_delims(elem.text)
    local language   = minted_language(elem, MintedInline)
    local attributes = minted_attributes(elem, MintedInline)
    local raw_minted = string.format(
      "\\mintinline[%s]{%s}%s%s%s",
      attributes,
      language,
      start_delim,
      elem.text,
      end_delim
    )
    -- NOTE: prior to pandoc commit 24a0d61, `beamer` cannot be used as the
    -- RawBlock format.  Using `latex` should not cause any problems.
    return pandoc.RawInline("latex", raw_minted)
  else
    return remove_minted_attibutes(elem)
  end
end

-- Override code blocks to use \begin{minted}...\end{minted} for beamer / latex
-- writers.  Other writers have all minted attributes removed.
function CodeBlock(block)
  if FORMAT == "beamer" or FORMAT == "latex" then
    local language   = minted_language(block, MintedBlock)
    local attributes = minted_attributes(block, MintedBlock)
    local raw_minted = string.format(
      "\\begin{minted}[%s]{%s}\n%s\n\\end{minted}",
      attributes,
      language,
      block.text
    )
    -- NOTE: prior to pandoc commit 24a0d61, `beamer` cannot be used as the
    -- RawBlock format.  Using `latex` should not cause any problems.
    return pandoc.RawBlock("latex", raw_minted)
  else
    return remove_minted_attibutes(block)
  end
end

-- Override headers to make all beamer frames fragile, since any minted
-- environments or \mintinline invocations will halt compilation if the frame
-- is not marked as fragile.
function Header(elem)
  if FORMAT == 'beamer' then
    -- Check first that 'fragile' is not already present.
    local has_fragile = false
    for _, val in ipairs(elem.classes) do
      if val == 'fragile' then
        has_fragile = true
        break
      end
    end

    -- If not found, add fragile to the list of classes.
    if not has_fragile then
      table.insert(elem.classes, 'fragile')
    end

    -- NOTE: pass the remaining work to pandoc, noting that 2.5 and below
    -- may duplicate the 'fragile' specifier.  Duplicated fragile does *not*
    -- cause compile errors.
    return elem
  end
end

-- NOTE: order of return matters, Meta needs to be first otherwise the metadata
-- from the document will not be loaded _first_.
return {
  {Meta = Meta},
  {Code = Code},
  {CodeBlock = CodeBlock},
  {Header = Header}
}

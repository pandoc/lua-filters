-- Ensure unpack also works if pandoc was compiled against Lua 5.1
local unpack = unpack or table.unpack
local List = require 'pandoc.List'
local stringify = (require 'pandoc.utils')['stringify']

--- Set some default options
local default = {
  opening = 'Dear Sir/Madam,',
  closing = 'Sincerely,',
  address = 'no address given'
}

--- Return a list of inlines representing a call to a latex command.
local function latex_command (command, ...)
  local entry = {
    pandoc.RawInline('latex', '\\' .. command),
  }
  for _, arg in ipairs{...} do
    entry[#entry + 1] = pandoc.RawInline('latex', '{')
    if type(arg) ~= 'table' then
      entry[#entry + 1] = pandoc.RawInline('latex', tostring(arg))
    else
      List.extend(entry, arg)
    end
    entry[#entry + 1] = pandoc.RawInline('latex', '}')
  end
  return entry
end

--- Convert the given meta-value to a list of inlines
local function ensure_inlines (val)
  if not val or type(val) == 'string' or type(val) == 'boolean' then
    return pandoc.MetaInlines{pandoc.Str(tostring(val))}
  elseif type(val) == 'table' and val.t == 'MetaInlines' then
      return val
  elseif type(val) == 'table' then
    local res = List:new{}
    for i = 1, #val do
      res:extend(val[i])
      res[#res + 1] = pandoc.RawInline('latex', '\\\\ ')
    end
    res[#res] = nil -- drop last linebreak
    return pandoc.MetaInlines(res)
  else
    return pandoc.MetaInlines{pandoc.Str(pandoc.utils.stringify(val))}
  end
end

--- Convert the given value to a MetaList
local function ensure_meta_list (val)
  if not val or val.t ~= 'MetaList'  then
    return pandoc.MetaList{}
  else
    return val
  end
end

--- Set supported variables as KOMA variables.
function setkomavar_commands (meta)
  local set_vars = {}
  local res = {}
  local function set_koma_var (name, value, enable)
    if value ~= nil then
      res[#res + 1] = latex_command('setkomavar', name, ensure_inlines(value))
      if enable then
        set_vars[#set_vars + 1] = name
      end
    end
  end

  set_koma_var('fromname', meta.fromname or meta.author)
  set_koma_var('fromaddress', meta.fromaddress or meta['return-address'])
  set_koma_var('subject', meta.subject)
  set_koma_var('title', meta.title)
  set_koma_var('signature', meta.signature)
  set_koma_var('customer', meta.customer)
  set_koma_var('yourref', meta.yourref)
  set_koma_var('myref', meta.myref)
  set_koma_var('invoice', meta.invoice)
  set_koma_var('place', meta.place)

  set_koma_var('fromfax', meta.fromfax or meta.fax, true)
  set_koma_var('fromurl', meta.fromurl or meta.url, true)
  set_koma_var('fromlogo', meta.fromlogo or meta.logo, true)
  set_koma_var('fromemail', meta.fromemail or meta.email, true)
  set_koma_var('fromphone', meta.fromphone or meta.phone, true)

  -- don't set date if date is set to `false`
  if meta.date == nil or meta.date == true then
    if meta['date-format'] then
      set_koma_var('date', os.date(stringify(date_format)))
    else
      set_koma_var('date', pandoc.MetaInlines{pandoc.RawInline('latex', '\\today')})
    end
  elseif meta.date then
    set_koma_var('date', meta.date)
  end

  if meta['KOMAoptions'] or #set_vars >= 1 then
    res[#res + 1] = latex_command(
      'KOMAoptions',
      meta['KOMAoptions']
        or table.concat(set_vars, '=true,') .. '=true'
    )
  end

  return res
end

--- Bring Metadata in a form suitable for the scrlttr KOMA class
local function make_koma_metadata(meta)
  local header_includes = ensure_meta_list(meta['header-includes'])
  List.extend(header_includes, setkomavar_commands(meta))

  local include_before = ensure_meta_list(meta['include-before'])
  List.extend(
    include_before,
    {
      pandoc.MetaInlines(
        latex_command(
          'begin',
          'letter',
          ensure_inlines(meta.address or default.address)
        )
      ),

      pandoc.MetaInlines(
        latex_command('opening', meta.opening or default.opening)
      ),
    }
  )

  local include_after = ensure_meta_list(meta['include-after'])
  List.extend(
    include_after,
    {
      pandoc.MetaInlines(
        latex_command('closing', meta.closing or default.closing)
      ),
      pandoc.MetaInlines(latex_command('end', 'letter')),
    }
  )

  -- unset or reset some unwanted vars
  meta.data   = nil  -- set via komavar 'date'
  meta.title  = nil  -- set via komavar 'subject'
  meta.indent = true -- disable parskib
  -- set documentclass to scrlttr2 if it's unset
  meta.documentclass = meta.documentclass or pandoc.MetaString'scrlttr2'


  meta['header-includes'] = header_includes
  meta['include-before'] = include_before
  meta['include-after'] = include_after

  return meta
end

return {
  {Meta = make_koma_metadata}
}

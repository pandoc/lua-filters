local utils = require 'pandoc.utils'
local List = require 'pandoc.List'

local citation_id_set = {}

-- Collect all citation IDs.
function Cite (c)
  local cs = c.citations
  for i = 1, #cs do
    citation_id_set[cs[i].id or cs[i].citationId] = true
  end
end

--- Return a list of citation IDs
function citation_ids ()
  local citations = {};
  for cid, _ in pairs(citation_id_set) do
    citations[#citations + 1] = cid
  end
  return citations
end

--- stringify meta inline elements. Pandoc prior to version 2.8
-- didn't properly tag MetaInline values, so making it necessary to use an
-- auxiliary Span.
local stringifyMetaInlines = function (el)
  return el.t
    and utils.stringify(el)
    or utils.stringify(pandoc.Span(el))
end

function bibdata (bibliography)
  function bibname (bibitem)
    return type(bibitem) == 'string'
      and bibitem:gsub('%.bib$', '')
      -- bibitem is assumed to be a list of inlines or MetaInlines element
      or stringifyMetaInlines(bibitem):gsub('%.bib$', '')
  end

  local bibs = bibliography.t == 'MetaList'
    and List.map(bibliography, bibname)
    or {bibname(bibliography)}
  return table.concat(bibs, ',')
end

function aux_content(bibliography)
  local cites = citation_ids()
  table.sort(cites)
  local citations = table.concat(cites, ',')
  return table.concat(
    {
      '\\bibstyle{alpha}',
      '\\bibdata{' .. bibdata(bibliography) .. '}',
      '\\citation{' .. citations .. '}',
      '',
    },
    '\n'
  )
end

function write_dummy_aux (bibliography, auxfile)
  local filename
  if type(auxfile) == 'string' then
    filename = auxfile
  elseif type(auxfile) == 'table' then
    -- assume list of inlines
    filename = utils.stringify(pandoc.Span(auxfile))
  else
    filename = 'bibexport.aux'
  end
  local fh = io.open(filename, 'w')
  fh:write(aux_content(bibliography))
  fh:close()
  io.stdout:write('Aux written to ' .. filename .. '\n')
  return filename
end

function Pandoc (doc)
  local meta = doc.meta
  if not meta.bibliography then
    return nil
  else
    -- create a dummy .aux file
    local auxfile_name = write_dummy_aux(meta.bibliography, meta.auxfile)
    os.execute('bibexport ' .. auxfile_name)
    io.stdout:write('Output written to bibexport.bib\n')
    return nil
  end
end

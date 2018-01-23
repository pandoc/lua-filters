
local List = require 'pandoc.List'

local M = {}
local authors = {}

local function is_tex(format)
    return format == 'latex' or format == 'tex' or format == 'context'
end

M.header_track_changes = [[
\usepackage[markup=underlined,authormarkup=none]{changes}
\definecolor{auth1}{HTML}{4477AA}
\definecolor{auth2}{HTML}{117733}
\definecolor{auth3}{HTML}{999933}
\definecolor{auth4}{HTML}{CC6677}
\definecolor{auth5}{HTML}{AA4499}
\definecolor{auth6}{HTML}{332288}
\usepackage[textsize=scriptsize]{todonotes}
\setlength{\marginparwidth}{3cm}
\makeatletter
\setremarkmarkup{\todo[color=Changes@Color#1!20]{\textbf{#1:}~#2}}
\makeatother
\newcommand{\note}[2][]{\added[#1,remark={#2}]{}}
\newcommand\hl{%
  \bgroup
  \expandafter\def\csname sout\space\endcsname{\bgroup \ULdepth =-.8ex \ULset}%
  \markoverwith{\textcolor{yellow}{\rule[-.5ex]{.1pt}{2.5ex}}}%
  \ULon}
]]

local function initials(s)
    ignore = { -- list of words to ignore
        ['dr'] = true, ['mr'] = true, ['ms'] = true, ['mrs'] = true, ['prof'] = true,
        ['mx'] = true, ['sir'] = true,
    }

    local ans = {}
    for w in s:gmatch '[%w\']+' do
        if not ignore[w:lower()] then ans[#ans+1] = w:sub(1,1):upper() end
    end
    return table.concat(ans)
end

local toTex = {["comment-start"] = "\\protect\\note", insertion = "\\added", deletion = "\\deleted"}

function M.Span(elem)
    if toTex[elem.classes[1]] ~= nil then
        local author = elem.attributes.author
        local inits
        if author:find(" ") then inits = initials(author) else inits = author end
        authors[inits] = author
        local s = toTex[elem.classes[1]] .. '[id=' .. inits .. ']{' .. pandoc.utils.stringify(elem.content) .. '}'
        if elem.classes[1] == "comment-start" then
            s = s .. '\\protect\\hl{'
        end
        return pandoc.RawInline('latex', s)
    elseif elem.classes[1] == "comment-end" then
        return pandoc.RawInline('latex', '}')
    end
end

local function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
    end
    return iter
end

--- Add packages to the header includes.
function M.add_track_changes(meta)
    local header_includes
    if meta['header-includes'] and meta['header-includes'].t == 'MetaList' then
        header_includes = meta['header-includes']
    else
        header_includes = pandoc.MetaList{meta.header_includes}
    end
    header_includes[#header_includes + 1] =
        pandoc.MetaBlocks{pandoc.RawBlock('latex', M.header_track_changes)}
    local a = 1
    for key,value in pairsByKeys(authors) do -- sorted author list; otherwise make test may fail
        header_includes[#header_includes + 1] =
            pandoc.MetaBlocks{pandoc.RawBlock('latex', '\\definechangesauthor[name={' .. value .. '}, color=auth' .. a .. ']{' .. key .. '}')}
        a = a + 1
    end
    meta['header-includes'] = header_includes
    return meta
end

M[1] = {
    Span = M.Span,
    Meta = is_tex(FORMAT) and M.add_track_changes or nil
}

return M

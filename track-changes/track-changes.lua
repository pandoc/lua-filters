local M = {}
local authors = {}

local function is_tex(format)
    return format == 'latex' or format == 'tex' or format == 'context'
end

local function is_html (format)
    return format == 'html' or format == 'html4' or format == 'html5'
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
\setremarkmarkup{\todo[color=Changes@Color#1!20]{\sffamily\textbf{#1:}~#2}}
\makeatother
\newcommand{\note}[2][]{\added[#1,remark={#2}]{}}
\newcommand\hlnotesingle{%
  \bgroup
  \expandafter\def\csname sout\space\endcsname{\bgroup \ULdepth =-.8ex \ULset}%
  \markoverwith{\textcolor{yellow}{\rule[-.5ex]{.1pt}{2.5ex}}}%
  \ULon}
\newcommand\hl[1]{\let\helpcmd\hlnotesingle\parhelp#1\par\relax\relax}
\long\def\parhelp#1\par#2\relax{%
  \helpcmd{#1}\ifx\relax#2\else\par\parhelp#2\relax\fi%
}
]]

local function initials(s)
    local ignore = { -- list of words to ignore
        ['dr'] = true, ['mr'] = true, ['ms'] = true, ['mrs'] = true, ['prof'] = true,
        ['mx'] = true, ['sir'] = true,
    }

    local ans = {}
    for w in s:gmatch '[%w\']+' do
        if not ignore[w:lower()] then ans[#ans+1] = w:sub(1,1):upper() end
    end
    return table.concat(ans)
end

relinerHtml = {
    Str = function (s)
        if s.text == "¶" then
            return pandoc.Str('&#10;')
        end
    end
}

relinerTex = {
    Str = function (s)
        if s.text == "¶" then
            return pandoc.Str('\\newline')
        end
    end
}

local toTex = {["comment-start"] = "\\protect\\note", insertion = "\\added", deletion = "\\deleted"}

function M.TrackingSpanToTex(elem)
    if toTex[elem.classes[1]] ~= nil then
        local author = elem.attributes.author
        local inits = author:find' ' and initials(author) or author
        authors[inits] = author
        local s = toTex[elem.classes[1]] .. '[id=' .. inits .. ']{'
        if elem.classes[1] == "comment-start" then
            s = s .. pandoc.utils.stringify(pandoc.walk_inline(elem, relinerTex)) .. '}\\protect\\hl{'
        else
            s = s .. pandoc.utils.stringify(elem.content) .. '}'
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
    local i = 0
    local iter = function ()
      i = i + 1
      return a[i], t[a[i]]
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

local toHtml = {["comment-start"] = "mark", insertion = "ins", deletion = "del"}

function M.TrackingSpanToHtml(elem)
    if toHtml[elem.classes[1]] ~= nil then
        local author = elem.attributes.author
        local inits = author:find' ' and initials(author) or author
        authors[inits] = author
        local s = '<' .. toHtml[elem.classes[1]]
        for k,v in pairs(elem.attributes) do
            local hattr = k
            if hattr ~= 'date' then hattr = 'data-' .. hattr end
            s = s .. ' ' .. hattr .. '="' .. v .. '"'
        end
        if elem.classes[1] == "comment-start" then
            if elem.identifier then
                s = s .. ' data-id="' .. elem.identifier .. '"'
            end
            s = s .. ' title="' .. pandoc.utils.stringify(pandoc.walk_inline(elem, relinerHtml)) .. '">'
        else
            s = s .. '>' .. pandoc.utils.stringify(elem.content) .. '</' .. toHtml[elem.classes[1]] .. '>'
        end
        return pandoc.RawInline('html', s)
    elseif elem.classes[1] == "comment-end" then
        return pandoc.RawInline('html', '</mark>')
    end
end

function M.SpanAcceptChanges(elem)
    if elem.classes[1] == "comment-start" or elem.classes[1] == "comment-end" then
        return {}
    elseif elem.classes[1] == "insertion" then
        return elem.content
    elseif elem.classes[1] == "deletion" then
        return {}
    end
end

function M.SpanRejectChanges(elem)
    if elem.classes[1] == "comment-start" or elem.classes[1] == "comment-end" then
        return {}
    elseif elem.classes[1] == "insertion" then
        return {}
    elseif elem.classes[1] == "deletion" then
        return elem.content
    end
end

if PANDOC_READER_OPTIONS.trackChanges == 'AcceptChanges' then
    M[1] = { Span = M.SpanAcceptChanges }
elseif PANDOC_READER_OPTIONS.trackChanges == 'RejectChanges' then
    M[1] = { Span = M.SpanRejectChanges }
else -- assumes AllChanges
    if is_html(FORMAT) then
        M[1] = {
            Span = M.TrackingSpanToHtml
        }
    elseif is_tex(FORMAT) then
        M[1] = {
            Span = M.TrackingSpanToTex,
            Meta = M.add_track_changes
        }
    end
end

return M

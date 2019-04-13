local authors = {}

local function is_tex(format)
    return format == 'latex' or format == 'tex' or format == 'context'
end

local function is_html (format)
    return format == 'html' or format == 'html4' or format == 'html5'
end

local function is_wordprocessing (format)
    return format == 'docx' or format == 'odt'
end

header_track_changes = [[

\makeatletter
\PassOptionsToPackage{textsize=scriptsize}{todonotes}
\PassOptionsToPackage{markup=underlined,authormarkup=none,commentmarkup=todo}{changes}
\usepackage{changes}
\@ifpackagelater{changes}{2018/11/03}{%
}{%
  \usepackage{todonotes}
  \setremarkmarkup{\todo[color=Changes@Color#1!20]{\sffamily\textbf{#1:}~#2}}
}%
\makeatother
\definecolor{auth1}{HTML}{4477AA}
\definecolor{auth2}{HTML}{117733}
\definecolor{auth3}{HTML}{999933}
\definecolor{auth4}{HTML}{CC6677}
\definecolor{auth5}{HTML}{AA4499}
\definecolor{auth6}{HTML}{332288}
\setlength{\marginparwidth}{3cm}
\newcommand{\note}[2][]{\added[#1,remark={#2}]{}}
\newcommand\hlnotesingle{%
  \bgroup
  \expandafter\def\csname sout\space\endcsname{\bgroup \ULdepth =-.8ex \ULset}%
  \markoverwith{\textcolor{yellow}{\rule[-.5ex]{.1pt}{2.5ex}}}%
  \ULon}
\newcommand\hlnote[1]{\let\helpcmd\hlnotesingle\parhelp#1\par\relax\relax}
\long\def\parhelp#1\par#2\relax{%
  \helpcmd{#1}\ifx\relax#2\else\par\parhelp#2\relax\fi%
}

\makeatletter
\newcommand\ifmoving{%
  \ifx\protect\@unexpandable@protect
      \expandafter\@firstoftwo
  \else
      \expandafter\@secondoftwo
  \fi
}

\newcommand{\gobbletwo}[2][]{\@bsphack\@esphack}
\newcommand{\gobbleone}[1][]{\@bsphack\@esphack}

\let\oldadded\added
\let\olddeleted\deleted
\let\oldhlnote\hlnote
\let\oldnote\note
\renewcommand{\added}{\ifmoving{\gobbleone}{\oldadded}}
\renewcommand{\deleted}{\ifmoving{\gobbletwo}{\olddeleted}}
\renewcommand{\hlnote}{\ifmoving{}{\oldhlnote}}
\renewcommand{\note}{\ifmoving{\gobbletwo}{\oldnote}}
\makeatother
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

reliner = {
    Str = function (s)
        if s.text == "¶" then
           return pandoc.LineBreak()
        end
    end
}

function SpanReliner(elem)
    local classes = elem.classes or elem.attr.classes
    if classes:includes("comment-start") then
        return pandoc.walk_inline(elem, reliner)
    end
end

local toTex = {["comment-start"] = "\\note", insertion = "\\added", deletion = "\\deleted"}

local function TrackingSpanToTex(elem)
    if toTex[elem.classes[1]] ~= nil then
        local author = elem.attributes.author
        local inits = author:find' ' and initials(author) or author
        authors[inits] = author
        local s = toTex[elem.classes[1]] .. '[id=' .. inits .. ']{'
        if elem.classes:includes("comment-start") then
            s = s .. pandoc.utils.stringify(pandoc.walk_inline(elem, relinerTex)) .. '}\\hlnote{'
        else
            s = s .. pandoc.utils.stringify(elem.content) .. '}'
        end
        return pandoc.RawInline('latex', s)
    elseif elem.classes:includes("comment-end") then
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
local function add_track_changes(meta)
    local header_includes
    if meta['header-includes'] and meta['header-includes'].t == 'MetaList' then
        header_includes = meta['header-includes']
    else
        header_includes = pandoc.MetaList{meta['header-includes']}
    end
    header_includes[#header_includes + 1] =
        pandoc.MetaBlocks{pandoc.RawBlock('latex', header_track_changes)}
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

local function TrackingSpanToHtml(elem)
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
        if elem.classes:includes("comment-start") then
            if elem.identifier then
                s = s .. ' data-id="' .. elem.identifier .. '"'
            end
            s = s .. ' title="' .. pandoc.utils.stringify(pandoc.walk_inline(elem, relinerHtml)) .. '">'
        else
            s = s .. '>' .. pandoc.utils.stringify(elem.content) .. '</' .. toHtml[elem.classes[1]] .. '>'
        end
        return pandoc.RawInline('html', s)
    elseif elem.classes:includes("comment-end") then
        return pandoc.RawInline('html', '</mark>')
    end
end

local function SpanAcceptChanges(elem)
    if elem.classes:includes("comment-start") or elem.classes:includes("comment-end") then
        return {}
    elseif elem.classes:includes("insertion") then
        return elem.content
    elseif elem.classes:includes("deletion") then
        return {}
    end
end

local function SpanRejectChanges(elem)
    if elem.classes:includes("comment-start") or elem.classes:includes("comment-end") then
        return {}
    elseif elem.classes:includes("insertion") then
        return {}
    elseif elem.classes:includes("deletion") then
        return elem.content
    end
end

function Pandoc(doc)
    local meta = doc.meta
    local trackChangesOptions = {all = 'AllChanges', accept = 'AcceptChanges', reject = 'RejectChanges' }
    local tc = meta and meta['trackChanges']
    tc = type(meta['trackChanges']) == 'table' and pandoc.utils.stringify(meta['trackChanges']) or meta['trackChanges'] or 'accept'
    local trackChanges = PANDOC_READER_OPTIONS and PANDOC_READER_OPTIONS.trackChanges or trackChangesOptions[tc]
    meta.trackChanges = nil -- remove it from the matadata
    
    local M = {}
    if trackChanges == 'AllChanges' then
        if is_html(FORMAT) then
            M[#M + 1] = {
                Span = TrackingSpanToHtml
            }
        elseif is_tex(FORMAT) then
            M[#M + 1] = {
                Span = TrackingSpanToTex,
            }
        elseif is_wordprocessing(FORMAT) then
            M[#M + 1] = { Span = SpanReliner }
        end
    elseif trackChanges == 'RejectChanges' then
        M[#M + 1] = { Span = SpanRejectChanges }
    else -- otherwise assumes AcceptChanges
        M[#M + 1] = { Span = SpanAcceptChanges }
    end

    if #M then
        local blocks = doc.blocks
        for i = 1, #M do
            blocks = pandoc.walk_block(pandoc.Div(blocks), M[i]).content
        end
        if trackChanges == 'AllChanges' and is_tex(FORMAT) then
            meta = add_track_changes(meta)
        end
        return pandoc.Pandoc(blocks, meta)
    end
end

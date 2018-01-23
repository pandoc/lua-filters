
local List = require 'pandoc.List'

local M = {}

local function is_html (format)
    return format == 'html' or format == 'html4' or format == 'html5'
end

local function is_tex(format)
    return format == 'latex' or format == 'tex' or format == 'context'
end

M.header_track_changes = [[
\usepackage[dvipsnames,svgnames,x11names]{xcolor}
\usepackage[markup=underlined,authormarkup=none]{changes}
% concatenate or create abbreviation for author names with spaces
\definechangesauthor[name={Mathias C. Walter}, color=NavyBlue]{MCW}
%%% Alternative definition to have the remarks
%%% in the margins instead of footnotes
\usepackage{todonotes}
\setlength{\marginparwidth}{3cm}
\makeatletter
\setremarkmarkup{\todo[color=Changes@Color#1!20,size=\scriptsize]{\textbf{#1:}~#2}}
\makeatother
\newcommand{\note}[2][]{\added[#1,remark={#2}]{}}
\newcommand\hl{\bgroup\markoverwith{\textcolor{yellow}{\rule[-.5ex]{.1pt}{2.5ex}}}\ULon} % \hl from soul package is not compatible
]]

function M.Span(elem)
    if elem.classes[1] == "comment-start" then
        return pandoc.RawInline('latex', '\\protect\\note[id=' .. elem.attributes.author .. ']{' .. pandoc.utils.stringify(elem.content) .. '}\\hl{')
    elseif elem.classes[1] == "comment-end" then
        return pandoc.RawInline('latex', '}')
    elseif elem.classes[1] == "insertion" then
        local content_str = pandoc.utils.stringify(elem.content)
        return pandoc.RawInline('latex', '\\added[id=' .. elem.attributes.author .. ']{' .. content_str .. '}')
    elseif elem.classes[1] == "deletion" then
        local content_str = pandoc.utils.stringify(elem.content)
        return pandoc.RawInline('latex', '\\deleted[id=' .. elem.attributes.author .. ']{' .. content_str .. '}')
    end
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

--- Add packages to the header includes.
function M.add_track_changes(meta)
    local header_includes
    if meta['header-includes'] and meta['header-includes'].t ~= 'MetaList' then
        header_includes = meta['header-includes']
    else
        header_includes = pandoc.MetaList{meta.header_includes}
    end
--    print(header_includes)
--    print(dump(header_includes))
    header_includes[#header_includes + 1] =
        pandoc.MetaBlocks{pandoc.RawBlock('latex', M.header_track_changes)}
    meta['header-includes'] = header_includes
    return meta
end

M[1] = {
    Span = M.Span,
    Meta = is_tex(FORMAT) and M.add_track_changes or nil
}

return M

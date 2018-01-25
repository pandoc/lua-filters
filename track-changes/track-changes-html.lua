local M = {}
local authors = {}

local function is_html (format)
    return format == 'html' or format == 'html4' or format == 'html5'
end

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

local toHtml = {["comment-start"] = "mark", insertion = "ins", deletion = "del"}

function M.TrackingSpanToHtml(elem)
    if toHtml[elem.classes[1]] ~= nil then
        local author = elem.attributes.author
        local inits = author:find' ' and initials(author) or author
        authors[inits] = author
        local s = '<' .. toHtml[elem.classes[1]] -- .. ' date="' .. elem.attributes.date .. '" data-author="' .. elem.attributes.author
        for k,v in pairs(elem.attributes) do
            local hattr = k
            if hattr ~= 'date' then hattr = 'data-' .. hattr end
            s = s .. ' ' .. hattr .. '="' .. v .. '"'
        end
        if elem.classes[1] == "comment-start" then
            s = s .. ' title="' .. pandoc.utils.stringify(elem.content) .. '">'
        else
            s = s .. '>' .. pandoc.utils.stringify(elem.content) .. '</' .. toHtml[elem.classes[1]] .. '>'
        end
        return pandoc.RawInline('html', s)
    elseif elem.classes[1] == "comment-end" then
        return pandoc.RawInline('html', '</mark>')
    end
end

if is_html(FORMAT) then
    M[1] = {
        Span = M.TrackingSpanToHtml,
    }
end

return M

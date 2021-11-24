--- Replaces plain quotation marks with typographic ones.
--
-- # SYNOPSIS
--
--      pandoc --lua-filter pandoc-quotes.lua
--
--
-- # DESCRIPTION
--
-- pandoc-quotes.lua is a filter for pandoc that replaces non-typographic
-- quotation marks with typographic ones for languages other than American
-- English.
--
-- You can define which typographic quotation marks to replace plain ones with
-- by setting either a document's quot-marks, quot-lang, or lang
-- metadata field. If none of these is set, pandoc-quotes.lua does nothing.
--
-- You can add your own mapping of a language to quotation marks or override
-- the default ones by setting quot-marks-by-lang.
--
-- ## quot-marks
--
-- A list of four strings, where the first item lists the primary left
-- quotation mark, the second the primary right quotation mark, the third
-- the secondary left quotation mark, and the fourth the secondary right
-- quotation mark.
--
-- For example:
--
-- ```yaml
-- ---
-- quot-marks:
--     - ''
--     - ''
--     - '
--     - '
-- ...
-- ```
--
-- You always have to set all four.
--
-- If each quotation mark consists of one character only,
-- you can write the whole list as a simple string.
--
-- For example:
--
-- ```yaml
-- ---
-- quot-marks: ""''
-- ...
-- ```
--
-- If quot-marks is set, the other fields are ignored.
--
--
-- # quotation-lang
--
-- An RFC 5646-like code for the language the quotation marks of
-- which shall be used (e.g., "pt-BR", "es").
--
-- For example:
--
-- ```yaml
-- ---
-- quot-lang: de-AT
-- ...
-- ```
--
-- Note: Only the language and the country tags of RFC 5646 are supported.
-- For example, "it-CH" (i.e., Italian as spoken in Switzerland) is fine,
-- but "it-756" (also Italian as spoken in Switzerland) will return the
-- quotation marks for "it" (i.e., Italian as spoken in general).
--
-- If quot-marks is set, quot-lang is ignored.
--
--
-- # lang
--
-- The format of lang is the same as for quot-lang. If quot-marks
-- or quot-lang is set, lang is ignored.
--
-- For example:
--
-- ```yaml
-- ---
-- lang: de-AT
-- ...
-- ```
--
--
-- # ADDING LANGUAGES
--
-- You can add quotation marks for unsupported languages, or override the
-- defaults, by setting the metadata field quot-marks-by-lang to a maping
-- of RFC 5646-like language codes (e.g., "pt-BR", "es") to lists of quotation
-- marks, which are given in the same format as for the quot-marks
-- metadata field.
--
-- For example:
--
-- ```yaml
-- ---
-- quot-marks-by-lang:
--     abc-XYZ: ""''
-- lang: abc-XYZ
-- ...
-- ```
--
--
-- # CAVEATS
--
-- pandoc represents documents as abstract syntax trees internally, and
-- quotations are nodes in that tree. However, pandoc-quotes.lua replaces
-- those nodes with their content, adding proper quotation marks. That is,
-- pandoc-quotes.lua pushes quotations from the syntax of a document's
-- representation into its semantics. That being so, you should not
-- use pandoc-quotes.lua with output formats that represent quotes
-- syntactically (e.g., HTML, LaTeX, ConTexT). Moroever, filters running after
-- pandoc-quotes won't recognise quotes. So, it should be the last or
-- one of the last filters you apply.
--
-- Support for quotation marks of different languages is certainly incomplete
-- and likely erroneous. See <https://github.com/odkr/pandoc-quotes.lua> if
-- you'd like to help with this.
--
-- pandoc-quotes.lua is Unicode-agnostic.
--
--
-- # SEE ALSO
--
-- pandoc(1)
--
--
-- # AUTHOR
--
-- Copyright 2019 Odin Kroeger
--
--
-- # LICENSE
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
--
--
-- @script pandoc-quotes.lua
-- @release 0.1.10
-- @author Odin Kroeger
-- @copyright 2018, 2020 Odin Kroeger
-- @license MIT


-- # INITIALISATION

local M = {}

local pairs = pairs
local require = require

local io = io
local table = table
local package = package

local pandoc = pandoc
if not pandoc.utils then pandoc.utils = require 'pandoc.utils' end

local _ENV = M

local text = require 'text'


-- # CONSTANTS

--- The name of this script.
SCRIPT_NAME = 'pandoc-quotes.lua'

--- The path seperator of the operating system.
PATH_SEP = package.config:sub(1, 1)

--- The character sequence to end a line.
if PATH_SEP == '\\' then EOL = '\r\n'
                    else EOL = '\n'   end


--- A list of mappings from RFC 5646-ish language codes to quotation marks.
--
-- I have adopted the list below from:
-- <https://en.wikipedia.org/w/index.php?title=Quotation_mark&oldid=836731669>
--
-- I tried to come up with reasonable defaults for secondary quotes for
-- language that, according to the Wikipedia, don't have any.
--
-- Adding languages:
--
-- Add an ordered pair, where the first item is an RFC 5646 language
-- code (though only the language and country tags are supported) and the
-- second item is a list of quotation marks, in the following order:
-- primary left, primary right, secondary left, secondary right.
--
-- You have to list four quotation marks, even if the langauge you add does
-- not use secondary quotation marks. Just come up with something that makes
-- sense. This is because a user may, rightly, find that just because their
-- language does not 'officially' have secondary quotation marks, they
-- are going to use them anyway. And they should get a reasonable result,
-- not a runtime error.
--
-- The order in which languages are listed is meaningless. If you define
-- variants for a language that is spoken in different countries, also
-- define a 'default' for the language alone, without the country tag.
QUOT_MARKS_BY_LANG = {
    ar          = {'”',  '“',     '’',  '‘'    },
    bs          = {'”',  '”',     '’',  '’'    },
    bo          = {'「', '」',     '『', '』'    },
    bs          = {'”',  '”',     '’',  '’'    },
    cn          = {'「', '」',     '『', '』'    },
    cs          = {'„',  '“',     '‚',  '‘'    },
    cy          = {'‘',  '’',     '“',  '”'    },
    da          = {'»',  '«',     '›',  '‹'    },
    de          = {'„',  '“',     '‚',  '‘'    },
    ['de-CH']   = {'«',  '»',     '‹',  '›'    },
    el          = {'«',  '»',     '“',  '”'    },
    en          = {'“',  '”',     '‘',  '’'    },
    ['en-US']   = {'“',  '”',     '‘',  '’'    },
    ['en-GB']   = {'‘',  '’',     '“',  '”'    },
    ['en-UK']   = {'‘',  '’',     '“',  '”'    },
    ['en-CA']   = {'“',  '”',     '‘',  '’'    },
    eo          = {'“',  '”',     '‘',  '’'    },
    es          = {'«',  '»',     '“',  '”'    },
    et          = {'„',  '“',     '‚',  '‘'    },
    fi          = {'”',  '”',     '’',  '’'    },
    fil         = {'“',  '”',     '‘',  '’'    },
    fa          = {'«',  '»',     '‹',  '›'    },
    fr          = {'«',  '»',     '‹',  '›'    },
    ga          = {'“',  '”',     '‘',  '’'    },
    gd          = {'‘',  '’',     '“',  '”'    },
    gl          = {'«',  '»',     '‹',  '›'    },
    he          = {'“',  '”',     '‘',  '’'    },
    hi          = {'“',  '”',     '‘',  '’'    },
    hu          = {'„',  '”',     '»',  '«'    },
    hr          = {'„',  '“',     '‚',  '‘'    },
    ia          = {'“',  '”',     '‘',  '’'    },
    id          = {'“',  '”',     '‘',  '’'    },
    is          = {'„',  '“',     '‚',  '‘'    },
    it          = {'«',  '»',     '“',  '”'    },
    ['it-CH']   = {'«',  '»',     '‹',  '›'    },
    ja          = {'「', '」',    '『',  '』'    },
    jbo         = {'lu', 'li\'u', 'lu', 'li\'u'},
    ka          = {'„',  '“',     '‚',  '‘'    },
    khb         = {'《', '》',    '〈',  '〉'    },
    kk          = {'«',  '»',     '‹',  '›'    },
    km          = {'«',  '»',     '‹',  '›'    },
    ko          = {'《', '》',    '〈',  '〉'    },
    ['ko-KR']   = {'“',  '”',     '‘',  '’'    },
    lt          = {'„',  '“',     '‚',  '‘'    },
    lv          = {'„',  '“',     '‚',  '‘'    },
    lo          = {'«',  '»',     '‹',  '›'    },
    nl          = {'„',  '”',     '‚',  '’'    },
    mk          = {'„',  '“',     '’',  '‘'    },
    mn          = {'«',  '»',     '‹',  '›'    },
    mt          = {'“',  '”',     '‘',  '’'    },
    no          = {'«',  '»',     '«',  '»'    },
    pl          = {'„',  '”',     '»',  '«'    },
    ps          = {'«',  '»',     '‹',  '›'    },
    pt          = {'«',  '»',     '“',  '”'    },
    ['pt-BR']   = {'“',  '”',     '‘',  '’'    },
    rm          = {'«',  '»',     '‹',  '›'    },
    ro          = {'„',  '”',     '«',  '»'    },
    ru          = {'«',  '»',     '“',  '”'    },
    sk          = {'„',  '“',     '‚',  '‘'    },
    sl          = {'„',  '“',     '‚',  '‘'    },
    sq          = {'„',  '“',     '‚',  '‘'    },
    sr          = {'„',  '“',     '’',  '’'    },
    sv          = {'”',  '”',     '’',  '’'    },
    tdd         = {'「', '」',    '『',  '』'    },
    ti          = {'«',  '»',     '‹',  '›'    },
    th          = {'“',  '”',     '‘',  '’'    },
    thi         = {'「', '」',    '『',  '』'    },
    tr          = {'«',  '»',     '‹',  '›'    },
    ug          = {'«',  '»',     '‹',  '›'    },
    uk          = {'«',  '»',     '„',  '“'    },
    uz          = {'«',  '»',     '„',  '“'    },
    vi          = {'“',  '”',     '‘',  '’'    },
    wen         = {'„',  '“',     '‚',  '‘'    },
    ka          = {'„',  '“',     '‚',  '‘'    },
    khb         = {'《', '》',     '〈', '〉'    },
    kk          = {'«',  '»',     '‹',  '›'    },
    km          = {'«',  '»',     '‹',  '›'    },
    ko          = {'《', '》',     '〈', '〉'    },
    ['ko-KR']   = {'“',  '”',     '‘',  '’'    },
    lt          = {'„',  '“',     '‚',  '‘'    },
    lv          = {'„',  '“',     '‚',  '‘'    },
    lo          = {'«',  '»',     '‹',  '›'    },
    nl          = {'„',  '”',     '‚',  '’'    },
    mk          = {'„',  '“',     '’',  '‘'    },
    mn          = {'«',  '»',     '‹',  '›'    },
    mt          = {'“',  '”',     '‘',  '’'    },
    no          = {'«',  '»',     '«',  '»'    },
    pl          = {'„',  '”',     '»',  '«'    },
    ps          = {'«',  '»',     '‹',  '›'    },
    pt          = {'«',  '»',     '“',  '”'    },
    ['pt-BR']   = {'“',  '”',     '‘',  '’'    },
    rm          = {'«',  '»',     '‹',  '›'    },
    ro          = {'„',  '”',     '«',  '»'    },
    ru          = {'«',  '»',     '“',  '”'    },
    sk          = {'„',  '“',     '‚',  '‘'    },
    sl          = {'„',  '“',     '‚',  '‘'    },
    sq          = {'„',  '“',     '‚',  '‘'    },
    sr          = {'„',  '“',     '’',  '’'    },
    sv          = {'”',  '”',     '’',  '’'    },
    tdd         = {'「', '」',     '『', '』'    },
    ti          = {'«',  '»',     '‹',  '›'    },
    th          = {'“',  '”',     '‘',  '’'    },
    thi         = {'「', '」',     '『', '』'    },
    tr          = {'«',  '»',     '‹',  '›'    },
    ug          = {'«',  '»',     '‹',  '›'    },
    uk          = {'«',  '»',     '„',  '“'    },
    uz          = {'«',  '»',     '„',  '“'    },
    vi          = {'“',  '”',     '‘',  '’'    },
    wen         = {'„',  '“',     '‚',  '‘'    }
}


-- # FUNCTIONS

--- Prints warnings to STDERR.
--
-- Prefixes messages with `SCRIPT_NAME` and ": ".
-- Also appends an end of line sequence.
--
-- @tparam string str A string format to be written to STDERR.
-- @tparam string ... Arguments to that format.
function warn (str, ...)
    io.stderr:write(SCRIPT_NAME, ': ', string.format(str, ...), EOL)
end


--- Applies a function to every element of a list.
--
-- @tparam func f The function.
-- @tparam tab list The list.
-- @treturn tab The return values of `f`.
function map (f, list)
    local ret = {}
    for k, v in pairs(list) do ret[k] = f(v) end
    return ret
end

do
    local stringify = pandoc.utils.stringify

    --- Reads quotation marks from a `quot-marks` metadata field.
    --
    -- @tparam pandoc.MetaValue The content of a metadata field.
    --  Must be either of type pandoc.MetaInlines or pandoc.MetaList.
    -- @treturn[1] {pandoc.Str,pandoc.Str,pandoc.Str,pandoc.Str}
    --  A table of quotation marks
    -- @treturn[2] `nil` if an error occurred.
    -- @treturn[2] string An error message.
    function get_quotation_marks (meta)
        if meta.t == 'MetaInlines' then
            local marks = stringify(meta)
            if text.len(marks) ~= 4 then
                return nil, 'not four quotation marks'
            end
            local ret = {}
            for i = 1, 4 do ret[i] = text.sub(marks, i, i) end
            return ret
        elseif meta.t == 'MetaList' then
            local marks = map(stringify, meta)
            if #marks ~= 4 then
                return nil, 'not four quotation marks'
            end
            return marks
        end
        return nil, 'neither a string nor a list'
    end
end


do
    local stringify = pandoc.utils.stringify

    -- Holds the quotation marks for the language of the document.
    -- Common to `configure` and `insert_quot_marks`.
    local QUOT_MARKS = nil

    --- Determines the quotation marks for the document.
    --
    -- Stores them in `QUOT_MARKS`, which it shares with `insert_quot_marks`.
    -- Prints errors to STDERR.
    --
    -- @tparam pandoc.Meta The document's metadata.
    function configure (meta)
        local quot_marks, lang
        if meta['quot-marks-by-lang'] then
            for k, v in pairs(meta['quot-marks-by-lang']) do
                local quot_marks, err = get_quotation_marks(v)
                if not quot_marks then
                    warn('metadata field "quot-marks-by-lang": lang "%s": %s.',
                         k, err)
                    return
                end
                QUOT_MARKS_BY_LANG[k] = quot_marks
            end
        end
        if meta['quot-marks'] then
            local err
            quot_marks, err = get_quotation_marks(meta['quot-marks'])
            if not quot_marks then
                warn('metadata field "quot-marks": %s.', err)
                return
            end
        elseif meta['quot-lang'] then
            lang = stringify(meta['quot-lang'])
        elseif meta['lang'] then
            lang = stringify(meta['lang'])
        end
        if lang then
            for i = 1, 3 do
                if     i == 2 then lang = lang:match '^(%a+)'
                elseif i == 3 then
                    local expr = '^' .. lang .. '-'
                    for k, v in pairs(QUOT_MARKS_BY_LANG) do
                        if k:match(expr) then quot_marks = v break end
                    end
                end
                if     i  < 3 then quot_marks = QUOT_MARKS_BY_LANG[lang] end
                if quot_marks then break end
            end
        end
        if quot_marks then QUOT_MARKS = map(pandoc.Str, quot_marks)
        elseif lang then warn('%s: unknown language.', lang) end
    end


    do
        local insert = table.insert
        --- Replaces quoted elements with quoted text.
        --
        -- Uses the quotation marks stored in `QUOT_MARKS`,
        -- which it shares with `configure`.
        --
        -- @tparam pandoc.Quoted quoted A quoted element.
        -- @treturn {pandoc.Str,pandoc.Inline,...,pandoc.Str}
        --  A list with the opening quote (as `pandoc.Str`),
        --  the content of `quoted`, and the closing quote (as `pandoc.Str`).
        function insert_quot_marks (quoted)
            if not QUOT_MARKS then return end
            local quote_type = quoted.quotetype
            local inlines    = quoted.content
            local left, right
            if     quote_type == 'DoubleQuote' then left, right = 1, 2
            elseif quote_type == 'SingleQuote' then left, right = 3, 4
            else   error('unknown quote type') end
            insert(inlines, 1, QUOT_MARKS[left])
            insert(inlines,    QUOT_MARKS[right])
            return inlines
        end
    end
end

return {{Meta = configure}, {Quoted = insert_quot_marks}}

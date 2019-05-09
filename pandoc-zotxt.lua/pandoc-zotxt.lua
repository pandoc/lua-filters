--- pandoc-zotxt.lua - Looks up citations in Zotero and adds references. 
--
-- # SYNOPSIS
-- 
--      pandoc --lua-filter pandoc-zotxt.lua -F pandoc-citeproc
-- 
-- 
-- # DESCRIPTION
-- 
-- pandoc-zotxt.lua looks up sources of citations in Zotero and adds
-- them either to a document's `references` metadata field or to its
-- bibliography, where pandoc-citeproc can pick them up.
-- 
-- You cite your sources using so-called "easy citekeys" (provided by zotxt) or
-- "Better BibTeX Citation Keys" (provided by Better BibTeX for Zotero) and
-- then tell pandoc to run pandoc-zotxt.lua before pandoc-citeproc.
-- That's all all there is to it. (See the documentation of zotxt and 
-- Better BibTeX for Zotero respectively for details.)
-- 
-- You can also use pandoc-zotxt.lua to manage a bibliography file. This is
-- usually a lot faster. Simply set the `zotero-bibliography` metadata field
-- to a filename. pandoc-zotxt.lua will then add the sources you cite to that
-- file, rather than to the `references` metadata field. It will also add
-- that file to the document's `bibliography` metadata field, so that
-- pandoc-zotxt.lua picks it up. The biblography is stored in CSL JSON,
-- so the filename must end in ".json".
-- 
-- pandoc-zotxt.lua takes relative filenames to be relative to the directory
-- of the first input file you pass to pandoc or, if you don't pass any input
-- files, as relative to the current working directory.
-- 
-- Note, pandoc-zotxt.lua only ever adds sources to bibliography files.
-- It doesn't update or delete them. To update your bibliography file,
-- delete it. pandoc-zotxt.lua will then regenerate it from scratch.
-- 
-- 
-- # CAVEATS
-- 
-- pandoc-zotxt.lua is Unicode-agnostic.
-- 
-- 
-- # SEE ALSO
-- 
-- pandoc(1), pandoc-citeproc(1)
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
-- @script pandoc-zotxt.lua
-- @release 0.3.15
-- @author Odin Kroeger
-- @copyright 2018, 2019 Odin Kroeger
-- @license MIT


-- # INITIALISATION

local pandoc_zotxt = {}

local assert = assert
local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local require = require
local tostring = tostring
local type = type

local io = io
local math = math
local package = package

local open = io.open
local concat = table.concat
local insert = table.insert
local remove = table.remove
local unpack = table.unpack

local pandoc = pandoc
local PANDOC_STATE = PANDOC_STATE
local PANDOC_SCRIPT_FILE = PANDOC_SCRIPT_FILE
local stringify = pandoc.utils.stringify

local _ENV = pandoc_zotxt

local text = require 'text'
local sub = text.sub


-- # CONSTANTS

--- The URL to lookup citation data.
--
-- See <https://github.com/egh/zotxt> for details.
--
-- @see get_source
ZOTXT_QUERY_URL_BASE = 'http://localhost:23119/zotxt/items?'

--- Types of citation keys.
--
-- See <https://github.com/egh/zotxt> for details.
--
-- @table ZOTXT_KEYTYPES
-- @see get_source
ZOTXT_KEYTYPES = {
	'easykey',	   -- zotxt easy citekey 
	'betterbibtexkey', -- Better BibTeX citation key
	'key'		   -- Zotero item ID
}

--- The name of this script.
NAME = 'pandoc-zotxt.lua'

--- The version of this script.
VERSION = '0.3.15'


-- # LIBRARIES

--- The path seperator of the operating system.
PATH_SEP = sub(package.config, 1, 1)

do
    local split_expr = '(.-' .. PATH_SEP .. '?)([^' .. PATH_SEP .. ']-)$'
    local san_exprs = {{PATH_SEP .. '%.' .. PATH_SEP, PATH_SEP},
        {PATH_SEP .. '+', PATH_SEP}, {'^%.' .. PATH_SEP, ''}}
    
    --- Splits a file's path into a directory and a filename part.
    --
    -- @tparam string path The path to the file.
    -- @treturn string The file's path.
    -- @treturn string The file's name.
    --
    -- This function makes an educated guess given the string it's passed.
    -- It doesn't look at the filesystem. The guess is educated enough though.
    function split_path (path)
        assert(path ~= '', 'path is the empty string')
        for _, s in ipairs(san_exprs) do path = path:gsub(unpack(s)) end
        local dir, fname = path:match(split_expr)
        dir = dir:gsub('(.)' .. PATH_SEP .. '$', '%1')
        if dir == '' then dir = '.' end
        if fname == '' then fname = '.' end
        return dir, fname
    end
end


do
    local expr = {'share', 'lua', '5.3', '?.lua'}
    local wd, fname = split_path(PANDOC_SCRIPT_FILE)
    package.path = concat({package.path, concat({wd, unpack(expr)}, PATH_SEP),
        concat({wd, fname .. '-' .. VERSION, unpack(expr)}, PATH_SEP)}, ';')
end

local json = require 'lunajson'
local encode = json.encode
local decode = json.decode


-- # FUNCTIONS

--- Prints warnings to STDERR.
--
-- @tparam string ... Strings to be written to STDERR.
--
-- Prefixes every line with the global `NAME` and ": ".
-- Also, appends a single linefeed if needed.
function warn (...)
    local stderr = io.stderr
    local str = concat({...})
    for line in str:gmatch('([^\n]*)\n?') do
        stderr:write(NAME, ': ', line, '\n')
    end
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


--- Returns the position of an element in a list.
--
-- @param elem The element.
-- @tparam tab list The list.
-- @treturn integer The index of the element,
--  `nil` if the list doesn't contain the element.
function get_position (elem, list)
    assert(type(list) == 'table', 'given list is not of type "table".')
    for i, v in ipairs(list) do
        if v == elem then return i end
    end
    return nil
end


--- Checks if a path is absolute.
--
-- @tparam string path A path.
-- @treturn bool `true` if the path is absolute, `false` otherwise.
function is_path_absolute (path)
    if PATH_SEP == '\\' and path:match('^.:\\') then return true end
    return path:match('^' .. PATH_SEP) ~= nil
end


--- Returns the directory of the first input file or '.'.
--
-- @treturn string The directory of that file.
function get_input_directory ()
    local file = PANDOC_STATE.input_files[1]
    if not file then return '.' end
    return split_path(file)
end


do
    local pairs = pairs
    local tostring = tostring
    local type = type
    local floor = math.floor

    --- Converts all numbers in a multi-dimensional table to strings.
    --
    -- Also converts floating point numbers to integers. This is needed 
    -- because all numbers are floating point numbers in JSON, but older
    -- versions of Pandoc expect integers.
    --
    -- @param data Data of any type.
    -- @return The given data, with all numbers converted into strings.
    function convert_numbers_to_strings (data, depth)
        if not depth then depth = 1 end
        assert(depth < 512, 'too many recursions')
        local data_type = type(data)
        if data_type == 'table' then
            local s = {}
            for k, v in pairs(data) do 
                s[k] = convert_numbers_to_strings(v, depth + 1)
            end
            return s
        elseif data_type == 'number' then
            return tostring(floor(data))
        else
            return data
        end
    end
end


do
    local query_url_base = ZOTXT_QUERY_URL_BASE
    local keytypes = ZOTXT_KEYTYPES
    local fetch = pandoc.mediabag.fetch
    local pcall = pcall
    local decode = decode
    local concat = concat
    local insert = insert
    local remove = remove

    ---  Retrieves bibliographic data for a source from Zotero.
    --
    -- Retrieves bibliographic data by citation key, trying different
    -- types of citation keys, starting with the last one a lookup was
    -- successful for.
    --
    -- The global `ZOTXT_QUERY_URL` defines where to get data from.
    -- The global `ZOTXT_KEYTYPES` defines what keytypes to try.
    -- See <https://github.com/egh/zotxt> for details.
    --
    -- @tparam string citekey The citation key of the source,
    --  e.g., 'name:2019word', 'name2019WordWordWord'.
    -- @treturn table Bibliographic data in CSL format,
    --  `nil` if the source wasn't found or an error occurred.
    -- @treturn string An error message, if applicable.
    function get_source (citekey)
        assert(type(citekey) == 'string', 'given citekey is not a string')
        assert(citekey ~= '', 'given citekey is the empty string')
        local _, reply
        for i = 1, #keytypes do
            local query_url = concat({query_url_base,
                keytypes[i], '=', citekey})
            _, reply = fetch(query_url, '.')
            local ok, data = pcall(decode, reply)
            if ok then
                insert(keytypes, 1, remove(keytypes, i))
                local source = convert_numbers_to_strings(data[1])
                source.id = citekey
                return source
            end
        end
        return nil, reply
    end
end


--- Reads a JSON file.
--
-- @tparam string fname Name of the file.
-- @return The parsed data, `nil` if an error occurred.
-- @treturn string An error message, if applicable.
-- @treturn number An error number. Positive numbers are OS error numbers, 
--  negative numbers indicate a JSON decoding error.
function read_json_file (fname)
    assert(fname ~= '', 'given filename is the empty string')
    local f, err, errno = open(fname, 'r')
    if not f then return nil, err, errno end
    local json, err, errno = f:read('a')
    if not json then return nil, err, errno end
    local ok, err, errno = f:close()
    if not ok then return nil, err, errno end
    local ok, data = pcall(decode, json) 
    if not ok then return nil, 'JSON parse error', -1 end
    return convert_numbers_to_strings(data)
end


--- Writes data to a file in JSON.
--
-- @param data Data.
-- @tparam string fname Name of the file.
-- @treturn bool `true` if the data was written to the file, `nil` otherwise.
-- @treturn string An error message, if applicable.
-- @treturn integer An error number. Positive numbers are OS error numbers, 
--  negative numbers indicate a JSON encoding error.
function write_json_file (data, fname)
    assert(fname ~= '', 'given filename is the empty string')
    local ok, json = pcall(encode, data)
    if not ok then return nil, 'JSON encoding error', -1 end
    local f, err, errno = open(fname, 'w')
    if not f then return nil, err, errno end
    local ok, err, errno = f:write(json, '\n')
    if not ok then return nil, err, errno end
    ok, err, errno = f:close()
    if not ok then return nil, err, errno end
    return true
end


--- Adds cited sources to a bibliography file.
--
-- @tparam string fname The filename of the biblography.
-- @tparam {string,...} citekeys The citation keys of the sources to add,
--  e.g., 'name:2019word', 'name2019WordWordWord'.
-- @treturn bool `true` if the bibliography was updated
--   or no update was needed, `nil` if an error occurred.
-- @treturn string An error message, if applicable.
--
-- Prints an error message to STDERR for every source that cannot be found.
function update_bibliography (fname, citekeys)
    assert(type(citekeys) == 'table', 'given list of keys is not a table')
    if #citekeys == 0 then return end
    local refs, err, errno = read_json_file(fname)
    if not refs then
        if err and errno ~= 2 then return nil, err, errno end
        refs = {}
    end
    local ids = map(function (x) return x.id end, refs)
    for _, citekey in ipairs(citekeys) do
        if not get_position(citekey, ids) then
            local ref, err = get_source(citekey)
            if ref then
                insert(refs, ref)
            else
                warn(err)
            end
        end
    end
    if (#refs > #ids) then
        return write_json_file(refs, fname)
    end
    return true
end


do
    local CITEKEYS = {}

    do
        local insert = insert
        local seen = {}

        --- Collects all citekeys used in a document.
        --
        -- Saves them into the variable `CITEKEYS`, which is shared with
        -- `add_references` and `add_bibliography`.
        --
        -- @tparam pandoc.Cite citations A citation.        
        function collect_sources (citations)
            local c = citations.citations
            for i = 1, #c do
                id = c[i].id
                if not seen[id] then
                    seen[id] = true
                    insert(CITEKEYS, id)
                end
            end
        end
    end


    --- Adds sources to the metadata block of a document.
    --
    -- Reads citekeys of cited sources from the variable `CITEKEYS`,
    -- which is shared with `collect_sources`.  Never modifies `CITEKEYS`.
    --
    -- @tparam pandoc.Meta meta A metadata block.
    -- @treturn pandoc.Meta An updated metadata block, with the field
    --  `references` added if needed, `nil` if no sources were found.
    --
    -- Prints an error message to STDERR for every source that cannot be found.
    function add_references (meta)
        if #CITEKEYS == 0 then return end
        if not meta.references then meta.references = {} end
        for _, citekey in ipairs(CITEKEYS) do
            local ref, err = get_source(citekey)
            if ref then
                insert(meta.references, ref)
            else
                warn(err)
            end
        end
        return meta
    end
    

    --- Adds sources to a bibliography and the biblography to the document.
    --
    -- Reads citekeys of cited sources from the variable `CITEKEYS`,
    -- which is shared with `collect_sources`. Never modifies `CITEKEYS`.
    --
    -- @tparam pandoc.Meta meta A metadata block.
    -- @treturn pandoc.Meta An updated metadata block, with the field
    --  `bibliography` added when needed, `nil` if no sources were found,
    --  `zotero-bibliography` is not set, or an error occurred.
    -- @treturn string An error message, if applicable.
    --
    -- Prints an error message to STDERR for every source that cannot be found.
    function add_bibliography (meta)
        if not #CITEKEYS or not meta['zotero-bibliography'] then return end
        local fname = stringify(meta['zotero-bibliography'])
        if not fname:match('.json$') then
            return nil, fname .. ': does not end in ".json".'
        end 
        if not is_path_absolute(fname) then
            fname = get_input_directory() .. PATH_SEP .. fname
        end
        local ok, err = update_bibliography(fname, CITEKEYS)
        if ok then
            if not meta.bibliography then
                meta.bibliography = fname
            elseif meta.bibliography.t == 'MetaInlines' then
                meta.bibliography = {stringify(meta.bibliography), fname}
            elseif meta.bibliography.t == 'MetaList' then
                insert(meta.bibliography, fname)
            end
            return meta
        else
            return nil, err
        end
    end
end


--- Adds sources to the document's metadata or to the bibliography.
--
-- Checks whether the current documents uses a bibliography. If so, adds cited
-- sources that aren't in it yet to the file. Otherwise, adds all cited
-- sources to the document's metadata.
--
-- @tparam pandoc.Meta meta A metadata block.
-- @treturn pandoc.Meta An updated metadata block, with references or
--  a pointer to the bibliography file, `nil` if nothing
--  was done or an error occurred.
--
-- Prints messages to STDERR if errors occur.
function add_sources (meta)
    do
        local meta, err = add_bibliography(meta)
        if meta then return meta end
        if err then warn(err) end
    end
    return add_references(meta)
end


-- # BOILERPLATE
--
-- Returning the whole script, rather than only a list of mappings of 
-- Pandoc data types to functions, allows for unit testing.

-- First pass. Collect citations.
pandoc_zotxt[1] = {Cite = collect_sources}

-- Second pass. Add cited sources.
pandoc_zotxt[2] = {Meta = add_sources}

return pandoc_zotxt

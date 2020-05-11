--- pandoc-zotxt-test.lua - A wrapper to call pandoc-zotxt.lua.
--
-- # SYNOPSIS
-- 
--      pandoc --lua-filter pandoc-zotxt-test.lua
-- 
-- 
-- # DESCRIPTION
-- 
-- A fake Pandoc filter that calls pandoc-zotxt.lua, but modifies its
-- configuration before doing so. Currently, it only changes the
-- URL for source lookups. This is useful for testing.
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
-- @script test.lua
-- @author Odin Kroeger
-- @copyright 2018, 2019 Odin Kroeger
-- @license MIT


-- # SHORTHANDS

local concat = table.concat
local insert = table.insert
local unpack = table.unpack


-- # LIBRARIES

local text = require 'text'
local sub = text.sub

--- The path seperator of the operating system
local PATH_SEP = sub(package.config, 1, 1)

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

--- The directory of this script.
local SCRIPT_DIR = split_path(PANDOC_SCRIPT_FILE)

--- The directory of the test suite. 
local TEST_DIR = concat({SCRIPT_DIR, '..'}, PATH_SEP)

--- The repository directory.
local REPO_DIR = concat({TEST_DIR, '..'}, PATH_SEP)

package.path = package.path .. ';' .. 
    concat({REPO_DIR, 'share', 'lua', '5.3', '?.lua'}, PATH_SEP)

local M = require 'pandoc-zotxt'


-- # BOILERPLATE

--- Runs the tests
--
-- Looks up the `tests` metadata field in the current Pandoc document
-- and passes it to `lu.LuaUnit.run`, as is.
--
-- @tparam pandoc.Doc doc A Pandoc document.
function run (doc)
    local meta = doc.meta
    if meta then
        local config = {}
        for k, v in pairs(meta) do config[k] = v end
        if config['query-base-url'] then
            if config['query-base-url']:match('/$') then
                M.ZOTXT_QUERY_BASE_URL = config['query-base-url']
            else
                M.ZOTXT_QUERY_BASE_URL = config['query-base-url'] .. '/'
            end
        end
    end
end

insert(M, 1, {Pandoc = run})
return M


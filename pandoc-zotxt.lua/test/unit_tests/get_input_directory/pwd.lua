--- pwd.lua - Unit test for get_input_directory. 
--
-- @script pwd.lua
-- @author Odin Kroeger
-- @copyright 2018, 2019 Odin Kroeger
-- @license MIT
--
-- This script must be run as a Pandoc filter from the root of the repository.
--
--
-- LICENSE
-- =======
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

-- SHORTHANDS
-- ==========

local concat = table.concat
local unpack = table.unpack
local format = string.format


-- LIBRARIES
-- =========

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

local SCRIPT_DIR, SCRIPT_NAME = split_path(PANDOC_SCRIPT_FILE)
local TEST_BASE_DIR = SCRIPT_DIR .. PATH_SEP .. '..' .. PATH_SEP .. '..'
local REPO_BASE_DIR = TEST_BASE_DIR .. PATH_SEP .. '..'

package.path = package.path .. ';' .. 
    concat({REPO_BASE_DIR, 'share', 'lua', '5.3', '?.lua'}, PATH_SEP)

local P = require 'pandoc-zotxt'



-- TEST
-- ====

assert(P.get_input_directory() == '.')